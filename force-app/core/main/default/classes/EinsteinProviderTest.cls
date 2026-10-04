@isTest
private class EinsteinProviderTest {

    private static final String VALID_JSON =
        '{"persona":{"First_Name__c":"Sarah","Last_Name__c":"Jenkins","Title__c":"VP Treasury","Brand__c":"Cumulus Bank"}}';

    @isTest
    static void shouldReturnPersonaJson_WhenModelReturnsValidJson() {
        EinsteinProvider.mockGeneratedText = VALID_JSON;

        Test.startTest();
        DemoStudioPersonaGenerator.Result r = new EinsteinProvider().generate('brief', 'Cumulus Bank');
        Test.stopTest();

        Assert.areEqual(VALID_JSON, r.personaJson, 'personaJson should be the extracted model JSON');
        Assert.isTrue(r.summary.contains('Sarah Jenkins'), 'Summary should name the persona');
        Assert.isTrue(r.summary.contains('Cumulus Bank'), 'Summary should reflect the brand hint');
    }

    @isTest
    static void shouldStripCodeFences_WhenModelWrapsJson() {
        EinsteinProvider.mockGeneratedText = '```json\n' + VALID_JSON + '\n```';

        Test.startTest();
        String json = EinsteinProvider.callAndExtractJson('prompt');
        Test.stopTest();

        Assert.areEqual(VALID_JSON, json, 'Fenced JSON should be unwrapped to the raw object');
    }

    @isTest
    static void shouldExtractFirstObject_WhenModelAddsPreamble() {
        EinsteinProvider.mockGeneratedText = 'Here you go: ' + VALID_JSON + ' hope that helps';

        Test.startTest();
        String json = EinsteinProvider.callAndExtractJson('prompt');
        Test.stopTest();

        Assert.areEqual(VALID_JSON, json, 'Leading/trailing prose should be stripped');
    }

    @isTest
    static void shouldThrow_WhenModelReturnsNoJson() {
        EinsteinProvider.mockGeneratedText = 'no json here at all';

        Test.startTest();
        try {
            EinsteinProvider.callAndExtractJson('prompt');
            Assert.fail('Expected EinsteinProviderException when no JSON present');
        } catch (EinsteinProvider.EinsteinProviderException e) {
            Assert.isTrue(e.getMessage().contains('no parseable JSON'), 'Message should indicate missing JSON');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrow_WhenModelReturnsMalformedJson() {
        EinsteinProvider.mockGeneratedText = '{"persona": {bad json}}';

        Test.startTest();
        try {
            EinsteinProvider.callAndExtractJson('prompt');
            Assert.fail('Expected EinsteinProviderException for invalid JSON');
        } catch (EinsteinProvider.EinsteinProviderException e) {
            Assert.isTrue(
                e.getMessage().contains('invalid JSON') || e.getMessage().contains('no parseable JSON'),
                'Message should indicate a JSON problem'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void shouldFallBackSummary_WhenJsonHasNoPersona() {
        // Valid JSON object but without a persona node exercises buildSummary's
        // resilient path.
        EinsteinProvider.mockGeneratedText = '{"other":true}';

        Test.startTest();
        DemoStudioPersonaGenerator.Result r = new EinsteinProvider().generate('brief', null);
        Test.stopTest();

        Assert.isNotNull(r.summary, 'Summary should always be populated');
    }
}
