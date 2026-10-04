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
        // WhatsApp + RCS branches are added in their own build phases.
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
            'MARKETING_AVATAR_URL' => str(c, 'marketingAvatarUrl', ''),
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
}
