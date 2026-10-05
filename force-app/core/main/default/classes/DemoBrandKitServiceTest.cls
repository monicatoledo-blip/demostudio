/**
 * Tests DemoBrandKitService: list/get for Brand Kits (Demo_Theme__c) and
 * Personas (Demo_Persona__c) consumed by Story Studio.
 */
@isTest
private class DemoBrandKitServiceTest {

    @testSetup
    static void setup() {
        insert new Demo_Theme__c(
            Name = 'Target', Primary_Color__c = '#CC0404', Accent_Color__c = '#700202',
            Logo_URL__c = 'https://cdn/logo.png', Secondary_Logo_URL__c = 'https://cdn/sec.png'
        );
        insert new Demo_Persona__c(
            Name = 'Jen Heartley', First_Name__c = 'Jen', Last_Name__c = 'Heartley',
            Title__c = 'Director', Company__c = 'Global Dynamics',
            Primary_Email__c = 'jen@example.com', Primary_Phone__c = '555-0198',
            Avatar_URL__c = 'https://cdn/a.png'
        );
    }

    @isTest
    static void listsAndGetsBrandKit() {
        Id kitId = [SELECT Id FROM Demo_Theme__c WHERE Name = 'Target' LIMIT 1].Id;
        Test.startTest();
        List<Map<String, Object>> kits = DemoBrandKitService.listBrandKits();
        Demo_Theme__c kit = DemoBrandKitService.getBrandKit(kitId);
        Test.stopTest();
        System.assertEquals(1, kits.size(), 'One brand kit listed.');
        System.assertEquals('Target', kits[0].get('label'));
        System.assertEquals('#CC0404', kits[0].get('primary'));
        System.assertEquals('Target', kit.Name);
    }

    @isTest
    static void listsAndGetsPersona() {
        Id pId = [SELECT Id FROM Demo_Persona__c WHERE First_Name__c = 'Jen' LIMIT 1].Id;
        Test.startTest();
        List<Map<String, Object>> personas = DemoBrandKitService.listPersonas();
        Demo_Persona__c p = DemoBrandKitService.getPersona(pId);
        Test.stopTest();
        System.assertEquals(1, personas.size(), 'One persona listed.');
        System.assertEquals('Jen Heartley', personas[0].get('label'));
        System.assert(String.valueOf(personas[0].get('subtitle')).contains('Director'), 'Subtitle has title/company.');
        System.assertEquals('Jen', p.First_Name__c);
    }
}
