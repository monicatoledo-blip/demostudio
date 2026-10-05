/**
 * Tests for StoryEmailPreviewController: per-channel rendering via the
 * mockTemplate seam, the base64 inlining of relative /sfc/ ContentVersion image
 * URLs (the logo-not-loading fix), and the download content-type path.
 */
@isTest
private class StoryEmailPreviewControllerTest {

    // 1x1 transparent PNG.
    private static final String PNG_B64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

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

    private static void setPage(Id recId) {
        Test.setCurrentPage(new PageReference('/apex/StoryEmailPreview'));
        if (recId != null) ApexPages.currentPage().getParameters().put('id', recId);
    }

    @isTest
    static void resolvesShepherdUrlToDataUri() {
        Id cvId = insertPng();
        Test.startTest();
        String out = StoryEmailPreviewController.resolveImgUrl(
            '/sfc/servlet.shepherd/version/download/' + cvId
        );
        Test.stopTest();
        System.assert(out.startsWith('data:image/png;base64,'), 'Expected a PNG data URI, got: ' + out.left(40));
        // The inlined bytes must round-trip back to the original image.
        String b64 = out.substringAfter('base64,');
        System.assertEquals(PNG_B64, b64, 'Inlined base64 should equal the ContentVersion bytes.');
    }

    @isTest
    static void passesThroughAbsoluteUrlsAndAbsolutizesRelative() {
        Test.startTest();
        String abs = StoryEmailPreviewController.resolveImgUrl('https://res.cloudinary.com/x/logo.png');
        String data = StoryEmailPreviewController.resolveImgUrl('data:image/png;base64,AAAA');
        String rel = StoryEmailPreviewController.resolveImgUrl('/some/other/path.png');
        String blank = StoryEmailPreviewController.resolveImgUrl('');
        Test.stopTest();
        System.assertEquals('https://res.cloudinary.com/x/logo.png', abs, 'Absolute http URL unchanged.');
        System.assertEquals('data:image/png;base64,AAAA', data, 'Data URI unchanged.');
        System.assert(rel.startsWith('http'), 'Root-relative URL should be absolutized: ' + rel);
        System.assertEquals('', blank, 'Blank URL returned as-is.');
    }

    @isTest
    static void resolveConfigImagesMutatesLogoAndCardMedia() {
        Id cvId = insertPng();
        String sfc = '/sfc/servlet.shepherd/version/download/' + cvId;
        Map<String, Object> c = new Map<String, Object>{
            'logoUrl' => sfc,
            'marketingAvatarUrl' => 'https://cdn/x.png',
            'messages' => new List<Object>{
                new Map<String, Object>{ 'card' => new Map<String, Object>{ 'mediaUrl' => sfc } },
                new Map<String, Object>{ 'cards' => new List<Object>{
                    new Map<String, Object>{ 'mediaUrl' => sfc }
                } }
            }
        };
        Test.startTest();
        StoryEmailPreviewController.resolveConfigImages(c);
        Test.stopTest();
        System.assert(String.valueOf(c.get('logoUrl')).startsWith('data:'), 'logoUrl inlined.');
        System.assertEquals('https://cdn/x.png', c.get('marketingAvatarUrl'), 'Absolute avatar untouched.');
        Map<String, Object> m0 = (Map<String, Object>) ((List<Object>) c.get('messages'))[0];
        System.assert(String.valueOf(((Map<String, Object>) m0.get('card')).get('mediaUrl')).startsWith('data:'), 'card media inlined.');
    }

    @isTest
    static void rendersEmailWithSubstitutedTokens() {
        Id recId = newSim('Email', '{"brandName":"Target","customerFirstName":"Jen","headline":"Hello"}');
        StoryEmailPreviewController.mockTemplate =
            '<html><body><h1>[[HEADLINE]]</h1><p>[[BRAND_NAME]]</p><img src="[[LOGO_URL]]"/></body></html>';
        setPage(recId);
        StoryEmailPreviewController ctrl = new StoryEmailPreviewController();
        Test.startTest();
        String html = ctrl.getHtml();
        Test.stopTest();
        System.assert(html.contains('Target'), 'Brand token substituted.');
        System.assert(html.contains('Hello'), 'Headline substituted.');
    }

    @isTest
    static void rendersRcsHeroCardOnWhiteChipWithInlinedLogo() {
        Id cvId = insertPng();
        String cfg = '{"channel":"RCS","brandName":"Target","primaryColor":"#CC0404","featureSectionColor":"#700202"'
            + ',"logoUrl":"/sfc/servlet.shepherd/version/download/' + cvId + '"'
            + ',"messages":[{"sender":"bot","type":"richCardVertical","card":{"mediaUrl":"","title":"Hi","description":"d","buttons":[{"label":"Go","action":"openUrl","target":""}]}}]}';
        Id recId = newSim('RCS', cfg);
        StoryEmailPreviewController.mockTemplate = '<html><body>[[RCS_THREAD_HTML]] [[RCS_BRAND_NAME]]</body></html>';
        setPage(recId);
        StoryEmailPreviewController ctrl = new StoryEmailPreviewController();
        Test.startTest();
        String html = ctrl.getHtml();
        Test.stopTest();
        // Branded gradient preserved + logo on a white chip (the black-box fix).
        System.assert(html.contains('linear-gradient(135deg,#CC0404'), 'Branded gradient kept: ' + html.left(400));
        System.assert(html.contains('background:#ffffff;border-radius:12px'), 'Logo sits on a white chip.');
        // Logo src inlined as a data URI (the logo-not-loading fix) — no /sfc/ left.
        System.assert(html.contains('src="data:image/png;base64,'), 'Logo inlined as data URI.');
        System.assert(!html.contains('/sfc/servlet.shepherd'), 'No unresolved shepherd URL remains.');
    }

    @isTest
    static void rendersSmsAndWhatsapp() {
        StoryEmailPreviewController.mockTemplate = '<html><body>[[SMS_THREAD_HTML]][[WA_THREAD_HTML]] [[BRAND_NAME]]</body></html>';
        Id sms = newSim('SMS', '{"channel":"SMS","brandName":"Target","messages":[{"sender":"bot","text":"Hi"}]}');
        Id wa = newSim('WhatsApp', '{"channel":"WhatsApp","brandName":"Target","messages":[{"sender":"bot","text":"Hi"}]}');
        setPage(sms);
        Test.startTest();
        String smsHtml = new StoryEmailPreviewController().getHtml();
        setPage(wa);
        String waHtml = new StoryEmailPreviewController().getHtml();
        Test.stopTest();
        System.assert(smsHtml.contains('Target'), 'SMS brand substituted.');
        System.assert(waHtml.contains('Target'), 'WhatsApp brand substituted.');
    }

    @isTest
    static void blankIdAndContentType() {
        Id recId = newSim('RCS', '{"brandName":"Target","channel":"RCS"}');
        setPage(null);
        Test.startTest();
        String noId = new StoryEmailPreviewController().getHtml();
        setPage(recId);
        StoryEmailPreviewController ctrl = new StoryEmailPreviewController();
        String plain = ctrl.getPageContentType();
        ApexPages.currentPage().getParameters().put('download', '1');
        String dl = ctrl.getPageContentType();
        Test.stopTest();
        System.assert(noId.contains('No story id'), 'Blank id handled.');
        System.assertEquals('text/html', plain, 'Default content type.');
        System.assert(dl.startsWith('text/html#2-way_'), 'Download sets a filename: ' + dl);
    }
}
