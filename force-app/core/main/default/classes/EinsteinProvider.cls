/**
 * Real LLM-backed persona generator using org-native Einstein.
 *
 * Uses aiplatform.ModelsAPI (GPT-4o via sfdc_ai__DefaultOpenAIGPT4Omni).
 * No callout / no API key — call stays inside SF, honors Einstein Trust Layer.
 *
 * Contract: build a schema-anchored prompt from the brief, call the model,
 * extract the first JSON object from the response, return it as personaJson.
 * Any failure (model error, unparseable JSON) throws — the router catches
 * and falls back to ArchetypeProvider.
 */
public with sharing class EinsteinProvider implements IPersonaProvider {

    private static final String MODEL_NAME = 'sfdc_ai__DefaultOpenAIGPT4Omni';

    public DemoStudioPersonaGenerator.Result generate(String brief, String brandHint) {
        String prompt = PersonaPromptBuilder.build(brief, brandHint);
        String jsonBody = callAndExtractJson(prompt);
        DemoStudioPersonaGenerator.Result r = new DemoStudioPersonaGenerator.Result();
        r.personaJson = jsonBody;
        r.summary = buildSummary(jsonBody, brandHint);
        return r;
    }

    /**
     * Shared entry point — accepts a fully-composed prompt, calls the model,
     * extracts and validates JSON, throws on any failure. Used by the main
     * generate() path AND by DemoStudioPersonaGenerator.generateCollectionForPersona
     * for the sparkle "generate more" buttons.
     */
    public static String callAndExtractJson(String prompt) {
        String raw = callModelStatic(prompt);
        String jsonBody = extractJsonStatic(raw);
        if (String.isBlank(jsonBody)) {
            throw new EinsteinProviderException('Model returned no parseable JSON.');
        }
        try {
            JSON.deserializeUntyped(jsonBody);
        } catch (Exception e) {
            throw new EinsteinProviderException('Model returned invalid JSON: ' + e.getMessage());
        }
        return jsonBody;
    }

    private static String callModelStatic(String prompt) {
        aiplatform.ModelsAPI api = new aiplatform.ModelsAPI();
        aiplatform.ModelsAPI.createGenerations_Request req = new aiplatform.ModelsAPI.createGenerations_Request();
        req.modelName = MODEL_NAME;
        aiplatform.ModelsAPI_GenerationRequest body = new aiplatform.ModelsAPI_GenerationRequest();
        body.prompt = prompt;
        req.body = body;
        aiplatform.ModelsAPI.createGenerations_Response resp = api.createGenerations(req);
        if (resp == null || resp.Code200 == null || resp.Code200.generation == null) {
            throw new EinsteinProviderException('Model returned empty response.');
        }
        return resp.Code200.generation.generatedText;
    }

    private String callModel(String prompt) {
        aiplatform.ModelsAPI api = new aiplatform.ModelsAPI();
        aiplatform.ModelsAPI.createGenerations_Request req = new aiplatform.ModelsAPI.createGenerations_Request();
        req.modelName = MODEL_NAME;
        aiplatform.ModelsAPI_GenerationRequest body = new aiplatform.ModelsAPI_GenerationRequest();
        body.prompt = prompt;
        req.body = body;
        aiplatform.ModelsAPI.createGenerations_Response resp = api.createGenerations(req);
        if (resp == null || resp.Code200 == null || resp.Code200.generation == null) {
            throw new EinsteinProviderException('Model returned empty response.');
        }
        return resp.Code200.generation.generatedText;
    }

    private static String extractJsonStatic(String raw) {
        return extractJsonImpl(raw);
    }

    /**
     * Strip common wrapper patterns (```json ... ``` fences, prose preamble).
     * Locates the first balanced {...} object in the string.
     */
    private String extractJson(String raw) {
        return extractJsonImpl(raw);
    }

    private static String extractJsonImpl(String raw) {
        if (String.isBlank(raw)) return null;
        String s = raw.trim();
        // Strip fences
        if (s.startsWith('```')) {
            Integer nl = s.indexOf('\n');
            if (nl > 0) s = s.substring(nl + 1);
            if (s.endsWith('```')) s = s.substring(0, s.length() - 3);
            s = s.trim();
        }
        // Find first balanced JSON object
        Integer start = s.indexOf('{');
        if (start < 0) return null;
        Integer depth = 0;
        Boolean inString = false;
        Boolean escape = false;
        for (Integer i = start; i < s.length(); i++) {
            String c = s.substring(i, i + 1);
            if (escape) { escape = false; continue; }
            if (c == '\\') { escape = true; continue; }
            if (c == '"') { inString = !inString; continue; }
            if (inString) continue;
            if (c == '{') depth++;
            else if (c == '}') {
                depth--;
                if (depth == 0) return s.substring(start, i + 1);
            }
        }
        return null;
    }

    private String buildSummary(String jsonBody, String brandHint) {
        try {
            Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            Map<String, Object> persona = (Map<String, Object>) root.get('persona');
            String first = persona == null ? '' : String.valueOf(persona.get('First_Name__c'));
            String last  = persona == null ? '' : String.valueOf(persona.get('Last_Name__c'));
            String title = persona == null ? '' : String.valueOf(persona.get('Title__c'));
            String brand = String.isNotBlank(brandHint) ? brandHint
                : (persona == null ? '' : String.valueOf(persona.get('Brand__c')));
            String name = (first + ' ' + last).trim();
            List<String> parts = new List<String>();
            if (String.isNotBlank(name)) parts.add(name);
            if (title != null && title != 'null' && String.isNotBlank(title)) parts.add(title);
            if (brand != null && brand != 'null' && String.isNotBlank(brand)) parts.add('for ' + brand);
            return 'Generated ' + String.join(parts, ' · ') + '.';
        } catch (Exception e) {
            return 'Persona generated.';
        }
    }

    public class EinsteinProviderException extends Exception {}
}
