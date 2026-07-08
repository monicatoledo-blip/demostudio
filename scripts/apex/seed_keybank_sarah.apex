// Seed KeyBank Commercial theme + Sarah Jenkins persona + all child records.
// Idempotent: deletes any prior seed rows by well-known Names first.

// 1. Wipe prior seed (safe — only touches records named exactly like our seed)
delete [SELECT Id FROM Demo_Persona_Identity__c WHERE Persona__r.Name = 'Sarah Jenkins — VP Treasury'];
delete [SELECT Id FROM Demo_Persona_Insight__c   WHERE Persona__r.Name = 'Sarah Jenkins — VP Treasury'];
delete [SELECT Id FROM Demo_Persona_Activity__c  WHERE Persona__r.Name = 'Sarah Jenkins — VP Treasury'];
delete [SELECT Id FROM Demo_Persona_Journey__c   WHERE Persona__r.Name = 'Sarah Jenkins — VP Treasury'];
delete [SELECT Id FROM Demo_Persona__c WHERE Name = 'Sarah Jenkins — VP Treasury'];
delete [SELECT Id FROM Demo_Theme__c   WHERE Name = 'KeyBank Commercial'];

// 2. Theme
Demo_Theme__c theme = new Demo_Theme__c(
    Name = 'KeyBank Commercial',
    Primary_Color__c = '#C8102E',
    Accent_Color__c = '#0A1F44',
    Background_Gradient__c = 'linear-gradient(135deg,#0A1F44 0%,#1C3B7B 100%)',
    Logo_Static_Resource__c = 'KeyBankLogo',
    Font_Family__c = 'Salesforce Sans, Arial, sans-serif',
    Header_Style__c = 'Gradient'
);
insert theme;

// 3. Recipe JSON — Individuals is now a tab INSIDE demoUnifiedProfileHeader, not a separate slot.
String recipe = '{'
  + '"leftRail":['
  +   '{"component":"demoUnifiedProfileHeader"}'
  + '],'
  + '"center":['
  +   '{"component":"demoAgentforceBrief"},'
  +   '{"component":"demoCrossSellInsights"}'
  + '],'
  + '"rightRail":['
  +   '{"component":"demoActivityTimeline"},'
  +   '{"component":"demoLikelihoodScoreCard"},'
  +   '{"component":"demoActiveJourneyTracker"}'
  + ']}';

// 4. Persona
Demo_Persona__c p = new Demo_Persona__c(
    Name = 'Sarah Jenkins — VP Treasury',
    First_Name__c = 'Sarah',
    Last_Name__c = 'Jenkins',
    Title__c = 'VP of Treasury',
    Company__c = 'Meridian Logistics',
    Brand__c = 'KeyBank Commercial',
    // Points to the SarahAvatar static resource — no CSP concern, ships with this project.
    Avatar_URL__c = '/resource/SarahAvatar',
    Customer_ID__c = 'KB-C-58392',
    Primary_Email__c = 'sarah.jenkins@meridianlogistics.com',
    Primary_Phone__c = '(315) 545-1254',
    Primary_Address__c = '2259 Green Avenue, Alpharetta, GA 30004',
    Segment__c = 'Commercial Cross-Sell Target',
    Lifecycle_Stage__c = 'Cross-Sell Target',
    LTV__c = 250000,
    Propensity__c = 'Very High',
    Engagement_Score__c = 84,
    Engagement_Label__c = 'Highly Engaged',
    Risk_Tier__c = 'Low',
    Badge_Text__c = 'Pre-Approved Buyer',
    Suggested_Opener__c = 'Hi Sarah, I noticed Meridian just uploaded the underwriting documents for the treasury services expansion — congratulations on progressing that quickly. I want to make sure we finalize your approval today so we can activate the new receivables platform before your Q3 cash flow cycle. Are you free for a brief call this afternoon to walk through the final terms?',
    Intent_Summary__c = 'Sarah initiated a Treasury Management services expansion at Meridian Logistics and successfully uploaded the required underwriting documents this morning. She is actively engaging with the Agentforce virtual assistant regarding activation timelines and is a strong cross-sell target for the Commercial Card and FX Hedging products.',
    Key_Context__c = 'Sarah is pre-approved for a $500K expanded credit line with an estimated Lifetime Value of $250K. Her unified profile synced instantly via Data Cloud, showing she has successfully uploaded her SOC-2 attestation and Proof of Funds. She is waiting on final underwriter clearance to activate the receivables platform.',
    Open_Likelihood__c = 92,
    Click_Likelihood__c = 78,
    Unsubscribe_Risk__c = 4,
    Theme__c = theme.Id,
    Component_Recipe__c = recipe
);
insert p;

// 5. Identities (Individuals tab)
insert new List<Demo_Persona_Identity__c>{
    new Demo_Persona_Identity__c(Persona__c=p.Id, Type__c='Email',   Value__c='sarah.jenkins@meridianlogistics.com', Label__c='Primary', Sort_Order__c=1),
    new Demo_Persona_Identity__c(Persona__c=p.Id, Type__c='Email',   Value__c='sjenkins@gmail.com',                  Label__c='Personal', Sort_Order__c=2),
    new Demo_Persona_Identity__c(Persona__c=p.Id, Type__c='Email',   Value__c='sarah.j@meridianlog.com',             Label__c='Work Alt', Sort_Order__c=3),
    new Demo_Persona_Identity__c(Persona__c=p.Id, Type__c='Phone',   Value__c='(315) 545-1254', Label__c='Primary', Sort_Order__c=1),
    new Demo_Persona_Identity__c(Persona__c=p.Id, Type__c='Phone',   Value__c='(404) 555-0123', Label__c='Mobile', Sort_Order__c=2),
    new Demo_Persona_Identity__c(Persona__c=p.Id, Type__c='Address', Value__c='2259 Green Avenue, Alpharetta, GA 30004', Label__c='Primary', Sort_Order__c=1),
    new Demo_Persona_Identity__c(Persona__c=p.Id, Type__c='Address', Value__c='1000 Corporate Blvd, Atlanta, GA 30328', Label__c='Office', Sort_Order__c=2)
};

// 6. Cross-sell insights
insert new List<Demo_Persona_Insight__c>{
    new Demo_Persona_Insight__c(Persona__c=p.Id, Title__c='Commercial Card Program', Category__c='Cross-Sell',
        Why_This_Suggestion__c='Meridian processes $4.2M in annual T&E spend through disparate personal cards. Consolidating to a KeyBank Commercial Card program would recover an estimated $84K/yr in rebates and give Sarah spend visibility across all 43 employees.',
        CTA_Label__c='Present Program', Sort_Order__c=1),
    new Demo_Persona_Insight__c(Persona__c=p.Id, Title__c='FX Hedging (KeyForex)', Category__c='Cross-Sell',
        Why_This_Suggestion__c='Meridian imports 22% of parts from Canada and Mexico. Current FX exposure creates ~$140K annual P&L volatility. KeyForex forward contracts would lock margins during their tariff-sensitive period.',
        CTA_Label__c='Offer Hedging', Sort_Order__c=2)
};

// 7. Activity timeline
insert new List<Demo_Persona_Activity__c>{
    new Demo_Persona_Activity__c(Persona__c=p.Id, Type__c='Doc',   Title__c='Uploaded Underwriting Documents',
        Description__c='SOC-2 attestation and Proof of Funds successfully uploaded via the secure KeyBank commercial document portal.',
        Timestamp_Label__c='5:22 PM | Today', Icon__c='utility:upload', Sort_Order__c=1),
    new Demo_Persona_Activity__c(Persona__c=p.Id, Type__c='Email', Title__c='Replied to Email: Welcome to KeyBank Treasury',
        Description__c='Customer initiated a real-time conversation with the Agentforce virtual assistant regarding activation timelines.',
        Timestamp_Label__c='10:18 AM | Today', Icon__c='utility:email', Sort_Order__c=2),
    new Demo_Persona_Activity__c(Persona__c=p.Id, Type__c='Web',   Title__c='Web Intent Detected: Receivables Platform',
        Description__c='Adaptive web inquiry researching receivables automation on keybank.com/commercial.',
        Timestamp_Label__c='20 Days Ago', Icon__c='utility:world', Sort_Order__c=3),
    new Demo_Persona_Activity__c(Persona__c=p.Id, Type__c='SMS',   Title__c='SMS Sent: Credit Line Pre-Approval',
        Description__c='Automated pre-approval notification sent via Marketing Cloud Advanced.',
        Timestamp_Label__c='3:15 PM | April 28', Icon__c='utility:sms', Sort_Order__c=4)
};

// 8. Active journeys
insert new List<Demo_Persona_Journey__c>{
    new Demo_Persona_Journey__c(Persona__c=p.Id, Journey_Name__c='Commercial Onboarding — Treasury Services', Business_Unit__c='Commercial', Status__c='Active', Enrolled_Date__c=Date.today().addDays(-14)),
    new Demo_Persona_Journey__c(Persona__c=p.Id, Journey_Name__c='Cross-Sell Nurture — Commercial Card',       Business_Unit__c='Commercial', Status__c='Active', Enrolled_Date__c=Date.today().addDays(-7)),
    new Demo_Persona_Journey__c(Persona__c=p.Id, Journey_Name__c='Wealth Advisory Introduction',               Business_Unit__c='Wealth',     Status__c='Paused', Enrolled_Date__c=Date.today().addDays(-45))
};

System.debug('Seeded persona: ' + p.Id);
System.debug('Seeded theme:   ' + theme.Id);
