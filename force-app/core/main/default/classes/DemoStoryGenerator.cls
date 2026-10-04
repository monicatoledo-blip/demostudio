/**
 * AI generation for Story Studio: given an industry, brand, campaign context,
 * and angle, asks Einstein (via EinsteinProvider / GPT-4o) to produce the email
 * content AND a first-pass 2-way conversation, as JSON matching the Story Studio
 * config keys.
 */
public with sharing class DemoStoryGenerator {

    @AuraEnabled
    public static String generateEmail(String industry, String brand, String context, String angle) {
        return EinsteinProvider.callAndExtractJson(buildPrompt(industry, brand, context, angle));
    }

    // SMS / WhatsApp / RCS: generate just the 2-way thread (these sims have no
    // subject/headline/body — the thread is the whole experience).
    @AuraEnabled
    public static String generateSms(String industry, String brand, String context, String angle) {
        return EinsteinProvider.callAndExtractJson(buildSmsPrompt(industry, brand, context, angle));
    }

    @TestVisible
    private static String buildSmsPrompt(String industry, String brand, String context, String angle) {
        String ind = String.isBlank(industry) ? 'Financial Services' : industry;
        String br = String.isBlank(brand) ? 'the brand' : brand;
        String ang = String.isBlank(angle) ? 'a relevant marketing offer' : angle;
        String ctx = String.isBlank(context)
            ? ('A ' + ang + ' campaign from ' + br + ' for its ' + ind + ' customers.')
            : context;

        return String.join(new List<String>{
            'You are a senior lifecycle-marketing strategist writing a Salesforce demo SMS conversation for the ' + ind + ' industry.',
            'Brand: ' + br + '. Campaign angle: ' + ang + '.',
            'Campaign context (the deal / audience / narrative to demo):',
            ctx,
            '',
            'Return ONLY a single JSON object (no prose, no code fences) with EXACTLY this shape:',
            '{ "messages": [ {"sender":"bot","text":string}, {"sender":"user","text":string}, ... ] }',
            'Rules for "messages":',
            '- 4 to 6 turns, ALTERNATING, and the FIRST message MUST be "bot" (the brand sending a short marketing/outreach text).',
            '- "bot" = the brand / its AI agent. "user" = the recipient (' + br + ' customer).',
            '- After the opening brand text, the recipient ("user") replies with a realistic question grounded in the campaign context, then the brand AI agent ("bot") answers helpfully and specifically for ' + ind + ', and so on.',
            '- SMS style: short, conversational, 1-2 sentences per message, no markdown. You may use at most one tasteful emoji in the opening brand text only.',
            '- You may include [[CUSTOMER_FIRST_NAME]] and [[BRAND_NAME]] tokens; they are substituted at render time.',
            'Make it specific to the campaign context and angle - not generic. Do not include any key other than "messages". Output must be valid JSON.'
        }, '\n');
    }

    @TestVisible
    private static String buildPrompt(String industry, String brand, String context, String angle) {
        String ind = String.isBlank(industry) ? 'Financial Services' : industry;
        String br = String.isBlank(brand) ? 'the brand' : brand;
        String ang = String.isBlank(angle) ? 'a relevant marketing offer' : angle;
        String ctx = String.isBlank(context)
            ? ('A ' + ang + ' campaign from ' + br + ' for its ' + ind + ' customers.')
            : context;

        return String.join(new List<String>{
            'You are a senior marketing strategist writing a Salesforce demo email for the ' + ind + ' industry.',
            'Brand: ' + br + '. Campaign angle: ' + ang + '.',
            'Campaign context (the deal / audience / narrative to demo):',
            ctx,
            '',
            'Return ONLY a single JSON object (no prose, no code fences) with EXACTLY these keys:',
            '{',
            '  "subjectLine": string,',
            '  "headline": string (short, punchy),',
            '  "subHeadline": string,',
            '  "bodyParagraph": string (2 short paragraphs separated by a blank line; may include [[CUSTOMER_FIRST_NAME]]),',
            '  "featureColumn1": string (one benefit, 3-4 full sentences, ~4-5 lines),',
            '  "featureColumn2": string (another benefit, 3-4 full sentences, ~4-5 lines),',
            '  "bullet1": string, "bullet2": string, "bullet3": string,',
            '  "ctaButtonText": string (2-4 words),',
            '  "replyPromptHeadline": string, "replyPromptBody": string (invite the reader to reply to this email to chat with an AI agent),',
            '  "messages": [ {"sender":"user","text":string}, {"sender":"bot","text":string}, ... ]',
            '}',
            'The "messages" array is the back-and-forth AFTER the email: 4 to 6 turns, alternating starting with "user" (the customer asking a question grounded in the campaign context) then "bot" (the brand AI agent answering helpfully and specifically for ' + ind + '). Keep each message realistic and concise.',
            'Make the copy specific to the campaign context and angle above - not generic. Do not include any key other than those listed. Output must be valid JSON.'
        }, '\n');
    }
}
