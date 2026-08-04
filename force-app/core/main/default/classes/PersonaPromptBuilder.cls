/**
 * Builds the system + user prompt sent to the LLM by EinsteinProvider.
 * Kept in its own class so the schema description can be tuned without
 * touching provider plumbing.
 *
 * Design: single-shot prompt (no chat turns). Anchors the model with an
 * explicit JSON schema, one worked example, and a strict "JSON only" close.
 * Includes the user's transcript verbatim as the last section.
 */
public with sharing class PersonaPromptBuilder {

    public class PersonaPromptBuilderException extends Exception {}


    public static String build(String brief, String brandHint) {
        String safeBrief = brief == null ? '' : brief;
        String brandLine = String.isBlank(brandHint)
            ? ''
            : 'The persona should be branded for "' + brandHint + '". Use that brand name verbatim in persona.Brand__c and reflect it throughout the copy.\n';

        return
            'You are Demo Studio Persona Generator. Build a JSON persona ' +
            'bundle for a Salesforce Contact demo record.\n\n' +
            '## WHO THE PERSONA IS\n' +
            'The persona is the FICTIONAL CUSTOMER that appears on the demo ' +
            'Contact record. On the Salesforce record page the persona is ' +
            'the CONTACT BEING VIEWED — a customer of the champion\'s company ' +
            'whose profile a Relationship Manager (RM) / banker / sales rep ' +
            'would open to prepare for outreach.\n\n' +
            '## WHO THE PERSONA IS NOT\n' +
            '- The persona is NOT the Salesforce user watching the demo.\n' +
            '- The persona is NOT the RM / banker / sales rep. That person ' +
            'is the VIEWER of the record, not the record.\n' +
            '- The persona is NOT the internal champion / admin / SE / ' +
            'stakeholder who provided the context.\n\n' +
            'If the context names a rep or champion (e.g. "James manages a ' +
            'manufacturing client", "Sarah is the Marketing Cloud admin"), ' +
            'James / Sarah are the RM or champion — NOT the persona. The ' +
            'persona is one of James\'s clients (or Sarah\'s customers) — invent ' +
            'a plausible one that fits the story. Intent_Summary and ' +
            'Key_Context describe what the CUSTOMER has been doing. The ' +
            'Suggested_Opener is what the RM says TO that customer.\n\n' +
            'If the context describes a customer directly, use that ' +
            'description. If ambiguous, invent a plausible customer that ' +
            'fits the industry and story angle.\n\n' +
            '## INPUT STRUCTURE\n' +
            'The context below is organized into labeled sections:\n' +
            '- ## STORY CONTEXT — the deal, champion, business case, or ' +
            'narrative framing. Use this to pick the persona\'s industry, ' +
            'brand, segment, and story angle. Do NOT use this as the persona ' +
            'itself.\n' +
            '- ## PERSONA TO BUILD — an optional explicit description of ' +
            'the fictional customer. If provided, follow it closely. If ' +
            'absent, invent one that fits the story context.\n\n' +
            '## OUTPUT\n' +
            'Return ONLY a JSON object matching this schema — no prose, no ' +
            'markdown fences:\n' + SCHEMA + '\n\n' +
            '## RULES\n' +
            '- INVENT REALISTIC FAKE DATA. FAILURE = any generic placeholder ' +
            'or template string in a value. FORBIDDEN examples of BAD values: ' +
            '"US PHONE NUMBER", "client1 email", "person1@example.com", ' +
            '"customer1@example.com", "contact1@company.com", "user@example.com", ' +
            '"TBD", "[FIRST NAME]", "phone number here", "email address", ' +
            'anything with @example.com as the domain, anything of the form ' +
            '"person<N>", "client<N>", "contact<N>", "user<N>@...", or any ' +
            'value that reads as a template. Every string must be a specific, ' +
            'inhabited-looking fake as if you wrote it yourself:\n' +
            '  * Phone → "(area code) 555-XXXX" with a real US area code, ' +
            'e.g. "(415) 555-0148".\n' +
            '  * Email → derived from the PERSONA\'s actual first + last name ' +
            'and their company, e.g. "sally.smith@merchant-first.com" ' +
            '(NEVER @example.com, NEVER person1@).\n' +
            '  * Secondary/alt emails → still derived from the persona\'s ' +
            'name (e.g. "s.smith@gmail.com", "sallysmith@icloud.com"), ' +
            'NEVER "client1@" or "person2@".\n' +
            '  * Address → real US city, state, ZIP.\n' +
            '  * Company → a plausible business name, not "Company Inc".\n' +
            'If you catch yourself typing "example.com" or "personN@" in ANY ' +
            'value, rewrite it before returning. Blanks and placeholders are ' +
            'never acceptable.\n' +
            '- Every string reads like a real Salesforce demo — specific ' +
            'numbers, believable names, plausible companies.\n' +
            '- Every collection (identities, insights, activities, journeys, ' +
            'kpis, alerts, segments, nbas) has at least 2 rows.\n' +
            '- Sort_Order__c is a small integer starting at 1.\n' +
            '- Recipe places demoUnifiedProfileHeader in leftRail and ' +
            'demoAgentforceBrief in center at minimum.\n' +
            '- No Id fields on any row.\n' +
            '- Intent_Summary__c and Key_Context__c describe what the ' +
            'PERSONA (the customer) has been doing / who they are — website ' +
            'visits, opens, life events, product signals, tenure, segment. ' +
            'They are NEVER about the RM\'s workflow, the RM\'s clients in ' +
            'aggregate, or "fragmented engagement data".\n' +
            '- Suggested_Opener__c is a single sentence the RM says TO the ' +
            'persona, addressing them by first name — e.g. "Hi Ada, I saw ' +
            'you registered for the Q3 webinar…". It is NEVER a summary or ' +
            'a description of what the RM is going to do.\n' +
            '- The story context describes what SALESFORCE is demonstrating ' +
            'to the champion. It is NOT what the persona\'s alerts / insights / ' +
            'NBAs should pitch. The persona\'s record content lives entirely ' +
            'in the champion\'s business domain — a bank\'s alerts are about ' +
            'the customer\'s FINANCIAL life, an insurer\'s NBAs are about the ' +
            'customer\'s POLICIES, a retailer\'s insights are about the ' +
            'customer\'s SHOPPING patterns. The story angle should be visible ' +
            'in the shape of the signals (rich engagement data → high scores ' +
            'and multi-channel activity; cross-sell → the persona has clear ' +
            'attach opportunities; retention → churn signals). Never surface ' +
            'the Salesforce product itself in the content.\n' +
            '- FORBIDDEN in any Title__c / Body__c / Why_This_Suggestion__c / ' +
            'Category_Label__c / Intent_Summary__c / Key_Context__c / opener: ' +
            'the words "unified profile", "unified engagement", "Data Cloud", ' +
            '"Agentforce", "Salesforce", "single view of the customer", ' +
            '"CRM adoption", "cross-channel visibility", "banker ' +
            'productivity", or any suggestion that the persona (or their ' +
            'company) should ADOPT a Salesforce product. If you catch ' +
            'yourself writing an alert like "Consider a unified profile ' +
            'solution" — that is the meta-pitch to the SE, not a real alert ' +
            'about this customer. Delete it and write a real one instead.\n' +
            '- GOOD alert examples: "Retirement Gap — Behind target by $460K", ' +
            '"Idle Cash — $112K in checking exceeds recommended reserve", ' +
            '"Debt Alert — DTI at 34.5% on student loan payment". These are ' +
            'about the customer\'s money.\n' +
            '- GOOD cross-sell insight examples: "Merchant Services Bundle — ' +
            'SMB approval + 48h window = 45% attach", "Trust & Estate Services ' +
            'for HNW downloader". These are the champion\'s products to the ' +
            'customer.\n' +
            '- GOOD NBA examples: "Discuss Loan Approval Path", "Optimize ' +
            'Checking Account Funds", "Introduce Senior Wealth Advisor". ' +
            'These are what the RM does next with THIS customer.\n' +
            brandLine +
            '\n## EXAMPLE (illustrative — invent your own content)\n' +
            EXAMPLE + '\n\n' +
            '---\n' + safeBrief + '\n---\n\nJSON:';
    }

    /**
     * Schema description. Every field the persona bundle supports is enumerated
     * so the model doesn't guess field names. Kept compact — Einstein is smart
     * enough with types once field names are correct.
     */
    /**
     * Prompt for generating a single collection (KPIs, alerts, segments, etc.)
     * on an existing persona. `personaSummary` describes who the persona is
     * (name, title, company, brand, story). `collectionKey` picks the schema
     * slice. `mode` = 'replace' | 'append'. `existingRowsJson` is optional —
     * when present, tell the model to avoid duplicates.
     */
    public static String buildForCollection(String personaSummary, String collectionKey, String mode, String existingRowsJson, String extraHint) {
        return buildForCollection(personaSummary, collectionKey, mode, existingRowsJson, extraHint, 0);
    }

    public static String buildForCollection(String personaSummary, String collectionKey, String mode, String existingRowsJson, String extraHint, Integer existingCount) {
        String slice = COLLECTION_SLICES.get(collectionKey);
        if (String.isBlank(slice)) {
            throw new PersonaPromptBuilderException('Unknown collection: ' + collectionKey);
        }
        Boolean isAppend = 'append'.equalsIgnoreCase(mode);
        // Concrete target counts so the model doesn't over-generate. Replace
        // aims for the same size as the existing set (or 3 if empty). Append
        // is fixed at 2 new rows.
        Integer targetCount;
        if (isAppend) {
            targetCount = 2;
        } else {
            targetCount = existingCount != null && existingCount > 0 ? existingCount : 3;
        }
        String modeLine = isAppend
            ? 'APPEND MODE. Return EXACTLY ' + targetCount + ' NEW rows that add fresh angles. Do NOT repeat any existing rows shown below. The client will concatenate your output to the existing rows.'
            : 'REPLACE MODE. Return EXACTLY ' + targetCount + ' fresh rows. The client will discard whatever exists today and use YOUR rows only. Do not try to preserve any existing rows.';
        // On REPLACE mode we do NOT show existing rows to the model at all —
        // showing them makes the model more likely to echo them back and end
        // up doubling the collection size. On APPEND we keep them for
        // dedup context.
        String existingLine;
        if (isAppend) {
            existingLine = String.isBlank(existingRowsJson) ? '(No existing rows.)' : existingRowsJson;
        } else {
            existingLine = '(Hidden in REPLACE mode — do not attempt to preserve them.)';
        }

        return
            'You are Demo Studio Persona Generator. Generate a single ' +
            'collection of rows for an existing persona. Return ONLY a ' +
            'JSON object with the key "' + collectionKey + '" and an array ' +
            'of rows as its value. No prose, no fences.\n\n' +
            '## THE PERSONA\n' + personaSummary + '\n\n' +
            '## COLLECTION TO GENERATE\n' + collectionKey + '\n\n' +
            '## MODE\n' + modeLine + '\n\n' +
            '## EXISTING ROWS (for context — do not duplicate on append)\n' +
            existingLine + '\n\n' +
            (String.isBlank(extraHint) ? '' : '## ADDITIONAL GUIDANCE\n' + extraHint + '\n\n') +
            '## SCHEMA FOR THIS COLLECTION\n' + slice + '\n\n' +
            '## RULES\n' +
            '- Row values must fit the persona\'s industry, story, and brand.\n' +
            '- Sort_Order__c starts at 1 (or continues from the last existing row on append).\n' +
            '- No Id fields.\n' +
            '- Copy reads like real Salesforce demo content — specific numbers, plausible details.\n' +
            '- The row content lives in the CHAMPION\'S business domain (a ' +
            'bank\'s alerts are about the customer\'s financial life; an ' +
            'insurer\'s NBAs are about the customer\'s policies). Never surface ' +
            'the Salesforce product itself — no "unified profile", "Data ' +
            'Cloud", "Agentforce", "Salesforce", "single view of the ' +
            'customer", or suggestions that the persona should adopt a ' +
            'Salesforce product. If the persona summary mentions a pitch ' +
            'angle, that angle is what SALESFORCE is demonstrating to the ' +
            'champion — the row content should embody the angle in real ' +
            'domain terms (e.g. cross-sell angle → generate rich attach ' +
            'opportunities, NOT a row titled "Enable cross-sell in Data ' +
            'Cloud").\n\n' +
            'JSON:';
    }

    private static final Map<String, String> COLLECTION_SLICES = new Map<String, String>{
        'kpis'       => '[ { "Label__c": short, "Value__c": display e.g. "$1,326,969", "Sublabel__c": short caption, "Is_Highlighted__c": boolean, "Sort_Order__c": int } ]',
        'alerts'     => '[ { "Category_Label__c": short e.g. "Retirement Gap", "Category_Style__c": "Info|Success|Warning|Danger", "Title__c": string, "Body__c": 1-2 sentences, "Sort_Order__c": int } ]',
        'segments'   => '[ { "Label__c": short pill text, "Sort_Order__c": int } ]',
        'nbas'       => '[ { "Title__c": string, "Category__c": short e.g. "Cross-Sell", "Why_This_Suggestion__c": 1-2 sentences, "CTA_Label__c": string, "Image_URL__c": optional URL, "Sort_Order__c": int } ]',
        'insights'   => '[ { "Title__c": string, "Category__c": "Cross-Sell|Retention|Risk", "Why_This_Suggestion__c": string, "CTA_Label__c": string, "Sort_Order__c": int } ]',
        'activities' => '[ { "Type__c": "Email|SMS|Web|Doc|Call|Meeting", "Title__c": string, "Description__c": string, "Timestamp_Label__c": free-form e.g. "Today", "Icon__c": SLDS name e.g. "utility:email", "Sort_Order__c": int } ]',
        'journeys'   => '[ { "Journey_Name__c": string, "Business_Unit__c": "Commercial|Wealth|Retail|Marketing", "Status__c": "Active|Paused|Completed", "Enrolled_Date__c": "YYYY-MM-DD" } ]',
        'identities' => '[ { "Type__c": "Email|Phone|Address", "Value__c": string, "Label__c": string, "Sort_Order__c": int } ]'
    };

    private static final String SCHEMA =
        '{\n' +
        '  "persona": {\n' +
        '    "First_Name__c": string, "Last_Name__c": string, "Title__c": string,\n' +
        '    "Company__c": string, "Brand__c": string, "Customer_ID__c": string,\n' +
        '    "Primary_Email__c": string, "Primary_Phone__c": string, "Primary_Address__c": string,\n' +
        '    "Segment__c": string, "Lifecycle_Stage__c": one of "Prospect|Lead|Active Customer|Cross-Sell Target|Churn Risk",\n' +
        '    "LTV__c": number, "Currency_Code__c": ISO code e.g. "USD",\n' +
        '    "Propensity__c": one of "Low|Medium|High|Very High",\n' +
        '    "Engagement_Score__c": 0-100, "Engagement_Label__c": string,\n' +
        '    "Risk_Tier__c": one of "Low|Medium|High",\n' +
        '    "Badge_Text__c": short string,\n' +
        '    "Intent_Summary__c": 2-3 sentences describing what THIS CUSTOMER (the persona) has been doing lately — website visits, email opens, life events, product signals, application steps. Written in third person about the persona. NEVER describes the sales rep\'s activity or the rep\'s clients.\n' +
        '    "Key_Context__c": 2-3 sentences of additional signal about THIS CUSTOMER — segment, prior products, tenure, engagement pattern, unified profile insights the rep should know before reaching out. Third person about the persona.\n' +
        '    "Suggested_Opener__c": one sentence the RELATIONSHIP MANAGER / SALES REP would say TO the persona to open the conversation. Written in first person, addressed to the persona by name — e.g. "Hi Sarah, congrats on wrapping the underwriting docs — I want to make sure we land your Q3 expansion cleanly." NEVER a summary about the persona; it is the rep\'s spoken opener to the persona.\n' +
        '    "Open_Likelihood__c": 0-100, "Click_Likelihood__c": 0-100, "Unsubscribe_Risk__c": 0-100\n' +
        '  },\n' +
        '  "identities": [ { "Type__c": "Email|Phone|Address", "Value__c": string, "Label__c": string, "Sort_Order__c": int } ],\n' +
        '  "insights":   [ { "Title__c": string, "Category__c": "Cross-Sell|Retention|Risk", "Why_This_Suggestion__c": string, "CTA_Label__c": string, "Sort_Order__c": int } ],\n' +
        '  "activities": [ { "Type__c": "Email|SMS|Web|Doc|Call|Meeting", "Title__c": string, "Description__c": string, "Timestamp_Label__c": free-form e.g. "Today", "Icon__c": SLDS name e.g. "utility:email", "Sort_Order__c": int } ],\n' +
        '  "journeys":   [ { "Journey_Name__c": string, "Business_Unit__c": "Commercial|Wealth|Retail|Marketing", "Status__c": "Active|Paused|Completed", "Enrolled_Date__c": "YYYY-MM-DD" } ],\n' +
        '  "kpis":       [ { "Label__c": short, "Value__c": display e.g. "$1,326,969", "Sublabel__c": short caption, "Is_Highlighted__c": boolean, "Sort_Order__c": int } ],\n' +
        '  "alerts":     [ { "Category_Label__c": short e.g. "Retirement Gap", "Category_Style__c": "Info|Success|Warning|Danger", "Title__c": string, "Body__c": 1-2 sentences, "Sort_Order__c": int } ],\n' +
        '  "segments":   [ { "Label__c": short pill text, "Sort_Order__c": int } ],\n' +
        '  "nbas":       [ { "Title__c": string, "Category__c": short e.g. "Cross-Sell", "Why_This_Suggestion__c": 1-2 sentences, "CTA_Label__c": string, "Image_URL__c": optional public image URL, "Sort_Order__c": int } ],\n' +
        '  "recipe": {\n' +
        '    "leftRail": [ { "component": "demoUnifiedProfileHeader" } ],\n' +
        '    "center":   [ { "component": one of "demoAgentforceBrief|demoKpiStatRow|demoAiInsightsAlerts|demoCrossSellInsights|demoNextBestActions" } ],\n' +
        '    "rightRail":[ { "component": one of "demoLikelihoodScoreCard|demoActivityTimeline|demoActiveJourneyTracker" } ]\n' +
        '  }\n' +
        '}';

    private static final String EXAMPLE =
        '{"persona":{"First_Name__c":"Sarah","Last_Name__c":"Jenkins","Title__c":"VP of Treasury","Company__c":"Meridian Logistics","Brand__c":"Cumulus Bank","Customer_ID__c":"CUM-C-58392","Primary_Email__c":"sarah.jenkins@meridian.example","Primary_Phone__c":"(315) 555-1254","Primary_Address__c":"2259 Green Avenue, Alpharetta, GA 30004","Segment__c":"Commercial Cross-Sell Target","Lifecycle_Stage__c":"Cross-Sell Target","LTV__c":250000,"Currency_Code__c":"USD","Propensity__c":"Very High","Engagement_Score__c":84,"Engagement_Label__c":"Highly Engaged","Risk_Tier__c":"Low","Badge_Text__c":"Pre-Approved Buyer","Suggested_Opener__c":"Hi Sarah, congratulations on the underwriting docs moving through.","Intent_Summary__c":"Sarah initiated a Treasury Management expansion and uploaded underwriting documents this morning. She is a strong cross-sell for the Commercial Card program.","Key_Context__c":"Pre-approved for a $500K expansion. Data Cloud shows SOC-2 attestation received. Waiting on final underwriter clearance.","Open_Likelihood__c":92,"Click_Likelihood__c":78,"Unsubscribe_Risk__c":4},' +
        '"identities":[{"Type__c":"Email","Value__c":"sarah.jenkins@meridian.example","Label__c":"Primary","Sort_Order__c":1},{"Type__c":"Phone","Value__c":"(315) 555-1254","Label__c":"Mobile","Sort_Order__c":1}],' +
        '"insights":[{"Title__c":"Commercial Card Program","Category__c":"Cross-Sell","Why_This_Suggestion__c":"$4.2M annual T&E spend on disparate cards. Bundling recovers ~$84K/yr.","CTA_Label__c":"Present Program","Sort_Order__c":1}],' +
        '"activities":[{"Type__c":"Doc","Title__c":"Uploaded Underwriting Documents","Description__c":"SOC-2 attestation received via secure portal.","Timestamp_Label__c":"Today","Icon__c":"utility:upload","Sort_Order__c":1}],' +
        '"journeys":[{"Journey_Name__c":"Commercial Onboarding — Treasury","Business_Unit__c":"Commercial","Status__c":"Active","Enrolled_Date__c":"2026-06-15"}],' +
        '"kpis":[{"Label__c":"Assets","Value__c":"$1,326,969","Sublabel__c":"6 Accounts","Is_Highlighted__c":false,"Sort_Order__c":1},{"Label__c":"Net Worth","Value__c":"$1,107,789","Sublabel__c":"Calculated Insight","Is_Highlighted__c":true,"Sort_Order__c":2}],' +
        '"alerts":[{"Category_Label__c":"Cash Optimization","Category_Style__c":"Success","Title__c":"Idle Cash in Checking","Body__c":"Balance $112K exceeds recommended reserve.","Sort_Order__c":1}],' +
        '"segments":[{"Label__c":"High Net Worth","Sort_Order__c":1},{"Label__c":"Multi-Product Client","Sort_Order__c":2}],' +
        '"nbas":[{"Title__c":"Discuss Treasury Expansion","Category__c":"Cross-Sell","Why_This_Suggestion__c":"Application uploaded today. 78% attach rate within 48h.","CTA_Label__c":"Discuss Options","Image_URL__c":"","Sort_Order__c":1}],' +
        '"recipe":{"leftRail":[{"component":"demoUnifiedProfileHeader"}],"center":[{"component":"demoAgentforceBrief"},{"component":"demoKpiStatRow"},{"component":"demoAiInsightsAlerts"}],"rightRail":[{"component":"demoLikelihoodScoreCard"},{"component":"demoActivityTimeline"},{"component":"demoActiveJourneyTracker"}]}}';
}
