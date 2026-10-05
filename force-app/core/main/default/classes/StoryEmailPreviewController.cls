/**
 * Renders a Demo_Story__c's 2-way email as full HTML for the Visualforce preview
 * page (StoryEmailPreview). Lightning Web Security blocks srcdoc/blob/data iframe
 * content, so the Story Studio preview iframe loads a relative /apex/ URL instead;
 * this controller produces that page's body from the story's saved Config_JSON__c
 * by token-substituting over the demoStoryEmailTemplate static resource.
 */
public with sharing class StoryEmailPreviewController {

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

        // Pick the ported template + renderer by channel. Email is the default
        // and its behavior is unchanged; SMS/WhatsApp/RCS are additive branches.
        String ch = channel == null ? 'email' : channel.toLowerCase();
        String resource = 'demoStoryEmailTemplate';
        if (ch == 'sms') resource = 'demoStorySmsTemplate';
        else if (ch == 'whatsapp') resource = 'demoStoryWhatsappTemplate';
        else if (ch == 'rcs') resource = 'demoStoryRcsTemplate';

        String tpl;
        try { tpl = new PageReference('/resource/' + resource).getContent().toString(); }
        catch (Exception e) { return '<p style="font-family:Arial">Template load failed: ' + e.getMessage() + '</p>'; }

        if (ch == 'sms') return renderSms(tpl, c);
        else if (ch == 'whatsapp') return renderWhatsapp(tpl, c);
        else if (ch == 'rcs') return renderRcs(tpl, c);
        return renderEmail(tpl, c);
    }

    private static String str(Map<String, Object> c, String k, String dflt) {
        Object v = c.get(k);
        return v == null ? dflt : String.valueOf(v);
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
        out = out.replaceAll('(?i)<img[^>]*src="\\s*"[^>]*>', '');
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
        out = out.replaceAll('(?i)<img[^>]*src="\\s*"[^>]*>', '');
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
        out = out.replaceAll('(?i)<img[^>]*src="\\s*"[^>]*>', '');
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
            'RCS_BRAND_LOGO_URL' => str(c, 'logoUrl', messagingHeaderAvatar(c)),
            'RCS_BRAND_BANNER_URL' => str(c, 'heroImageUrl', ''),
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
        out = out.replaceAll('(?i)<img[^>]*src="\\s*"[^>]*>', '');
        return out;
    }

    private static String rcsDevice(Map<String, Object> c) {
        String d = str(c, 'device', 'android');
        return (d == 'ios') ? 'ios' : 'android';
    }

    private static String buildRcsThread(Map<String, Object> c) {
        String parts = '';
        for (Object o : msgList(c)) {
            if (!(o instanceof Map<String, Object>)) continue;
            Map<String, Object> m = (Map<String, Object>) o;
            String sender = String.valueOf(m.get('sender')) == 'user' ? 'user' : 'bot';
            String text = m.get('text') == null ? '' : String.valueOf(m.get('text'));
            Map<String, Object> card = (m.get('card') instanceof Map<String, Object>) ? (Map<String, Object>) m.get('card') : null;
            List<Object> chips = (m.get('chips') instanceof List<Object>) ? (List<Object>) m.get('chips') : new List<Object>();

            // A rich card (bot only) replaces the bubble; else a text bubble
            // (if any) followed by a quick-reply chip row (if any).
            if (sender == 'bot' && card != null && rcsCardHasContent(card)) {
                parts += rcsCardRow(card, str(c, 'primaryColor', '#2A94D6'), str(c, 'logoUrl', messagingHeaderAvatar(c)));
            } else {
                if (String.isNotBlank(text)) parts += rcsBubbleRow(sender, text);
                if (sender == 'bot' && !chips.isEmpty()) parts += rcsChipsRow(chips);
            }
        }
        return parts;
    }

    private static String rcsBubbleRow(String sender, String text) {
        String side = sender == 'user' ? 'rcs-row-user' : 'rcs-row-bot';
        String skin = sender == 'user' ? 'rcs-bubble-user' : 'rcs-bubble-bot';
        return '<div class="rcs-row ' + side + ' hidden-msg" data-sender="' + sender + '">'
            + '<div class="rcs-bubble ' + skin + '"><div class="rcs-copy">' + smsBubble(text) + '</div></div></div>';
    }

    private static String rcsChipsRow(List<Object> chips) {
        String items = '';
        for (Object ch : chips) {
            String label = (ch == null) ? '' : String.valueOf(ch);
            if (String.isBlank(label)) continue;
            items += '<button type="button" class="rcs-chip" data-action="quickReply" data-label="'
                + escapeSms(label) + '"><span class="rcs-chip-label-text">' + escapeSms(label) + '</span></button>';
        }
        if (String.isBlank(items)) return '';
        return '<div class="rcs-row rcs-row-bot hidden-msg" data-sender="bot">'
            + '<div class="rcs-chips-row">' + items + '</div></div>';
    }

    private static Boolean rcsCardHasContent(Map<String, Object> card) {
        return String.isNotBlank(str(card, 'title', '')) || String.isNotBlank(str(card, 'description', ''))
            || String.isNotBlank(str(card, 'mediaUrl', ''));
    }

    private static String rcsCardRow(Map<String, Object> card, String brandColor, String brandLogo) {
        String url = str(card, 'mediaUrl', '');
        String media;
        if (String.isNotBlank(url)) {
            media = '<div class="rcs-card-media rcs-card-media-medium"><img alt="" src="' + escapeSms(url)
                + '" loading="lazy" referrerpolicy="no-referrer" /></div>';
        } else {
            // Rich cards always show media — fall back to a branded placeholder
            // (brand gradient + centered logo) so the card never looks empty.
            String logo = String.isBlank(brandLogo) ? '' :
                '<img alt="" src="' + escapeSms(brandLogo) + '" style="max-width:52%;max-height:62%;object-fit:contain;" referrerpolicy="no-referrer" />';
            media = '<div class="rcs-card-media rcs-card-media-medium" style="min-height:150px;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,'
                + escapeSms(brandColor) + ' 0%, #ffffff 160%);">' + logo + '</div>';
        }
        String title = String.isNotBlank(str(card, 'title', '')) ? '<h4 class="rcs-card-title-text">' + smsBubble(str(card, 'title', '')) + '</h4>' : '';
        String descHtml = String.isNotBlank(str(card, 'description', '')) ? '<p class="rcs-card-desc">' + smsBubble(str(card, 'description', '')) + '</p>' : '';
        String buttons = '';
        Object b = card.get('buttons');
        if (b instanceof List<Object>) {
            String btns = '';
            for (Object o : (List<Object>) b) {
                String label = (o == null) ? '' : String.valueOf(o);
                if (String.isBlank(label)) continue;
                btns += '<button type="button" class="rcs-card-btn" data-action="openUrl" data-label="'
                    + escapeSms(label) + '">' + escapeSms(label) + '</button>';
            }
            if (String.isNotBlank(btns)) buttons = '<div class="rcs-card-buttons">' + btns + '</div>';
        }
        return '<div class="rcs-row rcs-row-bot hidden-msg" data-sender="bot">'
            + '<div class="rcs-card rcs-card-vertical">' + media
            + '<div class="rcs-card-body">' + title + descHtml + buttons + '</div></div></div>';
    }
}
