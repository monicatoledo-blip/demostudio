/**
 * AI generation for Story Studio: given an industry, brand, and use case, asks
 * Einstein (via EinsteinProvider / GPT-4o) to produce the email content AND a
 * first-pass 2-way conversation, as JSON matching the Story Studio config keys.
 */
public with sharing class DemoStoryGenerator {

    @AuraEnabled
    public static String generateEmail(String industry, String brand, String useCase) {
        return EinsteinProvider.callAndExtractJson(buildPrompt(industry, brand, useCase));
    }

    @TestVisible
    private static String buildPrompt(String industry, String brand, String useCase) {
        String ind = String.isBlank(industry) ? 'Financial Services' : industry;
        String br = String.isBlank(brand) ? 'the brand' : brand;
        String uc = String.isBlank(useCase) ? 'a relevant marketing offer for this audience' : useCase;

        return String.join(new List<String>{
            'You are a senior marketing strategist writing a Salesforce demo email for the ' + ind + ' industry.',
            'Brand: ' + br + '. Use case: ' + uc + '.',
            'Return ONLY a single JSON object (no prose, no code fences) with EXACTLY these keys:',
            '{',
            '  "subjectLine": string,',
            '  "headline": string (short, punchy),',
            '  "subHeadline": string,',
            '  "bodyParagraph": string (2 short paragraphs separated by a blank line; may include [[CUSTOMER_FIRST_NAME]]),',
            '  "featureColumn1": string (one benefit, ~1 sentence),',
            '  "featureColumn2": string (another benefit, ~1 sentence),',
            '  "bullet1": string, "bullet2": string, "bullet3": string,',
            '  "ctaButtonText": string (2-4 words),',
            '  "replyPromptHeadline": string, "replyPromptBody": string (invite the reader to reply to this email to chat with an AI agent),',
            '  "messages": [ {"sender":"user","text":string}, {"sender":"bot","text":string}, ... ]',
            '}',
            'The "messages" array is the back-and-forth AFTER the email: 4 to 6 turns, alternating starting with "user" (the customer asking a question) then "bot" (the brand AI agent answering helpfully and specifically for ' + ind + '). Keep each message realistic and concise.',
            'Do not include any key other than those listed. Output must be valid JSON.'
        }, '\n');
    }
}
