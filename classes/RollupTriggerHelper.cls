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
/*
        Map <Id, Integer> accountCntMap = new Map <Id, Integer>();
        Map <Id, Integer> opportunityCntMap = new Map <Id, Integer>();
        Map <Id, Integer> contactCntMap = new Map <Id, Integer>();
        Map <Id, Integer> leadCntMap = new Map <Id, Integer>();
*/
system.debug('bol 1');
        String soqlQuery;    // Dynamic soql query string
system.debug('bol 2');
        Map<boolean, String> activityType = new Map<boolean, String> {true => 'task', false => 'event'};
system.debug('bol 3');
system.debug('bol 4');
        Map<boolean, String> updateField = new Map<boolean, String> {true => 'Task_Count__c', false => 'Event_Count__c'};
system.debug('bol 5');
        Map <Id, Integer> sObjectCntMap = new Map <Id, Integer>();  // SObject, activity count
system.debug('bol 6');
        List <SObject> whatActivities = new List <SObject>(); // Handle Tasks AND/OR Events
        List <SObject> whoActivities = new List <SObject>(); // Handle Tasks AND/OR Events
        Task T;
        Event E;

        ID[] whoIds = new ID[] {};
        ID[] whatIds = new ID[] {};

        Integer cnt;   // Hold new activity count

        // For updating enmasse
        List <Account> updateAccounts = new List <Account>();
system.debug('bol 7');
        List <Opportunity> updateOpportunities = new List <Opportunity>();
system.debug('bol 8');
        List <Contact> updateContacts = new List <Contact>();
system.debug('bol 9');
        List <Lead> updateLeads = new List <Lead>();
system.debug('bol 10');

        boolean isAccount = false;
        boolean isContact = false;
        boolean isLead = false;
        boolean isOpportunity = false;
        boolean isWhatid; // If relating to accounts or opportunities

/*
        ID[] accountIDs = new ID[0];
        ID[] contactIDs = new ID[0];
        ID[] leadIDs = new ID[0];
        ID[] opportunityIds = new ID[0];
*/
        // Which SObject are we talking about - used to build dynamic soql query
        // Rules need to be only one type of SObject can be created during an insert, delete, undelete
        // I can't see a way where a trigger would start off related to an account and then switch to contact in the same
        // apex transaction
        system.debug('bol 11');
        for (ID idToFind : idsToFind) {
            system.debug('bol 12');
system.debug('idToFind: ' + idToFind);

            if (!isAccount) {
                system.debug('bol 12.1');
                isAccount = (idToFind.getSObjectType() == accountType);
                system.debug('bol 13');
            }

            if (!isContact) {
                system.debug('bol 12.2');
                isContact = (idToFind.getSObjectType() == contactType);
                system.debug('bol 14');
            }
            if (!isLead) {
                system.debug('bol 12.3');
                isLead  = (idToFind.getSObjectType() == leadType);
                system.debug('bol 15');
            }
            if (!isOpportunity) {
                system.debug('bol 12.4');
                isOpportunity = (idToFind.getSObjectType() == opportunityType);
                system.debug('bol 16');
            }

        }

system.debug('idsToFind: ' + idsToFind);
system.debug('1');
        for (ID idToFind : idsToFind) {
                sObjectCntMap.put(idToFind, 0); // Stuff id in map with roll up count zero
                if (idToFind.getSObjectType() == accountType || idToFind.getSObjectType() == opportunityType)
                    whatIds.add(idToFind);
                else
                    whoIds.add(idToFind);
            }
system.debug('2');

        soqlQuery = 'SELECT Id, whatid FROM '+ activityType.get(isTask) +' WHERE  whatId IN :idsToFind';
        whatActivities =  Database.query(soqlQuery);
system.debug('whatActivities' + whatActivities);

        soqlQuery = 'SELECT Id, whoid FROM '+ activityType.get(isTask) +' WHERE whoId IN :idsToFind';
        whoActivities =  Database.query(soqlQuery);
system.debug('whoActivities' + whoActivities);

system.debug('3');

        if (whatActivities.size() > 0) {
system.debug('4');
            for (SObject a : whatActivities) {
system.debug('5');
                if (isTask){
system.debug('7');
                    T = (Task) a;
system.debug('8');
                    cnt = SObjectCntMap.get(T.whatid) + 1;
system.debug('9');
                } else {
system.debug('10');
                    E =  (Event) a;
system.debug('11');
                    cnt = SObjectCntMap.get(E.whatid) + 1;
system.debug('12');
                }

                if (isDelete) {
system.debug('19');
                    if (cnt > 0)
                        cnt--;
                    else
                    cnt = 0;
system.debug('20');
                }
                if (isTask)
                    SObjectCntMap.put(T.whatId, cnt);
                else
                    SObjectCntMap.put(E.whatId, cnt);

system.debug('25');
            }

        }

        if (whoActivities.size() > 0) {
system.debug('4');
            for (SObject a : whoActivities) {
system.debug('5');
                if (isTask){
system.debug('7');
                    T = (Task) a;
system.debug('8');
                    cnt = SObjectCntMap.get(T.whoid) + 1;
system.debug('9');
                } else {
system.debug('10');
                    E =  (Event) a;
system.debug('11');
                    cnt = SObjectCntMap.get(E.whoid) + 1;
system.debug('12');
                }

                if (isDelete) {
system.debug('19');
                    if (cnt > 0)
                        cnt--;
                    else
                    cnt = 0;
system.debug('20');
                }
                if (isTask)
                    SObjectCntMap.put(T.whoId, cnt);
                else
                    SObjectCntMap.put(E.whoId, cnt);

system.debug('25');
            }

        }

        if (isAccount) {
system.debug('26');
            soqlQuery = 'SELECT id, ' + updateField.get(isTask) + ' FROM Account WHERE Id IN :idsToFind';
system.debug('soqlQuery: ' + soqlQuery);
            List <Account> accounts = Database.query(soqlQuery);
system.debug('accounts ' + accounts);
system.debug('27');
            for (Account acct : accounts) {
system.debug('28');
                cnt = SObjectCntMap.get(acct.Id);
system.debug('29');
                if (isTask)
                    acct.Task_Count__c = cnt;
                else
                    acct.Event_Count__c = cnt;
                updateAccounts.add(acct);
system.debug('30');
            }
system.debug('31');
            Database.update(updateAccounts);
system.debug('32');
        }

        if (isContact) {
system.debug('33');
            soqlQuery = 'SELECT id, ' + updateField.get(isTask) + ' FROM Contact WHERE Id IN :idsToFind';
system.debug('soqlQuery: ' + soqlQuery);
system.debug('34');
            List <contact> contacts = Database.query(soqlQuery);
system.debug('35');
            for (Contact con : contacts) {
system.debug('36');
                cnt = SObjectCntMap.get(con.Id);
                if (isTask)
                    con.Task_Count__c = cnt;
                else
                    con.Event_Count__c = cnt;
system.debug('37');
                updateContacts.add(con);
system.debug('38');
            }
system.debug('39');
system.debug('updateContacts: ' + updateContacts);
            Database.update(updateContacts);
system.debug('40');
        }

        if (isLead) {
system.debug('41');
            soqlQuery = 'SELECT id, ' + updateField.get(isTask) + ' FROM lead WHERE Id IN :idsToFind';
            List <lead> leads = Database.query(soqlQuery);
system.debug('42');
            for (lead ld : leads) {
system.debug('43');
                cnt = SObjectCntMap.get(ld.Id);
                if (isTask)
                    ld.Task_Count__c = cnt;
                else
                    ld.Event_Count__c = cnt;
system.debug('44');
                updateLeads.add(ld);
system.debug('45');
            }
system.debug('46');
            Database.update(updateLeads);
system.debug('47');
        }

        if (isOpportunity) {
system.debug('48');
            soqlQuery = 'SELECT id, ' + updateField.get(isTask) + ' FROM Opportunity WHERE Id IN :idsToFind';
            List <opportunity> opportunities = Database.query(soqlQuery);
            for (Opportunity op : opportunities) {
system.debug('49');
                cnt = SObjectCntMap.get(op.Id);
                if (isTask)
                    op.Task_Count__c = cnt;
                else
                    op.Event_Count__c = cnt;
system.debug('50');
                updateOpportunities.add(op);
system.debug('51');
            }
system.debug('52');
            Database.update(updateOpportunities);
system.debug('53');
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
system.debug('DoActivities 1');
        if (activities.size() < 1) return;  // Nothing to see here
system.debug('DoActivities 2');
        if (activities.getSObjectType() == TaskType && activities.getSObjectType() == EventType) return; // No idea how we got here
system.debug('DoActivities 3');

        if (activities.getSObjectType() == TaskType) {
system.debug('DoActivities 4');
            isTask = true;                // talking about tasks
            tasks = activities;           // SObject now needs to be of type Task
        }  else if (activities.getSObjectType() == EventType) {
system.debug('DoActivities 5');
            isTask = false;               // talking about events
            events = activities;          // SObject now needs to be of type Event
        }

        if (isTask) {
system.debug('DoActivities 6');
            for (Task t: tasks) {
system.debug('DoActivities 7');
                if (t.whoId != null)
                    Ids.add(t.whoId);

                if (t.whatId != null)
                    Ids.add(t.whatId);
system.debug('DoActivities 8');
            }
        } else {
system.debug('DoActivities 9');
            for (Event e: events) {
system.debug('DoActivities 10');
                if (e.whoId != null)
                    Ids.add(e.whoId);

                if (e.whatId != null)
                    Ids.add(e.whatId);
system.debug('DoActivities 11');
            }
        }
        if (Ids.size() > 0) {
system.debug('DoActivities 12');
            buildSObjectList(Ids, isTask, isDelete);
system.debug('DoActivities 13');
        }
    }
}