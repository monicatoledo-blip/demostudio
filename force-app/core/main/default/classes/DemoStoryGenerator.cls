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

    // Industry-appropriate human escalation role + regulated-space guardrails,
    // shared by the email and SMS prompts so threads close responsibly.
    @TestVisible
    private static String complianceRules(String industry) {
        String ind = String.isBlank(industry) ? '' : industry.toLowerCase();
        String role;
        String prohibit;
        if (ind.contains('financial')) {
            role = 'a licensed financial advisor / relationship manager';
            prohibit = 'Do NOT give specific financial, investment, loan, or tax advice or quote exact rates/returns as if guaranteed; keep it general and defer specifics to the licensed human.';
        } else if (ind.contains('health') || ind.contains('life sciences')) {
            role = 'a licensed care coordinator or the recipient’s provider';
            prohibit = 'Do NOT give medical diagnosis, treatment, dosage, or clinical advice; defer any health specifics to the licensed human.';
        } else if (ind.contains('insurance')) {
            role = 'a licensed insurance agent';
            prohibit = 'Do NOT give specific coverage, claims, or eligibility determinations; defer specifics to the licensed agent.';
        } else if (ind.contains('public')) {
            role = 'a caseworker or representative';
            prohibit = 'Do NOT give legal or eligibility determinations; defer specifics to the representative.';
        } else {
            role = 'a specialist (representative, concierge, or account manager)';
            prohibit = 'Keep claims accurate and avoid promising anything the brand cannot guarantee.';
        }
        return String.join(new List<String>{
            'COMPLIANCE (hard rules): ' + prohibit,
            'The conversation MUST END with a brand/agent ("bot") message that (a) helpfully addresses the recipient’s final question and (b) offers to connect them with ' + role + ' to take it from here. NEVER end on a recipient ("user") message or leave a question unanswered.'
        }, '\n');
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
            'FIRST, identify the RECIPIENT: scan the campaign context for the person being messaged — look for cues like "Recipient is <Name>", "target <Name>", "<Name>, a ...", or any explicit personal name. If you find one, you MUST set "customerName" to their full name and "customerFirstName" to their first name. Only use "" for both if the context truly names no individual. Never invent a name.',
            'Return ONLY a single JSON object (no prose, no code fences) with EXACTLY this shape:',
            '{ "customerFirstName": string, "customerName": string, "messages": [ {"sender":"bot","text":string}, {"sender":"user","text":string}, ... ] }',
            'Example: context "...Recipient is Daniel Flores, a frequent traveler..." => "customerFirstName":"Daniel", "customerName":"Daniel Flores".',
            complianceRules(ind),
            'Rules for "messages":',
            '- 5 or 7 turns, ALTERNATING, with the FIRST message "bot" (brand outreach) and the LAST message "bot" (so it ends on the agent, never on a recipient question).',
            '- "bot" = the brand / its AI agent. "user" = the recipient (' + br + ' customer).',
            '- After the opening brand text, the recipient ("user") replies with a realistic question grounded in the campaign context, then the brand AI agent ("bot") answers helpfully and specifically for ' + ind + ', and so on.',
            '- SMS style: short, conversational, 1-2 sentences per message, no markdown. You may use at most one tasteful emoji in the opening brand text only.',
            '- Use the [[CUSTOMER_FIRST_NAME]] and [[BRAND_NAME]] tokens for the recipient first name and brand (they are substituted at render time) rather than writing the literal names into the text.',
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
            'FIRST, identify the RECIPIENT: scan the campaign context for the person being emailed — look for cues like "Recipient is <Name>", "target <Name>", "<Name>, a ...", or any explicit personal name. If you find one, set "customerName" to their full name and "customerFirstName" to their first name; use "" for both only if the context truly names no individual. Never invent a name. (Example: "...Recipient is Daniel Flores..." => "customerFirstName":"Daniel", "customerName":"Daniel Flores".) Keep the email body addressed via [[CUSTOMER_FIRST_NAME]] rather than writing the literal name.',
            'Return ONLY a single JSON object (no prose, no code fences) with EXACTLY these keys:',
            '{',
            '  "customerFirstName": string, "customerName": string,',
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
            'The "messages" array is the back-and-forth AFTER the email: 4 or 6 turns, alternating, STARTING with "user" (the customer asking a question grounded in the campaign context) and ENDING with "bot" (the brand AI agent). Keep each message realistic and concise.',
            complianceRules(ind),
            'Make the copy specific to the campaign context and angle above - not generic. Do not include any key other than those listed. Output must be valid JSON.'
        }, '\n');
    }
}
