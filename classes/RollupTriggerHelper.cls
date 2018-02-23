public with sharing class RollupTriggerHelper {
	/*
			Rollup Trigger Helper - counts both events and activities and adds the total to a custom field on Account, Contact, Lead and Opportunity.

			Revision Notes:
			February 22, 2018 - hitting SOQL query limit

	*/
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

    private static void buildSObjectList(ID[] idsToFind, boolean isTask, boolean isDelete) {
        String whatObject;
        List <SObject> sObjectList;
        Map <Id, Integer> accountCntMap = new Map <Id, Integer>();
        Map <Id, Integer> opportunityCntMap = new Map <Id, Integer>();
        Map <Id, Integer> contactCntMap = new Map <Id, Integer>();
        Map <Id, Integer> leadCntMap = new Map <Id, Integer>();
        Integer cnt;

        List <Account> updateAccounts = new List <Account>();
        List <Opportunity> updateOpportunities = new List <Opportunity>();
        List <Contact> updateContacts = new List <Contact>();
        List <Lead> updateLeads = new List <Lead>();

        ID[] accountIDs = new ID[0];
        ID[] contactIDs = new ID[0];
        ID[] leadIDs = new ID[0];
        ID[] opportunityIds = new ID[0];

        for (ID idToFind : idsToFind) {
            if (idToFind.getSObjectType() == accountType) {
                accountIds.add(idToFind);
            }
            else if (idToFind.getSObjectType() == contactType) {
                contactIds.add(idToFind);
            }
            else if (idToFind.getSObjectType() == opportunityType) {
                opportunityIds.add(idToFind);
            }
            else if (idToFind.getSObjectType() == leadType) {
                leadIds.add(idToFind);
            }
        }

        if (accountIds.size() > 0) {
            for (ID accountId : accountIds) accountCntMap.put(accountId, 0); // Set the accountid, cnt
            if (isTask) {
                for (Task t : [SELECT Id, whatId FROM Task WHERE whatId IN :accountIDs]) {
                    cnt = accountCntMap.get(t.whatid) + 1;
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    }
                    accountCntMap.put(t.whatId, cnt);
                }
                for (Account acct : [SELECT id, Task_Count__c FROM Account WHERE Id IN :accountIDs]) {
                    cnt = accountCntMap.get(acct.Id);
                    acct.Task_Count__c = cnt;
                    updateAccounts.add(acct);
                }
            } else {
                // events
                for (Event e: [SELECT Id, whatId FROM Event WHERE whatId IN :accountIDs]) {
                    cnt = accountCntMap.get(e.whatid) + 1;
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    }
                    accountCntMap.put(e.whatId, cnt);
                }
                for (Account acct : [SELECT id, Event_Count__c FROM Account WHERE Id IN :accountIDs]) {
                    cnt = accountCntMap.get(acct.Id);
                    acct.Event_Count__c = cnt;
                    updateAccounts.add(acct);
                }
            }
            Database.update(updateAccounts);
        }

        if (opportunityIds.size() > 0) {
            for (ID opportunityId : opportunityIds) opportunityCntMap.put(opportunityId, 0); // Set the accountid, cnt
            if (isTask) {
                for (Task t : [SELECT Id, whatId FROM Task WHERE whatId IN :opportunityIDs]) {
                    cnt = opportunityCntMap.get(t.whatid) + 1;
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    }
                    opportunityCntMap.put(t.whatId, cnt);
                }
                for (Opportunity ops : [SELECT id, Task_Count__c FROM Opportunity WHERE Id IN :opportunityIDs]) {
                    cnt = opportunityCntMap.get(ops.Id);
                    ops.Task_Count__c = cnt;
                    updateOpportunities.add(ops);
                }
            } else {
                // Events
                for (Event e : [SELECT Id, whatId FROM Event WHERE whatId IN :opportunityIDs]) {
                    cnt = opportunityCntMap.get(e.whatid) + 1;
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    }
                    opportunityCntMap.put(e.whatId, cnt);
                }
                for (Opportunity ops : [SELECT id, Event_Count__c FROM Opportunity WHERE Id IN :opportunityIDs]) {
                    cnt = opportunityCntMap.get(ops.Id);
                    ops.Event_Count__c = cnt;
                    updateOpportunities.add(ops);
                }
            }
            Database.update(updateOpportunities);
        }

        if (contactIds.size() > 0) {
            for (ID contactId : contactIds) contactCntMap.put(contactId, 0); // Set the accountid, cnt
            if (isTask) {
                for (Task t : [SELECT Id, whoId FROM Task WHERE whoId IN :contactIDs]) {
                    cnt = contactCntMap.get(t.whoid) + 1;
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    }
                    contactCntMap.put(t.whoId, cnt);
                }
                for (Contact cons : [SELECT id, Task_Count__c FROM Contact WHERE Id IN :contactIDs]) {
                    cnt = contactCntMap.get(cons.Id);
                    cons.Task_Count__c = cnt;
                    updateContacts.add(cons);
                }
            } else {
                // Event
                for (Event e : [SELECT Id, whoId FROM Event WHERE whoId IN :contactIDs]) {
                    cnt = contactCntMap.get(e.whoid) + 1;
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    }
                    contactCntMap.put(e.whoId, cnt);
                }
                for (Contact cons : [SELECT id, Event_Count__c FROM Contact WHERE Id IN :contactIDs]) {
                    cnt = contactCntMap.get(cons.Id);
                    cons.Event_Count__c = cnt;
                    updateContacts.add(cons);
                }
            }
            Database.update(updateContacts);
        }

        if (leadIds.size() > 0) {
            for (ID leadId : leadIds) leadCntMap.put(leadId, 0); // Set the accountid, cnt
            if (isTask) {
                for (Task t : [SELECT Id, whoId FROM Task WHERE whoId IN :leadIDs]) {
                    cnt = leadCntMap.get(t.whoid) + 1;
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    }
                    leadCntMap.put(t.whoId, cnt);
                }
                for (Lead leads : [SELECT id, Task_Count__c FROM Lead WHERE Id IN :leadIDs]) {
                    cnt = leadCntMap.get(leads.Id);
                    leads.Task_Count__c = cnt;
                    updateLeads.add(leads);
                }
            } else {
                // Events
                for (Event e : [SELECT Id, whoId FROM Event WHERE whoId IN :leadIDs]) {
                    cnt = leadCntMap.get(e.whoid) + 1;
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    }
                    leadCntMap.put(e.whoId, cnt);
                }
                for (Lead leads : [SELECT id, Event_Count__c FROM Lead WHERE Id IN :leadIDs]) {
                    cnt = leadCntMap.get(leads.Id);
                    leads.Event_Count__c = cnt;
                    updateLeads.add(leads);
                }
            }
            Database.update(updateLeads);
        }
    }


    public static void BeforeDelete (List <SObject> activities) {
        DoActivities (activities, true);
    }


    /*
public static void AfterDelete (List <SObject> activities) {
DoActivities (activities);
}
*/
    public static void AfterInsert (List <SObject> activities) {
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

        Id[] Ids = new Id[0];

        if (activities.size() < 1) return;  // Nothing to see here
        if (activities.getSObjectType() == TaskType && activities.getSObjectType() == EventType) return; // No idea how we got here

        if (activities.getSObjectType() == TaskType) {
            isTask = true;                // talking about tasks
            tasks = activities;           // SObject now needs to be of type Task
        }  else if (activities.getSObjectType() == EventType) {
            isTask = false;               // talking about events
            events = activities;          // SObject now needs to be of type Event
        }

        if (isTask) {
            for (Task t: tasks) {
                if (t.whoId != null)
                    Ids.add(t.whoId);

                if (t.whatId != null)
                    Ids.add(t.whatId);

            }
        } else {
            for (Event e: events) {
                if (e.whoId != null)
                    Ids.add(e.whoId);

                if (e.whatId != null)
                    Ids.add(e.whatId);
            }
        }
        if (Ids.size() > 0) {
            buildSObjectList(Ids, isTask, isDelete);
        }
    }
}