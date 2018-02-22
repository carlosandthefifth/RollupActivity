trigger RollupTriggerEvent on Event (before delete, after delete, after insert, after undelete) {
   if (trigger.isafter) {
	 	if (trigger.isInsert)
	 		RollupTriggerHelper.AfterInsert (Trigger.new);
	 		
	 	if (trigger.isUndelete) 
	 		RollupTriggerHelper.AfterUndelete (Trigger.new);

//	 	if (trigger.isDelete) 
//	 		RollupTriggerHelper.AfterDelete (Trigger.new);
   } 
   else 	 	
	 	if (trigger.isDelete)	
	 		RollupTriggerHelper.BeforeDelete (Trigger.old);
      
}