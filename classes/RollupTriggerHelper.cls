public with sharing class RollupTriggerHelper {
    /*
        Rollup Trigger Helper - counts both events and activities and adds the total to a custom field on Account, Contact, Lead and Opportunity.

        Revision Notes:
            February 22, 2018 - hitting SOQL query limit : Fixed February 23, 2018 20:05
            February 23, 2018 - 22:39 - subtraction is not correct
  	*/

    // Comparison variables - global to helper class
    private	static Schema.SObjectType eventType = Schema.getGlobalDescribe().get('Event');
    private	static Schema.SObjectType taskType = Schema.getGlobalDescribe().get('Task');
    private	static Schema.SObjectType accountType = Schema.getGlobalDescribe().get('Account');
    private	static Schema.SObjectType opportunityType = Schema.getGlobalDescribe().get('Opportunity');
    private	static Schema.SObjectType contactType = Schema.getGlobalDescribe().get('Contact');
    private	static Schema.SObjectType leadType = Schema.getGlobalDescribe().get('Lead');


    // Track event or task
    private static boolean isEvent = false;
    private static boolean isTask = false;

    private static void buildSObjectList(ID[] idsToFind, boolean isTask, boolean isDelete) {
        /*
            Handles the heavy lifting of counting tasks/events for accounts, opportunities, leads and contacts
        */

        String soqlQuery;    // Dynamic soql query string

        // Used to build dynamic soql query
        Map<boolean, String> activityType = new Map<boolean, String> {true => 'task', false => 'event'};
        Map<boolean, String> updateField = new Map<boolean, String> {true => 'Task_Count__c', false => 'Event_Count__c'};

        Map <Id, Integer> sObjectCntMap = new Map <Id, Integer>();  // SObject, activity count

        List <SObject> whatActivities = new List <SObject>(); // Handle Tasks AND/OR Events for whatIds
        List <SObject> whoActivities = new List <SObject>(); // Handle Tasks AND/OR Events for whoIds

        // temp vars used to convert Sobjects
        Task T;
        Event E;

        Integer cnt;   // counter for number of tasks/events

        // For updating enmasse
        List <Account> updateAccounts = new List <Account>();
        List <Opportunity> updateOpportunities = new List <Opportunity>();
        List <Contact> updateContacts = new List <Contact>();
        List <Lead> updateLeads = new List <Lead>();

        // Track which object we are focused on
        boolean isAccount = false;
        boolean isContact = false;
        boolean isLead = false;
        boolean isOpportunity = false;

        boolean isWhatid; // If relating to accounts or opportunities


        for (ID idToFind : idsToFind) {
            // loop through all ids passed in.  Can be a mix of Accounts/Contacts,
            // Opportunities/Contacts and Leads.  Leads cannot be related to an
            // account or opportunity through a task.
            // At the end of this loop we will have at the most two objects
            // that we need to consider

            sObjectCntMap.put(idToFind, 0); // Stuff id in map with roll up count zero

            if (!isAccount) {
                isAccount = (idToFind.getSObjectType() == accountType);
            }
            if (isDelete) {
                if (idToFind.getSObjectType() == accountType) {
                    if (isTask) {
                        Account a  = [SELECT ID, Task_Count__c FROM Account WHERE  Id = :idToFind];
                        sObjectCntMap.put(idToFind, (Integer) a.Task_Count__c);
                    }
                    else {
                        Account a  = [SELECT Event_Count__c FROM Account WHERE  Id = :idToFind];
                        sObjectCntMap.put(idToFind, (Integer) a.Event_Count__c);
                    }
                }
            }

            if (!isContact) {
                isContact = (idToFind.getSObjectType() == contactType);
            }
            if (isDelete) {
                if (idToFind.getSObjectType() == contactType) {
                    if (isTask) {
                        Contact c  = [SELECT Task_Count__c FROM Contact WHERE  Id = :idToFind];
                        sObjectCntMap.put(idToFind, (Integer) c.Task_Count__c);
                    }
                    else {
                        Contact c  = [SELECT Event_Count__c FROM Contact WHERE  Id = :idToFind];
                        sObjectCntMap.put(idToFind,  (Integer) c.Event_Count__c);
                    }
                }
            }

            if (!isLead) {
                isLead  = (idToFind.getSObjectType() == leadType);
            }
            if (isDelete) {
                if (idToFind.getSObjectType() == leadType) {
                    if (isTask) {
                        Lead l  = [SELECT Task_Count__c FROM Lead WHERE  Id = :idToFind];
                        sObjectCntMap.put(idToFind, (Integer) l.Task_Count__c);
                    }
                    else {
                        Lead l  = [SELECT Event_Count__c FROM Lead WHERE  Id = :idToFind];
                        sObjectCntMap.put(idToFind, (Integer) l.Event_Count__c);
                    }
                }
            }
            if (!isOpportunity) {
                isOpportunity = (idToFind.getSObjectType() == opportunityType);
            }
            if (isDelete) {
                if (idToFind.getSObjectType() == opportunityType) {
                    if (isTask) {
                        Opportunity o  = [SELECT Task_Count__c FROM Opportunity WHERE  Id = :idToFind];
                        sObjectCntMap.put(idToFind, (Integer) o.Task_Count__c);
                    }
                    else {
                        Opportunity o  = [SELECT Event_Count__c FROM Opportunity WHERE  Id = :idToFind];
                        sObjectCntMap.put(idToFind, (Integer) o.Event_Count__c);
                    }
                }
            }
        }
system.debug('1');

        // Query tasks that are related to whatId (Accounts, Opportunities)
        soqlQuery = 'SELECT Id, whatid FROM '+ activityType.get(isTask) +' WHERE  whatId IN :idsToFind';
        whatActivities =  Database.query(soqlQuery);

        // Query tasks that are related to whoId (Contacts, Leads)
        soqlQuery = 'SELECT Id, whoid FROM '+ activityType.get(isTask) +' WHERE whoId IN :idsToFind';
        whoActivities =  Database.query(soqlQuery);


system.debug('2');

        if (whatActivities.size() > 0) {
system.debug('2.1');
            for (SObject a : whatActivities) {
system.debug('2.2');
                // loop through all whatid activities
                if (isTask){
system.debug('2.3');
                    T = (Task) a; // convert SObject whatActivities to Task
system.debug('2.4 what ' + T.whatId + 'a: ' + a);
                    cnt = SObjectCntMap.get(T.whatid); // find id in list
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    } else {
system.debug('2.5');
                        // not deleting add oen
                        cnt++;
                    }
system.debug('2.6');
                    SObjectCntMap.put(T.whatId, cnt);
system.debug('2.7');
                } else {
system.debug('2.8');
                    E =  (Event) a;
                    cnt = SObjectCntMap.get(E.whatid); // find id in list
                    if (isDelete) {
system.debug('2.9 cnt ' + cnt);
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    } else {
system.debug('2.10');
                        // not deleting add oen
                        cnt++;
                    }
system.debug('2.11');
                    SObjectCntMap.put(E.whatId, cnt);
system.debug('2.12');
                }
            }
        }
system.debug('3');

        if (whoActivities.size() > 0) {
            for (SObject a : whoActivities) {
                // loop through all whatid activities
                if (isTask){
                    T = (Task) a; // convert SObject whatActivities to Task
                    cnt = SObjectCntMap.get(T.whoid); // find id in list
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    } else {
                        // not deleting add oen
                        cnt++;
                    }
                    SObjectCntMap.put(T.whoId, cnt);
                } else {
                    E =  (Event) a;
                    cnt = SObjectCntMap.get(E.whoid); // find id in list
                    if (isDelete) {
                        if (cnt > 0)
                            cnt--;
                        else
                            cnt = 0;
                    } else {
                        // not deleting add oen
                        cnt++;
                    }
                    SObjectCntMap.put(E.whoId, cnt);
                }
            }
        }

        if (isAccount) {
            soqlQuery = 'SELECT id, ' + updateField.get(isTask) + ' FROM Account WHERE Id IN :idsToFind';
            List <Account> accounts = Database.query(soqlQuery);  // List of accounts related to task/event who/what id
            for (Account acct : accounts) {
                cnt = SObjectCntMap.get(acct.Id); // get the count previously recorded
                if (isTask)
                    acct.Task_Count__c = cnt;  // set the Task_Count__c field
                else
                    acct.Event_Count__c = cnt; // set the Event_Count__c field
                updateAccounts.add(acct);  // Update account with id grabbed from soql query and Event_Count__c/Task_Count__c
            }
            Database.update(updateAccounts);  // commit to Database
        }

        if (isContact) {
            soqlQuery = 'SELECT id, ' + updateField.get(isTask) + ' FROM Contact WHERE Id IN :idsToFind';
            List <contact> contacts = Database.query(soqlQuery); // List of contacts related to task/event who/what id
            for (Contact con : contacts) {
                cnt = SObjectCntMap.get(con.Id);  // get the count previously recorded
                if (isTask)
                    con.Task_Count__c = cnt;  // set the Task_Count__c field
                else
                    con.Event_Count__c = cnt; // set the Event_Count__c field
                updateContacts.add(con);   // Update contact with id grabbed from soql query and Event_Count__c/Task_Count__c
            }
            Database.update(updateContacts);  // commit to Database
        }

        if (isLead) {
            soqlQuery = 'SELECT id, ' + updateField.get(isTask) + ' FROM lead WHERE Id IN :idsToFind';
            List <lead> leads = Database.query(soqlQuery); // List of leads related to task/event who/what id
            for (lead ld : leads) {
                cnt = SObjectCntMap.get(ld.Id);  // get the count previously recorded
                if (isTask)
                    ld.Task_Count__c = cnt;  // set the Task_Count__c field
                else
                    ld.Event_Count__c = cnt;  // set the Event_Count__c field
                updateLeads.add(ld);  // Update lead with id grabbed from soql query and Event_Count__c/Task_Count__c
            }
            Database.update(updateLeads);  // commit to database
        }

        if (isOpportunity) {
            soqlQuery = 'SELECT id, ' + updateField.get(isTask) + ' FROM Opportunity WHERE Id IN :idsToFind';
            List <opportunity> opportunities = Database.query(soqlQuery); // List of opportunities related to task/event who/what id
            for (Opportunity op : opportunities) {
                cnt = SObjectCntMap.get(op.Id); // get the count previously recorded
                if (isTask)
                    op.Task_Count__c = cnt;  // set the Task_Count__c field
                else
                    op.Event_Count__c = cnt;  // set the Event_Count__c field
                updateOpportunities.add(op);  // Update opportunity with id grabbed from soql query and Event_Count__c/Task_Count__c
            }
            Database.update(updateOpportunities);   // commit to database
        }
    }

    public static void BeforeDelete (List <SObject> activities) {
        DoActivities (activities, true);
    }

    public static void AfterInsert (List <SObject> activities) {
        DoActivities (activities, false);
    }

    public static void AfterUndelete (List <SObject> activities) {
        DoActivities (activities, false);
    }

    private static void DoActivities (List <SObject> activities, boolean isDelete) {


        Id[] Ids = new Id[0]; // holds who what ids

        // hold the different activities
        List <Task> tasks;
        List <Event> events;

        if (activities.size() < 1) return;  // Nothing to see here - empty trigger.new - is that possible

        if (activities.getSObjectType() == TaskType && activities.getSObjectType() == EventType) return; // No idea how we got here - two triggers called at once - nah

        if (activities.getSObjectType() == TaskType) {
            isTask = true;                // talking about tasks
            tasks = activities;           // SObject now needs to be of type Task
        }  else if (activities.getSObjectType() == EventType) {
            isTask = false;               // talking about events
            events = activities;          // SObject now needs to be of type Event
        }

        // Strip out all the SObject stuff - we just need Ids here
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
            // Off to figure out how many activities are assocated with account, opportunity, contact and lead
            buildSObjectList(Ids, isTask, isDelete);
        }
    }
}
