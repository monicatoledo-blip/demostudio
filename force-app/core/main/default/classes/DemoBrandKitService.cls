/**
 * Supplies DemoStudio Brand Kits (Demo_Theme__c) and Personas (Demo_Persona__c)
 * to Story Studio so a 2-Way Simulator inherits a brand's colors/logo and a
 * persona's customer identity. Read-only.
 */
public with sharing class DemoBrandKitService {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> listBrandKits() {
        List<Map<String, Object>> out = new List<Map<String, Object>>();
        for (Demo_Theme__c t : [
            SELECT Id, Name, Primary_Color__c, Accent_Color__c, Logo_URL__c, Background_Gradient__c
            FROM Demo_Theme__c ORDER BY Name LIMIT 500
        ]) {
            out.add(new Map<String, Object>{
                'value' => t.Id, 'label' => t.Name,
                'logo' => t.Logo_URL__c, 'primary' => t.Primary_Color__c,
                'accent' => t.Accent_Color__c, 'gradient' => t.Background_Gradient__c
            });
        }
        return out;
    }

    @AuraEnabled
    public static Demo_Theme__c getBrandKit(Id kitId) {
        return [
            SELECT Id, Name, Primary_Color__c, Accent_Color__c, Logo_URL__c, Background_Gradient__c
            FROM Demo_Theme__c WHERE Id = :kitId LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> listPersonas() {
        List<Map<String, Object>> out = new List<Map<String, Object>>();
        for (Demo_Persona__c p : [
            SELECT Id, Name, First_Name__c, Last_Name__c, Title__c, Company__c, Avatar_URL__c
            FROM Demo_Persona__c ORDER BY Name LIMIT 500
        ]) {
            String sub = String.join(new List<String>{
                p.Title__c == null ? '' : p.Title__c,
                p.Company__c == null ? '' : p.Company__c
            }, ' · ').trim();
            out.add(new Map<String, Object>{
                'value' => p.Id, 'label' => p.Name,
                'subtitle' => sub, 'avatar' => p.Avatar_URL__c
            });
        }
        return out;
    }

    @AuraEnabled
    public static Demo_Persona__c getPersona(Id personaId) {
        return [
            SELECT Id, Name, First_Name__c, Last_Name__c, Title__c, Company__c,
                   Primary_Email__c, Primary_Phone__c, Primary_Address__c, Avatar_URL__c, Theme__c
            FROM Demo_Persona__c WHERE Id = :personaId LIMIT 1
        ];
    }
}
