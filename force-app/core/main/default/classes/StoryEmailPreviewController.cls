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
        return dl == '1' ? 'text/html#story-email.html' : 'text/html';
    }

    public String getHtml() {
        String storyId = ApexPages.currentPage().getParameters().get('id');
        if (String.isBlank(storyId)) return '<p style="font-family:Arial">No story id.</p>';

        Map<String, Object> c = new Map<String, Object>();
        for (Two_Way_Simulator__c s : [SELECT Config_JSON__c FROM Two_Way_Simulator__c WHERE Id = :storyId LIMIT 1]) {
            if (String.isNotBlank(s.Config_JSON__c)) {
                try { c = (Map<String, Object>) JSON.deserializeUntyped(s.Config_JSON__c); } catch (Exception e) {}
            }
        }

        String tpl;
        try { tpl = new PageReference('/resource/demoStoryEmailTemplate').getContent().toString(); }
        catch (Exception e) { return '<p style="font-family:Arial">Template load failed: ' + e.getMessage() + '</p>'; }

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
        // Scripts are KEPT so the 2-way Reply interactivity works in the preview.
        // The preview is a cross-domain Visualforce iframe, so the sim's JS runs in
        // its own frame. (If a future template's JS misbehaves, re-add a strip here.)
        return out;
    }
}
