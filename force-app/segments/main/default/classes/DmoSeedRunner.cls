/**
 * Seeds Demo_DMO_* records from a Static Resource JSON pack.
 * Called from dcSeedAdmin LWC. Static resource must be named
 * demoDmoSeedFins / demoDmoSeedHealthcare / demoDmoSeedRetail /
 * demoDmoSeedOnboarding (or any SE-added Static Resource with the same
 * JSON shape).
 *
 * Pack shape:
 * {
 *   "individuals": [{ "First_Name__c":"...", ...standard fields... }, ...],
 *   "events":      [{ "individualRef":0, "Event_Type__c":"...", ... }, ...],
 *   "transactions":[{ "individualRef":0, "Amount__c":123.45, ... }, ...]
 * }
 *
 * `individualRef` is a 0-based index into the individuals array — child rows
 * get bound to the correct parent Id after individuals are inserted.
 */
public with sharing class DmoSeedRunner {

    public class SeedResult {
        @AuraEnabled public Integer individuals;
        @AuraEnabled public Integer events;
        @AuraEnabled public Integer transactions;
        @AuraEnabled public Long durationMs;
        @AuraEnabled public String pack;
    }

    public class SeedException extends Exception {}

    @AuraEnabled
    public static SeedResult runSeed(String packName, Boolean wipeExisting) {
        if (String.isBlank(packName)) {
            throw new AuraHandledException('packName is required');
        }
        List<StaticResource> rs = [SELECT Id, Body FROM StaticResource WHERE Name = :packName LIMIT 1];
        if (rs.isEmpty()) {
            throw new AuraHandledException('Static Resource not found: ' + packName);
        }
        return runSeedFromJson(packName, rs[0].Body.toString(), wipeExisting);
    }

    // Test hook — tests can't insert StaticResource, so feed raw JSON directly.
    @TestVisible
    private static SeedResult runSeedFromJson(String packName, String bodyJson, Boolean wipeExisting) {
        Long startMs = System.now().getTime();

        Map<String, Object> pack;
        try {
            pack = (Map<String, Object>) JSON.deserializeUntyped(bodyJson);
        } catch (Exception e) {
            throw new AuraHandledException('Seed body is not valid JSON: ' + e.getMessage());
        }

        if (wipeExisting == true) {
            wipe();
        }

        List<Object> individualsRaw = (List<Object>) pack.get('individuals');
        List<Object> eventsRaw = (List<Object>) pack.get('events');
        List<Object> transactionsRaw = (List<Object>) pack.get('transactions');

        List<Demo_DMO_Individual__c> individuals = buildIndividuals(individualsRaw);
        insert individuals;

        List<Demo_DMO_Event__c> events = buildEvents(eventsRaw, individuals);
        if (!events.isEmpty()) {
            insertInChunks(events, 10000);
        }

        List<Demo_DMO_Transaction__c> transactions = buildTransactions(transactionsRaw, individuals);
        if (!transactions.isEmpty()) {
            insertInChunks(transactions, 10000);
        }

        SeedResult result = new SeedResult();
        result.individuals = individuals.size();
        result.events = events.size();
        result.transactions = transactions.size();
        result.durationMs = System.now().getTime() - startMs;
        result.pack = packName;
        return result;
    }

    private static void wipe() {
        delete [SELECT Id FROM Demo_Segment_Membership__c LIMIT 50000];
        delete [SELECT Id FROM Demo_DMO_Event__c LIMIT 50000];
        delete [SELECT Id FROM Demo_DMO_Transaction__c LIMIT 50000];
        delete [SELECT Id FROM Demo_DMO_Individual__c LIMIT 50000];
    }

    private static List<Demo_DMO_Individual__c> buildIndividuals(List<Object> rows) {
        List<Demo_DMO_Individual__c> result = new List<Demo_DMO_Individual__c>();
        if (rows == null) return result;
        for (Object rowObj : rows) {
            Map<String, Object> row = (Map<String, Object>) rowObj;
            Demo_DMO_Individual__c ind = new Demo_DMO_Individual__c();
            applyFields(ind, row);
            result.add(ind);
        }
        return result;
    }

    private static List<Demo_DMO_Event__c> buildEvents(List<Object> rows, List<Demo_DMO_Individual__c> individuals) {
        List<Demo_DMO_Event__c> result = new List<Demo_DMO_Event__c>();
        if (rows == null) return result;
        for (Object rowObj : rows) {
            Map<String, Object> row = (Map<String, Object>) rowObj;
            Demo_DMO_Event__c evt = new Demo_DMO_Event__c();
            Integer refIdx = (Integer) row.get('individualRef');
            if (refIdx == null || refIdx < 0 || refIdx >= individuals.size()) continue;
            evt.Individual__c = individuals[refIdx].Id;
            row.remove('individualRef');
            applyFields(evt, row);
            result.add(evt);
        }
        return result;
    }

    private static List<Demo_DMO_Transaction__c> buildTransactions(List<Object> rows, List<Demo_DMO_Individual__c> individuals) {
        List<Demo_DMO_Transaction__c> result = new List<Demo_DMO_Transaction__c>();
        if (rows == null) return result;
        for (Object rowObj : rows) {
            Map<String, Object> row = (Map<String, Object>) rowObj;
            Demo_DMO_Transaction__c txn = new Demo_DMO_Transaction__c();
            Integer refIdx = (Integer) row.get('individualRef');
            if (refIdx == null || refIdx < 0 || refIdx >= individuals.size()) continue;
            txn.Individual__c = individuals[refIdx].Id;
            row.remove('individualRef');
            applyFields(txn, row);
            result.add(txn);
        }
        return result;
    }

    private static void applyFields(SObject target, Map<String, Object> row) {
        Map<String, Schema.SObjectField> fieldMap = target.getSObjectType().getDescribe().fields.getMap();
        for (String key : row.keySet()) {
            Schema.SObjectField f = fieldMap.get(key.toLowerCase());
            if (f == null) continue;
            Schema.DescribeFieldResult fd = f.getDescribe();
            if (!fd.isCreateable()) continue;
            Object rawVal = row.get(key);
            target.put(f, coerce(rawVal, fd.getType()));
        }
    }

    private static Object coerce(Object raw, Schema.DisplayType t) {
        if (raw == null) return null;
        if (t == Schema.DisplayType.DATE && raw instanceof String) {
            return Date.valueOf((String) raw);
        }
        if (t == Schema.DisplayType.DATETIME && raw instanceof String) {
            return DateTime.valueOfGmt(((String) raw).replace('T', ' ').replace('Z', ''));
        }
        return raw;
    }

    private static void insertInChunks(List<SObject> rows, Integer chunkSize) {
        for (Integer i = 0; i < rows.size(); i += chunkSize) {
            Integer stopAt = Math.min(i + chunkSize, rows.size());
            List<SObject> slice = new List<SObject>();
            for (Integer j = i; j < stopAt; j++) slice.add(rows[j]);
            insert slice;
        }
    }
}
