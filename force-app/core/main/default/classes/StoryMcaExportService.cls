/**
 * "Push to Marketing Cloud" — exports a 2-Way Simulator EMAIL into a real,
 * editable Marketing Cloud Advanced (MC Next) email asset on Core.
 *
 * A single Connect-REST POST to /connect/cms/contents (contentType
 * sfdc_cms__email) creates the ManagedContent AND auto-wires its EmailContent
 * wrapper, so one click yields a sendable MCA email. The creative is emitted as
 * discrete lightning/html blocks (header / hero / body / features / bullets /
 * CTA) so each is an individually editable component in the MCA email builder,
 * inside a wrapper that keeps the brand source + data providers so MCA
 * personalization/dynamic-content still resolves. CREATIVE ONLY — the 2-way
 * reply thread stays a DemoStudio simulation.
 *
 * See reference-mca-email-content-model. Callout pattern mirrors
 * DemoStudioDeployService (same-org session-token, no Named Credential).
 */
public with sharing class StoryMcaExportService {

    // Optional overrides (tests / explicit targeting). When null, resolved per-org.
    @TestVisible private static String spaceId;    // CMS content space id (resolved if null)
    @TestVisible private static String dataGraph = 'Marketing_Content_Personalizat';
    private static final String CMS_PATH = '/services/data/v62.0/connect/cms/contents';

    public class ExportException extends Exception {}

    public class Result {
        @AuraEnabled public String emailContentId;
        @AuraEnabled public String managedContentId;
        @AuraEnabled public String name;
        @AuraEnabled public String builderUrl;
    }

    // ---- @AuraEnabled boundary (converts to AuraHandledException) -----------
    // targetSpaceId optional — when blank, resolveSpaceId() picks the default
    // marketing workspace.
    @AuraEnabled
    public static Result pushEmailToMca(Id storyId, String targetSpaceId) {
        try {
            if (String.isNotBlank(targetSpaceId)) spaceId = targetSpaceId;
            return pushEmailToMcaImpl(storyId);
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    // Workspaces the SE can deploy into (the picker list). The resolved default
    // is flagged so the UI can pre-select it.
    @AuraEnabled
    public static List<Map<String, Object>> listMcaWorkspaces() {
        getApiSessionId(); // pre-warm before any callout (getContent ordering)
        List<Map<String, Object>> out = new List<Map<String, Object>>();
        String def;
        try { def = resolveSpaceId(); } catch (Exception e) { def = null; }
        try {
            HttpResponse res = send('GET', '/services/data/v62.0/connect/cms/spaces', null);
            // Surface a non-200 instead of silently returning an empty picker —
            // that was hiding the Lightning-session 401 (modal opened, dropdown
            // empty, no toast). Now the SE sees why.
            if (res.getStatusCode() != 200) {
                throw new ExportException('List workspaces failed (' + res.getStatusCode() + '): ' + res.getBody());
            }
            if (res.getStatusCode() == 200) {
                Object parsed = JSON.deserializeUntyped(res.getBody());
                if (parsed instanceof Map<String, Object>) {
                    Object sp = ((Map<String, Object>) parsed).get('spaces');
                    if (sp instanceof List<Object>) {
                        for (Object o : (List<Object>) sp) {
                            Map<String, Object> m = (Map<String, Object>) o;
                            // Only "marketing"-type spaces can hold MCA email
                            // content; skip Commerce/content/Brand-Center/etc.
                            // (MCA and MCAE both report spaceType "marketing" and
                            // can share a space — that's fine, both deploy to MCA.)
                            Object stObj = m.get('spaceType');
                            String st = (stObj instanceof Map<String, Object>)
                                ? String.valueOf(((Map<String, Object>) stObj).get('apiName'))
                                : String.valueOf(stObj);
                            if (st != 'marketing') continue;
                            String id = String.valueOf(m.get('id'));
                            out.add(new Map<String, Object>{
                                'value' => id,
                                'label' => String.valueOf(m.get('name')),
                                'isDefault' => (id == def)
                            });
                        }
                    }
                }
            }
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
        return out;
    }

    @TestVisible
    public static Result pushEmailToMcaImpl(Id storyId) {
        getApiSessionId(); // pre-warm before any callout (getContent ordering)
        Two_Way_Simulator__c s = [
            SELECT Id, Name, Channel__c, Config_JSON__c
            FROM Two_Way_Simulator__c WHERE Id = :storyId LIMIT 1
        ];
        String ch = s.Channel__c == null ? 'Email' : s.Channel__c;
        if (ch.toLowerCase() != 'email') {
            throw new ExportException('Push to Marketing Cloud currently supports the Email channel only (this is ' + ch + ').');
        }
        Map<String, Object> cfg = new Map<String, Object>();
        if (String.isNotBlank(s.Config_JSON__c)) {
            try { cfg = (Map<String, Object>) JSON.deserializeUntyped(s.Config_JSON__c); } catch (Exception e) {}
        }

        String title = (s.Name == null ? 'DemoStudio Email' : s.Name);
        String urlName = slug(title) + '-' + String.valueOf(Datetime.now().getTime());
        Map<String, Object> body = buildEmailContentBody(cfg, title);

        Map<String, Object> payload = new Map<String, Object>{
            'contentSpaceOrFolderId' => resolveSpaceId(),
            'contentType' => 'sfdc_cms__email',
            'title' => title,
            'urlName' => urlName,
            'contentBody' => body
        };

        HttpResponse res = send('POST', CMS_PATH, JSON.serialize(payload, true));
        Map<String, Object> created = okJson(res, 'Create MCA email');
        String apiNm = String.valueOf(created.get('apiName'));

        Result r = new Result();
        r.name = title;
        if (String.isNotBlank(apiNm)) {
            for (ManagedContent mc : [SELECT Id FROM ManagedContent WHERE ApiName = :apiNm LIMIT 1]) {
                r.managedContentId = mc.Id;
            }
        }
        if (r.managedContentId != null) {
            for (EmailContent ec : [SELECT Id FROM EmailContent WHERE ManagedContentId = :r.managedContentId LIMIT 1]) {
                r.emailContentId = ec.Id;
            }
        }
        if (r.emailContentId != null) {
            r.builderUrl = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/EmailContent/' + r.emailContentId + '/view';
        }
        return r;
    }

    // ---- callout (same-org session token) -----------------------------------

    // An API-enabled session id. UserInfo.getSessionId() returns a UI-only
    // session in a Lightning @AuraEnabled context, which the Connect REST API
    // rejects with 401 INVALID_SESSION_ID (anonymous Apex gives an API session,
    // which is why this works from anon but not from the button). A session
    // sourced from a Visualforce page's {!$Api.Session_ID} IS API-enabled.
    // getContent() can't run after an HTTP callout in the same transaction, so
    // the @AuraEnabled entry points pre-warm this before any callout fires.
    // Cached per transaction. Falls back to UserInfo on any failure (and in
    // tests, where getContent() is unsupported).
    @TestVisible private static String apiSessionId;
    private static String getApiSessionId() {
        if (String.isNotBlank(apiSessionId)) return apiSessionId;
        if (!Test.isRunningTest()) {
            try {
                String sid = Page.StoryMcaSession.getContent().toString().trim();
                if (String.isNotBlank(sid)) { apiSessionId = sid; return apiSessionId; }
            } catch (Exception e) { /* fall back */ }
        }
        apiSessionId = UserInfo.getSessionId();
        return apiSessionId;
    }

    private static HttpResponse send(String method, String path, String bodyJson) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + path);
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer ' + getApiSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        if (bodyJson != null) req.setBody(bodyJson);
        return new Http().send(req);
    }

    private static Map<String, Object> okJson(HttpResponse res, String action) {
        Integer sc = res.getStatusCode();
        if (sc < 200 || sc >= 300) {
            throw new ExportException(action + ' failed (' + sc + '): ' + res.getBody());
        }
        Object parsed = JSON.deserializeUntyped(res.getBody());
        return (parsed instanceof Map<String, Object>) ? (Map<String, Object>) parsed : new Map<String, Object>();
    }

    // ---- target space resolution (QBrix-portable) --------------------------
    // No hardcoded space. Default = the content space that already holds the most
    // MC email content (the active BU's default email workspace). Falls back to a
    // "Marketing Cloud"-named CMS space, else the first space. Override via the
    // `spaceId` static (or a future per-org setting) to target a specific BU.
    @TestVisible
    private static String resolveSpaceId() {
        if (String.isNotBlank(spaceId)) return spaceId;
        List<AggregateResult> ars = [
            SELECT AuthoredManagedContentSpaceId sid, COUNT(Id) n
            FROM ManagedContent
            WHERE ContentTypeFullyQualifiedName = 'sfdc_cms__email'
            GROUP BY AuthoredManagedContentSpaceId
            ORDER BY COUNT(Id) DESC LIMIT 1
        ];
        if (!ars.isEmpty() && ars[0].get('sid') != null) {
            return String.valueOf(ars[0].get('sid'));
        }
        // Fresh org with no email yet — pick a CMS space by name.
        HttpResponse res = send('GET', '/services/data/v62.0/connect/cms/spaces', null);
        if (res.getStatusCode() == 200) {
            Map<String, Object> j = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Object sp = j.get('spaces');
            if (sp instanceof List<Object> && !((List<Object>) sp).isEmpty()) {
                List<Object> spaces = (List<Object>) sp;
                String fallback;
                for (Object o : spaces) {
                    Map<String, Object> m = (Map<String, Object>) o;
                    String id = String.valueOf(m.get('id'));
                    String nm = String.valueOf(m.get('name'));
                    if (fallback == null) fallback = id;
                    if (nm != null && nm.toLowerCase().contains('marketing cloud')) return id;
                }
                if (fallback != null) return fallback;
            }
        }
        throw new ExportException('No Marketing Cloud content space found in this org to create the email in.');
    }

    @TestVisible
    private static String apiName(String s) {
        if (String.isBlank(s)) return 'Email';
        String a = s.replaceAll('[^A-Za-z0-9]+', '_').replaceAll('^_+|_+$', '');
        if (a.length() == 0) a = 'Email';
        if (a.substring(0, 1).isNumeric()) a = 'E' + a;
        return a.length() > 60 ? a.substring(0, 60) : a;
    }

    /** CMS urlName slug: lowercase, hyphen-separated, no leading digit. */
    @TestVisible
    private static String slug(String s) {
        if (String.isBlank(s)) return 'email';
        String a = s.toLowerCase().replaceAll('[^a-z0-9]+', '-').replaceAll('^-+|-+$', '');
        if (a.length() == 0) a = 'email';
        if (a.substring(0, 1).isNumeric()) a = 'e-' + a;
        return a.length() > 80 ? a.substring(0, 80) : a;
    }

    // ---- contentBody builder ------------------------------------------------

    // Set by buildBlocks when a hero image block is emitted, so we can wire its
    // Dynamic Content operation/variant.
    private static String heroBlockId;
    private static String heroContentKey;

    // Personalization Point + decision the hero's Dynamic Content binds to. These
    // are meshmesh demo values (a PP/decision created once in the builder); blank
    // them to skip DC wiring. QBrix portability: create or let the SE pick a PP.
    @TestVisible private static String dcPointName   = 'October_5_image_efb5_c_v_1650';
    @TestVisible private static String dcDecision    = 'Hero_2_1650';
    @TestVisible private static String dcDataspace   = 'default';
    // Image for the hero's second variation (so it visibly differs from the
    // default). Blank -> variation reuses the default image as a placeholder.
    @TestVisible private static String dcVariantImageUrl = 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1784760107/experience-generator/weg2v6yofhlu0gkszudd.jpg';

    @TestVisible
    private static Map<String, Object> buildEmailContentBody(Map<String, Object> c, String title) {
        heroBlockId = null; heroContentKey = null;
        List<Object> children = buildBlocks(c);

        Map<String, Object> body = new Map<String, Object>{
            // Neutral canvas (brand color stays in the header bar, not the whole bg).
            'backgroundColor' => '#f3f3f3',
            // No brand source — leave the builder's Brand picker empty so the SE
            // chooses (defaulting to a specific brand would be misleading).
            'lightning:dataProviders' => new List<Object>{
                new Map<String, Object>{
                    'attributes' => new Map<String, Object>{ 'objectApiName' => 'UnifiedIndividual__dlm' },
                    'definition' => 'sfdc_cms__unifiedIndividualDataProvider',
                    'sfdcExpressionKey' => '$unifiedIndividual'
                },
                new Map<String, Object>{
                    'attributes' => new Map<String, Object>{ 'dataGraphApiName' => dataGraph, 'dataspace' => 'default' },
                    'definition' => 'sfdc_cms__dataGraphDataProvider',
                    'sfdcExpressionKey' => '$dataGraph'
                }
            },
            'lightning:expressions' => new List<Object>(),
            'lightning:padding' => '{!$brand.spacing.none}',
            'messagePurpose' => 'promotional',
            'preheader' => str(c, 'subHeadline', str(c, 'headline', title)),
            'subjectLine' => str(c, 'subjectLine', title),
            'sfdc_cms:attachments' => new List<Object>(),
            'sfdc_cms:title' => title,
            'sfdc_cms:urlName' => slug(title),
            'sfdc_cms:block' => new Map<String, Object>{
                'definition' => 'sfdc_cms/rootContentBlock',
                'id' => genId(),
                'type' => 'block',
                'children' => children
            }
        };

        // Pre-enable Dynamic Content on the hero: a variant operation bound to the
        // personalization point/decision, plus a placeholder second variation
        // (same image by default — the SE swaps it live in the builder).
        if (String.isNotBlank(heroBlockId) && String.isNotBlank(heroContentKey)
                && String.isNotBlank(dcPointName) && String.isNotBlank(dcDecision)) {
            String variantId = genId();
            // Second variation image (distinct from default when configured).
            String variantKey = heroContentKey;
            if (String.isNotBlank(dcVariantImageUrl)) {
                String vk = createImageMedia(dcVariantImageUrl, 'Hero variation 2');
                if (String.isNotBlank(vk)) variantKey = vk;
            }
            body.put('sfdc_cms:operations', new List<Object>{
                new Map<String, Object>{
                    'definition' => 'sfdc_cms__pspVariantOperation',
                    'targetId' => heroBlockId,
                    'attributes' => new Map<String, Object>{
                        'personalizationPoint' => new Map<String, Object>{ 'dataspace' => dcDataspace, 'name' => dcPointName },
                        'decisionToVariantList' => new List<Object>{
                            new Map<String, Object>{ 'decisionName' => dcDecision, 'variantId' => variantId }
                        }
                    }
                }
            });
            body.put('sfdc_cms:variants', new List<Object>{
                new Map<String, Object>{
                    'id' => variantId,
                    'name' => 'Variation 2',
                    'type' => 'personalization',
                    'body' => new Map<String, Object>{
                        'sfdc_cms:block' => new Map<String, Object>{
                            'children' => new List<Object>{ imageBlock(variantKey, heroBlockId) }
                        }
                    }
                }
            });
        }
        return body;
    }

    // Turn the ordered sections into MCA blocks: HTML blocks for everything,
    // except the hero (marked "IMG::<url>") which becomes a NATIVE lightning/image
    // block so the MCA builder treats it as a real image with Dynamic Content.
    @TestVisible
    private static List<Object> buildBlocks(Map<String, Object> c) {
        List<Object> out = new List<Object>();
        for (String sec : sectionHtml(c)) {
            if (String.isBlank(sec)) continue;
            if (sec.startsWith('IMG::')) {
                String url = sec.substring(5);
                String contentKey = createImageMedia(url, str(c, 'brandName', 'Hero') + ' hero');
                if (String.isNotBlank(contentKey)) {
                    heroBlockId = genId();
                    heroContentKey = contentKey;
                    out.add(imageBlock(contentKey, heroBlockId));
                } else {
                    // Fallback to an HTML img if media creation failed.
                    out.add(htmlBlock('<img src="' + esc(url) + '" alt="" style="width:100%;display:block" />'));
                }
            } else {
                out.add(htmlBlock(sec));
            }
        }
        return out;
    }

    // Create an sfdc_cms__image from an absolute URL (platform fetches it) and
    // return its contentKey (apiName) for a native image block to reference.
    private static String createImageMedia(String url, String title) {
        if (String.isBlank(url) || !(url.toLowerCase().startsWith('http'))) return '';
        Map<String, Object> payload = new Map<String, Object>{
            'contentSpaceOrFolderId' => resolveSpaceId(),
            'contentType' => 'sfdc_cms__image',
            'title' => title,
            'urlName' => slug(title) + '-' + String.valueOf(Datetime.now().getTime()),
            'contentBody' => new Map<String, Object>{
                'sfdc_cms:media' => new Map<String, Object>{
                    'source' => new Map<String, Object>{ 'type' => 'url', 'url' => url }
                }
            }
        };
        try {
            HttpResponse res = send('POST', CMS_PATH, JSON.serialize(payload));
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                Object parsed = JSON.deserializeUntyped(res.getBody());
                if (parsed instanceof Map<String, Object>) {
                    Object ak = ((Map<String, Object>) parsed).get('apiName');
                    if (ak != null) return String.valueOf(ak);
                }
            }
        } catch (Exception e) { /* fall back */ }
        return '';
    }

    // Native image block referencing a CMS image by contentKey (full-width hero).
    // id is passed so the base block and its Dynamic-Content variant can share it.
    private static Map<String, Object> imageBlock(String contentKey, String blockId) {
        return new Map<String, Object>{
            'definition' => 'lightning/image',
            'id' => blockId,
            'type' => 'block',
            'attributes' => new Map<String, Object>{
                'imageFitConfig' => new Map<String, Object>{ 'width' => new Map<String, Object>{ 'unit' => '%', 'value' => 100 } },
                'imageInfo' => new Map<String, Object>{
                    'altText' => '', 'overrideAltText' => false,
                    'source' => new Map<String, Object>{
                        'type' => 'imageReference',
                        'ref' => new Map<String, Object>{ 'contentKey' => contentKey }
                    },
                    'url' => '/cms/media/' + contentKey
                },
                'lightning:horizontalAlignment' => 'center'
            }
        };
    }

    // Each logical section becomes its own lightning/html block (an individually
    // editable component in the MCA builder). Tokens are resolved to literal
    // brand/recipient text for v1.
    @TestVisible
    private static List<String> sectionHtml(Map<String, Object> c) {
        String brand = str(c, 'brandName', 'Your Brand');
        String primary = str(c, 'primaryColor', '#0A1F44');
        String accent = str(c, 'featureSectionColor', primary);
        String logo = resolveImg(str(c, 'logoUrl', ''));
        String first = str(c, 'customerFirstName', 'there');

        String headColor = str(c, 'headlineTextColor', '#FFFFFF');
        List<String> out = new List<String>();

        // 1) Logo — on the sim's Logo Background Color (handles transparent-PNG
        // logos; it's a per-sim branding input, not a fixed white).
        String logoBg = str(c, 'logoBgColor', '#ffffff');
        String logoW = str(c, 'logoWidth', '180');
        if (!logoW.contains('px') && !logoW.contains('%')) logoW += 'px';
        String logoTextColor = isDark(logoBg) ? '#ffffff' : esc(primary);
        String logoImg = String.isBlank(logo)
            ? ('<span style="color:' + logoTextColor + ';font:700 24px Arial">' + esc(brand) + '</span>')
            : ('<img src="' + esc(logo) + '" alt="' + esc(brand) + '" style="width:' + esc(logoW) + ';max-width:70%;height:auto;display:block;margin:0 auto" />');
        out.add('<div style="background:' + esc(logoBg) + ';padding:24px;text-align:center">' + logoImg + '</div>');

        // 2) Headline in a brand-color bar
        String head = tok(str(c, 'headline', ''), brand, first);
        if (String.isNotBlank(head)) {
            out.add('<div style="background:' + esc(primary) + ';padding:18px 24px;text-align:center">'
                + '<h1 style="margin:0;color:' + esc(headColor) + ';font:700 24px Arial">' + esc(head) + '</h1></div>');
        }

        // 3) Hero — marked so buildBlocks emits it as a NATIVE image block
        // (Dynamic-Content-capable), not an HTML img.
        String hero = resolveImg(str(c, 'heroImageUrl', ''));
        if (String.isNotBlank(hero)) {
            out.add('IMG::' + hero);
        }

        // 4) Feature 2-column (accent bar), before the body
        String f1 = tok(str(c, 'featureColumn1', ''), brand, first);
        String f2 = tok(str(c, 'featureColumn2', ''), brand, first);
        if (String.isNotBlank(f1) || String.isNotBlank(f2)) {
            String tc = str(c, 'featureColumnTextColor', '#FFFFFF');
            String col = '<td width="50%" valign="top" style="padding:18px;color:' + esc(tc) + ';font:14px/1.5 Arial">';
            out.add('<table width="100%" cellpadding="0" cellspacing="0" style="background:' + esc(accent) + '"><tr>'
                + col + esc(f1) + '</td>' + col + esc(f2) + '</td></tr></table>');
        }

        // 5) Subheadline (bold, centered)
        String sub = tok(str(c, 'subHeadline', ''), brand, first);
        if (String.isNotBlank(sub)) {
            out.add('<div style="padding:24px 24px 4px;text-align:center">'
                + '<p style="margin:0;font:700 18px Arial;color:#1a1a1a">' + esc(sub) + '</p></div>');
        }

        // 6) Body paragraphs
        String bodyRaw = tok(str(c, 'bodyParagraph', ''), brand, first);
        if (String.isNotBlank(bodyRaw)) {
            String paras = '';
            for (String p : bodyRaw.split('\\n\\n+')) {
                if (String.isNotBlank(p)) paras += '<p style="margin:0 0 16px;font:14px/1.6 Arial;color:#393939">' + esc(p.trim()) + '</p>';
            }
            out.add('<div style="padding:16px 24px 0">' + paras + '</div>');
        }

        // 7) Bullets
        Object sbRaw = c.get('showBullets');
        Boolean showBullets = (sbRaw == null) ? true : (sbRaw == true);
        if (showBullets) {
            String lis = '';
            for (String k : new List<String>{ 'bullet1', 'bullet2', 'bullet3' }) {
                String bl = tok(str(c, k, ''), brand, first);
                if (String.isNotBlank(bl)) lis += '<li style="margin:0 0 8px">' + esc(bl) + '</li>';
            }
            if (String.isNotBlank(lis)) out.add('<ul style="padding:8px 40px;font:14px/1.6 Arial;color:#393939">' + lis + '</ul>');
        }

        // 8) Reply prompt (the AI-concierge invite)
        String rpH = tok(str(c, 'replyPromptHeadline', ''), brand, first);
        String rpB = tok(str(c, 'replyPromptBody', ''), brand, first);
        if (String.isNotBlank(rpH) || String.isNotBlank(rpB)) {
            String r = '<div style="padding:12px 24px">';
            if (String.isNotBlank(rpH)) r += '<p style="margin:0 0 4px;font:700 14px Arial;color:#1a1a1a">💬 ' + esc(rpH) + '</p>';
            if (String.isNotBlank(rpB)) r += '<p style="margin:0;font:14px/1.6 Arial;color:#393939">' + esc(rpB) + '</p>';
            out.add(r + '</div>');
        }

        // 9) Signature
        out.add('<div style="padding:12px 24px 0"><p style="margin:0;font:14px/1.6 Arial;color:#393939">Best,<br>' + esc(brand) + '</p></div>');

        // 10) CTA button
        String cta = tok(str(c, 'ctaButtonText', ''), brand, first);
        if (String.isNotBlank(cta)) {
            String cc = str(c, 'ctaButtonColor', primary);
            out.add('<div style="padding:20px 24px 28px;text-align:center"><a href="#" '
                + 'style="display:inline-block;background:' + esc(cc) + ';color:#fff;text-decoration:none;'
                + 'padding:14px 32px;border-radius:24px;font:700 15px Arial">' + esc(cta) + '</a></div>');
        }

        // 11) Footer
        out.add('<div style="padding:20px 24px;text-align:center;color:#999;font:12px Arial">© ' + esc(brand) + '. All rights reserved.</div>');

        return out;
    }

    private static Map<String, Object> htmlBlock(String rawHtml) {
        // rawHtml only — no {!$brand...} refs, since the email is brand-agnostic
        // (self-contained inline styles) and has no brand source to resolve them.
        return new Map<String, Object>{
            'definition' => 'lightning/html',
            'id' => genId(),
            'type' => 'block',
            'attributes' => new Map<String, Object>{ 'rawHtml' => rawHtml }
        };
    }

    // [[BRAND_NAME]] / [[CUSTOMER_FIRST_NAME]] -> literal text (v1).
    private static String tok(String s, String brand, String first) {
        if (s == null) return '';
        return s.replace('[[BRAND_NAME]]', brand).replace('[[CUSTOMER_FIRST_NAME]]', first);
    }

    // Make an image render inside an MCA email HTML block, which only accepts
    // ABSOLUTE http(s) URLs (the sanitizer strips data: URIs; relative /sfc/ URLs
    // can't be served cross-context). Absolute URLs pass through; a /sfc/
    // ContentVersion is re-hosted to an absolute Cloudinary URL (same unsigned
    // cloud/preset Story Studio already uses). Anything else returns '' and the
    // caller falls back gracefully (logo -> brand-name text, hero -> omitted).
    private static Map<String, String> imgCache = new Map<String, String>();
    private static String resolveImg(String url) {
        if (String.isBlank(url)) return '';
        String u = url.trim();
        String lower = u.toLowerCase();
        if (lower.startsWith('http://') || lower.startsWith('https://')) return u;
        if (imgCache.containsKey(u)) return imgCache.get(u);
        String resolved = '';
        Matcher m = Pattern.compile('(?i)/sfc/servlet\\.shepherd/version/download/([a-zA-Z0-9]{15,18})').matcher(u);
        if (m.find()) {
            try {
                Id cvId = (Id) m.group(1);
                for (ContentVersion cv : [SELECT VersionData, FileType, ContentSize FROM ContentVersion WHERE Id = :cvId LIMIT 1]) {
                    if (cv.VersionData != null && cv.ContentSize != null && cv.ContentSize <= 10000000) {
                        String hosted = uploadToCloudinary(cv.VersionData, cv.FileType);
                        if (String.isNotBlank(hosted)) resolved = hosted;
                    }
                }
            } catch (Exception e) { /* fall back to '' */ }
        }
        imgCache.put(u, resolved);
        return resolved;
    }

    // Cloudinary unsigned upload (cloud dfx98jgdc / preset salesforcepersonalization,
    // the same one Story Studio uses). Returns the absolute secure_url, or '' on
    // failure. Requires the Cloudinary Remote Site Setting.
    @TestVisible private static String cloudinaryCloud  = 'dfx98jgdc';
    @TestVisible private static String cloudinaryPreset = 'salesforcepersonalization';
    private static String uploadToCloudinary(Blob data, String fileType) {
        String ft = (fileType == null ? 'PNG' : fileType).toLowerCase();
        String mime = ft == 'jpg' || ft == 'jpeg' ? 'image/jpeg' : ft == 'gif' ? 'image/gif' : ft == 'svg' ? 'image/svg+xml' : ft == 'webp' ? 'image/webp' : 'image/png';
        String dataUri = 'data:' + mime + ';base64,' + EncodingUtil.base64Encode(data);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.cloudinary.com/v1_1/' + cloudinaryCloud + '/image/upload');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
        req.setBody('upload_preset=' + EncodingUtil.urlEncode(cloudinaryPreset, 'UTF-8')
            + '&file=' + EncodingUtil.urlEncode(dataUri, 'UTF-8'));
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            Object parsed = JSON.deserializeUntyped(res.getBody());
            if (parsed instanceof Map<String, Object>) {
                Object su = ((Map<String, Object>) parsed).get('secure_url');
                if (su != null) return String.valueOf(su);
            }
        }
        return '';
    }

    private static String esc(String s) {
        if (s == null) return '';
        return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;');
    }

    // Perceived-luminance check so brand-name text is readable on the logo bg.
    private static Boolean isDark(String hex) {
        String h = (hex == null ? '' : hex.trim()).replace('#', '').toLowerCase();
        if (h.length() == 3) h = h.substring(0,1).repeat(2) + h.substring(1,2).repeat(2) + h.substring(2,3).repeat(2);
        if (h.length() < 6) return false;
        try {
            Decimal lum = 0.299 * hex2(h.substring(0,2)) + 0.587 * hex2(h.substring(2,4)) + 0.114 * hex2(h.substring(4,6));
            return lum < 140;
        } catch (Exception e) { return false; }
    }
    private static Integer hex2(String s) {
        String d = '0123456789abcdef';
        return d.indexOf(s.substring(0,1)) * 16 + d.indexOf(s.substring(1,2));
    }

    private static String str(Map<String, Object> c, String k, String dflt) {
        Object v = c.get(k);
        return (v == null || String.isBlank(String.valueOf(v))) ? dflt : String.valueOf(v);
    }

    // uuid-shaped id, unique within the document.
    private static String genId() {
        String h = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        return h.substring(0,8) + '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20,32);
    }
}
