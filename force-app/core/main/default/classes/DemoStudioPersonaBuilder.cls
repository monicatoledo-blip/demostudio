/**
 * Builds a complete Demo_Persona__c (with children) from a JSON blob.
 * Invocable from Flow so a Screen Flow can accept either raw JSON (paste from
 * an LLM) or structured Screen Flow inputs -> serialize -> call this.
 *
 * The JSON shape mirrors the "component recipe" plus persona/child fields:
 * {
 *   "persona": { "First_Name__c": "...", "Title__c": "...", ... },
 *   "themeId": "a2z...",   // OR "themeName": "Cumulus Bank"
 *   "identities": [ {"Type__c":"Email","Value__c":"...","Label__c":"Primary"}, ... ],
 *   "insights":  [ {...}, ... ],
 *   "activities":[ {...}, ... ],
 *   "journeys":  [ {...}, ... ],
 *   "recipe":    { "leftRail":[...], "center":[...], "rightRail":[...] }
 * }
 */
public with sharing class DemoStudioPersonaBuilder {

    public class BuildRequest {
        @InvocableVariable(required=true label='Persona JSON') public String personaJson;
    }
    public class BuildResult {
        @InvocableVariable(label='Persona Id') public String personaId;
        @InvocableVariable(label='Persona Name') public String personaName;
    }

    @InvocableMethod(label='Build Demo Persona from JSON'
                     description='Creates a Demo_Persona__c plus its child records from a JSON payload.')
    public static List<BuildResult> build(List<BuildRequest> requests) {
        List<BuildResult> results = new List<BuildResult>();
        for (BuildRequest req : requests) {
            results.add(buildOne(req.personaJson));
        }
        return results;
    }

    private static BuildResult buildOne(String rawJson) {
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(rawJson);
        Map<String, Object> personaMap = (Map<String, Object>) payload.get('persona');

        // Resolve theme
        Id themeId = null;
        if (payload.containsKey('themeId') && payload.get('themeId') != null) {
            themeId = (Id) payload.get('themeId');
        } else if (payload.containsKey('themeName') && payload.get('themeName') != null) {
            String tn = (String) payload.get('themeName');
            List<Demo_Theme__c> ts = [SELECT Id FROM Demo_Theme__c WHERE Name = :tn LIMIT 1];
            if (!ts.isEmpty()) themeId = ts[0].Id;
        }

        Demo_Persona__c p = new Demo_Persona__c();
        applyFields(p, personaMap);
        if (themeId != null) p.Theme__c = themeId;
        if (payload.containsKey('recipe')) {
            p.Component_Recipe__c = JSON.serialize(payload.get('recipe'));
        }
        insert p;

        insertChildren('Demo_Persona_Identity__c', (List<Object>) payload.get('identities'), p.Id);
        insertChildren('Demo_Persona_Insight__c',  (List<Object>) payload.get('insights'), p.Id);
        insertChildren('Demo_Persona_Activity__c', (List<Object>) payload.get('activities'), p.Id);
        insertChildren('Demo_Persona_Journey__c',  (List<Object>) payload.get('journeys'), p.Id);

        BuildResult r = new BuildResult();
        r.personaId = p.Id;
        r.personaName = p.Name;
        return r;
    }

    private static void insertChildren(String sobjectName, List<Object> rows, Id personaId) {
        if (rows == null || rows.isEmpty()) return;
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sobjectName);
        if (t == null) return;
        List<SObject> toInsert = new List<SObject>();
        for (Object o : rows) {
            SObject child = t.newSObject();
            applyFields(child, (Map<String, Object>) o);
            child.put('Persona__c', personaId);
            toInsert.add(child);
        }
        insert toInsert;
    }

    private static void applyFields(SObject record, Map<String, Object> values) {
        if (values == null) return;
        Map<String, Schema.SObjectField> fieldMap = record.getSObjectType().getDescribe().fields.getMap();
        for (String key : values.keySet()) {
            String lk = key.toLowerCase();
            if (!fieldMap.containsKey(lk)) continue;
            if (lk == 'id') continue;
            Object v = values.get(key);
            if (v == null) continue;
            Schema.DescribeFieldResult dfr = fieldMap.get(lk).getDescribe();
            Schema.DisplayType t = dfr.getType();
            try {
                if (t == Schema.DisplayType.CURRENCY || t == Schema.DisplayType.DOUBLE) {
                    record.put(key, Decimal.valueOf(String.valueOf(v)));
                } else if (t == Schema.DisplayType.INTEGER) {
                    record.put(key, Integer.valueOf(String.valueOf(v)));
                } else if (t == Schema.DisplayType.DATE) {
                    record.put(key, Date.valueOf(String.valueOf(v)));
                } else {
                    record.put(key, v);
                }
            } catch (Exception e) {
                // best-effort skip
            }
        }
    }
}
