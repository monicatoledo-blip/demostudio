/**
 * Tests for StoryMcaExportService (the "Push to Marketing Cloud" email export).
 * All Connect-REST and Cloudinary callouts are mocked (HttpCalloutMock), so no
 * real MCA email / CMS media is created. Covers: the full push happy path
 * (logo re-host + native hero image + Dynamic-Content variant wiring), the
 * workspace picker, space resolution (per-org + explicit + none-found), the
 * email-only guard, the create-failure path, and the slug/apiName helpers.
 */
@isTest
private class StoryMcaExportServiceTest {

    // 1x1 transparent PNG (same fixture the preview test uses).
    private static final String PNG_B64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

    // Routes by endpoint: Cloudinary upload, CMS spaces GET, CMS contents POST.
    private class Mock implements HttpCalloutMock {
        Boolean failCreate;      // force /connect/cms/contents POST -> 400
        Boolean noSpaces;        // force /connect/cms/spaces -> empty list
        Mock(Boolean failCreate, Boolean noSpaces) { this.failCreate = failCreate; this.noSpaces = noSpaces; }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String ep = req.getEndpoint();
            String m = req.getMethod();
            if (ep.contains('api.cloudinary.com')) {
                res.setStatusCode(200);
                res.setBody('{"secure_url":"https://res.cloudinary.com/test/img.png"}');
            } else if (ep.contains('/connect/cms/spaces')) {
                res.setStatusCode(200);
                res.setBody(noSpaces
                    ? '{"spaces":[]}'
                    : '{"spaces":[' +
                        '{"id":"0ZuKh000000TESTIAW","name":"Content Workspace for Marketing Cloud","spaceType":{"apiName":"marketing"}},' +
                        '{"id":"0ZuKh000000CMMRCE","name":"Commerce Content","spaceType":{"apiName":"content"}}' +
                      ']}');
            } else if (ep.contains('/connect/cms/contents') && m == 'POST') {
                if (failCreate) {
                    res.setStatusCode(400);
                    res.setBody('{"message":"forced create failure"}');
                } else {
                    res.setStatusCode(201);
                    res.setBody('{"apiName":"TESTKEY_ABCDEF"}');
                }
            } else if (ep.contains('/personalization/personalization-points')) {
                // Hero point create (POST) returns an id; reverse-link (PUT) 200.
                res.setStatusCode(m == 'POST' ? 201 : 200);
                res.setBody('{"id":"9ppTEST000000001AAA","status":"Processing"}');
            } else {
                res.setStatusCode(200);
                res.setBody('{}');
            }
            return res;
        }
    }

    private static Id insertPng() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test-Logo', PathOnClient = 'Test-Logo.png',
            VersionData = EncodingUtil.base64Decode(PNG_B64)
        );
        insert cv;
        return [SELECT Id FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].Id;
    }

    private static Id newSim(String channel, String configJson) {
        Two_Way_Simulator__c s = new Two_Way_Simulator__c(
            Name = 'placeholder', Channel__c = channel, Config_JSON__c = configJson
        );
        insert s;
        return s.Id;
    }

    // A rich email config that exercises every section + both image paths:
    // a relative /sfc/ logo (re-hosted via Cloudinary) and an absolute hero
    // (becomes a native image block + Dynamic-Content variant).
    private static String richConfig(Id logoCvId) {
        return JSON.serialize(new Map<String, Object>{
            'brandName' => 'Target', 'primaryColor' => '#CC0000',
            'featureSectionColor' => '#700000', 'headlineTextColor' => '#FFFFFF',
            'logoUrl' => '/sfc/servlet.shepherd/version/download/' + logoCvId,
            'logoBgColor' => '#0A1F44', 'logoWidth' => '200',   // dark bg + no-unit width branches
            'heroImageUrl' => 'https://ex.com/hero.jpg',
            'subjectLine' => 'Your cart misses you',
            'headline' => 'Still thinking it over, [[CUSTOMER_FIRST_NAME]]?',
            'subHeadline' => 'Complete your order and save',
            'featureColumn1' => 'Free shipping over $50.', 'featureColumn2' => 'Easy 30-day returns.',
            'bodyParagraph' => 'Hi [[CUSTOMER_FIRST_NAME]],\n\nThe items you loved are waiting.',
            'showBullets' => true, 'bullet1' => 'Early access', 'bullet2' => 'Points', 'bullet3' => 'Price match',
            'replyPromptHeadline' => 'Need help choosing?', 'replyPromptBody' => 'Just reply to this email.',
            'ctaButtonText' => 'Complete my order', 'ctaButtonColor' => '#CC0000',
            'customerFirstName' => 'Cynthia'
        });
    }

    @isTest
    static void pushHappyPath_resolvesSpacePerOrg() {
        Id logo = insertPng();
        Id sim = newSim('Email', richConfig(logo));
        Test.setMock(HttpCalloutMock.class, new Mock(false, false));
        Test.startTest();
        // Blank targetSpaceId -> resolveSpaceId() runs (aggregate empty -> GET spaces mock).
        // makeHeroDynamic=true -> provisionHeroPoint + the hero DC wiring block run.
        StoryMcaExportService.Result r = StoryMcaExportService.pushEmailToMca(sim, '', true);
        Test.stopTest();
        System.assertNotEquals(null, r, 'Result returned');
        System.assert(String.isNotBlank(r.name), 'Email name set from the sim record: ' + r.name);
    }

    @isTest
    static void pushHappyPath_explicitSpace() {
        Id logo = insertPng();
        Id sim = newSim('Email', richConfig(logo));
        Test.setMock(HttpCalloutMock.class, new Mock(false, false));
        Test.startTest();
        // Explicit targetSpaceId -> resolveSpaceId() short-circuits to it.
        // makeHeroDynamic=false -> hero deploys as a plain native image (no point).
        StoryMcaExportService.Result r = StoryMcaExportService.pushEmailToMca(sim, '0ZuKh000000EXPLCT', false);
        Test.stopTest();
        System.assertNotEquals(null, r, 'Result returned with explicit space');
    }

    @isTest
    static void listWorkspaces_returnsSpacesWithDefaultFlag() {
        Test.setMock(HttpCalloutMock.class, new Mock(false, false));
        Test.startTest();
        List<Map<String, Object>> ws = StoryMcaExportService.listMcaWorkspaces();
        Test.stopTest();
        System.assertEquals(1, ws.size(), 'Only the marketing space is kept; the content/commerce space is filtered out');
        System.assertEquals('0ZuKh000000TESTIAW', ws[0].get('value'), 'Workspace id surfaced');
        System.assertEquals(true, ws[0].get('isDefault'), 'Resolved space is flagged default');
    }

    @isTest
    static void push_rejectsNonEmailChannel() {
        Id sim = newSim('SMS', '{}');
        Test.setMock(HttpCalloutMock.class, new Mock(false, false));
        Boolean threw = false;
        Test.startTest();
        try {
            StoryMcaExportService.pushEmailToMcaImpl(sim);
        } catch (StoryMcaExportService.ExportException e) {
            threw = true;
            System.assert(e.getMessage().contains('Email channel'), 'Guard message: ' + e.getMessage());
        }
        Test.stopTest();
        System.assert(threw, 'Non-email channel should throw ExportException');
    }

    @isTest
    static void push_throwsWhenCreateFails() {
        Id logo = insertPng();
        Id sim = newSim('Email', richConfig(logo));
        Test.setMock(HttpCalloutMock.class, new Mock(true, false)); // email create -> 400
        Boolean threw = false;
        Test.startTest();
        try {
            StoryMcaExportService.pushEmailToMcaImpl(sim);
        } catch (StoryMcaExportService.ExportException e) {
            threw = true;
            System.assert(e.getMessage().contains('Create MCA email failed'), 'Create-failure message: ' + e.getMessage());
        }
        Test.stopTest();
        System.assert(threw, 'A non-2xx create should throw ExportException');
    }

    @isTest
    static void resolveSpace_throwsWhenNoSpaceFound() {
        Test.setMock(HttpCalloutMock.class, new Mock(false, true)); // spaces -> []
        Boolean threw = false;
        Test.startTest();
        try {
            StoryMcaExportService.resolveSpaceId();
        } catch (StoryMcaExportService.ExportException e) {
            threw = true;
            System.assert(e.getMessage().contains('content space'), 'No-space message: ' + e.getMessage());
        }
        Test.stopTest();
        System.assert(threw, 'No usable CMS space should throw ExportException');
    }

    @isTest
    static void slugAndApiNameHelpers() {
        System.assertEquals('hello-world', StoryMcaExportService.slug('Hello World!'));
        System.assertEquals('email', StoryMcaExportService.slug(''));
        System.assert(StoryMcaExportService.slug('123abc').startsWith('e-'), 'Leading-digit slug prefixed');
        System.assertEquals('Hello_World', StoryMcaExportService.apiName('Hello World'));
        System.assertEquals('Email', StoryMcaExportService.apiName(''));
        System.assert(StoryMcaExportService.apiName('9lives').startsWith('E'), 'Leading-digit apiName prefixed');
    }

    @isTest
    static void dcPickers_queryWithoutError() {
        // PersonalizationPoint/Decision are setup-style objects (not insertable in
        // tests), so these return empty here — assert they run cleanly and the
        // blank-point guard short-circuits listDecisions.
        Test.startTest();
        List<Map<String, Object>> pts = StoryMcaExportService.listPersonalizationPoints();
        List<Map<String, Object>> decsBlank = StoryMcaExportService.listDecisions('');
        List<Map<String, Object>> decs = StoryMcaExportService.listDecisions('Some_Point');
        Test.stopTest();
        System.assertNotEquals(null, pts, 'Points list returned');
        System.assertEquals(0, decsBlank.size(), 'Blank point -> no decisions');
        System.assertNotEquals(null, decs, 'Decisions list returned');
    }
}
