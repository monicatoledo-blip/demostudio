/**
 * Read + write adapter for the Data Cloud Segment Simulator LWCs.
 * Exposes describe metadata for the DMO (so the filter picker is fully
 * customizable), a live-count endpoint driven by the filter tree, save/publish
 * segment operations, and a persona-link helper.
 */
public with sharing class DataCloudSegmentService {

    // ─── Describe / metadata ─────────────────────────────────────────────

    public class AttributeDescriptor {
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public List<PicklistValue> picklistValues;
        @AuraEnabled public String referenceTo;
    }

    public class PicklistValue {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
    }

    public class ObjectDescriptor {
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;
        @AuraEnabled public String pluralLabel;
        @AuraEnabled public List<AttributeDescriptor> attributes;
    }

    public class DmoDescribeResult {
        @AuraEnabled public ObjectDescriptor root;
        @AuraEnabled public List<ObjectDescriptor> relatedObjects;
    }

    @AuraEnabled(cacheable=true)
    public static DmoDescribeResult describeIndividualDmo() {
        DmoDescribeResult result = new DmoDescribeResult();
        result.root = describeObject('Demo_DMO_Individual__c');
        result.relatedObjects = new List<ObjectDescriptor>{
            describeObject('Demo_DMO_Event__c'),
            describeObject('Demo_DMO_Transaction__c')
        };
        return result;
    }

    private static ObjectDescriptor describeObject(String apiName) {
        SObjectType t = Schema.getGlobalDescribe().get(apiName);
        if (t == null) {
            throw new AuraHandledException('Object not found: ' + apiName);
        }
        DescribeSObjectResult d = t.getDescribe();
        ObjectDescriptor od = new ObjectDescriptor();
        od.apiName = apiName;
        od.label = d.getLabel();
        od.pluralLabel = d.getLabelPlural();
        od.attributes = new List<AttributeDescriptor>();
        for (Schema.SObjectField f : d.fields.getMap().values()) {
            Schema.DescribeFieldResult fd = f.getDescribe();
            if (!fd.isAccessible()) continue;
            AttributeDescriptor a = new AttributeDescriptor();
            a.apiName = fd.getName();
            a.label = fd.getLabel();
            a.type = String.valueOf(fd.getType());
            a.isCustom = fd.isCustom();
            if (fd.getType() == Schema.DisplayType.PICKLIST || fd.getType() == Schema.DisplayType.MULTIPICKLIST) {
                a.picklistValues = new List<PicklistValue>();
                for (Schema.PicklistEntry pe : fd.getPicklistValues()) {
                    if (!pe.isActive()) continue;
                    PicklistValue pv = new PicklistValue();
                    pv.value = pe.getValue();
                    pv.label = pe.getLabel();
                    a.picklistValues.add(pv);
                }
            }
            List<Schema.SObjectType> refs = fd.getReferenceTo();
            if (refs != null && !refs.isEmpty()) {
                a.referenceTo = refs[0].getDescribe().getName();
            }
            od.attributes.add(a);
        }
        return od;
    }

    // ─── Segment CRUD ────────────────────────────────────────────────────

    @AuraEnabled(cacheable=true)
    public static List<Demo_Segment__c> listSegments(String scope) {
        Boolean mineOnly = scope == 'mine';
        if (mineOnly) {
            Id uid = UserInfo.getUserId();
            return [
                SELECT Id, Name, Description__c, Status__c, Population_Count__c,
                       Last_Refreshed__c, Publish_Schedule__c, Owner_Persona__c,
                       CreatedDate, LastModifiedDate
                FROM Demo_Segment__c
                WHERE OwnerId = :uid
                ORDER BY LastModifiedDate DESC
                LIMIT 200
            ];
        }
        return [
            SELECT Id, Name, Description__c, Status__c, Population_Count__c,
                   Last_Refreshed__c, Publish_Schedule__c, Owner_Persona__c,
                   CreatedDate, LastModifiedDate
            FROM Demo_Segment__c
            ORDER BY LastModifiedDate DESC
            LIMIT 200
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Demo_Segment__c getSegment(Id segmentId) {
        List<Demo_Segment__c> rows = [
            SELECT Id, Name, Description__c, Segment_On__c, Status__c,
                   Filter_Json__c, Population_Count__c, Last_Refreshed__c,
                   Publish_Schedule__c, Owner_Persona__c
            FROM Demo_Segment__c
            WHERE Id = :segmentId
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    @AuraEnabled
    public static Id saveSegment(String segmentJson) {
        if (String.isBlank(segmentJson)) {
            throw new AuraHandledException('Segment payload is required');
        }
        Demo_Segment__c parsed = (Demo_Segment__c) JSON.deserialize(segmentJson, Demo_Segment__c.class);
        if (parsed.Status__c == null) {
            parsed.Status__c = 'Draft';
        }
        if (parsed.Segment_On__c == null) {
            parsed.Segment_On__c = 'Individual';
        }
        upsert parsed;
        return parsed.Id;
    }

    // ─── Live count / preview ────────────────────────────────────────────

    @AuraEnabled
    public static Integer countMatching(String filterJson) {
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', filterJson);
        String soql = 'SELECT COUNT() FROM Demo_DMO_Individual__c';
        if (String.isNotBlank(wc.fragment)) {
            soql += ' WHERE ' + wc.fragment;
        }
        return Database.countQueryWithBinds(soql, wc.binds, AccessLevel.USER_MODE);
    }

    @AuraEnabled
    public static List<Demo_DMO_Individual__c> sampleMatching(String filterJson, Integer limitN) {
        Integer effectiveLimit = (limitN == null || limitN < 1 || limitN > 50) ? 10 : limitN;
        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', filterJson);
        String soql = 'SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, ' +
                      'Tier__c, Lifecycle_Stage__c, Engagement_Score__c, Ltv__c ' +
                      'FROM Demo_DMO_Individual__c';
        if (String.isNotBlank(wc.fragment)) {
            soql += ' WHERE ' + wc.fragment;
        }
        soql += ' ORDER BY LastModifiedDate DESC LIMIT ' + effectiveLimit;
        return Database.queryWithBinds(soql, wc.binds, AccessLevel.USER_MODE);
    }

    // ─── Publish ─────────────────────────────────────────────────────────

    @AuraEnabled
    public static Integer publishSegment(Id segmentId) {
        Demo_Segment__c seg = getSegment(segmentId);
        if (seg == null) {
            throw new AuraHandledException('Segment not found');
        }
        seg.Status__c = 'Publishing';
        update seg;

        delete [SELECT Id FROM Demo_Segment_Membership__c WHERE Segment__c = :segmentId LIMIT 50000];

        DataCloudFilterCompiler.WhereClause wc =
            DataCloudFilterCompiler.compile('Demo_DMO_Individual__c', seg.Filter_Json__c);
        String soql = 'SELECT Id FROM Demo_DMO_Individual__c';
        if (String.isNotBlank(wc.fragment)) {
            soql += ' WHERE ' + wc.fragment;
        }
        soql += ' LIMIT 50000';
        List<SObject> matches = Database.queryWithBinds(soql, wc.binds, AccessLevel.USER_MODE);

        List<Demo_Segment_Membership__c> memberships = new List<Demo_Segment_Membership__c>();
        DateTime now = DateTime.now();
        for (SObject ind : matches) {
            memberships.add(new Demo_Segment_Membership__c(
                Segment__c = segmentId,
                Individual__c = (Id) ind.get('Id'),
                Qualified_Date__c = now
            ));
        }
        if (!memberships.isEmpty()) {
            insert memberships;
        }

        seg.Status__c = 'Published';
        seg.Population_Count__c = memberships.size();
        seg.Last_Refreshed__c = now;
        update seg;

        return memberships.size();
    }

    // ─── Persona linkage ─────────────────────────────────────────────────

    @AuraEnabled
    public static Id linkPersonaToSegment(Id personaId, Id segmentId) {
        if (personaId == null || segmentId == null) {
            throw new AuraHandledException('Both personaId and segmentId are required');
        }
        Demo_Segment__c seg = [SELECT Id, Name FROM Demo_Segment__c WHERE Id = :segmentId LIMIT 1];
        Demo_Persona_Segment__c tag = new Demo_Persona_Segment__c(
            Persona__c = personaId,
            Label__c = seg.Name
        );
        insert tag;
        return tag.Id;
    }
}
