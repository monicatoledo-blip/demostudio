/**
 * Central test data builder for Demo Studio Apex tests. Keeps @TestSetup and
 * test methods free of inline record construction. Every builder can insert
 * (doInsert=true) or just return the in-memory records for the caller to tweak.
 */
@isTest
public class TestDataFactory {

    // ---- Brand Kit (Demo_Theme__c) ----------------------------------------

    public static Demo_Theme__c createTheme(String name, Boolean doInsert) {
        Demo_Theme__c t = new Demo_Theme__c(
            Name = name,
            Primary_Color__c = '#117ACA',
            Accent_Color__c = '#0B5FAE',
            Background_Gradient__c = 'linear-gradient(135deg, #117ACA 0%, #0B5FAE 100%)',
            Header_Style__c = 'Gradient',
            Font_Family__c = 'Salesforce Sans',
            Logo_URL__c = 'https://icons.duckduckgo.com/ip3/cumulusbank.com.ico'
        );
        if (doInsert) insert t;
        return t;
    }

    // ---- Persona (Demo_Persona__c) ----------------------------------------

    public static Demo_Persona__c createPersona(String first, String last, Boolean doInsert) {
        return createPersona(first, last, null, doInsert);
    }

    public static Demo_Persona__c createPersona(String first, String last, Id themeId, Boolean doInsert) {
        Demo_Persona__c p = new Demo_Persona__c(
            Name = (first + ' ' + last).trim(),
            First_Name__c = first,
            Last_Name__c = last,
            Title__c = 'VP of Treasury',
            Company__c = 'Cumulus Bank',
            Brand__c = 'Cumulus Bank',
            Primary_Email__c = 'valid.person@cumulusbank.com',
            Primary_Phone__c = '(415) 555-0148',
            Segment__c = 'Commercial Cross-Sell Target',
            Lifecycle_Stage__c = 'Cross-Sell Target',
            LTV__c = 250000,
            Currency_Code__c = 'USD',
            Propensity__c = 'Very High',
            Engagement_Score__c = 84,
            Risk_Tier__c = 'Low',
            Theme__c = themeId
        );
        if (doInsert) insert p;
        return p;
    }

    // ---- Persona children --------------------------------------------------

    public static void createChildren(Id personaId) {
        List<SObject> kids = new List<SObject>{
            new Demo_Persona_Identity__c(Persona__c = personaId, Type__c = 'Email', Value__c = 'primary@cumulusbank.com', Label__c = 'Primary', Sort_Order__c = 1),
            new Demo_Persona_Insight__c(Persona__c = personaId, Title__c = 'Commercial Card Program', Category__c = 'Cross-Sell', Sort_Order__c = 1),
            new Demo_Persona_Activity__c(Persona__c = personaId, Type__c = 'Doc', Title__c = 'Uploaded Docs', Sort_Order__c = 1),
            new Demo_Persona_Journey__c(Persona__c = personaId, Journey_Name__c = 'Onboarding', Business_Unit__c = 'Commercial', Status__c = 'Active'),
            new Demo_Persona_Kpi__c(Persona__c = personaId, Label__c = 'Assets', Value__c = '$1,326,969', Sort_Order__c = 1),
            new Demo_Persona_Alert__c(Persona__c = personaId, Category_Label__c = 'Cash Optimization', Title__c = 'Idle Cash', Sort_Order__c = 1),
            new Demo_Persona_Segment__c(Persona__c = personaId, Label__c = 'High Net Worth', Sort_Order__c = 1),
            new Demo_Persona_Nba__c(Persona__c = personaId, Title__c = 'Discuss Expansion', Category__c = 'Cross-Sell', Sort_Order__c = 1)
        };
        insert kids;
    }

    // ---- Contact -----------------------------------------------------------

    public static Contact createContact(String first, String last, Boolean doInsert) {
        Contact c = new Contact(FirstName = first, LastName = last, Email = first.toLowerCase() + '.' + last.toLowerCase() + '@example.org');
        if (doInsert) insert c;
        return c;
    }
}
