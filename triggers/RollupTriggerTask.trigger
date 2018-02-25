trigger RollupTriggerTask on Task (after delete, after insert, after undelete) {

 	if (trigger.isInsert)
 		RollupTriggerHelper.AfterInsert (Trigger.new);

 	if (trigger.isUndelete)
 		RollupTriggerHelper.AfterUndelete (Trigger.new);

    if (trigger.isDelete) {
/*
ID[] oldIDs = new ID[] {};
ID[] newIDs = new ID[] {};
for (Task t:trigger.old)
oldIds.add(t.id);
for (Task t:trigger.new)
oldIds.add(t.id);

system.debug('trigger.old: ' + oldIds.size());
system.debug('trigger.new: ' + newIds.size());
*/
        RollupTriggerHelper.AfterDelete(Trigger.old);
    }

    if (trigger.isUpdate)
        RollupTriggerHelper.AfterDelete (Trigger.new);
}
