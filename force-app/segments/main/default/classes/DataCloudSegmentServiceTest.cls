@isTest
private class DataCloudSegmentServiceTest {

    private static List<Demo_DMO_Individual__c> makeIndividuals() {
        List<Demo_DMO_Individual__c> rows = new List<Demo_DMO_Individual__c>{
            new Demo_DMO_Individual__c(First_Name__c='Amy', Last_Name__c='A', Tier__c='Gold',    Household_Income__c=250000, Lifecycle_Stage__c='Active'),
            new Demo_DMO_Individual__c(First_Name__c='Bob', Last_Name__c='B', Tier__c='Platinum',Household_Income__c=500000, Lifecycle_Stage__c='Active'),
            new Demo_DMO_Individual__c(First_Name__c='Cid', Last_Name__c='C', Tier__c='Silver',  Household_Income__c=75000,  Lifecycle_Stage__c='Prospect'),
            new Demo_DMO_Individual__c(First_Name__c='Dee', Last_Name__c='D', Tier__c='Bronze',  Household_Income__c=45000,  Lifecycle_Stage__c='Churned')
        };
        insert rows;
        return rows;
    }

    @isTest
    static void describe_returns_root_and_related() {
        DataCloudSegmentService.DmoDescribeResult r = DataCloudSegmentService.describeIndividualDmo();
        System.assertEquals('Demo_DMO_Individual__c', r.root.apiName);
        System.assert(r.root.attributes.size() > 10, 'expected many attributes');
        System.assertEquals(2, r.relatedObjects.size());
    }

    @isTest
    static void count_matches_direct_filter() {
        makeIndividuals();
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Tier__c","op":"in","value":["Gold","Platinum"]}]}';
        Integer n = DataCloudSegmentService.countMatching(json);
        System.assertEquals(2, n);
    }

    @isTest
    static void sample_returns_sample_rows() {
        makeIndividuals();
        String json = '{"kind":"container","operator":"AND","include":true,"children":[' +
                      '{"kind":"direct","field":"Household_Income__c","op":"gt","value":100000}]}';
        List<Demo_DMO_Individual__c> rows = DataCloudSegmentService.sampleMatching(json, 10);
        System.assertEquals(2, rows.size());
    }

    @isTest
    static void save_creates_segment_as_draft() {
        Demo_Segment__c seg = new Demo_Segment__c(Name='Test Segment', Description__c='hi');
        Id id = DataCloudSegmentService.saveSegment(JSON.serialize(seg));
        Demo_Segment__c reloaded = DataCloudSegmentService.getSegment(id);
        System.assertEquals('Draft', reloaded.Status__c);
        System.assertEquals('Individual', reloaded.Segment_On__c);
    }

    @isTest
    static void publish_materializes_memberships() {
        makeIndividuals();
        Demo_Segment__c seg = new Demo_Segment__c(
            Name='High Tier',
            Filter_Json__c='{"kind":"container","operator":"AND","include":true,"children":[' +
                           '{"kind":"direct","field":"Tier__c","op":"in","value":["Gold","Platinum"]}]}'
        );
        Id id = DataCloudSegmentService.saveSegment(JSON.serialize(seg));

        Integer pop = DataCloudSegmentService.publishSegment(id);
        System.assertEquals(2, pop);

        Demo_Segment__c reloaded = DataCloudSegmentService.getSegment(id);
        System.assertEquals('Published', reloaded.Status__c);
        System.assertEquals(2, reloaded.Population_Count__c);
        System.assertNotEquals(null, reloaded.Last_Refreshed__c);

        Integer memCount = [SELECT COUNT() FROM Demo_Segment_Membership__c WHERE Segment__c = :id];
        System.assertEquals(2, memCount);
    }

    @isTest
    static void republish_replaces_previous_memberships() {
        makeIndividuals();
        Demo_Segment__c seg = new Demo_Segment__c(
            Name='All',
            Filter_Json__c='{"kind":"container","operator":"AND","include":true,"children":[' +
                           '{"kind":"direct","field":"Tier__c","op":"eq","value":"Gold"}]}'
        );
        Id id = DataCloudSegmentService.saveSegment(JSON.serialize(seg));
        DataCloudSegmentService.publishSegment(id);

        seg.Id = id;
        seg.Filter_Json__c = '{"kind":"container","operator":"AND","include":true,"children":[' +
                             '{"kind":"direct","field":"Tier__c","op":"eq","value":"Platinum"}]}';
        DataCloudSegmentService.saveSegment(JSON.serialize(seg));
        Integer pop = DataCloudSegmentService.publishSegment(id);

        System.assertEquals(1, pop);
        Integer memCount = [SELECT COUNT() FROM Demo_Segment_Membership__c WHERE Segment__c = :id];
        System.assertEquals(1, memCount, 'previous memberships should be replaced');
    }

    @isTest
    static void list_segments_scope_all() {
        Demo_Segment__c seg = new Demo_Segment__c(Name='List Me');
        insert seg;
        List<Demo_Segment__c> all = DataCloudSegmentService.listSegments('all');
        System.assert(all.size() >= 1);
        List<Demo_Segment__c> mine = DataCloudSegmentService.listSegments('mine');
        System.assert(mine.size() >= 1);
    }

    @isTest
    static void link_persona_to_segment_writes_child() {
        Demo_Persona__c persona = new Demo_Persona__c(Name='P', First_Name__c='P');
        insert persona;
        Demo_Segment__c seg = new Demo_Segment__c(Name='HNW Prospects');
        insert seg;

        Id tagId = DataCloudSegmentService.linkPersonaToSegment(persona.Id, seg.Id);
        Demo_Persona_Segment__c tag = [SELECT Id, Persona__c, Label__c FROM Demo_Persona_Segment__c WHERE Id = :tagId];
        System.assertEquals(persona.Id, tag.Persona__c);
        System.assertEquals('HNW Prospects', tag.Label__c);
    }
}
