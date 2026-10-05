/**
 * Renders a Demo_Story__c's 2-way email as full HTML for the Visualforce preview
 * page (StoryEmailPreview). Lightning Web Security blocks srcdoc/blob/data iframe
 * content, so the Story Studio preview iframe loads a relative /apex/ URL instead;
 * this controller produces that page's body from the story's saved Config_JSON__c
 * by token-substituting over the demoStoryEmailTemplate static resource.
 */
public with sharing class StoryEmailPreviewController {

    // Test seam. PageReference.getContent() (used to load the static-resource
    // template) is not supported in test context, so tests set this to a small
    // template string and getHtml() uses it instead. Only consulted under
    // Test.isRunningTest(). Mirrors EinsteinProvider.mockGeneratedText.
    @TestVisible
    private static String mockTemplate;

    // When ?download=1, set a filename so the browser downloads the HTML instead
    // of rendering it inline (used by the Story Studio "Download HTML" button).
    public String getPageContentType() {
        String dl = ApexPages.currentPage().getParameters().get('download');
        if (dl != '1') return 'text/html';
        String id = ApexPages.currentPage().getParameters().get('id');
        String brand = 'brand';
        String channel = 'email';
        if (String.isNotBlank(id)) {
            for (Two_Way_Simulator__c s : [SELECT Brand__c, Channel__c, Config_JSON__c FROM Two_Way_Simulator__c WHERE Id = :id LIMIT 1]) {
                if (String.isNotBlank(s.Brand__c)) {
                    brand = s.Brand__c;
                } else if (String.isNotBlank(s.Config_JSON__c)) {
                    try {
                        Map<String, Object> c = (Map<String, Object>) JSON.deserializeUntyped(s.Config_JSON__c);
                        if (c.get('brandName') != null) brand = String.valueOf(c.get('brandName'));
                    } catch (Exception e) {}
                }
                if (String.isNotBlank(s.Channel__c)) channel = s.Channel__c;
            }
        }
        String slug = (brand + '_' + channel).replaceAll('[^A-Za-z0-9]+', '-').replaceAll('^-|-$', '');
        String d = Datetime.now().format('yyyy-MM-dd');
        return 'text/html#2-way_' + slug + '_' + d + '.html';
    }

    public String getHtml() {
        String storyId = ApexPages.currentPage().getParameters().get('id');
        if (String.isBlank(storyId)) return '<p style="font-family:Arial">No story id.</p>';

        Map<String, Object> c = new Map<String, Object>();
        String channel = 'Email';
        for (Two_Way_Simulator__c s : [SELECT Channel__c, Config_JSON__c FROM Two_Way_Simulator__c WHERE Id = :storyId LIMIT 1]) {
            if (String.isNotBlank(s.Channel__c)) channel = s.Channel__c;
            if (String.isNotBlank(s.Config_JSON__c)) {
                try { c = (Map<String, Object>) JSON.deserializeUntyped(s.Config_JSON__c); } catch (Exception e) {}
            }
        }
        // The saved config carries its own channel; prefer it if present (keeps
        // preview + record in sync even if the field hasn't refreshed yet).
        if (c.get('channel') != null && String.isNotBlank(String.valueOf(c.get('channel')))) {
            channel = String.valueOf(c.get('channel'));
        }

        // Resolve every injected image URL to something that loads outside the
        // Lightning domain. A brand logo/avatar is often a RELATIVE Salesforce
        // `/sfc/servlet.shepherd/version/download/<CV>` URL, which 404s both in
        // the cross-domain *.vf.force.com preview iframe AND in downloaded HTML
        // (resolves to file:///sfc/...). We inline such ContentVersion images as
        // base64 data URIs (work offline + cross-domain, no session) and absolute-
        // prefix any other relative URL. Absolute http(s)/data URLs pass through.
        resolveConfigImages(c);

        // Pick the ported template + renderer by channel. Email is the default
        // and its behavior is unchanged; SMS/WhatsApp/RCS are additive branches.
        String ch = channel == null ? 'email' : channel.toLowerCase();
        String resource = 'demoStoryEmailTemplate';
        if (ch == 'sms') resource = 'demoStorySmsTemplate';
        else if (ch == 'whatsapp') resource = 'demoStoryWhatsappTemplate';
        else if (ch == 'rcs') resource = 'demoStoryRcsTemplate';

        String tpl;
        if (Test.isRunningTest() && mockTemplate != null) {
            tpl = mockTemplate;
        } else {
            try { tpl = new PageReference('/resource/' + resource).getContent().toString(); }
            catch (Exception e) { return '<p style="font-family:Arial">Template load failed: ' + e.getMessage() + '</p>'; }
        }

        if (ch == 'sms') return renderSms(tpl, c);
        else if (ch == 'whatsapp') return renderWhatsapp(tpl, c);
        else if (ch == 'rcs') return renderRcs(tpl, c);
        return renderEmail(tpl, c);
    }

    private static String str(Map<String, Object> c, String k, String dflt) {
        Object v = c.get(k);
        return v == null ? dflt : String.valueOf(v);
    }

    // ----------------------------------------------------------------------
    // Image-URL resolution — see getHtml(). Relative /sfc/ ContentVersion URLs
    // are inlined as base64 data URIs; other relative URLs are absolute-prefixed.
    // ----------------------------------------------------------------------

    // Max ContentVersion size we inline as base64. The data URI can appear
    // several times in one page (header banner + card), and getHtml() runs in
    // the 6 MB synchronous VF heap, so keep this modest — brand logos/avatars
    // (the only /sfc/ images we inline) are small; larger assets fall back to an
    // absolute core-domain URL.
    private static final Integer MAX_INLINE_BYTES = 800000;

    // Dedupe cache so the same logo across header + card is only queried once.
    private static Map<String, String> resolvedUrlCache = new Map<String, String>();

    // Config keys that hold a single image URL (resolved in place).
    private static final List<String> IMG_KEYS = new List<String>{
        'logoUrl', 'marketingAvatarUrl', 'customerAvatarUrl', 'agentAvatarUrl', 'heroImageUrl'
    };

    @TestVisible
    private static void resolveConfigImages(Map<String, Object> c) {
        if (c == null || c.isEmpty()) return;
        for (String k : IMG_KEYS) {
            Object v = c.get(k);
            if (v != null && String.isNotBlank(String.valueOf(v))) {
                c.put(k, resolveImgUrl(String.valueOf(v)));
            }
        }
        // Rich-card / carousel media URLs inside the RCS/messaging thread.
        Object m = c.get('messages');
        if (m instanceof List<Object>) {
            for (Object o : (List<Object>) m) {
                if (!(o instanceof Map<String, Object>)) continue;
                Map<String, Object> msg = (Map<String, Object>) o;
                resolveCardMedia(msg.get('card'));
                Object cards = msg.get('cards');
                if (cards instanceof List<Object>) {
                    for (Object co : (List<Object>) cards) resolveCardMedia(co);
                }
            }
        }
    }

    private static void resolveCardMedia(Object cardObj) {
        if (!(cardObj instanceof Map<String, Object>)) return;
        Map<String, Object> card = (Map<String, Object>) cardObj;
        Object mu = card.get('mediaUrl');
        if (mu != null && String.isNotBlank(String.valueOf(mu))) {
            card.put('mediaUrl', resolveImgUrl(String.valueOf(mu)));
        }
    }

    // Turn any image URL into one that loads cross-domain / offline.
    @TestVisible
    private static String resolveImgUrl(String url) {
        if (String.isBlank(url)) return url;
        String u = url.trim();
        if (resolvedUrlCache.containsKey(u)) return resolvedUrlCache.get(u);
        String resolved = u;
        String lower = u.toLowerCase();
        if (lower.startsWith('http://') || lower.startsWith('https://') || lower.startsWith('data:')) {
            // Already absolute / inline — nothing to do.
            resolved = u;
        } else {
            // Extract a ContentVersion id from a shepherd download URL and inline
            // the bytes; fall back to an absolute core-domain URL on any failure.
            Id cvId = contentVersionIdFrom(u);
            String dataUri = (cvId == null) ? null : inlineContentVersion(cvId);
            resolved = (dataUri != null) ? dataUri : absolutize(u);
        }
        resolvedUrlCache.put(u, resolved);
        return resolved;
    }

    // Pull the 15/18-char ContentVersion id out of a
    // /sfc/servlet.shepherd/version/download/<id>[?params] URL.
    private static Id contentVersionIdFrom(String u) {
        Matcher mm = Pattern.compile('(?i)/sfc/servlet\\.shepherd/version/download/([a-zA-Z0-9]{15,18})').matcher(u);
        if (!mm.find()) return null;
        try { return (Id) mm.group(1); } catch (Exception e) { return null; }
    }

    private static String inlineContentVersion(Id cvId) {
        try {
            for (ContentVersion cv : [
                SELECT VersionData, FileType, ContentSize
                FROM ContentVersion WHERE Id = :cvId LIMIT 1
            ]) {
                if (cv.VersionData == null || cv.ContentSize == null || cv.ContentSize > MAX_INLINE_BYTES) return null;
                return 'data:' + mimeForFileType(cv.FileType) + ';base64,' + EncodingUtil.base64Encode(cv.VersionData);
            }
        } catch (Exception e) {
            // No access / not found — fall back to absolute URL.
        }
        return null;
    }

    private static String mimeForFileType(String fileType) {
        String ft = fileType == null ? '' : fileType.toUpperCase();
        if (ft == 'PNG') return 'image/png';
        if (ft == 'JPG' || ft == 'JPEG') return 'image/jpeg';
        if (ft == 'GIF') return 'image/gif';
        if (ft == 'SVG') return 'image/svg+xml';
        if (ft == 'WEBP') return 'image/webp';
        return 'image/png';
    }

    // Prefix a root-relative URL with the org base domain so it is absolute.
    private static String absolutize(String u) {
        if (!u.startsWith('/')) return u;
        try { return URL.getOrgDomainUrl().toExternalForm() + u; }
        catch (Exception e) { return u; }
    }

    private static String initials(String s) {
        if (String.isBlank(s)) return '';
        String out = '';
        for (String w : s.trim().split('\\s+')) { if (w.length() > 0) out += w.substring(0, 1); }
        return out.length() > 2 ? out.substring(0, 2).toUpperCase() : out.toUpperCase();
    }

    private static String renderEmail(String tpl, Map<String, Object> c) {
        String name = str(c, 'customerName', 'Rachel Green');
        String first = str(c, 'customerFirstName', name.split(' ')[0]);
        String agent = str(c, 'agentName', 'Penny');
        Object sb = c.get('showBullets');
        Boolean showBullets = (sb == null) ? true : (sb == true);

        // body paragraphs -> <p> blocks, with first-name token resolved
        String bodyRaw = str(c, 'bodyParagraph', '').replace('[[CUSTOMER_FIRST_NAME]]', first);
        String body = '';
        for (String p : bodyRaw.split('\\n\\n+')) {
            if (String.isNotBlank(p)) {
                body += '<p style="font-size:14px;line-height:1.6;color:#393939;margin:0 0 16px 0;">' + p.trim() + '</p>';
            }
        }

        // messages JSON for [[EMAIL_MESSAGES_ARRAY]]
        List<Object> msgs = new List<Object>();
        Object m = c.get('messages');
        if (m instanceof List<Object>) {
            for (Object o : (List<Object>) m) {
                Map<String, Object> mm = (Map<String, Object>) o;
                msgs.add(new Map<String, Object>{ 'sender' => mm.get('sender'), 'text' => mm.get('text') });
            }
        }
        String msgsJson = JSON.serialize(msgs).replace('<', '\\u003c').replace('>', '\\u003e').replace('&', '\\u0026');

        Map<String, String> tok = new Map<String, String>{
            'BRAND_NAME' => str(c, 'brandName', 'Cumulus Financial'),
            'BRAND_DOMAIN' => str(c, 'brandDomain', 'cumulusfinserv.com'),
            'LOGO_URL' => str(c, 'logoUrl', ''),
            'LOGO_BG_COLOR' => str(c, 'logoBgColor', '#0A1F44'),
            'LOGO_WIDTH' => str(c, 'logoWidth', '140'),
            'PRIMARY_COLOR' => str(c, 'primaryColor', '#0A1F44'),
            'HERO_IMAGE_URL' => str(c, 'heroImageUrl', ''),
            'SUBJECT_LINE' => str(c, 'subjectLine', ''),
            'HEADLINE' => str(c, 'headline', ''),
            'HEADLINE_TEXT_COLOR' => str(c, 'headlineTextColor', '#FFFFFF'),
            'SUB_HEADLINE' => str(c, 'subHeadline', ''),
            'BODY_PARAGRAPH' => body,
            'CTA_BUTTON_TEXT' => str(c, 'ctaButtonText', 'Learn more'),
            'CTA_BUTTON_COLOR' => str(c, 'ctaButtonColor', '#0A1F44'),
            'FEATURE_SECTION_COLOR' => str(c, 'featureSectionColor', '#0A1F44'),
            'FEATURE_COLUMN_TEXT_COLOR' => str(c, 'featureColumnTextColor', '#FFFFFF'),
            'BULLETS_DISPLAY' => showBullets ? '' : 'display:none;',
            'BULLET_1' => str(c, 'bullet1', ''),
            'BULLET_2' => str(c, 'bullet2', ''),
            'BULLET_3' => str(c, 'bullet3', ''),
            'AGENT_NAME' => agent,
            'AGENT_INITIALS' => initials(agent),
            'MARKETING_INITIALS' => initials(agent),
            'AGENT_AVATAR_URL' => str(c, 'agentAvatarUrl', ''),
            'MARKETING_AVATAR_URL' => str(c, 'marketingAvatarUrl', ''),
            'CUSTOMER_AVATAR_URL' => str(c, 'customerAvatarUrl', ''),
            'CUSTOMER_NAME' => name,
            'CUSTOMER_FIRST_NAME' => first,
            'CUSTOMER_INITIALS' => initials(name),
            'CUSTOMER_EMAIL' => str(c, 'customerEmail', ''),
            'CUSTOMER_TITLE' => str(c, 'customerTitle', ''),
            'CUSTOMER_COMPANY' => str(c, 'customerCompany', ''),
            'CUSTOMER_MOBILE' => str(c, 'customerMobile', ''),
            'REPLY_PROMPT_HEADLINE' => str(c, 'replyPromptHeadline', ''),
            'REPLY_PROMPT_BODY' => str(c, 'replyPromptBody', ''),
            'EMAIL_MESSAGES_ARRAY' => msgsJson,
            'FEATURE_COLUMN_1' => str(c, 'featureColumn1', 'Round up every purchase'),
            'FEATURE_COLUMN_2' => str(c, 'featureColumn2', 'Grow savings automatically')
        };
        String out = tpl;
        for (String k : tok.keySet()) {
            out = out.replace('[[' + k + ']]', tok.get(k) == null ? '' : tok.get(k));
        }
        // Resolve brand tokens nested inside inserted body/feature copy (the
        // default copy uses [[BRAND_NAME]] so it re-brands when the kit changes).
        out = out.replace('[[BRAND_NAME]]', tok.get('BRAND_NAME') == null ? '' : tok.get('BRAND_NAME'));
        out = out.replace('[[BRAND_DOMAIN]]', tok.get('BRAND_DOMAIN') == null ? '' : tok.get('BRAND_DOMAIN'));
        // Remove broken <img> tags whose src resolved to empty (no logo/hero set).
        out = out.replaceAll('(?i)<img[^>]{0,600}src="\\s*"[^>]{0,600}>', '');
        // Scripts are KEPT so the 2-way Reply interactivity works in the preview.
        // The preview is a cross-domain Visualforce iframe, so the sim's JS runs in
        // its own frame. (If a future template's JS misbehaves, re-add a strip here.)
        return out;
    }

    // ----------------------------------------------------------------------
    // Messaging-channel helpers (shared by SMS / WhatsApp / RCS)
    // ----------------------------------------------------------------------

    // HTML-escape a string for safe injection into a messaging bubble.
    // Mirrors the Experience Generator's escapeHtmlForSms (script.js:6932).
    private static String escapeSms(String text) {
        if (text == null) return '';
        return text.replace('&', '&amp;').replace('<', '&lt;')
                   .replace('>', '&gt;').replace('"', '&quot;');
    }

    // Escape bubble text and turn newlines into <br> (script.js:6941 smsBubbleHtml).
    private static String smsBubble(String text) {
        return escapeSms(text).replace('\r\n', '\n').replace('\n', '<br>');
    }

    // Extract the shared {sender,text,imageUrl} message list from the config.
    private static List<Object> msgList(Map<String, Object> c) {
        Object m = c.get('messages');
        return (m instanceof List<Object>) ? (List<Object>) m : new List<Object>();
    }

    // Header title shown in the SMS/WhatsApp/RCS chat header. Uses an explicit
    // messagingAgentHeader if set, else composes "<Agent> (<Brand> AI Agent)".
    private static String messagingHeader(Map<String, Object> c) {
        String explicit = str(c, 'messagingAgentHeader', '');
        if (String.isNotBlank(explicit)) return explicit;
        String agent = str(c, 'agentName', 'Penny');
        String brand = str(c, 'brandName', 'Cumulus Financial');
        return agent + ' (' + brand + ' AI Agent)';
    }

    // Resolve brand/customer tokens that may appear inside message copy, the
    // same way renderEmail resolves [[BRAND_NAME]] over the whole output.
    private static String resolveSharedTokens(String out, Map<String, Object> c) {
        String name = str(c, 'customerName', 'Rachel Green');
        String first = str(c, 'customerFirstName', name.split(' ')[0]);
        return out
            .replace('[[BRAND_NAME]]', str(c, 'brandName', 'Cumulus Financial'))
            .replace('[[BRAND_DOMAIN]]', str(c, 'brandDomain', 'cumulusfinserv.com'))
            .replace('[[CUSTOMER_FIRST_NAME]]', first)
            .replace('[[CUSTOMER_NAME]]', name)
            .replace('[[AGENT_NAME]]', str(c, 'agentName', 'Penny'));
    }

    // ----------------------------------------------------------------------
    // SMS — Apple iMessage-style thread (ported from buildAppleSmsThreadHtml,
    // script.js:7199). Each row is one .message-group.hidden-msg; the ported
    // template's own tap-to-reveal script plays them one at a time.
    // ----------------------------------------------------------------------
    private static String renderSms(String tpl, Map<String, Object> c) {
        Map<String, String> tok = new Map<String, String>{
            'SMS_THREAD_HTML' => buildSmsThread(c),
            'SMS_THEME' => smsTheme(c),
            // The chat header is the agent you're texting — prefer the agent
            // avatar, fall back to the marketing sender avatar.
            'MARKETING_AVATAR_URL' => messagingHeaderAvatar(c),
            'MESSAGING_AGENT_HEADER' => messagingHeader(c)
        };
        String out = tpl;
        for (String k : tok.keySet()) {
            out = out.replace('[[' + k + ']]', tok.get(k) == null ? '' : tok.get(k));
        }
        out = resolveSharedTokens(out, c);
        // Remove the header avatar <img> if no avatar is set (grey circle shows).
        out = out.replaceAll('(?i)<img[^>]{0,600}src="\\s*"[^>]{0,600}>', '');
        // Scripts KEPT so tap-to-reveal plays the 2-way thread.
        return out;
    }

    private static String messagingHeaderAvatar(Map<String, Object> c) {
        String agentAv = str(c, 'agentAvatarUrl', '');
        return String.isNotBlank(agentAv) ? agentAv : str(c, 'marketingAvatarUrl', '');
    }

    private static String smsTheme(Map<String, Object> c) {
        // Shared across messaging channels (Studio exposes one Light/Dark control).
        String t = str(c, 'theme', 'light');
        return String.isBlank(t) ? 'light' : t;
    }

    private static String buildSmsThread(Map<String, Object> c) {
        String parts = '';
        for (Object o : msgList(c)) {
            if (!(o instanceof Map<String, Object>)) continue;
            Map<String, Object> m = (Map<String, Object>) o;
            String sender = String.valueOf(m.get('sender')) == 'user' ? 'user' : 'bot';
            String text = m.get('text') == null ? '' : String.valueOf(m.get('text'));
            String img = m.get('imageUrl') == null ? '' : String.valueOf(m.get('imageUrl'));
            if (String.isBlank(text) && String.isBlank(img)) continue;
            String rowAlign = sender == 'user' ? 'row-user' : 'row-bot';
            String skin = sender == 'user' ? 'bubble-user' : 'bubble-bot';
            String bubbles = '';
            if (String.isNotBlank(img) && String.isNotBlank(text)) {
                bubbles = smsBubbleEl(sender, skin, '<img class="msg-attached-image" src="' + escapeSms(img) + '" alt="" loading="lazy" referrerpolicy="no-referrer" />')
                      + smsBubbleEl(sender, skin, '<div class="msg-copy">' + smsBubble(text) + '</div>');
            } else if (String.isNotBlank(img)) {
                bubbles = smsBubbleEl(sender, skin, '<img class="msg-attached-image" src="' + escapeSms(img) + '" alt="" loading="lazy" referrerpolicy="no-referrer" />');
            } else {
                bubbles = smsBubbleEl(sender, skin, '<div class="msg-copy">' + smsBubble(text) + '</div>');
            }
            // Every bubble starts hidden; the template script plays them in
            // order — agent/marketing bubbles appear instantly, the recipient's
            // replies type out in the composer before posting (mirrors email).
            parts += '<div class="row ' + rowAlign + '" data-sender="' + sender
                   + '"><div class="message-group hidden-msg">' + bubbles + '</div></div>';
        }
        return parts;
    }

    private static String smsBubbleEl(String role, String skin, String content) {
        return '<div class="message ' + role + ' bubble ' + skin + '">' + content + '</div>';
    }

    // ----------------------------------------------------------------------
    // WhatsApp — ported from buildWhatsAppThreadHtml (script.js:7231). Same
    // config + playback engine as SMS; WhatsApp bubble skin + meta/checks.
    // ----------------------------------------------------------------------
    private static final String WHATSAPP_THREAD_TIME = '11:42 AM';

    private static String renderWhatsapp(String tpl, Map<String, Object> c) {
        Map<String, String> tok = new Map<String, String>{
            'WHATSAPP_THREAD_HTML' => buildWhatsappThread(c),
            'WHATSAPP_THEME' => smsTheme(c),
            'MARKETING_AVATAR_URL' => messagingHeaderAvatar(c),
            'MESSAGING_AGENT_HEADER' => messagingHeader(c)
        };
        String out = tpl;
        for (String k : tok.keySet()) {
            out = out.replace('[[' + k + ']]', tok.get(k) == null ? '' : tok.get(k));
        }
        out = resolveSharedTokens(out, c);
        out = out.replaceAll('(?i)<img[^>]{0,600}src="\\s*"[^>]{0,600}>', '');
        return out;
    }

    private static String buildWhatsappThread(Map<String, Object> c) {
        String ts = escapeSms(WHATSAPP_THREAD_TIME);
        String parts = '';
        for (Object o : msgList(c)) {
            if (!(o instanceof Map<String, Object>)) continue;
            Map<String, Object> m = (Map<String, Object>) o;
            String sender = String.valueOf(m.get('sender')) == 'user' ? 'user' : 'bot';
            String text = m.get('text') == null ? '' : String.valueOf(m.get('text'));
            String img = m.get('imageUrl') == null ? '' : String.valueOf(m.get('imageUrl'));
            if (String.isBlank(text) && String.isBlank(img)) continue;
            String bubbleInner = waBubbleInner(text, img);
            if (sender == 'user') {
                parts += '<div class="row row-outgoing" data-sender="user">'
                    + '<div class="message wa-outgoing hidden-msg"><div class="wa-bubble wa-bubble-out">'
                    + '<div class="wa-text">' + bubbleInner + '</div>'
                    + '<div class="wa-meta-row"><span class="wa-time">' + ts + '</span>'
                    + '<span class="wa-checks" aria-hidden="true">✓✓</span></div></div></div></div>';
            } else {
                parts += '<div class="row row-incoming" data-sender="bot">'
                    + '<div class="message wa-incoming hidden-msg"><div class="wa-bubble wa-bubble-in">'
                    + '<div class="wa-text">' + bubbleInner + '</div>'
                    + '<div class="wa-meta-row"><span class="wa-time">' + ts + '</span></div></div></div></div>';
            }
        }
        return parts;
    }

    // Bubble inner: optional image + copy (mirrors buildMessageBubbleInner).
    private static String waBubbleInner(String text, String img) {
        String bits = '';
        if (String.isNotBlank(text)) bits += '<div class="msg-copy">' + smsBubble(text) + '</div>';
        if (String.isNotBlank(img)) {
            bits += '<img class="msg-attached-image" src="' + escapeSms(img) + '" alt="" loading="lazy" referrerpolicy="no-referrer" />';
        }
        return bits;
    }

    // ----------------------------------------------------------------------
    // RCS — verified-brand header + text bubbles + quick-reply chips + rich
    // cards (ported from renderRcsBubble/renderRcsChipsRow/renderRcsCard,
    // script.js:7948+). Same compose/typing playback engine as SMS/WhatsApp.
    // ----------------------------------------------------------------------
    private static String renderRcs(String tpl, Map<String, Object> c) {
        String brand = str(c, 'brandName', 'Cumulus Financial');
        String domain = str(c, 'brandDomain', 'cumulusfinserv.com');
        Map<String, String> tok = new Map<String, String>{
            'RCS_THREAD_HTML' => buildRcsThread(c),
            'RCS_DEVICE' => rcsDevice(c),
            'RCS_THEME' => smsTheme(c),
            'RCS_VERIFIED' => 'verified',
            'RCS_BRAND_COLOR' => str(c, 'primaryColor', '#2A94D6'),
            'RCS_BRAND_NAME' => brand,
            'RCS_BRAND_INITIALS' => initials(brand),
            // Circle avatar = SECONDARY logo (fits a circle); the wide banner =
            // PRIMARY logo (a wordmark cuts off in the circle).
            'RCS_BRAND_LOGO_URL' => str(c, 'marketingAvatarUrl', str(c, 'logoUrl', '')),
            'RCS_BRAND_BANNER_URL' => str(c, 'logoUrl', ''),
            'RCS_BRAND_DESC' => str(c, 'rcsBrandDesc', brand + ' on RCS Business Messaging — offers, updates, and help, right in your messages.'),
            'RCS_BRAND_WEBSITE' => domain,
            'RCS_BRAND_EMAIL' => 'support@' + domain,
            'RCS_BRAND_PHONE' => str(c, 'rcsBrandPhone', '+1 (312) 555-0180'),
            'RCS_BRAND_TERMS_URL' => domain + '/terms'
        };
        String out = tpl;
        for (String k : tok.keySet()) {
            out = out.replace('[[' + k + ']]', tok.get(k) == null ? '' : tok.get(k));
        }
        out = resolveSharedTokens(out, c);
        out = out.replaceAll('(?i)<img[^>]{0,600}src="\\s*"[^>]{0,600}>', '');
        return out;
    }

    private static String rcsDevice(Map<String, Object> c) {
        String d = str(c, 'device', 'android');
        return (d == 'ios') ? 'ios' : 'android';
    }

    // Exact port of buildRcsThreadHtml (script.js:7948). Each message becomes a
    // .rcs-msg-group (carrying data-msg-index/kind/typing-ms) wrapping one or
    // more .rcs-row units; the ported runtime adds hidden-msg + plays them.
    private static String buildRcsThread(Map<String, Object> c) {
        String brandColor = str(c, 'primaryColor', '#2A94D6');
        // Second gradient stop = brand accent (like the brand-kit card). A dark
        // primary->accent gradient lets even a logo with a dark background blend
        // in and show the mark, instead of a black box on a light gradient.
        String brandAccent = str(c, 'featureSectionColor', brandColor);
        // Hero card logo placeholder uses the PRIMARY logo (reads against the
        // brand gradient); falls back to the secondary.
        String brandLogo = str(c, 'logoUrl', str(c, 'marketingAvatarUrl', ''));
        String parts = '';
        Integer msgIdx = 0;
        for (Object o : msgList(c)) {
            if (!(o instanceof Map<String, Object>)) { msgIdx++; continue; }
            Map<String, Object> m = (Map<String, Object>) o;
            String sender = String.valueOf(m.get('sender')) == 'user' ? 'user' : 'bot';
            String type = str(m, 'type', 'text');
            String text = str(m, 'text', '');
            List<Object> chips = (m.get('chips') instanceof List<Object>) ? (List<Object>) m.get('chips') : new List<Object>();
            String rowsHtml = '';
            if (type == 'quickReplies') {
                if (String.isNotBlank(text)) rowsHtml += rcsBubbleHtml(sender, text);
                if (!chips.isEmpty()) rowsHtml += rcsChipsRowHtml(chips);
            } else if (type == 'richCardVertical' || type == 'richCardHorizontal') {
                String layout = type == 'richCardHorizontal' ? 'horizontal' : 'vertical';
                Map<String, Object> cardObj = (m.get('card') instanceof Map<String, Object>) ? (Map<String, Object>) m.get('card') : m;
                rowsHtml += rcsCardHtml(sender, cardObj, layout, brandColor, brandAccent, brandLogo);
            } else if (type == 'cardCarousel') {
                List<Object> cards = (m.get('cards') instanceof List<Object>) ? (List<Object>) m.get('cards') : new List<Object>();
                if (!cards.isEmpty()) rowsHtml += rcsCarouselHtml(sender, cards, brandColor, brandAccent, brandLogo);
            } else if (type == 'suggestedActions') {
                if (!chips.isEmpty()) rowsHtml += rcsChipsRowHtml(chips);
            } else {
                // 'text' (and any legacy row): bubble, plus chips if present.
                if (String.isNotBlank(text)) rowsHtml += rcsBubbleHtml(sender, text);
                if (!chips.isEmpty()) rowsHtml += rcsChipsRowHtml(chips);
            }
            if (String.isNotBlank(rowsHtml)) {
                Integer typingMs = sender == 'bot' ? rcsTypingMs(str(m, 'typingDuration', 'off')) : 0;
                parts += '<div class="rcs-msg-group" data-msg-index="' + msgIdx + '" data-msg-kind="'
                    + escapeSms(type) + '" data-typing-ms="' + typingMs + '">' + rowsHtml + '</div>';
            }
            msgIdx++;
        }
        return parts;
    }

    private static Integer rcsTypingMs(String setting) {
        if (setting == 'short') return 800;
        if (setting == 'medium') return 1600;
        if (setting == 'long') return 2800;
        return 0;
    }

    private static String rcsBubbleHtml(String sender, String text) {
        String side = sender == 'user' ? 'rcs-row-user' : 'rcs-row-bot';
        String skin = sender == 'user' ? 'rcs-bubble-user' : 'rcs-bubble-bot';
        return '<div class="rcs-row ' + side + '"><div class="rcs-bubble ' + skin
            + '"><div class="rcs-copy">' + smsBubble(text) + '</div></div></div>';
    }

    // Chip may be a plain string (label) or a map {label,action,target,response,responseType}.
    private static String rcsChipsRowHtml(List<Object> chips) {
        String items = '';
        for (Object ch : chips) {
            String label; String action = 'quickReply'; String target = ''; String resp = ''; String respType = '';
            if (ch instanceof Map<String, Object>) {
                Map<String, Object> cm = (Map<String, Object>) ch;
                label = str(cm, 'label', '');
                action = str(cm, 'action', 'quickReply');
                target = str(cm, 'target', '');
                resp = str(cm, 'response', '');
                respType = str(cm, 'responseType', '');
            } else {
                label = (ch == null) ? '' : String.valueOf(ch);
            }
            if (String.isBlank(label)) continue;
            String icon = rcsChipIconSvg(action);
            String respAttr = String.isNotBlank(resp) ? ' data-response="' + escapeSms(resp) + '"' : '';
            String respTypeAttr = String.isNotBlank(respType) ? ' data-response-type="' + escapeSms(respType) + '"' : '';
            items += '<button type="button" class="rcs-chip' + (String.isNotBlank(icon) ? ' rcs-chip-has-icon' : '')
                + '" data-action="' + escapeSms(action) + '" data-target="' + escapeSms(target) + '" data-label="'
                + escapeSms(label) + '"' + respAttr + respTypeAttr + '>' + icon
                + '<span class="rcs-chip-label-text">' + escapeSms(label) + '</span></button>';
        }
        if (String.isBlank(items)) return '';
        return '<div class="rcs-row rcs-row-bot"><div class="rcs-chips-row">' + items + '</div></div>';
    }

    private static String rcsChipIconSvg(String action) {
        if (action == 'openUrl') return '<svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2zm6.9 6h-2.9a15.7 15.7 0 0 0-1.4-3.6A8 8 0 0 1 18.9 8zM12 4c.8 1.2 1.5 2.5 1.9 4h-3.8c.4-1.5 1.1-2.8 1.9-4zM4.3 14c-.2-.6-.3-1.3-.3-2s.1-1.4.3-2h3.4c-.1.6-.1 1.3-.1 2s0 1.4.1 2H4.3zm.8 2h3c.3 1.3.8 2.5 1.4 3.6A8 8 0 0 1 5.1 16zm3-8H5.1a8 8 0 0 1 4.3-3.6c-.6 1.1-1.1 2.3-1.4 3.6zM12 20c-.8-1.2-1.5-2.5-1.9-4h3.8c-.4 1.5-1.1 2.8-1.9 4zm2.3-6H9.7c-.1-.6-.2-1.3-.2-2s.1-1.4.2-2h4.7c.1.6.2 1.3.2 2s-.1 1.4-.3 2zm.3 5.6c.6-1.1 1.1-2.3 1.4-3.6h2.9a8 8 0 0 1-4.3 3.6zM16.4 14c.1-.6.1-1.3.1-2s0-1.4-.1-2h3.4c.1.6.2 1.3.2 2s-.1 1.4-.2 2h-3.4z"/></svg>';
        if (action == 'dial') return '<svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true"><path fill="currentColor" d="M20 15.5c-1.2 0-2.5-.2-3.6-.6a1 1 0 0 0-1 .2l-2.2 2.2a15 15 0 0 1-6.6-6.6l2.2-2.2a1 1 0 0 0 .2-1c-.4-1.2-.6-2.4-.6-3.6a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1c0 9.4 7.6 17 17 17a1 1 0 0 0 1-1v-3.4a1 1 0 0 0-1-1z"/></svg>';
        if (action == 'viewLocation') return '<svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true"><path fill="currentColor" d="M12 2a7 7 0 0 0-7 7c0 5.3 7 13 7 13s7-7.7 7-13a7 7 0 0 0-7-7zm0 9.5a2.5 2.5 0 1 1 0-5 2.5 2.5 0 0 1 0 5z"/></svg>';
        if (action == 'createCalendarEvent') return '<svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true"><path fill="currentColor" d="M19 3h-1V1h-2v2H8V1H6v2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2zm0 16H5V8h14v11z"/></svg>';
        return '';
    }

    // Card media — image or autoplaying muted video (ported renderRcsCardMedia).
    // Falls back to a branded placeholder (gradient + logo) when no media is set
    // so a rich card never looks empty.
    private static String rcsCardMedia(Map<String, Object> card, String brandColor, String brandAccent, String brandLogo) {
        String url = str(card, 'mediaUrl', '');
        String size = str(card, 'mediaSize', 'medium');
        if (String.isBlank(url)) {
            // No media set: branded placeholder — the brand-color gradient frames
            // the card (keeps the branded look), and the logo sits on a clean WHITE
            // chip inside it so it always reads. Without the chip, a transparent
            // logo with dark/black elements (e.g. Target's black wordmark) is
            // swallowed by the dark gradient, AND the stylesheet rule
            // `.rcs-card-media img { background:#000 }` forces a black background on
            // the <img> itself — together they render as a BLACK BOX behind the
            // mark. The white chip + an explicit transparent img background fixes it
            // for ANY brand logo, independent of host (/sfc shepherd, Cloudinary…).
            String logo = String.isBlank(brandLogo) ? '' :
                '<div style="background:#ffffff;border-radius:12px;padding:14px 18px;'
                + 'box-shadow:0 2px 10px rgba(0,0,0,0.18);display:flex;align-items:center;'
                + 'justify-content:center;max-width:78%;max-height:72%;box-sizing:border-box;">'
                + '<img alt="" src="' + escapeSms(brandLogo) + '" referrerpolicy="no-referrer" '
                + 'style="width:auto;height:auto;max-width:100%;max-height:72px;object-fit:contain;'
                + 'background:transparent;display:block;" /></div>';
            return '<div class="rcs-card-media rcs-card-media-' + escapeSms(size)
                + '" style="min-height:150px;display:flex;align-items:center;justify-content:center;'
                + 'background:linear-gradient(135deg,' + escapeSms(brandColor) + ' 0%, '
                + escapeSms(brandAccent) + ' 100%);">' + logo + '</div>';
        }
        Boolean isVideo = str(card, 'mediaType', 'image') == 'video';
        String mediaInner = isVideo
            ? '<video autoplay muted loop playsinline preload="metadata" src="' + escapeSms(url) + '"></video>'
            : '<img alt="" src="' + escapeSms(url) + '" loading="lazy" referrerpolicy="no-referrer" />';
        return '<div class="rcs-card-media rcs-card-media-' + escapeSms(size) + '">' + mediaInner + '</div>';
    }

    // Card buttons (ported from renderRcsCard button map).
    private static String rcsCardButtons(Object b) {
        if (!(b instanceof List<Object>)) return '';
        String btns = '';
        for (Object o : (List<Object>) b) {
            String label; String action = 'openUrl'; String target = ''; String resp = ''; String respType = '';
            if (o instanceof Map<String, Object>) {
                Map<String, Object> bm = (Map<String, Object>) o;
                label = str(bm, 'label', '');
                action = str(bm, 'action', 'openUrl');
                target = str(bm, 'target', '');
                resp = str(bm, 'response', '');
                respType = str(bm, 'responseType', '');
            } else {
                label = (o == null) ? '' : String.valueOf(o);
            }
            if (String.isBlank(label)) continue;
            String respAttr = String.isNotBlank(resp) ? ' data-response="' + escapeSms(resp) + '"' : '';
            String respTypeAttr = String.isNotBlank(respType) ? ' data-response-type="' + escapeSms(respType) + '"' : '';
            btns += '<button type="button" class="rcs-card-btn" data-action="' + escapeSms(action)
                + '" data-target="' + escapeSms(target) + '" data-label="' + escapeSms(label) + '"'
                + respAttr + respTypeAttr + '>' + escapeSms(label) + '</button>';
        }
        return String.isBlank(btns) ? '' : '<div class="rcs-card-buttons">' + btns + '</div>';
    }

    private static String rcsCardBody(Map<String, Object> card) {
        String title = String.isNotBlank(str(card, 'title', '')) ? '<h4 class="rcs-card-title-text">' + smsBubble(str(card, 'title', '')) + '</h4>' : '';
        String descHtml = String.isNotBlank(str(card, 'description', '')) ? '<p class="rcs-card-desc">' + smsBubble(str(card, 'description', '')) + '</p>' : '';
        return '<div class="rcs-card-body">' + title + descHtml + rcsCardButtons(card.get('buttons')) + '</div>';
    }

    private static String rcsCardHtml(String sender, Map<String, Object> card, String layout, String brandColor, String brandAccent, String brandLogo) {
        String side = sender == 'user' ? 'rcs-row-user' : 'rcs-row-bot';
        return '<div class="rcs-row ' + side + '"><div class="rcs-card rcs-card-' + escapeSms(layout) + '">'
            + rcsCardMedia(card, brandColor, brandAccent, brandLogo) + rcsCardBody(card) + '</div></div>';
    }

    private static String rcsCarouselHtml(String sender, List<Object> cards, String brandColor, String brandAccent, String brandLogo) {
        String side = sender == 'user' ? 'rcs-row-user' : 'rcs-row-bot';
        String items = '';
        for (Object o : cards) {
            if (!(o instanceof Map<String, Object>)) continue;
            Map<String, Object> cd = (Map<String, Object>) o;
            items += '<div class="rcs-carousel-item rcs-card rcs-card-vertical">'
                + rcsCardMedia(cd, brandColor, brandAccent, brandLogo) + rcsCardBody(cd) + '</div>';
        }
        return '<div class="rcs-row ' + side + '"><div class="rcs-carousel">' + items + '</div></div>';
    }
}
