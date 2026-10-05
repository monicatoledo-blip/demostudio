/**
 * Tests DemoStoryGenerator: the generate* entry points (mocking the model via
 * EinsteinProvider.mockGeneratedText) and the @TestVisible prompt builders +
 * compliance rules across industries.
 */
@isTest
private class DemoStoryGeneratorTest {

    @isTest
    static void generateEntryPointsReturnModelJson() {
        EinsteinProvider.mockGeneratedText = '{"customerFirstName":"Jen","messages":[{"sender":"bot","text":"Hi"}]}';
        Test.startTest();
        String email = DemoStoryGenerator.generateEmail('Financial Services', 'Cumulus', 'ctx', 'offer');
        String sms = DemoStoryGenerator.generateSms('Retail', 'Target', 'ctx', 'cart');
        String rcs = DemoStoryGenerator.generateRcs('Insurance', 'Acme', 'ctx', 'renewal');
        Test.stopTest();
        for (String out : new List<String>{ email, sms, rcs }) {
            System.assert(String.isNotBlank(out), 'Generation returned content.');
            System.assert(out.contains('"messages"'), 'Returned the model JSON: ' + out);
        }
    }

    @isTest
    static void complianceRulesVaryByIndustry() {
        System.assert(DemoStoryGenerator.complianceRules('Financial Services').contains('financial advisor'), 'FINS role.');
        System.assert(DemoStoryGenerator.complianceRules('Health & Life Sciences').contains('care coordinator'), 'Health role.');
        System.assert(DemoStoryGenerator.complianceRules('Insurance').contains('insurance agent'), 'Insurance role.');
        System.assert(DemoStoryGenerator.complianceRules('Public Sector').contains('caseworker'), 'Public role.');
        System.assert(DemoStoryGenerator.complianceRules('Retail').contains('specialist'), 'Default role.');
        System.assert(DemoStoryGenerator.complianceRules(null).contains('specialist'), 'Null industry → default.');
    }

    @isTest
    static void promptBuildersIncludeContextAndTokens() {
        // Non-blank args.
        String email = DemoStoryGenerator.buildPrompt('Retail', 'Target', 'Cart abandon', 'win-back');
        String sms = DemoStoryGenerator.buildSmsPrompt('Retail', 'Target', 'Cart abandon', 'win-back');
        String rcs = DemoStoryGenerator.buildRcsPrompt('Retail', 'Target', 'Cart abandon', 'win-back');
        for (String p : new List<String>{ email, sms, rcs }) {
            System.assert(p.contains('Target'), 'Brand in prompt.');
            System.assert(p.contains('[[CUSTOMER_FIRST_NAME]]'), 'Token guidance present.');
        }
        System.assert(rcs.contains('richCardVertical'), 'RCS prompt describes the card schema.');
        // Blank args exercise the default fallbacks.
        String blankEmail = DemoStoryGenerator.buildPrompt('', '', '', '');
        System.assert(blankEmail.contains('Financial Services'), 'Default industry.');
        System.assert(blankEmail.contains('the brand'), 'Default brand.');
        System.assert(String.isNotBlank(DemoStoryGenerator.buildSmsPrompt(null, null, null, null)), 'SMS blank ok.');
        System.assert(String.isNotBlank(DemoStoryGenerator.buildRcsPrompt(null, null, null, null)), 'RCS blank ok.');
    }
}
