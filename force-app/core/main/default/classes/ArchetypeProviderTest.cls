@isTest
private class ArchetypeProviderTest {

    @isTest
    static void shouldReturnClarifyingQuestion_WhenBriefHasNoKeywords() {
        Test.startTest();
        DemoStudioPersonaGenerator.Result r = new ArchetypeProvider().generate('hello there friend', null);
        Test.stopTest();

        Assert.isNull(r.personaJson, 'No keyword match should not produce a persona');
        Assert.isTrue(r.summary.contains('more'), 'Summary should ask for more detail');
    }

    @isTest
    static void shouldReturnPayloadWithBrand_WhenBriefMatchesKeywordsAndBrandHint() {
        Test.startTest();
        DemoStudioPersonaGenerator.Result r = new ArchetypeProvider().generate(
            'commercial banking treasury cross-sell treasury for a mid-market logistics client', 'Cumulus Bank'
        );
        Test.stopTest();

        Assert.isNotNull(r.personaJson, 'A keyword match should return the archetype payload');
        Assert.isTrue(r.personaJson.contains('Cumulus Bank'), 'Brand hint should be injected into the payload');
        Assert.isTrue(r.summary.contains('Cumulus Bank'), 'Summary should mention the brand');
    }

    @isTest
    static void shouldExtractBrandFromBrief_WhenNoBrandHint() {
        Test.startTest();
        DemoStudioPersonaGenerator.Result r = new ArchetypeProvider().generate(
            'commercial banking treasury cross-sell at Globex Corp. who needs FX hedging', null
        );
        Test.stopTest();

        Assert.isNotNull(r.personaJson, 'A keyword match should return the archetype payload');
        Assert.isTrue(r.personaJson.contains('Globex Corp'), 'Brand should be extracted from the brief and injected');
    }

    @isTest
    static void shouldHandleNullBrief_WhenGenerating() {
        Test.startTest();
        DemoStudioPersonaGenerator.Result r = new ArchetypeProvider().generate(null, null);
        Test.stopTest();

        Assert.isNull(r.personaJson, 'Null brief cannot match any archetype');
    }
}
