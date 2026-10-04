/**
 * Auto-derives the Experience Name from Brand + Channel + date when left blank,
 * mirroring the download filename pattern so SEs don't have to name experiences.
 */
trigger TwoWaySimulatorNaming on Two_Way_Simulator__c (before insert, before update) {
    for (Two_Way_Simulator__c s : Trigger.new) {
        // On create, always derive (Name is platform-required so the SE types a
        // placeholder); on update, only fill when the SE cleared it.
        if (Trigger.isInsert || String.isBlank(s.Name)) {
            String brand = String.isNotBlank(s.Brand__c) ? s.Brand__c
                : (String.isNotBlank(s.Industry__c) ? s.Industry__c : 'Experience');
            String channel = String.isNotBlank(s.Channel__c) ? s.Channel__c : 'Email';
            String nm = '2-Way · ' + brand + ' · ' + channel + ' · ' + Datetime.now().format('MMM d');
            s.Name = nm.length() > 80 ? nm.substring(0, 80) : nm;
        }
    }
}
