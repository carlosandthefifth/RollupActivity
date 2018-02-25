trigger RollupTriggerEvent on Event (after delete, after insert, after undelete, after update) {
 	if (trigger.isInsert)
 		RollupTriggerHelper.AfterInsert (Trigger.new);

 	if (trigger.isUndelete)
 		RollupTriggerHelper.AfterUndelete (Trigger.new);

    if (trigger.isDelete)
		RollupTriggerHelper.AfterDelete (Trigger.old);  // trigger.old contains what is to be deleted and trigger new is null

    if (trigger.isUpdate)
        RollupTriggerHelper.AfterUpdate (Trigger.new);  
}