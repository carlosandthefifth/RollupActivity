trigger RollupTriggerTask on Task (before delete, after insert, after undelete) {

   if (trigger.isafter) {
	 	if (trigger.isInsert)
	 		RollupTriggerHelper.AfterInsert (Trigger.new);

	 	if (trigger.isUndelete) 
	 		RollupTriggerHelper.AfterUndelete (Trigger.new);
		
				  	
	} else if (trigger.isBefore)
		RollupTriggerHelper.BeforeDelete(Trigger.old);   	
}