@isTest
private class DmoSeedRunnerTest {

    @isTest
    static void seed_inserts_individuals_events_transactions() {
        String pack = '{'
            + '"individuals":['
            +   '{"First_Name__c":"Alice","Last_Name__c":"A","Email__c":"a@example.com","Tier__c":"Gold"},'
            +   '{"First_Name__c":"Bob","Last_Name__c":"B","Email__c":"b@example.com","Tier__c":"Silver"}'
            + '],'
            + '"events":['
            +   '{"individualRef":0,"Event_Type__c":"EmailOpen","Channel__c":"Email"},'
            +   '{"individualRef":1,"Event_Type__c":"PageView","Channel__c":"Web"}'
            + '],'
            + '"transactions":['
            +   '{"individualRef":0,"Amount__c":100.00,"Category__c":"Banking","Status__c":"Complete"}'
            + ']'
            + '}';

        DmoSeedRunner.SeedResult r = DmoSeedRunner.runSeedFromJson('demoDmoSeedTest', pack, false);

        System.assertEquals(2, r.individuals);
        System.assertEquals(2, r.events);
        System.assertEquals(1, r.transactions);
        System.assertEquals('demoDmoSeedTest', r.pack);

        System.assertEquals(2, [SELECT COUNT() FROM Demo_DMO_Individual__c]);
        System.assertEquals(2, [SELECT COUNT() FROM Demo_DMO_Event__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Demo_DMO_Transaction__c]);
    }

    @isTest
    static void wipeExisting_deletes_prior_rows() {
        insert new Demo_DMO_Individual__c(First_Name__c='OldAlice', Last_Name__c='X');
        String pack = '{"individuals":[{"First_Name__c":"New","Last_Name__c":"N"}],"events":[],"transactions":[]}';

        DmoSeedRunner.runSeedFromJson('demoDmoSeedWipeTest', pack, true);

        List<Demo_DMO_Individual__c> remaining = [SELECT First_Name__c FROM Demo_DMO_Individual__c];
        System.assertEquals(1, remaining.size());
        System.assertEquals('New', remaining[0].First_Name__c);
    }

    @isTest
    static void missing_pack_throws_aura_exception() {
        Boolean threw = false;
        try {
            DmoSeedRunner.runSeed('doesNotExist', false);
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'missing pack should throw');
    }

    @isTest
    static void bad_json_throws_aura_exception() {
        Boolean threw = false;
        try {
            DmoSeedRunner.runSeedFromJson('bad', 'not valid json {', false);
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'bad JSON should throw');
    }

    @isTest
    static void date_string_gets_coerced() {
        String pack = '{"individuals":[' +
            '{"First_Name__c":"D","Last_Name__c":"D","Date_of_Birth__c":"1990-05-15"}' +
            '],"events":[],"transactions":[]}';

        DmoSeedRunner.runSeedFromJson('demoDmoSeedDate', pack, false);

        Demo_DMO_Individual__c ind = [SELECT Date_of_Birth__c FROM Demo_DMO_Individual__c WHERE First_Name__c='D'];
        System.assertEquals(Date.newInstance(1990, 5, 15), ind.Date_of_Birth__c);
    }
}
