/**
 * Auto-derives the Personalized Website Experience Name from Brand Kit (or Brand/
 * Industry) + date so SEs don't have to name experiences — mirrors
 * TwoWaySimulatorNaming. Without this, guided-created records have a blank Name and
 * Salesforce shows the record Id (ugly browser tab / list). On create it always
 * derives; on update only when the Name was cleared.
 */
trigger PersonalizedWebsiteNaming on Demo_Story__c (before insert, before update) {
    Set<Id> kitIds = new Set<Id>();
    for (Demo_Story__c s : Trigger.new) {
        if (s.Brand_Kit__c != null) kitIds.add(s.Brand_Kit__c);
    }
    Map<Id, Demo_Theme__c> kits = kitIds.isEmpty()
        ? new Map<Id, Demo_Theme__c>()
        : new Map<Id, Demo_Theme__c>([SELECT Id, Name FROM Demo_Theme__c WHERE Id IN :kitIds]);

    for (Demo_Story__c s : Trigger.new) {
        if (Trigger.isInsert || String.isBlank(s.Name)) {
            String brand = (s.Brand_Kit__c != null && kits.containsKey(s.Brand_Kit__c))
                ? kits.get(s.Brand_Kit__c).Name
                : (String.isNotBlank(s.Brand__c) ? s.Brand__c
                    : (String.isNotBlank(s.Industry__c) ? s.Industry__c : 'Website'));
            String nm = 'Web · ' + brand + ' · ' + Datetime.now().format('MMM d');
            s.Name = nm.length() > 80 ? nm.substring(0, 80) : nm;
        }
    }
}
