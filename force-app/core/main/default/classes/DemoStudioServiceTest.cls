@isTest
private class DemoStudioServiceTest {

    @TestSetup
    static void setup() {
        Demo_Theme__c theme = TestDataFactory.createTheme('Cumulus Bank', true);
        Demo_Persona__c p = TestDataFactory.createPersona('Sarah', 'Jenkins', theme.Id, true);
        TestDataFactory.createChildren(p.Id);
    }

    private static Demo_Persona__c thePersona() {
        return [SELECT Id FROM Demo_Persona__c WHERE First_Name__c = 'Sarah' LIMIT 1];
    }

    // ---- getPersonaBundle --------------------------------------------------

    @isTest
    static void shouldReturnBundleWithThemeAndChildren_WhenPersonaExists() {
        Id personaId = thePersona().Id;

        Test.startTest();
        DemoStudioService.PersonaBundle b = DemoStudioService.getPersonaBundle(personaId);
        Test.stopTest();

        Assert.isNotNull(b.persona, 'Persona should be returned');
        Assert.isNotNull(b.theme, 'Theme should be hydrated from the lookup');
        Assert.areEqual(1, b.identities.size(), 'Identity child should be returned');
        Assert.areEqual(1, b.kpis.size(), 'KPI child should be returned');
        Assert.areEqual(1, b.segments.size(), 'Segment child should be returned');
    }

    @isTest
    static void shouldReturnEmptyBundle_WhenPersonaIdNull() {
        Test.startTest();
        DemoStudioService.PersonaBundle b = DemoStudioService.getPersonaBundle(null);
        Test.stopTest();
        Assert.isNull(b.persona, 'Null id should yield an empty bundle');
    }

    // ---- getPersonaBundleForContact + overlay ------------------------------

    @isTest
    static void shouldReturnEmpty_WhenContactNullOrNoPersona() {
        Contact c = TestDataFactory.createContact('No', 'Persona', true);

        Test.startTest();
        DemoStudioService.PersonaBundle nullBundle = DemoStudioService.getPersonaBundleForContact(null);
        DemoStudioService.PersonaBundle noPersona = DemoStudioService.getPersonaBundleForContact(c.Id);
        Test.stopTest();

        Assert.isNull(nullBundle.persona, 'Null contact id yields empty bundle');
        Assert.isNull(noPersona.persona, 'Contact without a persona yields empty bundle');
    }

    @isTest
    static void shouldOverlayContactIdentity_WhenPersonaFieldsBlank() {
        Account a = new Account(Name = 'Overlay Corp');
        insert a;
        Demo_Persona__c blank = new Demo_Persona__c(Name = 'Blank One');
        insert blank;
        Contact c = new Contact(
            FirstName = 'Abigail', LastName = 'Anderson', Title = 'CFO',
            Email = 'abigail@overlay.com', Phone = '(212) 555-0100',
            MailingStreet = '1 Market St', MailingCity = 'San Francisco',
            MailingState = 'CA', MailingPostalCode = '94105',
            AccountId = a.Id, Demo_Persona__c = blank.Id
        );
        insert c;

        Test.startTest();
        DemoStudioService.PersonaBundle b = DemoStudioService.getPersonaBundleForContact(c.Id);
        Test.stopTest();

        Assert.areEqual('Abigail', b.persona.First_Name__c, 'Blank first name overlaid from Contact');
        Assert.areEqual('CFO', b.persona.Title__c, 'Blank title overlaid from Contact');
        Assert.areEqual('Overlay Corp', b.persona.Company__c, 'Blank company overlaid from Account');
        Assert.areEqual('abigail@overlay.com', b.persona.Primary_Email__c, 'Blank email overlaid');
        Assert.isTrue(b.persona.Primary_Address__c.contains('San Francisco'), 'Address composed from mailing fields');
    }

    // ---- createContactForPersona (duplicate-rule bypass) -------------------

    @isTest
    static void shouldCreateContact_EvenWhenDuplicateExists() {
        Demo_Persona__c p = thePersona();
        // Pre-existing contact that matches on name+email so the Standard
        // Contact Duplicate Rule would otherwise block a second one.
        insert new Contact(FirstName = 'Sarah', LastName = 'Jenkins', Email = 'valid.person@cumulusbank.com');

        Test.startTest();
        Id newId = DemoStudioService.createContactForPersona(p.Id);
        Test.stopTest();

        Assert.isNotNull(newId, 'Contact should be created despite the duplicate rule');
        Contact created = [SELECT Demo_Persona__c FROM Contact WHERE Id = :newId];
        Assert.areEqual(p.Id, created.Demo_Persona__c, 'New contact should be linked to the persona');
        // The Demo Persona record type is stamped when the running user can
        // assign it; if not, creation still succeeds (crash-proof) — so we
        // assert on the guaranteed outcome (the persona link), not the RT.
    }

    @isTest
    static void shouldReturnNull_WhenCreatingContactForNullPersona() {
        Test.startTest();
        Id newId = DemoStudioService.createContactForPersona(null);
        Test.stopTest();
        Assert.isNull(newId, 'Null persona id should short-circuit to null');
    }

    // ---- assign / unassign -------------------------------------------------

    @isTest
    static void shouldAssignRenameAndSnapshot_ThenRestoreOnUnassign() {
        Demo_Persona__c p = thePersona();
        Contact c = TestDataFactory.createContact('Rachel', 'Adams', true);

        Test.startTest();
        DemoStudioService.assignContactsToPersona(new List<Id>{ c.Id }, p.Id);
        Contact assigned = [SELECT FirstName, LastName, Demo_Persona__c, Demo_Original_Snapshot__c FROM Contact WHERE Id = :c.Id];
        DemoStudioService.unassignContacts(new List<Id>{ c.Id });
        Test.stopTest();

        Assert.areEqual(p.Id, assigned.Demo_Persona__c, 'Persona should be linked on assign');
        Assert.areEqual('Sarah', assigned.FirstName, 'First name renamed to persona');
        Assert.isTrue(assigned.LastName.startsWith('Jenkins'), 'Last name carries persona + initials suffix');
        Assert.isTrue(String.isNotBlank(assigned.Demo_Original_Snapshot__c), 'Original identity snapshot stored');

        Contact restored = [SELECT FirstName, LastName, Demo_Persona__c FROM Contact WHERE Id = :c.Id];
        Assert.isNull(restored.Demo_Persona__c, 'Persona cleared on unassign');
        Assert.areEqual('Rachel', restored.FirstName, 'Original first name restored on unassign');
        Assert.areEqual('Rachel', restored.FirstName, 'Original first name restored');
        Assert.areEqual('Adams', restored.LastName, 'Original last name restored');
    }

    // ---- getContactsForPersona + searchContacts ----------------------------

    @isTest
    static void shouldReturnAssignedContacts_ForMineAndAllScopes() {
        Demo_Persona__c p = thePersona();
        Id newId = DemoStudioService.createContactForPersona(p.Id);

        Test.startTest();
        List<Contact> mine = DemoStudioService.getContactsForPersona(p.Id, 'mine');
        List<Contact> all = DemoStudioService.getContactsForPersona(p.Id, 'all');
        List<Contact> none = DemoStudioService.getContactsForPersona(null, 'mine');
        Test.stopTest();

        Assert.areEqual(1, mine.size(), 'Mine scope should find the contact I created');
        Assert.areEqual(1, all.size(), 'All scope should find it too');
        Assert.areEqual(0, none.size(), 'Null persona returns empty');
    }

    @isTest
    static void shouldSearchRecentAndByPattern() {
        Demo_Persona__c p = thePersona();
        DemoStudioService.createContactForPersona(p.Id); // Sarah Jenkins, assigned by me

        Test.startTest();
        List<Contact> recent = DemoStudioService.searchContacts('', 'mine');   // < 2 chars -> recent
        List<Contact> byName = DemoStudioService.searchContacts('Jenkins', 'mine');
        List<Contact> byNameAll = DemoStudioService.searchContacts('Jenkins', 'all');
        Test.stopTest();

        Assert.isTrue(recent.size() >= 1, 'Recent fallback should return my contacts');
        Assert.isTrue(byName.size() >= 1, 'Pattern search (mine) should match by name');
        Assert.isTrue(byNameAll.size() >= 1, 'Pattern search (all) should match by name');
    }

    // ---- savePersonaBundle (sync + email sanitize) -------------------------

    @isTest
    static void shouldUpdatePersonaSyncChildrenAndCleanEmail() {
        Demo_Persona__c p = thePersona();
        Demo_Persona_Segment__c keep = new Demo_Persona_Segment__c(Persona__c = p.Id, Label__c = 'Keep', Sort_Order__c = 1);
        Demo_Persona_Segment__c drop = new Demo_Persona_Segment__c(Persona__c = p.Id, Label__c = 'Drop', Sort_Order__c = 2);
        insert new List<Demo_Persona_Segment__c>{ keep, drop };

        Map<String, Object> personaMap = new Map<String, Object>{
            'Id' => p.Id,
            'Last_Name__c' => 'Updated',
            'Primary_Email__c' => 'contact@Jennifer Travisarchitecture.com' // has a space -> must clean
        };
        // keep -> update (renamed), drop -> absent (deleted), new -> insert
        List<Object> segments = new List<Object>{
            new Map<String, Object>{ 'Id' => keep.Id, 'Label__c' => 'Renamed', 'Sort_Order__c' => 1 },
            new Map<String, Object>{ 'Label__c' => 'Fresh', 'Sort_Order__c' => 3 }
        };
        Map<String, Object> payload = new Map<String, Object>{ 'persona' => personaMap, 'segments' => segments };

        Test.startTest();
        Id returned = DemoStudioService.savePersonaBundle(JSON.serialize(payload));
        Test.stopTest();

        Assert.areEqual(p.Id, returned, 'Save should return the persona id');
        Demo_Persona__c after = [SELECT Last_Name__c, Primary_Email__c FROM Demo_Persona__c WHERE Id = :p.Id];
        Assert.areEqual('Updated', after.Last_Name__c, 'Persona field should update');
        // Email fields are stored lowercase by the platform; the point is the
        // space was stripped and the value saved rather than throwing.
        Assert.areEqual('contact@jennifertravisarchitecture.com', after.Primary_Email__c, 'Spaced email should be cleaned, not rejected');

        Map<String, Integer> labels = new Map<String, Integer>();
        for (Demo_Persona_Segment__c s : [SELECT Label__c FROM Demo_Persona_Segment__c WHERE Persona__c = :p.Id]) {
            labels.put(s.Label__c, 1);
        }
        Assert.isTrue(labels.containsKey('Renamed'), 'Existing segment should be updated');
        Assert.isTrue(labels.containsKey('Fresh'), 'New segment should be inserted');
        Assert.isFalse(labels.containsKey('Drop'), 'Omitted segment should be deleted');
    }

    @isTest
    static void shouldThrow_WhenSavingBundleWithoutPersonaId() {
        Map<String, Object> payload = new Map<String, Object>{ 'persona' => new Map<String, Object>() };
        Test.startTest();
        try {
            DemoStudioService.savePersonaBundle(JSON.serialize(payload));
            Assert.fail('Expected AuraHandledException when persona id missing');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e, 'AuraHandledException expected');
        }
        Test.stopTest();
    }

    // ---- sanitizeEmail (direct, @TestVisible) ------------------------------

    @isTest
    static void shouldSanitizeEmails() {
        Assert.areEqual('contact@JenniferTravisarchitecture.com',
            DemoStudioService.sanitizeEmail('contact@Jennifer Travisarchitecture.com'),
            'Whitespace should be stripped to produce a valid address');
        Assert.areEqual('a@b.com', DemoStudioService.sanitizeEmail('a@b.com'), 'A valid address passes through');
        Assert.isNull(DemoStudioService.sanitizeEmail('not-an-email'), 'An unsalvageable value drops to null');
        Assert.isNull(DemoStudioService.sanitizeEmail('   '), 'Blank drops to null');
    }

    // ---- themes ------------------------------------------------------------

    @isTest
    static void shouldListThemesForMineAndAll_AndGetById() {
        Demo_Theme__c t = [SELECT Id FROM Demo_Theme__c WHERE Name = 'Cumulus Bank' LIMIT 1];

        Test.startTest();
        List<DemoStudioService.ThemeSummary> mine = DemoStudioService.listThemes('mine');
        List<DemoStudioService.ThemeSummary> all = DemoStudioService.listThemes('all');
        Demo_Theme__c fetched = DemoStudioService.getTheme(t.Id);
        Demo_Theme__c none = DemoStudioService.getTheme(null);
        Test.stopTest();

        Assert.isTrue(mine.size() >= 1, 'Mine scope should include my kit (used by my persona)');
        Assert.isTrue(all.size() >= 1, 'All scope should include the kit');
        Assert.areEqual(t.Id, fetched.Id, 'getTheme should fetch by id');
        Assert.isNull(none, 'getTheme(null) returns null');
    }

    @isTest
    static void shouldSaveTheme_AndThrowWithoutId() {
        Demo_Theme__c t = [SELECT Id FROM Demo_Theme__c WHERE Name = 'Cumulus Bank' LIMIT 1];
        Map<String, Object> payload = new Map<String, Object>{ 'Id' => t.Id, 'Name' => 'Renamed Kit', 'Primary_Color__c' => '#FF0000' };

        Test.startTest();
        Id savedId = DemoStudioService.saveTheme(JSON.serialize(payload));
        try {
            DemoStudioService.saveTheme(JSON.serialize(new Map<String, Object>()));
            Assert.fail('Expected AuraHandledException without theme id');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e, 'AuraHandledException expected');
        }
        Test.stopTest();

        Assert.areEqual(t.Id, savedId, 'saveTheme returns the theme id');
        Assert.areEqual('Renamed Kit', [SELECT Name FROM Demo_Theme__c WHERE Id = :t.Id].Name, 'Theme should be renamed');
    }

    // ---- archetypes --------------------------------------------------------

    @isTest
    static void shouldListArchetypesAndFetchPayload() {
        Test.startTest();
        List<DemoStudioService.ArchetypeSummary> summaries = DemoStudioService.listArchetypes();
        String payload = DemoStudioService.getArchetypePayload('Commercial_Cross_Sell');
        String none = DemoStudioService.getArchetypePayload(null);
        Test.stopTest();

        Assert.isTrue(summaries.size() >= 1, 'Archetypes should be listed from custom metadata');
        Assert.isNotNull(payload, 'Known archetype should return its payload JSON');
        Assert.isNull(none, 'Blank name returns null payload');
    }
}
