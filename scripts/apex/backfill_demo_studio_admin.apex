// Assign Demo_Studio_Admin to every active user that doesn't already have it.
// Idempotent: skips users who already hold the permset.
PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Demo_Studio_Admin' LIMIT 1];

Set<Id> alreadyAssigned = new Set<Id>();
for (PermissionSetAssignment a : [
    SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id
]) {
    alreadyAssigned.add(a.AssigneeId);
}

List<PermissionSetAssignment> toInsert = new List<PermissionSetAssignment>();
for (User u : [SELECT Id FROM User WHERE IsActive = true AND UserType = 'Standard']) {
    if (!alreadyAssigned.contains(u.Id)) {
        toInsert.add(new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        ));
    }
}

if (!toInsert.isEmpty()) {
    Database.SaveResult[] results = Database.insert(toInsert, false);
    Integer ok = 0, fail = 0;
    for (Database.SaveResult r : results) {
        if (r.isSuccess()) ok++;
        else {
            fail++;
            System.debug('Assign failed: ' + r.getErrors());
        }
    }
    System.debug('Backfill complete. Assigned: ' + ok + ', Failed: ' + fail + ', Already had it: ' + alreadyAssigned.size());
} else {
    System.debug('Nothing to backfill. Already assigned to ' + alreadyAssigned.size() + ' users.');
}
