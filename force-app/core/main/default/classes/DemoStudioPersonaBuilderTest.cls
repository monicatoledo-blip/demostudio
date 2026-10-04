@isTest
private class DemoStudioPersonaBuilderTest {

    @isTest
    static void shouldBuildPersonaWithChildren_WhenGivenFullJson() {
        Demo_Theme__c theme = TestDataFactory.createTheme('Cumulus Bank', true);

        String json = '{'
            + '"persona":{"First_Name__c":"Sarah","Last_Name__c":"Jenkins","Title__c":"VP Treasury","LTV__c":250000,"Engagement_Score__c":84},'
            + '"themeName":"Cumulus Bank",'
            + '"recipe":{"leftRail":[{"component":"demoUnifiedProfileHeader"}]},'
            + '"identities":[{"Type__c":"Email","Value__c":"sarah@x.com","Label__c":"Primary","Sort_Order__c":1}],'
            + '"insights":[{"Title__c":"Cross-Sell","Category__c":"Cross-Sell","Sort_Order__c":1}],'
            + '"activities":[{"Type__c":"Doc","Title__c":"Upload","Sort_Order__c":1}],'
            + '"journeys":[{"Journey_Name__c":"Onboarding","Business_Unit__c":"Commercial","Status__c":"Active","Enrolled_Date__c":"2026-06-15"}]'
            + '}';

        DemoStudioPersonaBuilder.BuildRequest req = new DemoStudioPersonaBuilder.BuildRequest();
        req.personaJson = json;

        Test.startTest();
        List<DemoStudioPersonaBuilder.BuildResult> results =
            DemoStudioPersonaBuilder.build(new List<DemoStudioPersonaBuilder.BuildRequest>{ req });
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'One request should yield one result');
        Id personaId = (Id) results[0].personaId;
        Assert.isNotNull(personaId, 'Persona should be inserted');

        Demo_Persona__c p = [SELECT Id, First_Name__c, Theme__c, Component_Recipe__c, LTV__c FROM Demo_Persona__c WHERE Id = :personaId];
        Assert.areEqual('Sarah', p.First_Name__c, 'Persona fields should apply');
        Assert.areEqual(theme.Id, p.Theme__c, 'Theme should resolve by name');
        Assert.areEqual(250000, p.LTV__c, 'Numeric field should coerce');
        Assert.isTrue(p.Component_Recipe__c.contains('leftRail'), 'Recipe JSON should be serialized onto the persona');

        Assert.areEqual(1, [SELECT COUNT() FROM Demo_Persona_Identity__c WHERE Persona__c = :personaId], 'Identity child inserted');
        Assert.areEqual(1, [SELECT COUNT() FROM Demo_Persona_Journey__c WHERE Persona__c = :personaId], 'Journey child inserted');
    }

    @isTest
    static void shouldBuildPersona_WhenThemeIdProvidedDirectly() {
        Demo_Theme__c theme = TestDataFactory.createTheme('Direct Kit', true);
        String json = '{"persona":{"First_Name__c":"Ada","Last_Name__c":"Byron"},"themeId":"' + theme.Id + '"}';
        DemoStudioPersonaBuilder.BuildRequest req = new DemoStudioPersonaBuilder.BuildRequest();
        req.personaJson = json;

        Test.startTest();
        List<DemoStudioPersonaBuilder.BuildResult> results =
            DemoStudioPersonaBuilder.build(new List<DemoStudioPersonaBuilder.BuildRequest>{ req });
        Test.stopTest();

        Demo_Persona__c p = [SELECT Theme__c FROM Demo_Persona__c WHERE Id = :results[0].personaId];
        Assert.areEqual(theme.Id, p.Theme__c, 'Theme should resolve from an explicit themeId');
    }

    @isTest
    static void shouldBuildPersona_WhenNoChildrenOrTheme() {
        String json = '{"persona":{"First_Name__c":"Solo","Last_Name__c":"Persona"}}';
        DemoStudioPersonaBuilder.BuildRequest req = new DemoStudioPersonaBuilder.BuildRequest();
        req.personaJson = json;

        Test.startTest();
        List<DemoStudioPersonaBuilder.BuildResult> results =
            DemoStudioPersonaBuilder.build(new List<DemoStudioPersonaBuilder.BuildRequest>{ req });
        Test.stopTest();

        Assert.isNotNull(results[0].personaId, 'Persona should build with no children or theme');
    }
}
