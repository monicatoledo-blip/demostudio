// Seed the default Cumulus Bank theme. Idempotent — safe to run repeatedly.
// This is the "starter" theme new personas are pointed to when the user
// hasn't picked something else.

Demo_Theme__c cumulus;
List<Demo_Theme__c> existing = [SELECT Id FROM Demo_Theme__c WHERE Name = 'Cumulus Bank' LIMIT 1];
if (existing.isEmpty()) {
    cumulus = new Demo_Theme__c();
    cumulus.Name = 'Cumulus Bank';
} else {
    cumulus = existing[0];
}
cumulus.Primary_Color__c        = '#1F5FBF';
cumulus.Accent_Color__c         = '#0B2A5B';
cumulus.Background_Gradient__c  = 'linear-gradient(135deg,#0B2A5B 0%,#1F5FBF 60%,#3A8DD3 100%)';
cumulus.Font_Family__c          = 'Inter, "Salesforce Sans", Arial, sans-serif';
cumulus.Header_Style__c         = 'Gradient';
// No static resource logo yet — theme relies on Logo_URL__c or the persona's Brand text.
upsert cumulus;

System.debug('Cumulus theme id: ' + cumulus.Id);
