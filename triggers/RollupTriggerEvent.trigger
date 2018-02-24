trigger RollupTriggerEvent on Event (after delete, after insert, after undelete) {
 	if (trigger.isInsert)
 		RollupTriggerHelper.AfterInsert (Trigger.new);

 	if (trigger.isUndelete)
 		RollupTriggerHelper.AfterUndelete (Trigger.new);

    if (trigger.isDelete)
		RollupTriggerHelper.AfterDelete (Trigger.old);
}
