/**
 * Agent-backing action for Demo_Studio_Persona_Agent AND @AuraEnabled entry
 * point for the demoPersonaGenerator LWC.
 *
 * v2: this class is now a thin router. The actual generation lives in
 * IPersonaProvider implementations (EinsteinProvider, ArchetypeProvider).
 * Selection is driven by Demo_Studio_Config__mdt.AI_Provider__c.
 *
 * The @InvocableMethod + @AuraEnabled contract is preserved so the agent
 * and existing LWC surface don't change.
 */
public with sharing class DemoStudioPersonaGenerator {

    public class Request {
        @InvocableVariable(
            label='Brief'
            description='Natural-language description of the persona and story to build. Accepts full transcripts, meeting notes, or one-line briefs.'
            required=true
        )
        public String brief;

        @InvocableVariable(
            label='Brand Hint'
            description='Optional pre-set brand/customer name. If provided, the generator biases the persona toward this brand.'
            required=false
        )
        public String brandHint;
    }

    public class Result {
        @AuraEnabled
        @InvocableVariable(
            label='Summary'
            description='One-sentence human summary of what was generated.'
        )
        public String summary;
        @AuraEnabled
        @InvocableVariable(
            label='Persona JSON'
            description='Full persona bundle serialized as JSON, matching DemoStudioService.savePersonaBundle input schema.'
        )
        public String personaJson;
        @AuraEnabled
        public String providerUsed; // 'Einstein' | 'Archetype' — surfaces in the preview UI so users know which path ran.
    }

    @InvocableMethod(
        label='Generate Demo Persona'
        description='Generates a full Demo Studio persona JSON payload from a natural-language brief. Routes to the configured AI provider (Einstein by default, Archetype fallback).'
    )
    public static List<Result> generate(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            results.add(generateOne(req.brief == null ? '' : req.brief, req.brandHint));
        }
        return results;
    }

    /**
     * @AuraEnabled twin so LWCs can call this directly (bypassing the agent)
     * with the same input/output contract. Used by demoPersonaGenerator LWC.
     */
    @AuraEnabled
    public static Result generateForLwc(String brief, String brandHint) {
        return generateOne(brief == null ? '' : brief, brandHint);
    }

    /**
     * Backwards-compat overload for the older single-arg call signature.
     */
    @AuraEnabled
    public static Result generateForLwcLegacy(String brief) {
        return generateOne(brief == null ? '' : brief, null);
    }

    public class CollectionResult {
        @AuraEnabled public String collectionKey;   // e.g. 'kpis'
        @AuraEnabled public String rowsJson;        // JSON array string
        @AuraEnabled public String providerUsed;    // 'Einstein' | 'Archetype'
        @AuraEnabled public String error;           // populated if provider failed
    }

    /**
     * Generate rows for a single collection on an existing persona.
     * Called by the sparkle "Regenerate All / Add More" buttons in each
     * collection editor. Uses the persona's own fields as context so the
     * new rows fit the story.
     *
     * @param personaId    The persona whose collection is being generated
     * @param collectionKey  'kpis' | 'alerts' | 'segments' | 'nbas' | 'insights' | 'activities' | 'journeys' | 'identities'
     * @param mode         'replace' | 'append'
     * @param existingRowsJson  Serialized JSON array of the collection's current rows (client passes what's on screen)
     * @param extraHint    Optional caller-provided steering (e.g. the original story context)
     */
    @AuraEnabled
    public static CollectionResult generateCollectionForPersona(
        Id personaId,
        String collectionKey,
        String mode,
        String existingRowsJson,
        String extraHint
    ) {
        CollectionResult out = new CollectionResult();
        out.collectionKey = collectionKey;
        try {
            String personaSummary = summarizePersona(personaId);
            String prompt = PersonaPromptBuilder.buildForCollection(
                personaSummary, collectionKey, mode, existingRowsJson, extraHint
            );
            String raw = EinsteinProvider.callAndExtractJson(prompt);
            // Response is like {"kpis":[...]}. Pull the array out and re-emit as raw JSON string.
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(raw);
            Object arr = parsed.get(collectionKey);
            if (arr == null) {
                throw new AuraHandledException('Model response did not include "' + collectionKey + '".');
            }
            out.rowsJson = JSON.serialize(arr);
            out.providerUsed = 'Einstein';
            return out;
        } catch (Exception e) {
            out.error = e.getMessage();
            return out;
        }
    }

    private static String summarizePersona(Id personaId) {
        List<Demo_Persona__c> rows = [
            SELECT Name, First_Name__c, Last_Name__c, Title__c, Company__c, Brand__c,
                   Segment__c, Lifecycle_Stage__c, LTV__c, Currency_Code__c,
                   Propensity__c, Engagement_Score__c, Engagement_Label__c, Risk_Tier__c,
                   Intent_Summary__c, Key_Context__c, Suggested_Opener__c
            FROM Demo_Persona__c WHERE Id = :personaId LIMIT 1
        ];
        if (rows.isEmpty()) return 'No persona context available.';
        Demo_Persona__c p = rows[0];
        return String.join(new List<String>{
            'Name: ' + ((p.First_Name__c == null ? '' : p.First_Name__c) + ' ' + (p.Last_Name__c == null ? '' : p.Last_Name__c)).trim(),
            'Title: ' + p.Title__c,
            'Company: ' + p.Company__c,
            'Brand: ' + p.Brand__c,
            'Segment: ' + p.Segment__c,
            'Lifecycle: ' + p.Lifecycle_Stage__c,
            'LTV: ' + String.valueOf(p.LTV__c) + ' ' + p.Currency_Code__c,
            'Propensity: ' + p.Propensity__c,
            'Engagement: ' + String.valueOf(p.Engagement_Score__c) + ' (' + p.Engagement_Label__c + ')',
            'Risk Tier: ' + p.Risk_Tier__c,
            '',
            'Intent Summary: ' + p.Intent_Summary__c,
            'Key Context: ' + p.Key_Context__c
        }, '\n');
    }

    private static Result generateOne(String brief, String brandHint) {
        String providerKey = readConfiguredProvider();
        IPersonaProvider provider = buildProvider(providerKey);
        Result r;
        try {
            r = provider.generate(brief, brandHint);
            if (r == null) {
                r = new Result();
                r.summary = 'Provider returned no result. Try again with a more detailed brief.';
            }
            r.providerUsed = providerKey;
            return r;
        } catch (Exception e) {
            // Any provider failure — fall back to the deterministic Archetype
            // path so users always get something back rather than an error toast.
            IPersonaProvider fallback = new ArchetypeProvider();
            r = fallback.generate(brief, brandHint);
            r.providerUsed = 'Archetype (fallback)';
            r.summary = (r.summary == null ? '' : r.summary + ' ') +
                '(Einstein unavailable: ' + e.getMessage() + ')';
            return r;
        }
    }

    private static String readConfiguredProvider() {
        List<Demo_Studio_Config__mdt> rows = [
            SELECT AI_Provider__c
            FROM Demo_Studio_Config__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];
        if (rows.isEmpty() || String.isBlank(rows[0].AI_Provider__c)) return 'Einstein';
        return rows[0].AI_Provider__c;
    }

    private static IPersonaProvider buildProvider(String key) {
        if ('Archetype'.equalsIgnoreCase(key)) return new ArchetypeProvider();
        return new EinsteinProvider();
    }
}
