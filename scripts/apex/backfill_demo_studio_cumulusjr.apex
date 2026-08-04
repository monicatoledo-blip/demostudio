// One-time backfill: assign Demo_Studio_Admin permission set to all active
// users on System Administrator or Standard User profiles in Cumulus JR.
// Idempotent — skips users who already have the assignment.
// Run: sf apex run --file scripts/apex/backfill_demo_studio_cumulusjr.apex --target-org cumulusjr

PermissionSet ps = [
    SELECT Id FROM PermissionSet WHERE Name = 'Demo_Studio_Admin' LIMIT 1
];

Set<Id> alreadyAssigned = new Set<Id>();
for (PermissionSetAssignment a : [
    SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id
]) {
    alreadyAssigned.add(a.AssigneeId);
}

List<User> targets = [
    SELECT Id, Username FROM User
    WHERE IsActive = true
    AND Profile.Name IN ('System Administrator', 'Standard User')
];

List<PermissionSetAssignment> toInsert = new List<PermissionSetAssignment>();
for (User u : targets) {
    if (!alreadyAssigned.contains(u.Id)) {
        toInsert.add(new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        ));
    }
}

System.debug('Targets total: ' + targets.size());
System.debug('Already assigned: ' + (targets.size() - toInsert.size()));
System.debug('New assignments to insert: ' + toInsert.size());

if (!toInsert.isEmpty()) {
    Database.SaveResult[] results = Database.insert(toInsert, false);
    Integer ok = 0, fail = 0;
    for (Database.SaveResult r : results) {
        if (r.isSuccess()) ok++;
        else fail++;
    }
    System.debug('Inserted successfully: ' + ok);
    System.debug('Failed: ' + fail);
}
