DEMO STUDIO — PERSONA GENERATION PROMPT
========================================

Copy this whole prompt into ChatGPT / Claude / Gemini / Prompt Builder,
replacing {{BRIEF}} with your persona description. Paste the JSON response
into the "Generate Persona From Brief" flow.

---

You are generating a Demo_Persona__c record for a Salesforce demo. Return ONLY
valid JSON, no prose, no markdown fencing.

Brief: {{BRIEF}}

Return an object with these keys:

{
  "themeName": "Cumulus Bank",             // must match an existing Demo_Theme__c
  "persona": {
    "Name": "First Last — Role",
    "First_Name__c": "",
    "Last_Name__c": "",
    "Title__c": "",
    "Company__c": "",
    "Avatar_URL__c": "https://randomuser.me/api/portraits/women/44.jpg",
    "Customer_ID__c": "KB-C-XXXXX",
    "Primary_Email__c": "",
    "Primary_Phone__c": "(XXX) XXX-XXXX",
    "Primary_Address__c": "",
    "Segment__c": "",
    "Lifecycle_Stage__c": "Cross-Sell Target",  // Prospect|Nurturing Lead|Engaged NDR|Active Customer|Cross-Sell Target
    "LTV__c": 250000,
    "Propensity__c": "Very High",              // Low|Medium|High|Very High
    "Engagement_Score__c": 84,                 // 0-100
    "Engagement_Label__c": "Highly Engaged",
    "Risk_Tier__c": "Low",                     // Low|Medium|High
    "Badge_Text__c": "Pre-Approved Buyer",
    "Suggested_Opener__c": "Hi {FirstName}, ... (2-3 sentences, first-person outreach)",
    "Intent_Summary__c": "(2-3 sentences describing what this contact just did and why they matter)",
    "Key_Context__c": "(2-3 sentences of background: pre-approvals, LTV, current status)",
    "Open_Likelihood__c": 92,
    "Click_Likelihood__c": 78,
    "Unsubscribe_Risk__c": 4
  },
  "identities": [
    { "Type__c": "Email",   "Value__c": "primary@corp.com", "Label__c": "Primary", "Sort_Order__c": 1 },
    { "Type__c": "Email",   "Value__c": "personal@gmail.com", "Label__c": "Personal", "Sort_Order__c": 2 },
    { "Type__c": "Phone",   "Value__c": "(XXX) XXX-XXXX",  "Label__c": "Primary", "Sort_Order__c": 1 },
    { "Type__c": "Address", "Value__c": "Full address",     "Label__c": "Primary", "Sort_Order__c": 1 }
  ],
  "insights": [
    {
      "Title__c": "Cross-sell product name",
      "Category__c": "Cross-Sell",              // Cross-Sell|Next-Best-Action|Risk|Retention
      "Why_This_Suggestion__c": "(2-3 sentences of data-backed reasoning with a specific $ or % number)",
      "CTA_Label__c": "Present Program",
      "Sort_Order__c": 1
    }
  ],
  "activities": [
    {
      "Type__c": "Doc",                          // Email|SMS|Web|Doc|Call|Meeting
      "Title__c": "Short action title",
      "Description__c": "(1 sentence of what happened)",
      "Timestamp_Label__c": "5:22 PM | Today",
      "Icon__c": "utility:upload",
      "Sort_Order__c": 1
    }
  ],
  "journeys": [
    {
      "Journey_Name__c": "",
      "Business_Unit__c": "Commercial",           // Commercial|Wealth|Retail|Corporate Comms|Treasury
      "Status__c": "Active",                       // Active|Paused|Completed|Exited
      "Enrolled_Date__c": "2026-06-15"
    }
  ],
  "recipe": {
    "leftRail": [
      { "component": "demoUnifiedProfileHeader" },
      { "component": "demoRelatedIdentities" }
    ],
    "center": [
      { "component": "demoAgentforceBrief" },
      { "component": "demoCrossSellInsights" }
    ],
    "rightRail": [
      { "component": "demoActivityTimeline" },
      { "component": "demoLikelihoodScoreCard" },
      { "component": "demoActiveJourneyTracker" }
    ]
  }
}

Rules:
- Return JSON ONLY. No prose, no code fences, no markdown.
- All fields optional except persona.First_Name__c and persona.Last_Name__c.
- Currency values are unquoted numbers (e.g. 250000, not "$250,000").
- Dates in YYYY-MM-DD.
- 3-5 activities, 2-3 insights, 2-4 journeys, 4-6 identities typical.
- Component recipe should reflect the story being told — drop items that don't fit.
