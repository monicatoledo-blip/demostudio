/**
 * Read-only data adapter for the Demo Studio unified profile shell.
 * Aggregates a persona and its four child collections into a single wire response
 * so LWCs don't each need their own @wire round trip.
 */
public with sharing class DemoStudioService {

    public class PersonaBundle {
        @AuraEnabled public Demo_Persona__c persona;
        @AuraEnabled public Demo_Theme__c theme;
        @AuraEnabled public List<Demo_Persona_Identity__c> identities;
        @AuraEnabled public List<Demo_Persona_Insight__c> insights;
        @AuraEnabled public List<Demo_Persona_Activity__c> activities;
        @AuraEnabled public List<Demo_Persona_Journey__c> journeys;
        @AuraEnabled public List<Demo_Persona_Kpi__c> kpis;
        @AuraEnabled public List<Demo_Persona_Alert__c> alerts;
        @AuraEnabled public List<Demo_Persona_Segment__c> segments;
        @AuraEnabled public List<Demo_Persona_Nba__c> nbas;
    }

    @AuraEnabled(cacheable=true)
    public static PersonaBundle getPersonaBundleForContact(Id contactId) {
        PersonaBundle result = new PersonaBundle();
        if (contactId == null) {
            return result;
        }

        Contact c = [
            SELECT Id, FirstName, LastName, Name, Email, Phone, MailingStreet,
                   MailingCity, MailingState, MailingPostalCode, Title,
                   Account.Name, Demo_Persona__c
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        if (c.Demo_Persona__c == null) {
            return result;
        }

        PersonaBundle bundle = getPersonaBundle(c.Demo_Persona__c);
        overlayContactIdentity(bundle, c);
        return bundle;
    }

    /**
     * When rendering on a real Contact record page, prefer the Contact's own
     * name/email/phone/address over persona defaults IF the persona hasn't
     * been personalized. This keeps the header aligned to the Contact you're
     * viewing (e.g. "Abigail Anderson") rather than showing seeded defaults
     * (e.g. "Rachel Adams") for every unpersonalized persona.
     *
     * A persona is considered "personalized" for a field if it has a
     * non-blank value there. Real persona edits always win.
     */
    private static void overlayContactIdentity(PersonaBundle bundle, Contact c) {
        if (bundle == null || bundle.persona == null || c == null) return;
        Demo_Persona__c p = bundle.persona;
        if (String.isBlank(p.First_Name__c) && String.isNotBlank(c.FirstName)) {
            p.First_Name__c = c.FirstName;
        }
        if (String.isBlank(p.Last_Name__c) && String.isNotBlank(c.LastName)) {
            p.Last_Name__c = c.LastName;
        }
        if (String.isBlank(p.Title__c) && String.isNotBlank(c.Title)) {
            p.Title__c = c.Title;
        }
        if (String.isBlank(p.Company__c) && c.Account != null && String.isNotBlank(c.Account.Name)) {
            p.Company__c = c.Account.Name;
        }
        if (String.isBlank(p.Primary_Email__c) && String.isNotBlank(c.Email)) {
            p.Primary_Email__c = c.Email;
        }
        if (String.isBlank(p.Primary_Phone__c) && String.isNotBlank(c.Phone)) {
            p.Primary_Phone__c = c.Phone;
        }
        if (String.isBlank(p.Primary_Address__c)) {
            List<String> parts = new List<String>();
            if (String.isNotBlank(c.MailingStreet)) parts.add(c.MailingStreet);
            List<String> cityState = new List<String>();
            if (String.isNotBlank(c.MailingCity)) cityState.add(c.MailingCity);
            if (String.isNotBlank(c.MailingState)) cityState.add(c.MailingState);
            String cs = String.join(cityState, ', ');
            if (String.isNotBlank(cs) || String.isNotBlank(c.MailingPostalCode)) {
                parts.add((cs + ' ' + (c.MailingPostalCode == null ? '' : c.MailingPostalCode)).trim());
            }
            if (!parts.isEmpty()) {
                p.Primary_Address__c = String.join(parts, ', ');
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static PersonaBundle getPersonaBundle(Id personaId) {
        PersonaBundle result = new PersonaBundle();
        if (personaId == null) {
            return result;
        }

        List<Demo_Persona__c> personas = [
            SELECT Id, Name, First_Name__c, Last_Name__c, Title__c, Company__c, Brand__c,
                   Avatar_URL__c, Customer_ID__c,
                   Primary_Email__c, Primary_Phone__c, Primary_Address__c,
                   Segment__c, Lifecycle_Stage__c, LTV__c, Currency_Code__c, Propensity__c,
                   Engagement_Score__c, Engagement_Label__c, Risk_Tier__c,
                   Badge_Text__c, Suggested_Opener__c, Intent_Summary__c, Key_Context__c,
                   Open_Likelihood__c, Click_Likelihood__c, Unsubscribe_Risk__c,
                   Component_Recipe__c, Theme__c,
                   Theme__r.Name, Theme__r.Primary_Color__c, Theme__r.Accent_Color__c,
                   Theme__r.Background_Gradient__c, Theme__r.Logo_Static_Resource__c,
                   Theme__r.Font_Family__c, Theme__r.Header_Style__c
            FROM Demo_Persona__c
            WHERE Id = :personaId
            LIMIT 1
        ];

        if (personas.isEmpty()) {
            return result;
        }

        result.persona = personas[0];
        if (result.persona.Theme__c != null) {
            result.theme = new Demo_Theme__c(
                Id = result.persona.Theme__c,
                Name = result.persona.Theme__r.Name,
                Primary_Color__c = result.persona.Theme__r.Primary_Color__c,
                Accent_Color__c = result.persona.Theme__r.Accent_Color__c,
                Background_Gradient__c = result.persona.Theme__r.Background_Gradient__c,
                Logo_Static_Resource__c = result.persona.Theme__r.Logo_Static_Resource__c,
                Font_Family__c = result.persona.Theme__r.Font_Family__c,
                Header_Style__c = result.persona.Theme__r.Header_Style__c
            );
        }

        result.identities = [
            SELECT Id, Type__c, Value__c, Label__c, Sort_Order__c
            FROM Demo_Persona_Identity__c
            WHERE Persona__c = :personaId
            ORDER BY Type__c ASC, Sort_Order__c ASC NULLS LAST
        ];

        result.insights = [
            SELECT Id, Title__c, Category__c, Why_This_Suggestion__c, CTA_Label__c, Image_URL__c, Sort_Order__c
            FROM Demo_Persona_Insight__c
            WHERE Persona__c = :personaId
            ORDER BY Sort_Order__c ASC NULLS LAST
        ];

        result.activities = [
            SELECT Id, Type__c, Title__c, Description__c, Timestamp_Label__c, Icon__c, Sort_Order__c
            FROM Demo_Persona_Activity__c
            WHERE Persona__c = :personaId
            ORDER BY Sort_Order__c ASC NULLS LAST
        ];

        result.journeys = [
            SELECT Id, Journey_Name__c, Business_Unit__c, Status__c, Enrolled_Date__c
            FROM Demo_Persona_Journey__c
            WHERE Persona__c = :personaId
            ORDER BY Enrolled_Date__c DESC NULLS LAST
        ];

        result.kpis = [
            SELECT Id, Label__c, Value__c, Sublabel__c, Is_Highlighted__c, Sort_Order__c
            FROM Demo_Persona_Kpi__c
            WHERE Persona__c = :personaId
            ORDER BY Sort_Order__c ASC NULLS LAST
        ];

        result.alerts = [
            SELECT Id, Category_Label__c, Category_Style__c, Title__c, Body__c, Sort_Order__c
            FROM Demo_Persona_Alert__c
            WHERE Persona__c = :personaId
            ORDER BY Sort_Order__c ASC NULLS LAST
        ];

        result.segments = [
            SELECT Id, Label__c, Sort_Order__c
            FROM Demo_Persona_Segment__c
            WHERE Persona__c = :personaId
            ORDER BY Sort_Order__c ASC NULLS LAST
        ];

        result.nbas = [
            SELECT Id, Title__c, Category__c, Why_This_Suggestion__c, CTA_Label__c, Image_URL__c, Sort_Order__c
            FROM Demo_Persona_Nba__c
            WHERE Persona__c = :personaId
            ORDER BY Sort_Order__c ASC NULLS LAST
        ];

        return result;
    }

    // Scoping helper: a Contact belongs to "me" when either
    //   (a) I assigned the persona → Demo_Assigned_By__c = current user, OR
    //   (b) I created the persona   → Demo_Persona__r.CreatedById = current user.
    // Union semantics. Only used when scope='mine'; scope='all' returns org-wide.
    private static Boolean isMine(String scope) {
        return scope == null || scope == 'mine';
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsForPersona(Id personaId, String scope) {
        if (personaId == null) return new List<Contact>();
        Id me = UserInfo.getUserId();
        if (isMine(scope)) {
            return [
                SELECT Id, Name, FirstName, LastName, Email, Account.Name
                FROM Contact
                WHERE Demo_Persona__c = :personaId
                  AND (Demo_Assigned_By__c = :me OR Demo_Persona__r.CreatedById = :me)
                ORDER BY LastName ASC
                LIMIT 200
            ];
        }
        return [
            SELECT Id, Name, FirstName, LastName, Email, Account.Name
            FROM Contact
            WHERE Demo_Persona__c = :personaId
            ORDER BY LastName ASC
            LIMIT 200
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String term, String scope) {
        if (term == null) term = '';
        term = term.trim();
        Id me = UserInfo.getUserId();
        Boolean mine = isMine(scope);
        if (term.length() < 2) {
            // Recent contacts fallback
            if (mine) {
                return [
                    SELECT Id, Name, Email, Account.Name, Demo_Persona__c
                    FROM Contact
                    WHERE Demo_Assigned_By__c = :me
                       OR Demo_Persona__r.CreatedById = :me
                    ORDER BY LastModifiedDate DESC
                    LIMIT 15
                ];
            }
            return [
                SELECT Id, Name, Email, Account.Name, Demo_Persona__c
                FROM Contact
                ORDER BY LastModifiedDate DESC
                LIMIT 15
            ];
        }
        String pattern = '%' + term + '%';
        if (mine) {
            return [
                SELECT Id, Name, Email, Account.Name, Demo_Persona__c
                FROM Contact
                WHERE (Name LIKE :pattern OR Email LIKE :pattern)
                  AND (Demo_Assigned_By__c = :me OR Demo_Persona__r.CreatedById = :me)
                ORDER BY LastName ASC
                LIMIT 15
            ];
        }
        return [
            SELECT Id, Name, Email, Account.Name, Demo_Persona__c
            FROM Contact
            WHERE Name LIKE :pattern OR Email LIKE :pattern
            ORDER BY LastName ASC
            LIMIT 15
        ];
    }

    @AuraEnabled
    public static void assignContactsToPersona(List<Id> contactIds, Id personaId) {
        if (contactIds == null || contactIds.isEmpty() || personaId == null) return;

        Demo_Persona__c persona = [
            SELECT Id, First_Name__c, Last_Name__c
            FROM Demo_Persona__c WHERE Id = :personaId LIMIT 1
        ];
        String pFirst = String.isBlank(persona.First_Name__c) ? '' : persona.First_Name__c;
        String pLast  = String.isBlank(persona.Last_Name__c)  ? '' : persona.Last_Name__c;
        Boolean hasPersonaName = String.isNotBlank(pFirst) || String.isNotBlank(pLast);

        // Snapshot the ORIGINAL contact name/email/phone before renaming so
        // unassign can restore them. We stash the JSON on the Contact's own
        // Demo_Original_Snapshot__c field.
        List<Contact> existing = [
            SELECT Id, FirstName, LastName, Email, Phone, Demo_Original_Snapshot__c
            FROM Contact WHERE Id IN :contactIds
        ];

        // Track per-initials counter across this persona so JS1 / JS2 (Jacquelyn Smith)
        // don't collide with JR1 (Jacqueline Roberts) etc.
        Map<String, Integer> counterByInitials = suffixCountersForPersona(personaId);

        Id me = UserInfo.getUserId();
        List<Contact> updates = new List<Contact>();
        for (Contact c : existing) {
            Contact u = new Contact(
                Id = c.Id,
                Demo_Persona__c = personaId,
                Demo_Assigned_By__c = me
            );
            if (hasPersonaName) {
                if (String.isBlank(c.Demo_Original_Snapshot__c)) {
                    u.Demo_Original_Snapshot__c = JSON.serialize(new Map<String, String>{
                        'FirstName' => c.FirstName,
                        'LastName'  => c.LastName,
                        'Email'     => c.Email,
                        'Phone'     => c.Phone
                    });
                }
                // Build an identifier from the ORIGINAL contact so Sales still
                // recognizes the person (Rachel Adams JS1 = Jacquelyn Smith's row).
                String initials = buildInitials(c.FirstName, c.LastName);
                Integer n = counterByInitials.containsKey(initials) ? counterByInitials.get(initials) : 0;
                n++;
                counterByInitials.put(initials, n);
                String suffix = initials + String.valueOf(n);

                u.FirstName = pFirst;
                u.LastName  = (String.isBlank(pLast) ? '' : pLast + ' ') + suffix;
            }
            updates.add(u);
        }
        if (!updates.isEmpty()) update updates;
    }

    private static String buildInitials(String first, String last) {
        String f = (String.isBlank(first) ? '' : first.trim().substring(0, 1)).toUpperCase();
        String l = (String.isBlank(last)  ? '' : last.trim().substring(0, 1)).toUpperCase();
        String combined = f + l;
        return String.isBlank(combined) ? 'XX' : combined;
    }

    // Scan existing assignees for suffixes like "JS3" — group by initials so we
    // resume each initial-family's counter on the next assign.
    private static Map<String, Integer> suffixCountersForPersona(Id personaId) {
        Map<String, Integer> maxByInitials = new Map<String, Integer>();
        // Legacy MT<n> suffixes also get bucketed so we don't step on them.
        Pattern p = Pattern.compile('([A-Z]{2})(\\d+)\\s*$');
        for (Contact c : [
            SELECT LastName FROM Contact WHERE Demo_Persona__c = :personaId
        ]) {
            if (c.LastName == null) continue;
            Matcher m = p.matcher(c.LastName);
            if (m.find()) {
                String key = m.group(1);
                Integer n = Integer.valueOf(m.group(2));
                Integer cur = maxByInitials.containsKey(key) ? maxByInitials.get(key) : 0;
                if (n > cur) maxByInitials.put(key, n);
            }
        }
        return maxByInitials;
    }

    @AuraEnabled
    public static void unassignContacts(List<Id> contactIds) {
        if (contactIds == null || contactIds.isEmpty()) return;
        List<Contact> existing = [
            SELECT Id, Demo_Original_Snapshot__c
            FROM Contact WHERE Id IN :contactIds
        ];
        List<Contact> updates = new List<Contact>();
        for (Contact c : existing) {
            Contact u = new Contact(
                Id = c.Id,
                Demo_Persona__c = null,
                Demo_Assigned_By__c = null
            );
            // Restore the original name/email/phone if we stashed a snapshot on assign.
            if (String.isNotBlank(c.Demo_Original_Snapshot__c)) {
                try {
                    Map<String, Object> snap = (Map<String, Object>) JSON.deserializeUntyped(c.Demo_Original_Snapshot__c);
                    u.FirstName = (String) snap.get('FirstName');
                    u.LastName  = (String) snap.get('LastName');
                    u.Email     = (String) snap.get('Email');
                    u.Phone     = (String) snap.get('Phone');
                } catch (Exception ignored) {}
                u.Demo_Original_Snapshot__c = null;
            }
            updates.add(u);
        }
        update updates;
    }

    public class ArchetypeSummary {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String category;
        @AuraEnabled public String description;
        @AuraEnabled public String sampleBrief;
    }

    @AuraEnabled(cacheable=true)
    public static List<ArchetypeSummary> listArchetypes() {
        List<ArchetypeSummary> out = new List<ArchetypeSummary>();
        for (Persona_Archetype__mdt m : [
            SELECT DeveloperName, MasterLabel, Category__c, Description__c, Sample_Brief__c
            FROM Persona_Archetype__mdt
            ORDER BY Category__c ASC, MasterLabel ASC
        ]) {
            ArchetypeSummary s = new ArchetypeSummary();
            s.name = m.DeveloperName;
            s.label = m.MasterLabel;
            s.category = m.Category__c;
            s.description = m.Description__c;
            s.sampleBrief = m.Sample_Brief__c;
            out.add(s);
        }
        return out;
    }

    @AuraEnabled(cacheable=true)
    public static String getArchetypePayload(String archetypeName) {
        if (String.isBlank(archetypeName)) return null;
        List<Persona_Archetype__mdt> rows = [
            SELECT Payload_JSON__c FROM Persona_Archetype__mdt WHERE DeveloperName = :archetypeName LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0].Payload_JSON__c;
    }

    public class ThemeSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String primaryColor;
        @AuraEnabled public String accentColor;
        @AuraEnabled public String backgroundGradient;
        @AuraEnabled public String headerStyle;
        @AuraEnabled public String logoUrl;
    }

    /**
     * Brand Kits the running user should see.
     *   scope='mine' (default) — kits I created OR kits used by a persona I created
     *   scope='all'            — every kit in the org
     */
    @AuraEnabled(cacheable=true)
    public static List<ThemeSummary> listThemes(String scope) {
        Id me = UserInfo.getUserId();
        Boolean mine = isMine(scope);
        List<Demo_Theme__c> rows;
        if (mine) {
            // Union: my CreatedBy OR a personagraph I own already uses it.
            Set<Id> viaPersonas = new Set<Id>();
            for (Demo_Persona__c p : [
                SELECT Theme__c FROM Demo_Persona__c
                WHERE CreatedById = :me AND Theme__c != null
            ]) {
                if (p.Theme__c != null) viaPersonas.add(p.Theme__c);
            }
            rows = [
                SELECT Id, Name, Primary_Color__c, Accent_Color__c, Background_Gradient__c,
                       Header_Style__c, Logo_URL__c, Logo_Static_Resource__c
                FROM Demo_Theme__c
                WHERE CreatedById = :me OR Id IN :viaPersonas
                ORDER BY Name ASC
            ];
        } else {
            rows = [
                SELECT Id, Name, Primary_Color__c, Accent_Color__c, Background_Gradient__c,
                       Header_Style__c, Logo_URL__c, Logo_Static_Resource__c
                FROM Demo_Theme__c
                ORDER BY Name ASC
            ];
        }
        List<ThemeSummary> out = new List<ThemeSummary>();
        for (Demo_Theme__c t : rows) {
            ThemeSummary s = new ThemeSummary();
            s.id = t.Id;
            s.name = t.Name;
            s.primaryColor = t.Primary_Color__c;
            s.accentColor = t.Accent_Color__c;
            s.backgroundGradient = t.Background_Gradient__c;
            s.headerStyle = t.Header_Style__c;
            if (String.isNotBlank(t.Logo_URL__c)) {
                s.logoUrl = t.Logo_URL__c;
            } else if (String.isNotBlank(t.Logo_Static_Resource__c)) {
                s.logoUrl = '/resource/' + t.Logo_Static_Resource__c;
            }
            out.add(s);
        }
        return out;
    }

    @AuraEnabled(cacheable=true)
    public static Demo_Theme__c getTheme(Id themeId) {
        if (themeId == null) return null;
        List<Demo_Theme__c> ts = [
            SELECT Id, Name, Primary_Color__c, Accent_Color__c, Background_Gradient__c,
                   Logo_Static_Resource__c, Logo_URL__c, Font_Family__c, Header_Style__c
            FROM Demo_Theme__c
            WHERE Id = :themeId
            LIMIT 1
        ];
        return ts.isEmpty() ? null : ts[0];
    }

    @AuraEnabled
    public static Id saveTheme(String payloadJson) {
        Map<String, Object> values = (Map<String, Object>) JSON.deserializeUntyped(payloadJson);
        Id themeId = (Id) values.get('Id');
        if (themeId == null) {
            throw new AuraHandledException('Theme.Id is required to save.');
        }
        Demo_Theme__c t = new Demo_Theme__c(Id = themeId);
        applyFields(t, values);
        update t;
        return themeId;
    }

    /**
     * Save a persona bundle. The `payload` mirrors the shape returned by
     * getPersonaBundle. Child collections are diffed by Id: existing rows
     * with an Id in the payload are updated; missing rows are deleted; new
     * rows (no Id) are inserted. Persona fields are updated in place.
     */
    @AuraEnabled
    public static Id savePersonaBundle(String payloadJson) {
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(payloadJson);
        Map<String, Object> personaMap = (Map<String, Object>) payload.get('persona');
        Id personaId = (Id) personaMap.get('Id');
        if (personaId == null) {
            throw new AuraHandledException('Persona.Id is required to save.');
        }

        // Update persona core fields
        Demo_Persona__c p = new Demo_Persona__c(Id = personaId);
        applyFields(p, personaMap);
        update p;

        // Diff children
        syncChildren('Demo_Persona_Identity__c', (List<Object>) payload.get('identities'), personaId);
        syncChildren('Demo_Persona_Insight__c',  (List<Object>) payload.get('insights'), personaId);
        syncChildren('Demo_Persona_Activity__c', (List<Object>) payload.get('activities'), personaId);
        syncChildren('Demo_Persona_Journey__c',  (List<Object>) payload.get('journeys'), personaId);
        syncChildren('Demo_Persona_Kpi__c',      (List<Object>) payload.get('kpis'), personaId);
        syncChildren('Demo_Persona_Alert__c',    (List<Object>) payload.get('alerts'), personaId);
        syncChildren('Demo_Persona_Segment__c',  (List<Object>) payload.get('segments'), personaId);
        syncChildren('Demo_Persona_Nba__c',      (List<Object>) payload.get('nbas'), personaId);

        return personaId;
    }

    private static void syncChildren(String sobjectName, List<Object> rows, Id personaId) {
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sobjectName);
        if (t == null || rows == null) return;

        // Get existing ids for this persona
        Set<Id> existingIds = new Set<Id>();
        for (SObject existing : Database.query(
                'SELECT Id FROM ' + sobjectName + ' WHERE Persona__c = :personaId')) {
            existingIds.add((Id) existing.get('Id'));
        }

        List<SObject> toInsert = new List<SObject>();
        List<SObject> toUpdate = new List<SObject>();
        Set<Id> keepIds = new Set<Id>();

        for (Object o : rows) {
            Map<String, Object> row = (Map<String, Object>) o;
            Id rowId = (Id) row.get('Id');
            SObject rec = t.newSObject();
            applyFields(rec, row);
            rec.put('Persona__c', personaId);
            if (rowId != null) {
                rec.put('Id', rowId);
                keepIds.add(rowId);
                toUpdate.add(rec);
            } else {
                toInsert.add(rec);
            }
        }

        List<SObject> toDelete = new List<SObject>();
        for (Id existingId : existingIds) {
            if (!keepIds.contains(existingId)) {
                toDelete.add(t.newSObject(existingId));
            }
        }

        if (!toDelete.isEmpty()) delete toDelete;
        if (!toUpdate.isEmpty()) update toUpdate;
        if (!toInsert.isEmpty()) insert toInsert;
    }

    private static void applyFields(SObject record, Map<String, Object> values) {
        if (values == null) return;
        Map<String, Schema.SObjectField> fieldMap = record.getSObjectType().getDescribe().fields.getMap();
        Set<String> writableFields = new Set<String>();
        for (String k : fieldMap.keySet()) {
            if (fieldMap.get(k).getDescribe().isUpdateable()) writableFields.add(k);
        }
        for (String key : values.keySet()) {
            String lk = key.toLowerCase();
            if (!writableFields.contains(lk)) continue;
            if (lk == 'id') continue;
            Object v = values.get(key);
            if (v == null) {
                record.put(key, null);
                continue;
            }
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
                // Best-effort: skip a field that fails coercion rather than aborting the whole save
            }
        }
    }
}
