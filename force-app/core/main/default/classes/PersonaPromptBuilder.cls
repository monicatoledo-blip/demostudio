/**
 * Builds the system + user prompt sent to the LLM by EinsteinProvider.
 * Kept in its own class so the schema description can be tuned without
 * touching provider plumbing.
 *
 * Design: single-shot prompt (no chat turns). Anchors the model with an
 * explicit JSON schema, one worked example, and a strict "JSON only" close.
 * Includes the user's transcript verbatim as the last section.
 */
public with sharing class PersonaPromptBuilder {

    public class PersonaPromptBuilderException extends Exception {}


    public static String build(String brief, String brandHint) {
        String safeBrief = brief == null ? '' : brief;
        String brandLine = String.isBlank(brandHint)
            ? ''
            : 'The persona should be branded for "' + brandHint + '". Use that brand name verbatim in persona.Brand__c and reflect it throughout the copy.\n';

        return
            'You are Demo Studio Persona Generator. Build a JSON persona ' +
            'bundle for a Salesforce Contact demo record.\n\n' +
            '## WHO THE PERSONA IS\n' +
            'The persona is the FICTIONAL CUSTOMER that will appear on the ' +
            'demo Contact record. It is NEVER the Salesforce user watching ' +
            'the demo, and it is NEVER the internal champion / admin / SE / ' +
            'stakeholder who provided the context.\n\n' +
            'If the context describes an internal champion (e.g. "the ' +
            'Marketing Cloud admin at Cumulus Bank is building the business ' +
            'case"), that person is the BUYER — not the persona. The persona ' +
            'is a *customer* of the champion\'s company that the champion ' +
            'would demo to prove their story. If the context describes ' +
            'a customer directly, use that description. If ambiguous, invent ' +
            'a plausible customer that fits the industry and story angle.\n\n' +
            '## INPUT STRUCTURE\n' +
            'The context below is organized into labeled sections:\n' +
            '- ## STORY CONTEXT — the deal, champion, business case, or ' +
            'narrative framing. Use this to pick the persona\'s industry, ' +
            'brand, segment, and story angle. Do NOT use this as the persona ' +
            'itself.\n' +
            '- ## PERSONA TO BUILD — an optional explicit description of ' +
            'the fictional customer. If provided, follow it closely. If ' +
            'absent, invent one that fits the story context.\n\n' +
            '## OUTPUT\n' +
            'Return ONLY a JSON object matching this schema — no prose, no ' +
            'markdown fences:\n' + SCHEMA + '\n\n' +
            '## RULES\n' +
            '- Every string reads like a real Salesforce demo — specific ' +
            'numbers, believable names, plausible companies.\n' +
            '- Every collection (identities, insights, activities, journeys, ' +
            'kpis, alerts, segments, nbas) has at least 2 rows.\n' +
            '- Sort_Order__c is a small integer starting at 1.\n' +
            '- Recipe places demoUnifiedProfileHeader in leftRail and ' +
            'demoAgentforceBrief in center at minimum.\n' +
            '- No Id fields on any row.\n' +
            '- If the story context mentions specific product surfaces (e.g. ' +
            '"unified engagement visibility", "cross-sell", "banker ' +
            'productivity"), the persona\'s Intent_Summary / Key_Context / ' +
            'alerts / insights / NBAs must actively demonstrate that story ' +
            '— show engagement signals, activity across channels, insights ' +
            'that unlock the pitch.\n' +
            brandLine +
            '\n## EXAMPLE (illustrative — invent your own content)\n' +
            EXAMPLE + '\n\n' +
            '---\n' + safeBrief + '\n---\n\nJSON:';
    }

    /**
     * Schema description. Every field the persona bundle supports is enumerated
     * so the model doesn't guess field names. Kept compact — Einstein is smart
     * enough with types once field names are correct.
     */
    /**
     * Prompt for generating a single collection (KPIs, alerts, segments, etc.)
     * on an existing persona. `personaSummary` describes who the persona is
     * (name, title, company, brand, story). `collectionKey` picks the schema
     * slice. `mode` = 'replace' | 'append'. `existingRowsJson` is optional —
     * when present, tell the model to avoid duplicates.
     */
    public static String buildForCollection(String personaSummary, String collectionKey, String mode, String existingRowsJson, String extraHint) {
        String slice = COLLECTION_SLICES.get(collectionKey);
        if (String.isBlank(slice)) {
            throw new PersonaPromptBuilderException('Unknown collection: ' + collectionKey);
        }
        String modeLine = ('append'.equalsIgnoreCase(mode))
            ? 'Return 2-3 NEW rows that add fresh angles. Do NOT repeat any existing rows shown below.'
            : 'Return a fresh full set of rows that replaces whatever exists today.';
        String existingLine = String.isBlank(existingRowsJson)
            ? '(No existing rows.)'
            : existingRowsJson;

        return
            'You are Demo Studio Persona Generator. Generate a single ' +
            'collection of rows for an existing persona. Return ONLY a ' +
            'JSON object with the key "' + collectionKey + '" and an array ' +
            'of rows as its value. No prose, no fences.\n\n' +
            '## THE PERSONA\n' + personaSummary + '\n\n' +
            '## COLLECTION TO GENERATE\n' + collectionKey + '\n\n' +
            '## MODE\n' + modeLine + '\n\n' +
            '## EXISTING ROWS (for context — do not duplicate on append)\n' +
            existingLine + '\n\n' +
            (String.isBlank(extraHint) ? '' : '## ADDITIONAL GUIDANCE\n' + extraHint + '\n\n') +
            '## SCHEMA FOR THIS COLLECTION\n' + slice + '\n\n' +
            '## RULES\n' +
            '- Row values must fit the persona\'s industry, story, and brand.\n' +
            '- Sort_Order__c starts at 1 (or continues from the last existing row on append).\n' +
            '- No Id fields.\n' +
            '- Copy reads like real Salesforce demo content — specific numbers, plausible details.\n\n' +
            'JSON:';
    }

    private static final Map<String, String> COLLECTION_SLICES = new Map<String, String>{
        'kpis'       => '[ { "Label__c": short, "Value__c": display e.g. "$1,326,969", "Sublabel__c": short caption, "Is_Highlighted__c": boolean, "Sort_Order__c": int } ]',
        'alerts'     => '[ { "Category_Label__c": short e.g. "Retirement Gap", "Category_Style__c": "Info|Success|Warning|Danger", "Title__c": string, "Body__c": 1-2 sentences, "Sort_Order__c": int } ]',
        'segments'   => '[ { "Label__c": short pill text, "Sort_Order__c": int } ]',
        'nbas'       => '[ { "Title__c": string, "Category__c": short e.g. "Cross-Sell", "Why_This_Suggestion__c": 1-2 sentences, "CTA_Label__c": string, "Image_URL__c": optional URL, "Sort_Order__c": int } ]',
        'insights'   => '[ { "Title__c": string, "Category__c": "Cross-Sell|Retention|Risk", "Why_This_Suggestion__c": string, "CTA_Label__c": string, "Sort_Order__c": int } ]',
        'activities' => '[ { "Type__c": "Email|SMS|Web|Doc|Call|Meeting", "Title__c": string, "Description__c": string, "Timestamp_Label__c": free-form e.g. "Today", "Icon__c": SLDS name e.g. "utility:email", "Sort_Order__c": int } ]',
        'journeys'   => '[ { "Journey_Name__c": string, "Business_Unit__c": "Commercial|Wealth|Retail|Marketing", "Status__c": "Active|Paused|Completed", "Enrolled_Date__c": "YYYY-MM-DD" } ]',
        'identities' => '[ { "Type__c": "Email|Phone|Address", "Value__c": string, "Label__c": string, "Sort_Order__c": int } ]'
    };

    private static final String SCHEMA =
        '{\n' +
        '  "persona": {\n' +
        '    "First_Name__c": string, "Last_Name__c": string, "Title__c": string,\n' +
        '    "Company__c": string, "Brand__c": string, "Customer_ID__c": string,\n' +
        '    "Primary_Email__c": string, "Primary_Phone__c": string, "Primary_Address__c": string,\n' +
        '    "Segment__c": string, "Lifecycle_Stage__c": one of "Prospect|Lead|Active Customer|Cross-Sell Target|Churn Risk",\n' +
        '    "LTV__c": number, "Currency_Code__c": ISO code e.g. "USD",\n' +
        '    "Propensity__c": one of "Low|Medium|High|Very High",\n' +
        '    "Engagement_Score__c": 0-100, "Engagement_Label__c": string,\n' +
        '    "Risk_Tier__c": one of "Low|Medium|High",\n' +
        '    "Badge_Text__c": short string, "Suggested_Opener__c": first-person opener,\n' +
        '    "Intent_Summary__c": 2-3 sentences, "Key_Context__c": 2-3 sentences,\n' +
        '    "Open_Likelihood__c": 0-100, "Click_Likelihood__c": 0-100, "Unsubscribe_Risk__c": 0-100\n' +
        '  },\n' +
        '  "identities": [ { "Type__c": "Email|Phone|Address", "Value__c": string, "Label__c": string, "Sort_Order__c": int } ],\n' +
        '  "insights":   [ { "Title__c": string, "Category__c": "Cross-Sell|Retention|Risk", "Why_This_Suggestion__c": string, "CTA_Label__c": string, "Sort_Order__c": int } ],\n' +
        '  "activities": [ { "Type__c": "Email|SMS|Web|Doc|Call|Meeting", "Title__c": string, "Description__c": string, "Timestamp_Label__c": free-form e.g. "Today", "Icon__c": SLDS name e.g. "utility:email", "Sort_Order__c": int } ],\n' +
        '  "journeys":   [ { "Journey_Name__c": string, "Business_Unit__c": "Commercial|Wealth|Retail|Marketing", "Status__c": "Active|Paused|Completed", "Enrolled_Date__c": "YYYY-MM-DD" } ],\n' +
        '  "kpis":       [ { "Label__c": short, "Value__c": display e.g. "$1,326,969", "Sublabel__c": short caption, "Is_Highlighted__c": boolean, "Sort_Order__c": int } ],\n' +
        '  "alerts":     [ { "Category_Label__c": short e.g. "Retirement Gap", "Category_Style__c": "Info|Success|Warning|Danger", "Title__c": string, "Body__c": 1-2 sentences, "Sort_Order__c": int } ],\n' +
        '  "segments":   [ { "Label__c": short pill text, "Sort_Order__c": int } ],\n' +
        '  "nbas":       [ { "Title__c": string, "Category__c": short e.g. "Cross-Sell", "Why_This_Suggestion__c": 1-2 sentences, "CTA_Label__c": string, "Image_URL__c": optional public image URL, "Sort_Order__c": int } ],\n' +
        '  "recipe": {\n' +
        '    "leftRail": [ { "component": "demoUnifiedProfileHeader" } ],\n' +
        '    "center":   [ { "component": one of "demoAgentforceBrief|demoKpiStatRow|demoAiInsightsAlerts|demoCrossSellInsights|demoNextBestActions" } ],\n' +
        '    "rightRail":[ { "component": one of "demoLikelihoodScoreCard|demoActivityTimeline|demoActiveJourneyTracker" } ]\n' +
        '  }\n' +
        '}';

    private static final String EXAMPLE =
        '{"persona":{"First_Name__c":"Sarah","Last_Name__c":"Jenkins","Title__c":"VP of Treasury","Company__c":"Meridian Logistics","Brand__c":"Cumulus Bank","Customer_ID__c":"CUM-C-58392","Primary_Email__c":"sarah.jenkins@meridian.example","Primary_Phone__c":"(315) 555-1254","Primary_Address__c":"2259 Green Avenue, Alpharetta, GA 30004","Segment__c":"Commercial Cross-Sell Target","Lifecycle_Stage__c":"Cross-Sell Target","LTV__c":250000,"Currency_Code__c":"USD","Propensity__c":"Very High","Engagement_Score__c":84,"Engagement_Label__c":"Highly Engaged","Risk_Tier__c":"Low","Badge_Text__c":"Pre-Approved Buyer","Suggested_Opener__c":"Hi Sarah, congratulations on the underwriting docs moving through.","Intent_Summary__c":"Sarah initiated a Treasury Management expansion and uploaded underwriting documents this morning. She is a strong cross-sell for the Commercial Card program.","Key_Context__c":"Pre-approved for a $500K expansion. Data Cloud shows SOC-2 attestation received. Waiting on final underwriter clearance.","Open_Likelihood__c":92,"Click_Likelihood__c":78,"Unsubscribe_Risk__c":4},' +
        '"identities":[{"Type__c":"Email","Value__c":"sarah.jenkins@meridian.example","Label__c":"Primary","Sort_Order__c":1},{"Type__c":"Phone","Value__c":"(315) 555-1254","Label__c":"Mobile","Sort_Order__c":1}],' +
        '"insights":[{"Title__c":"Commercial Card Program","Category__c":"Cross-Sell","Why_This_Suggestion__c":"$4.2M annual T&E spend on disparate cards. Bundling recovers ~$84K/yr.","CTA_Label__c":"Present Program","Sort_Order__c":1}],' +
        '"activities":[{"Type__c":"Doc","Title__c":"Uploaded Underwriting Documents","Description__c":"SOC-2 attestation received via secure portal.","Timestamp_Label__c":"Today","Icon__c":"utility:upload","Sort_Order__c":1}],' +
        '"journeys":[{"Journey_Name__c":"Commercial Onboarding — Treasury","Business_Unit__c":"Commercial","Status__c":"Active","Enrolled_Date__c":"2026-06-15"}],' +
        '"kpis":[{"Label__c":"Assets","Value__c":"$1,326,969","Sublabel__c":"6 Accounts","Is_Highlighted__c":false,"Sort_Order__c":1},{"Label__c":"Net Worth","Value__c":"$1,107,789","Sublabel__c":"Calculated Insight","Is_Highlighted__c":true,"Sort_Order__c":2}],' +
        '"alerts":[{"Category_Label__c":"Cash Optimization","Category_Style__c":"Success","Title__c":"Idle Cash in Checking","Body__c":"Balance $112K exceeds recommended reserve.","Sort_Order__c":1}],' +
        '"segments":[{"Label__c":"High Net Worth","Sort_Order__c":1},{"Label__c":"Multi-Product Client","Sort_Order__c":2}],' +
        '"nbas":[{"Title__c":"Discuss Treasury Expansion","Category__c":"Cross-Sell","Why_This_Suggestion__c":"Application uploaded today. 78% attach rate within 48h.","CTA_Label__c":"Discuss Options","Image_URL__c":"","Sort_Order__c":1}],' +
        '"recipe":{"leftRail":[{"component":"demoUnifiedProfileHeader"}],"center":[{"component":"demoAgentforceBrief"},{"component":"demoKpiStatRow"},{"component":"demoAiInsightsAlerts"}],"rightRail":[{"component":"demoLikelihoodScoreCard"},{"component":"demoActivityTimeline"},{"component":"demoActiveJourneyTracker"}]}}';
}
