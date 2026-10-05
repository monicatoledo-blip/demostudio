/**
 * Tests the TwoWaySimulatorNaming trigger: Experience Name is derived from
 * Brand Kit (or Brand/Industry) + Channel + date on insert, re-derived on update
 * only when cleared, and capped at 80 chars.
 */
@isTest
private class TwoWaySimulatorNamingTest {

    @isTest
    static void derivesFromBrandKit() {
        Demo_Theme__c kit = new Demo_Theme__c(Name = 'Target');
        insert kit;
        Two_Way_Simulator__c s = new Two_Way_Simulator__c(
            Name = 'typed-placeholder', Channel__c = 'RCS', Brand_Kit__c = kit.Id
        );
        Test.startTest();
        insert s;
        Test.stopTest();
        s = [SELECT Name FROM Two_Way_Simulator__c WHERE Id = :s.Id];
        System.assert(s.Name.startsWith('2-Way · Target · RCS · '), 'Name derived from kit + channel: ' + s.Name);
    }

    @isTest
    static void fallsBackToBrandThenIndustryThenDefault() {
        Two_Way_Simulator__c brand = new Two_Way_Simulator__c(Name = 'x', Channel__c = 'SMS', Brand__c = 'Acme');
        Two_Way_Simulator__c ind = new Two_Way_Simulator__c(Name = 'x', Channel__c = 'Email', Industry__c = 'Retail & Consumer Goods');
        // No brand kit and no Brand__c: falls back to Industry__c (which defaults
        // to 'Financial Services' on this object).
        Two_Way_Simulator__c none = new Two_Way_Simulator__c(Name = 'x');
        insert new List<Two_Way_Simulator__c>{ brand, ind, none };
        Map<Id, Two_Way_Simulator__c> byId = new Map<Id, Two_Way_Simulator__c>(
            [SELECT Name FROM Two_Way_Simulator__c WHERE Id IN :new List<Id>{ brand.Id, ind.Id, none.Id }]
        );
        System.assert(byId.get(brand.Id).Name.startsWith('2-Way · Acme · SMS · '), byId.get(brand.Id).Name);
        System.assert(byId.get(ind.Id).Name.startsWith('2-Way · Retail & Consumer Goods · Email · '), byId.get(ind.Id).Name);
        System.assert(byId.get(none.Id).Name.startsWith('2-Way · Financial Services · Email · '), byId.get(none.Id).Name);
    }

    @isTest
    static void reDerivesOnUpdateOnlyWhenCleared() {
        Two_Way_Simulator__c s = new Two_Way_Simulator__c(Name = 'x', Channel__c = 'SMS', Brand__c = 'Acme');
        insert s;
        // A non-blank name set by the SE should be preserved on update.
        s.Name = 'My Custom Name';
        update s;
        System.assertEquals('My Custom Name', [SELECT Name FROM Two_Way_Simulator__c WHERE Id = :s.Id].Name);
        // Clearing it triggers re-derivation.
        s.Name = '';
        update s;
        System.assert([SELECT Name FROM Two_Way_Simulator__c WHERE Id = :s.Id].Name.startsWith('2-Way · Acme · SMS · '));
    }

    @isTest
    static void capsNameAt80Chars() {
        // A long brand pushes the derived name past 80; the trigger must cap it.
        Two_Way_Simulator__c s = new Two_Way_Simulator__c(Name = 'x', Channel__c = 'RCS', Brand__c = 'A'.repeat(90));
        insert s;
        System.assertEquals(80, [SELECT Name FROM Two_Way_Simulator__c WHERE Id = :s.Id].Name.length(), 'Name capped at 80.');
    }
}
