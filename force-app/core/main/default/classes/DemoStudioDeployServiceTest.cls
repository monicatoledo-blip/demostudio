/**
 * Tests for DemoStudioDeployService. All Connect REST / Tooling callouts are
 * mocked (HttpCalloutMock), so no real org objects are created. Covers the
 * deploy success path, clean teardown, the no-Adaptive-Web-stage guard, and the
 * failure -> rollback -> Error-status path.
 */
@isTest
private class DemoStudioDeployServiceTest {

    /** Returns 201+id for POSTs, 204 for DELETEs, 200 for GETs. Optionally 400 on point create. */
    private class Mock implements HttpCalloutMock {
        Boolean failPoints = false;
        Mock(Boolean failPoints) { this.failPoints = failPoints; }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String m = req.getMethod();
            String ep = req.getEndpoint();
            if (m == 'DELETE') {
                res.setStatusCode(204);
                res.setBody('');
            } else if (m == 'POST') {
                if (failPoints && ep.contains('/personalization-points')) {
                    res.setStatusCode(400);
                    res.setBody('[{"errorCode":"INVALID_API_INPUT","message":"forced test failure"}]');
                } else {
                    res.setStatusCode(201);
                    res.setBody('{"id":"081Kh000000TESTIAA","success":true}');
                }
            } else {
                res.setStatusCode(200);
                res.setBody('{"schemas":[]}');
            }
            return res;
        }
    }

    private static Demo_Story__c makeStory(Boolean withAdaptiveStage) {
        Demo_Story__c s = new Demo_Story__c(
            Name = 'Test Story', Data_Space__c = 'default',
            Industry__c = 'Financial Services', Brand__c = 'Cumulus Bank', Status__c = 'Draft');
        insert s;
        if (withAdaptiveStage) {
            Map<String, Object> c = new Map<String, Object>{
                'backgroundImageUrl' => 'https://ex.com/h.jpg', 'eyebrow' => 'HI',
                'header' => 'Head', 'subheader' => 'Sub', 'cta' => 'Go',
                'html' => '<!doctype html><html><body>x</body></html>'
            };
            insert new Demo_Stage__c(Story__c = s.Id, Stage_Type__c = 'Intent Capture',
                Channel__c = 'Adaptive Web', Surface__c = 'homepage_hero', Sort_Order__c = 1,
                Content_JSON__c = JSON.serialize(c));
        }
        return s;
    }

    @isTest
    static void deploy_then_teardown_succeeds() {
        Demo_Story__c s = makeStory(true);
        Test.setMock(HttpCalloutMock.class, new Mock(false));

        Test.startTest();
        String artifacts = DemoStudioDeployService.deployStoryImpl(s.Id);
        Test.stopTest();

        Demo_Story__c after = [SELECT Status__c, Last_Deployed__c, Deployed_Artifacts__c FROM Demo_Story__c WHERE Id = :s.Id];
        Assert.areEqual('Deployed', after.Status__c, 'Status should be Deployed');
        Assert.isNotNull(after.Last_Deployed__c, 'Last_Deployed should be stamped');
        Assert.isTrue(artifacts.contains('schemas'), 'Artifacts JSON should list schemas');

        // teardown in a second mocked window
        Test.setMock(HttpCalloutMock.class, new Mock(false));
        DemoStudioDeployService.teardownStoryImpl(s.Id);
        Demo_Story__c cleaned = [SELECT Status__c, Deployed_Artifacts__c FROM Demo_Story__c WHERE Id = :s.Id];
        Assert.areEqual('Draft', cleaned.Status__c, 'Status should reset to Draft');
        Assert.isNull(cleaned.Deployed_Artifacts__c, 'Artifacts should be cleared');
    }

    @isTest
    static void deploy_withoutAdaptiveStage_throws() {
        Demo_Story__c s = makeStory(false);
        Test.setMock(HttpCalloutMock.class, new Mock(false));

        Test.startTest();
        try {
            DemoStudioDeployService.deployStoryImpl(s.Id);
            Assert.fail('Expected DeployException when no Adaptive Web stage');
        } catch (DemoStudioDeployService.DeployException e) {
            Assert.isTrue(e.getMessage().contains('Adaptive Web'), 'Message should explain the missing stage');
        }
        Test.stopTest();
    }

    @isTest
    static void deploy_failure_rollsBack_andSetsError() {
        Demo_Story__c s = makeStory(true);
        Test.setMock(HttpCalloutMock.class, new Mock(true)); // force point-create 400

        Test.startTest();
        try {
            DemoStudioDeployService.deployStoryImpl(s.Id);
            Assert.fail('Expected DeployException on point-create failure');
        } catch (DemoStudioDeployService.DeployException e) {
            Assert.isTrue(e.getMessage().contains('Deploy failed'), 'Should wrap the failure');
        }
        Test.stopTest();

        Demo_Story__c after = [SELECT Status__c FROM Demo_Story__c WHERE Id = :s.Id];
        Assert.areEqual('Error', after.Status__c, 'Failed deploy should set Status to Error');
    }

    @isTest
    static void auraEntryPoint_wrapsErrorAsAuraHandled() {
        Demo_Story__c s = makeStory(false);
        Test.setMock(HttpCalloutMock.class, new Mock(false));
        Test.startTest();
        try {
            DemoStudioDeployService.deployStory(s.Id);
            Assert.fail('Expected AuraHandledException');
        } catch (AuraHandledException e) {
            // expected: the @AuraEnabled boundary converts DeployException
        }
        Test.stopTest();
    }
}
