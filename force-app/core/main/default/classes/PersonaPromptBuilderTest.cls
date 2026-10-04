@isTest
private class PersonaPromptBuilderTest {

    @isTest
    static void shouldIncludeSchemaAndBrief_WhenBuildingMainPrompt() {
        Test.startTest();
        String prompt = PersonaPromptBuilder.build('A VP of Treasury at a logistics firm', 'Cumulus Bank');
        Test.stopTest();

        Assert.isTrue(prompt.contains('Demo Studio Persona Generator'), 'Prompt should carry the system framing');
        Assert.isTrue(prompt.contains('A VP of Treasury at a logistics firm'), 'Prompt should embed the brief verbatim');
        Assert.isTrue(prompt.contains('Cumulus Bank'), 'Prompt should reflect the brand hint');
        Assert.isTrue(prompt.contains('"persona"'), 'Prompt should include the JSON schema');
    }

    @isTest
    static void shouldHandleNullBriefAndBlankBrand_WhenBuildingMainPrompt() {
        Test.startTest();
        String prompt = PersonaPromptBuilder.build(null, null);
        Test.stopTest();

        Assert.isNotNull(prompt, 'Prompt should still build with null inputs');
        Assert.isTrue(prompt.endsWith('JSON:'), 'Prompt should end with the JSON close');
    }

    @isTest
    static void shouldReturnReplaceSlice_WhenBuildingCollectionPrompt() {
        Test.startTest();
        String prompt = PersonaPromptBuilder.buildForCollection('Sarah, VP Treasury', 'kpis', 'replace', null, null, 3);
        Test.stopTest();

        Assert.isTrue(prompt.contains('REPLACE MODE'), 'Replace mode line should be present');
        Assert.isTrue(prompt.contains('kpis'), 'Collection key should appear');
    }

    @isTest
    static void shouldReturnAppendSlice_WhenBuildingCollectionPrompt() {
        Test.startTest();
        String prompt = PersonaPromptBuilder.buildForCollection('Sarah, VP Treasury', 'alerts', 'append', '[{"Title__c":"x"}]', 'focus on cash', 2);
        Test.stopTest();

        Assert.isTrue(prompt.contains('APPEND MODE'), 'Append mode line should be present');
        Assert.isTrue(prompt.contains('focus on cash'), 'Extra hint should be included');
    }

    @isTest
    static void shouldUseFourArgOverload_WhenNoCountGiven() {
        Test.startTest();
        String prompt = PersonaPromptBuilder.buildForCollection('Sarah', 'segments', 'replace', null, null);
        Test.stopTest();

        Assert.isTrue(prompt.contains('segments'), 'Four-arg overload should delegate correctly');
    }

    @isTest
    static void shouldThrow_WhenCollectionKeyUnknown() {
        Test.startTest();
        try {
            PersonaPromptBuilder.buildForCollection('Sarah', 'not_a_collection', 'replace', null, null, 0);
            Assert.fail('Expected PersonaPromptBuilderException for unknown collection');
        } catch (PersonaPromptBuilder.PersonaPromptBuilderException e) {
            Assert.isTrue(e.getMessage().contains('Unknown collection'), 'Message should name the problem');
        }
        Test.stopTest();
    }
}
