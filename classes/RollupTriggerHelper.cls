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

    private static List <SObject> buildSObjectList(ID[] idsToFind) {
        String whatObject;
        List <SObject> sObjectList;
        ID[] accountIDs = new ID[0];
        Map <Id, Integer> accountCntMap = new Map <Id, Integer>();
        Integer cnt;

        List <Account> updateAccounts = new List <Account>();

system.debug('idsToFind: ' + idsToFind);

        ID[] contactIDs = new ID[0];
        ID[] leadIDs = new ID[0];
        ID[] opportunityIds = new ID[0];
        for (ID idToFind : idsToFind) {
system.debug('idToFind: ' + idToFind);
            if (idToFind.getSObjectType() == accountType) {
system.debug('adding to accountids');
                accountIds.add(idToFind);
            }
            else if (idToFind.getSObjectType() == contactType) {
system.debug('adding to contactsids');
                contactIds.add(idToFind);
            }
            else if (idToFind.getSObjectType() == opportunityType) {
system.debug('adding to opportunityids');
                opportunityIds.add(idToFind);
            }
            else if (idToFind.getSObjectType() == leadType) {
system.debug('adding to leadids');
                leadIds.add(idToFind);
            }
        }

system.debug('1');
        if (accountIds.size() > 0) {
            for (ID accountId : accountIds) accountCntMap.put(accountId, 0); // Set the accountid, cnt
            system.debug('2 accountids: ' + accountids);
            for (Task t : [SELECT Id, whatId FROM Task WHERE whatId IN :accountIDs]) {
                system.debug('3');
                system.debug('t.whatid: ' + t.whatid);
                cnt = accountCntMap.get(t.whatid) + 1;

                system.debug('cnt: ' + cnt);
                system.debug('t.whatId: ' + t.whatId);

                accountCntMap.put(t.whatId, cnt);

            }
            for (Account acct : [SELECT id, Event_Count__c FROM Account WHERE Id IN :accountIDs]) {
                cnt = accountCntMap.get(acct.Id);
                system.debug('2 cnt: ' + cnt);
                system.debug('acct.id: ' + acct.Id);
                acct.Task_Count__c = cnt;
                updateAccounts.add(acct);
            }
            Database.update(updateAccounts);
/*

            String queryString = 'SELECT ID, Event_Count__c from Account where id  in :accountIds'; // so that we can update Event_Count__c
            sObjectList = Database.query(queryString);

            cnt = [SELECT Count() FROM Task t where t.whatId IN :accountIds];
            if (isDelete) cnt = cnt - 1;
            findAccount.Event_Count__c = cnt;
*/
        }

        if (contactIds.size() > 0) {
            String queryString = 'SELECT ID, Event_Count__c from Contact where id  in :contactIds';
            sObjectList = Database.query(queryString);
        }

        if (LeadIds.size() > 0) {
            String queryString = 'SELECT ID, Event_Count__c from Lead where id  in :leadIds';
            sObjectList = Database.query(queryString);
        }

        if (opportunityIds.size() > 0) {
            String queryString = 'SELECT ID, Event_Count__c from Account where id  in :opportunityIds';
            sObjectList = Database.query(queryString);
        }

        return sObjectList;
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
            isEvent = true;               // talking about events
            events = activities;          // SObject now needs to be of type Event
        }

        for (Task t: tasks) {
            if (t.whoId != null)
                Ids.add(t.whoId);

            if (t.whatId != null)
                Ids.add(t.whatId);

        }
        buildSObjectList(Ids);
    }

    private static void SetEventTaskCountWhoIdandWhatId(ID whoId, ID whatId, boolean isTask, boolean isEvent, boolean isDelete) {
        Account     findAccount;
        Opportunity findOpportunity;
        Contact 	findContact;
        Lead    	findLead;

        Integer cnt = 0;
        system.debug('not running SetEventTaskCountWhoIdandWhatId');
        return;
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