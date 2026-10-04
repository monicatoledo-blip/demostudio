@isTest
private class DemoStudioPersonaGeneratorTest {

    private static final String PERSONA_JSON =
        '{"persona":{"First_Name__c":"Sarah","Last_Name__c":"Jenkins","Title__c":"VP Treasury","Brand__c":"Cumulus Bank"}}';

    @isTest
    static void shouldGenerateViaEinstein_WhenModelReturnsJson() {
        EinsteinProvider.mockGeneratedText = PERSONA_JSON;

        Test.startTest();
        DemoStudioPersonaGenerator.Result r = DemoStudioPersonaGenerator.generateForLwc('a treasury brief', 'Cumulus Bank');
        Test.stopTest();

        Assert.areEqual(PERSONA_JSON, r.personaJson, 'Einstein path should return the model JSON');
        Assert.areEqual('Einstein', r.providerUsed, 'Provider should report Einstein');
    }

    @isTest
    static void shouldFallBackToArchetype_WhenEinsteinReturnsNothing() {
        // Null model text makes EinsteinProvider throw, exercising the
        // deterministic ArchetypeProvider fallback path.
        EinsteinProvider.mockGeneratedText = null;

        Test.startTest();
        DemoStudioPersonaGenerator.Result r = DemoStudioPersonaGenerator.generateForLwc(
            'commercial banking treasury cross-sell for a logistics client', 'Cumulus Bank'
        );
        Test.stopTest();

        Assert.isTrue(r.providerUsed.contains('fallback'), 'Should report the Archetype fallback');
        Assert.isTrue(r.summary.contains('Einstein unavailable'), 'Summary should note Einstein was unavailable');
    }

    @isTest
    static void shouldGenerateViaInvocable_WhenCalledFromFlow() {
        EinsteinProvider.mockGeneratedText = PERSONA_JSON;
        DemoStudioPersonaGenerator.Request req = new DemoStudioPersonaGenerator.Request();
        req.brief = 'brief';
        req.brandHint = 'Cumulus Bank';

        Test.startTest();
        List<DemoStudioPersonaGenerator.Result> results =
            DemoStudioPersonaGenerator.generate(new List<DemoStudioPersonaGenerator.Request>{ req });
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Invocable should return one result per request');
        Assert.areEqual(PERSONA_JSON, results[0].personaJson, 'Result should carry the persona JSON');
    }

    @isTest
    static void shouldGenerateViaLegacyOverload_WhenSingleArg() {
        EinsteinProvider.mockGeneratedText = PERSONA_JSON;

        Test.startTest();
        DemoStudioPersonaGenerator.Result r = DemoStudioPersonaGenerator.generateForLwcLegacy('brief');
        Test.stopTest();

        Assert.areEqual(PERSONA_JSON, r.personaJson, 'Legacy overload should still produce a persona');
    }

    @isTest
    static void shouldGenerateCollectionRows_WhenModelReturnsArray() {
        Demo_Persona__c p = TestDataFactory.createPersona('Sarah', 'Jenkins', true);
        EinsteinProvider.mockGeneratedText =
            '{"kpis":[{"Label__c":"Assets","Value__c":"$1M","Sort_Order__c":1},{"Label__c":"Net Worth","Value__c":"$2M","Sort_Order__c":2}]}';

        Test.startTest();
        DemoStudioPersonaGenerator.CollectionResult out =
            DemoStudioPersonaGenerator.generateCollectionForPersona(p.Id, 'kpis', 'replace', null, null);
        Test.stopTest();

        Assert.isNull(out.error, 'No error expected on a clean generation');
        Assert.areEqual('kpis', out.collectionKey, 'Collection key should round-trip');
        Assert.isTrue(out.rowsJson.contains('Assets'), 'Rows JSON should carry the generated rows');
    }

    @isTest
    static void shouldCapAppendRows_WhenModelOverGenerates() {
        Demo_Persona__c p = TestDataFactory.createPersona('Sarah', 'Jenkins', true);
        // Five rows returned, append mode caps at 3.
        EinsteinProvider.mockGeneratedText =
            '{"segments":[{"Label__c":"A"},{"Label__c":"B"},{"Label__c":"C"},{"Label__c":"D"},{"Label__c":"E"}]}';

        Test.startTest();
        DemoStudioPersonaGenerator.CollectionResult out =
            DemoStudioPersonaGenerator.generateCollectionForPersona(p.Id, 'segments', 'append', '[]', null);
        Test.stopTest();

        List<Object> rows = (List<Object>) JSON.deserializeUntyped(out.rowsJson);
        Assert.areEqual(3, rows.size(), 'Append mode should cap at 3 rows');
    }

    @isTest
    static void shouldReturnError_WhenCollectionKeyInvalid() {
        Demo_Persona__c p = TestDataFactory.createPersona('Sarah', 'Jenkins', true);

        Test.startTest();
        DemoStudioPersonaGenerator.CollectionResult out =
            DemoStudioPersonaGenerator.generateCollectionForPersona(p.Id, 'nonsense', 'replace', null, null);
        Test.stopTest();

        Assert.isNotNull(out.error, 'An unknown collection key should surface an error, not throw');
    }

    @isTest
    static void shouldReturnError_WhenModelOmitsCollectionKey() {
        Demo_Persona__c p = TestDataFactory.createPersona('Sarah', 'Jenkins', true);
        EinsteinProvider.mockGeneratedText = '{"somethingElse":[]}';

        Test.startTest();
        DemoStudioPersonaGenerator.CollectionResult out =
            DemoStudioPersonaGenerator.generateCollectionForPersona(p.Id, 'kpis', 'replace', null, null);
        Test.stopTest();

        Assert.isNotNull(out.error, 'Missing collection key in the response should surface an error');
    }
}
