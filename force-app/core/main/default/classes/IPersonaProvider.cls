/**
 * Provider interface for persona-generation backends.
 *
 * v1 shipped a keyword-scoring archetype matcher inline in
 * DemoStudioPersonaGenerator; v2 introduces this abstraction so we can
 * swap in a real LLM (EinsteinProvider) or fall back to the deterministic
 * archetype path per org config (Demo_Studio_Config__mdt.AI_Provider__c).
 *
 * Contract: return a PersonaResult with a JSON string matching the shape
 * the demoPersonaGenerator LWC / handleGeneratorApply expects. If the
 * provider is unable to produce a persona (blank brief, hard failure),
 * return a Result whose personaJson is null and whose summary carries a
 * user-facing clarifying prompt.
 */
public interface IPersonaProvider {
    DemoStudioPersonaGenerator.Result generate(String brief, String brandHint);
}
