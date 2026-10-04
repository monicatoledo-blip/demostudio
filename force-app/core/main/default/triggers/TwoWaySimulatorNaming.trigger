/**
 * Auto-derives the Experience Name from Brand Kit (or Brand/Industry) + Channel
 * + date so SEs don't have to name experiences. On create it always derives
 * (Name is platform-required, so the SE types a placeholder); on update it only
 * fills when the SE cleared it.
 */
trigger TwoWaySimulatorNaming on Two_Way_Simulator__c (before insert, before update) {
    Set<Id> kitIds = new Set<Id>();
    for (Two_Way_Simulator__c s : Trigger.new) {
        if (s.Brand_Kit__c != null) kitIds.add(s.Brand_Kit__c);
    }
    Map<Id, Demo_Theme__c> kits = kitIds.isEmpty()
        ? new Map<Id, Demo_Theme__c>()
        : new Map<Id, Demo_Theme__c>([SELECT Id, Name FROM Demo_Theme__c WHERE Id IN :kitIds]);

    for (Two_Way_Simulator__c s : Trigger.new) {
        if (Trigger.isInsert || String.isBlank(s.Name)) {
            String brand = (s.Brand_Kit__c != null && kits.containsKey(s.Brand_Kit__c))
                ? kits.get(s.Brand_Kit__c).Name
                : (String.isNotBlank(s.Brand__c) ? s.Brand__c
                    : (String.isNotBlank(s.Industry__c) ? s.Industry__c : 'Experience'));
            String channel = String.isNotBlank(s.Channel__c) ? s.Channel__c : 'Email';
            String nm = '2-Way · ' + brand + ' · ' + channel + ' · ' + Datetime.now().format('MMM d');
            s.Name = nm.length() > 80 ? nm.substring(0, 80) : nm;
        }
    }
}
