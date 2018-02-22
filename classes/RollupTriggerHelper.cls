public with sharing class RollupTriggerHelper {
	
   // show comparison variables 
	private	static Schema.SObjectType eventType = Schema.getGlobalDescribe().get('Event'); 
	private	static Schema.SObjectType taskType = Schema.getGlobalDescribe().get('Task'); 
	private	static Schema.SObjectType accountType = Schema.getGlobalDescribe().get('Account'); 
	private	static Schema.SObjectType opportunityType = Schema.getGlobalDescribe().get('Opportunity'); 
	private	static Schema.SObjectType contactType = Schema.getGlobalDescribe().get('Contact'); 
	private	static Schema.SObjectType leadType = Schema.getGlobalDescribe().get('Lead'); 

    
    // which activity are we talking about
    private static boolean isEvent = false;
    private static boolean isTask = false;    

    public static void BeforeDelete (List <SObject> activities) {
    	DoActivities (activities, true);
    }


/*
 	 public static void AfterDelete (List <SObject> activities) {
    	DoActivities (activities);
    }
 */  
	public static void AfterInsert (List <SObject> activities) {
system.debug('activities.size(): ' + activities.size());		
    	DoActivities (activities, false);
    }	
    
    public static void AfterUndelete (List <SObject> activities) {
   		DoActivities (activities, false);
   	}   	
   	   	
   	private static void DoActivities (List <SObject> activities, boolean isDelete) {
   		
   		// Activity list
   		List<Task> tasks;  // We're gonna...Bulk You Up!
   		List<Event> events;

   		Integer whatCnt;
   		Integer whoCnt;
        
        Account updateAccount;
        Opportunity updateOpportunity;
        Contact updateContact;
        Lead UpdateLead;
        if (activities.size() < 1) return;  // Nothing to see here
        if (activities.getSObjectType() == TaskType && activities.getSObjectType() == EventType) return; // No idea how we got here
        
   		if (activities.getSObjectType() == TaskType) {
   			isTask = true;                // talking about tasks
            tasks = activities;           // SObject now needs to be of type Task
 		}  else if (activities.getSObjectType() == EventType) {
   			isEvent = true;               // talking about events
   			events = activities;          // SObject now needs to be of type Event
 		}
   		
   		if (isTask) {
	  		for (Task t: tasks) {
	     		// Trigger bulkified
	     		// Get a count based on what or who id
	     		system.debug('istask whatid: ' + t.whatId);
	     		system.debug('istask whoid: ' + t.whoId);
	     		if (t.whatid != null && t.whoid != null) {
	        		SetEventTaskCountWhoIdandWhatId(t.whoId, t.whatId, isTask, isEvent, isDelete);
	     		} else if (t.whatid != null) {
					SetEventTaskCountWhoIdandWhatId(null, t.whatId, isTask, isEvent, isDelete);	     			
	     		} else if (t.whoid != null) {
					SetEventTaskCountWhoIdandWhatId(t.whoId, null, isTask, isEvent, isDelete);	     		}
	  		}
   		} else if (isEvent) {
   			for (Event e: Events) {
				if (e.whatid != null && e.whoid != null) {
					SetEventTaskCountWhoIdandWhatId(e.whoId, e.whatId, isTask, isEvent, isDelete);
				} else if (e.whatid != null) {
					SetEventTaskCountWhoIdandWhatId(null, e.whatId, isTask, isEvent, isDelete);
				} else if (e.whoid != null) {
					SetEventTaskCountWhoIdandWhatId(e.whoId, null, isTask, isEvent, isDelete);
				}
			}
   		}
   		
	}

	private static void SetEventTaskCountWhoIdandWhatId(ID whoId, ID whatId, boolean isTask, boolean isEvent, boolean isDelete) {
		Account     findAccount;
		Opportunity findOpportunity;
		Contact 	findContact;
		Lead    	findLead;
		
		Integer cnt = 0;
		
        if (whatId != null) {
			if (whatId.getSObjectType() == accountType) {
				findAccount = [SELECT ID, Event_Count__c from Account where id =:whatId];
                if (isEvent) {
                	cnt = [SELECT Count() FROM Event e where e.whatId=:whatId];
					if (isDelete) cnt = cnt - 1;
					findAccount.Event_Count__c = cnt;
                }
				else if (isTask) {
                	cnt = [SELECT Count() FROM Task t where t.whatId=:whatId];
					if (isDelete) cnt = cnt - 1;
					findAccount.Task_Count__c =  cnt;
				}	
				update findAccount;
			} else if (whatId.getSObjectType() == opportunityType) {
				findOpportunity = [SELECT ID, Event_Count__c from Opportunity where id =:whatId];
                if (isEvent) {
                	cnt = [SELECT Count() FROM Event e where e.whatId=:whatId];
					if (isDelete) cnt = cnt - 1;
					findOpportunity.Event_Count__c = cnt;
                }
				else if (isTask) {
					cnt = [SELECT Count() FROM Task t where t.whatId=:whatId];
					if (isDelete) cnt = cnt - 1;
					findOpportunity.Task_Count__c = cnt;
				}
				update findOpportunity;
			} 
        }
		
		if (whoId != null) {
			if (whoId.getSObjectType() == contactType) {
				findContact = [SELECT ID, Event_Count__c from Contact where id =:whoId];
                if (isEvent) {
				   	cnt = [SELECT Count() FROM Event e where e.whoId=:whoId];
					if (isDelete) cnt = cnt - 1;
					findContact.Event_Count__c = cnt;
                }
				else if (isTask) {
					cnt = [SELECT Count() FROM Task t where t.whoId=:whoId];
					if (isDelete) cnt = cnt - 1;
					findContact.Task_Count__c = cnt;
				}
				update findContact;
			} else if (whoId.getSObjectType() == leadType) {
				findLead = [SELECT ID, Event_Count__c from Lead where id =:whoId];
                if (isEvent) {
				   	cnt = [SELECT Count() FROM Event e where e.whoId=:whoId];
					if (isDelete) cnt = cnt - 1;
					findLead.Event_Count__c = cnt;
                }
				else if (isTask) {
					cnt = [SELECT Count() FROM Task t where t.whoId=:whoId];
					if (isDelete) cnt = cnt - 1;
					findLead.Task_Count__c = cnt;
				}
				update findLead;
			}	
		}
	}    
}