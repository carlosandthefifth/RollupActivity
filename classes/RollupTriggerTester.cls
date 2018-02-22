@istest
public with sharing class RollupTriggerTester {
    /*
TODO:
1.  Check rollup results
2.  Check bulkify
3.  Check for events for specific times and all day
4.  Recurring events?
5.
*/

    /*
Testing:
WhoId     and     WhatID
1.   account           null
2.   opportunity       null
3.   null              contact
4.   null              lead
5.   account           contact
6.   account           lead
7.   opportunity       contact
8.   opportunity       lead
9.   null              null
*/

    private static Account	newAccount;
    private static Opportunity newOpportunity;
    private static Contact	newContact;
    private static Lead newLead;

    private static Account	checkAccount;
    private static Opportunity checkOpportunity;
    private static Contact	checkContact;
    private static Lead checkLead;

    static testMethod void DMLTaskTEST() {
        test.starttest();
        // Task Test #1 - account null
        newAccount = new Account(name='test');
        insert newAccount;
        system.debug('test #1 newAccount Id: ' + newAccount.id);
        Task T = new Task(subject='test', status='not started', priority='normal', whatid=newAccount.id);
        // Three DML tests for our trigger
        insert T;
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Task_Count__c, 'test 1 - insert - checkAccount.Task_Count__c does not equal 1');

        delete T;
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(0, checkAccount.Task_Count__c, 'test 1 - delete - checkAccount.Task_Count__c does not equal 0');

        undelete T;
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Task_Count__c, 'test 1 - undelete - checkAccount.Task_Count__c does not equal 1');

        // Task Test #2 - opportunity null
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        T = new Task(subject='test', status='not started', priority='normal', whatid=newOpportunity.id);
        // Three DML tests for our trigger
        insert T;
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(1, checkOpportunity.Task_Count__c, 'test 2 - insert - checkOpportunity.Task_Count__c does not equal 1');

        delete T;
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(0, checkOpportunity.Task_Count__c, 'test 2 - delete - checkOpportunity.Task_Count__c does not equal 0');

        undelete T;
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(1, checkOpportunity.Task_Count__c, 'test 2 - undelete - checkOpportunity.Task_Count__c does not equal 1');

        // Check to see if we got the correct rollup value
        system.debug('NewOpportunity null task count' + NewOpportunity.Task_Count__c);

        // Task Test #3 - null contact
        newContact = new Contact(lastname='snookums');
        insert newContact;
        T = new Task(subject='test', status='not started', priority='normal', whoid=newContact.id);
        // Three DML tests for our trigger
        insert T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 3 - insert - checkContact.Task_Count__c does not equal 1');

        delete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Task_Count__c, 'test 3 - delete - checkContact.Task_Count__c does not equal 0');

        undelete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 3 - undelete - newContact.Task_Count__c does not equal 1');


        // Task Test #4  - null lead
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.debug('1 checklead: '+  checklead.task_count__c);
        T = new Task(subject='test', status='not started', priority='normal', whoid=newLead.id);
        // Three DML tests for our trigger
        insert T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 4 - insert - checkLead.Task_Count__c does not equal 1');

        delete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, checkLead.Task_Count__c, 'test 4 - delete - checkLead.Task_Count__c does not equal 0');

        undelete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 4 - undelete - checkLead.Task_Count__c does not equal 1');


        // Task Test #5 - account contact
        newContact = new Contact(lastname='snookums1');
        insert newContact;
        newAccount = new Account(name='test');
        insert newAccount;
        T = new Task(subject='test', status='not started', priority='normal', whatid=newAccount.id, whoid=newContact.id);
        // Three DML tests for our trigger
        insert T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 5 - insert - newContact.Task_Count__c does not equal 1');

        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Task_Count__c, 'test 5 - insert - newAccount.Task_Count__c does not equal 1');

        delete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Task_Count__c, 'test 5 - delete - newContact.Task_Count__c does not equal 0');
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(0, checkAccount.Task_Count__c, 'test 5 - delete - newAccount.Task_Count__c does not equal 1');

        undelete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 5 - undelete - newContact.Task_Count__c does not equal 1');
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Task_Count__c, 'test 5 - undelete - newAccount.Task_Count__c does not equal 1');


        // Task Test #6 - account lead
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        T = new Task(subject='test', status='not started', priority='normal',  whoid=newLead.id);
        // Three DML tests for our trigger
        insert T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 6 - insert - newLead.Task_Count__c does not equal 1');

        delete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, checkLead.Task_Count__c, 'test 6 - delete - newLead.Task_Count__c does not equal 0');

        undelete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 6 - insert - newLead.Task_Count__c does not equal 1');

        // Task Test #7 - opportunity   contact
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        newContact = new Contact(lastname='snookums');
        insert newContact;
        T = new Task(subject='test', status='not started', priority='normal', whatid=newOpportunity.id, whoid=newContact.id);
        // Three DML tests for our trigger
        insert T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 7 - insert - newContact.Task_Count__c does not equal 1');
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(1, checkOpportunity.Task_Count__c, 'test 7 - insert - newAccount.Task_Count__c does not equal 1');

        delete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Task_Count__c, 'test 7 - delete - newContact.Task_Count__c does not equal 0');
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(0, checkOpportunity.Task_Count__c, 'test 7 - delete - newAccount.Task_Count__c does not equal 0');

        undelete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 7 - undelete - newContact.Task_Count__c does not equal 1');
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(1, checkOpportunity.Task_Count__c, 'test 7 - undelete - newAccount.Task_Count__c does not equal 1');

        // Task Test #8 - opportunity lead
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        T = new Task(subject='test', status='not started', priority='normal',  whoid=newLead.id);
        // Three DML tests for our trigger
        insert T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 8 - insert - newLead.Task_Count__c does not equal 1');

        delete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, checkLead.Task_Count__c, 'test 8 - insert - newLead.Task_Count__c does not equal 0');

        undelete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 8 - insert - newLead.Task_Count__c does not equal 1');


        // Task Test #9  null  null
        T = new Task(subject='test', status='not started', priority='normal');
        // Three DML tests for our trigger
        insert T;
        delete T;
        undelete T;
        test.stoptest();
    }

    static testMethod void DMLEventTEST() {
    	test.starttest();
        // Event Test #1 - account null
        newAccount = new Account(name='test');
        insert newAccount;
        Event E = new Event(subject='test', startDateTime=dateTime.now()+10, endDateTime=dateTime.now()+20,  whatid=newAccount.id);

        // Three DML tests for our trigger
        insert E;
        checkAccount = [SELECT a.Event_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Event_Count__c, 'test 1 - insert - checkAccount.Event_Count__c does not equal 1');

        delete E;
        checkAccount = [SELECT a.Event_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(0, checkAccount.Event_Count__c, 'test 1 - delete - checkAccount.Event_Count__c does not equal 0');

        undelete E;
        checkAccount = [SELECT a.Event_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Event_Count__c, 'test 1 - undelete - checkAccount.Event_Count__c does not equal 1');

        // Event Test #2 - opportunity null
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        E = new Event(subject='test', startDateTime=dateTime.now()+10, endDateTime=datetime.now()+20, whatid=newOpportunity.id);
        // Three DML tests for our trigger
        insert E;
        checkOpportunity = [SELECT o.Event_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(1, checkOpportunity.Event_Count__c, 'test 2 - insert - checkOpportunity.Event_Count__c does not equal 1');

        delete E;
        checkOpportunity = [SELECT o.Event_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(0, checkOpportunity.Event_Count__c, 'test 2 - delete - checkOpportunity.Event_Count__c does not equal 0');

        undelete E;
        checkOpportunity = [SELECT o.Event_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(1, checkOpportunity.Event_Count__c, 'test 2 - undelete - checkOpportunity.Event_Count__c does not equal 1');
        // Check to see if we got the correct rollup value
        system.debug('NewOpportunity null event count: ' + NewOpportunity.Event_Count__c);

        // Event Test #3 - null contact
        newContact = new Contact(lastname='snookums');
        insert newContact;
        E = new Event(subject='test', startDateTime=dateTime.Now()+10, endDateTime=dateTime.Now()+20,  whoid=newContact.id);
        // Three DML tests for our trigger
        insert E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Event_Count__c, 'test 3 - insert - checkContact.Event_Count__c does not equal 1');

        delete E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Event_Count__c, 'test 3 - delete - checkContact.Event_Count__c does not equal 0');

        undelete E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Event_Count__c, 'test 3 - undelete - newContact.Event_Count__c does not equal 1');
        // Check to see if we got the correct rollup value
        system.debug('null NewContact event count: ' + NewContact.Event_Count__c);

        // Event Test #4  - null lead
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        E = new Event(subject='test', startDateTime=dateTime.now()+10, endDateTime=dateTime.now()+20, whoid=newLead.id);
        // Three DML tests for our trigger

        insert E;
        checkLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Event_Count__c, 'test 4 - insert - checkLead.Event_Count__c does not equal 1');

        delete E;
        checkLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, checkLead.Event_Count__c, 'test 4 - delete - checkLead.Event_Count__c does not equal 0');

        undelete E;
        checkLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Event_Count__c, 'test 4 - undelete - checkLead.Event_Count__c does not equal 1');

        // Event Test #5 - account contact
        newContact = new Contact(lastname='snookums');
        insert newContact;
        newAccount = new Account(name='test');
        insert newAccount;
        E = new Event(subject='test', startDateTime=dateTime.now()+10, endDateTime=dateTime.now()+20, whatid=newAccount.id, whoid=newContact.id);
        // Three DML tests for our trigger
        insert E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Event_Count__c, 'test 5 - insert - newContact.Event_Count__c does not equal 1');

        checkAccount = [SELECT a.Event_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Event_Count__c, 'test 5 - insert - newAccount.Event_Count__c does not equal 1');

        delete E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Event_Count__c, 'test 5 - delete - newContact.Event_Count__c does not equal 0');
        checkAccount = [SELECT a.Event_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(0, checkAccount.Event_Count__c, 'test 5 - delete - newAccount.Event_Count__c does not equal 1');

        undelete E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Event_Count__c, 'test 5 - undelete - newContact.Event_Count__c does not equal 1');
        checkAccount = [SELECT a.Event_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Event_Count__c, 'test 5 - undelete - newAccount.Event_Count__c does not equal 1');

        // Event Test #6 - account lead
        newAccount = new Account(name='test');
        insert newAccount;
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        E = new Event(subject='test', startDateTime=dateTime.now()+10, endDateTime=dateTime.now()+20, whoid=newLead.id);
        // Three DML tests for our trigger
        insert E;
        checkLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Event_Count__c, 'test 6 - insert - newLead.Event_Count__c does not equal 1');

        delete E;
        checkLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, checkLead.Event_Count__c, 'test 6 - delete - newLead.Event_Count__c does not equal 0');

        undelete E;
        checkLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Event_Count__c, 'test 6 - insert - newLead.Event_Count__c does not equal 1');

        // Event Test #7 - opportunity   contact
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        newContact = new Contact(lastname='snookums');
        insert newContact;
        E = new Event(subject='test',  startDateTime=dateTime.now()+10, endDateTime=dateTime.now()+20, whatid=newOpportunity.id, whoid=newContact.id);
        // Three DML tests for our trigger
        insert E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Event_Count__c, 'test 7 - insert - newContact.Event_Count__c does not equal 1');
        checkOpportunity = [SELECT o.Event_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(1, checkOpportunity.Event_Count__c, 'test 7 - insert - newAccount.Event_Count__c does not equal 1');

        delete E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Event_Count__c, 'test 7 - delete - newContact.Event_Count__c does not equal 0');
        checkOpportunity = [SELECT o.Event_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(0, checkOpportunity.Event_Count__c, 'test 7 - delete - newAccount.Event_Count__c does not equal 0');

        undelete E;
        checkContact = [SELECT c.Event_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Event_Count__c, 'test 7 - undelete - newContact.Event_Count__c does not equal 1');
        newOpportunity = [SELECT o.Event_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(1, newOpportunity.Event_Count__c, 'test 7 - undelete - newAccount.Event_Count__c does not equal 1');

        // Event Test #8 - opportunity lead
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        E = new Event(subject='test', startDateTime=dateTime.now()+10, endDateTime=dateTime.now()+20, whoid=newLead.id);
        // Three DML tests for our trigger
        insert E;
        checkLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Event_Count__c, 'test 8 - insert - newLead.Event_Count__c does not equal 1');

        delete E;
        newLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, newLead.Event_Count__c, 'test 8 - insert - newLead.Event_Count__c does not equal 0');

        undelete E;
        checkLead = [SELECT l.Event_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Event_Count__c, 'test 8 - insert - newLead.Event_Count__c does not equal 1');

        // Event Test #9  null  null
        E = new Event(subject='test', startDateTime=dateTime.now()+10, endDateTime=dateTime.now()+20);
        // Three DML tests for our trigger
        insert E;
        delete E;
        undelete E;
        test.stoptest();
    }

    static testMethod void BulkDMLTaskTEST() {
        // Task Test #1 - account null
        Task[] Tasks = new Task[] {};
        Task   T;
        Integer cnt;
        Integer numORecords = 1000;
        newAccount = new Account(name='test');
        insert newAccount;
        // Three DML tests for our trigger
        for (cnt = 0; cnt < numORecords; cnt++) {
        	T = new Task(subject='test', status='not started', priority='normal', whatid=newAccount.id);
        	Tasks.add(T);
        }
        system.debug('whatid: ' + t.whatid);
        test.starttest();
        insert Tasks;
    	checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
    	system.assertequals(numORecords, checkAccount.Task_Count__c, 'test 1 - insert - checkAccount.Task_Count__c does not equal 1');
/*
        delete Tasks;
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(0, checkAccount.Task_Count__c, 'test 1 - delete - checkAccount.Task_Count__c does not equal 0');

        undelete Tasks;
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(numORecords, checkAccount.Task_Count__c, 'test 1 - undelete - checkAccount.Task_Count__c does not equal 1');
*/
        test.stoptest();

/*
        // Task Test #2 - opportunity null
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        T = new Task(subject='test', status='not started', priority='normal', whatid=newOpportunity.id);
        // Three DML tests for our trigger
        insert T;
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(1, checkOpportunity.Task_Count__c, 'test 2 - insert - checkOpportunity.Task_Count__c does not equal 1');

        delete T;
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(0, checkOpportunity.Task_Count__c, 'test 2 - delete - checkOpportunity.Task_Count__c does not equal 0');

        undelete T;
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:newOpportunity.id];
        system.assertequals(1, checkOpportunity.Task_Count__c, 'test 2 - undelete - checkOpportunity.Task_Count__c does not equal 1');

        // Check to see if we got the correct rollup value
        system.debug('NewOpportunity null task count' + NewOpportunity.Task_Count__c);

        // Task Test #3 - null contact
        newContact = new Contact(lastname='snookums');
        insert newContact;
        T = new Task(subject='test', status='not started', priority='normal', whoid=newContact.id);
        // Three DML tests for our trigger
        insert T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 3 - insert - checkContact.Task_Count__c does not equal 1');

        delete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Task_Count__c, 'test 3 - delete - checkContact.Task_Count__c does not equal 0');

        undelete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 3 - undelete - newContact.Task_Count__c does not equal 1');


        // Task Test #4  - null lead
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.debug('1 checklead: '+  checklead.task_count__c);
        T = new Task(subject='test', status='not started', priority='normal', whoid=newLead.id);
        // Three DML tests for our trigger
        insert T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 4 - insert - checkLead.Task_Count__c does not equal 1');

        delete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, checkLead.Task_Count__c, 'test 4 - delete - checkLead.Task_Count__c does not equal 0');

        undelete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 4 - undelete - checkLead.Task_Count__c does not equal 1');


        // Task Test #5 - account contact
        newContact = new Contact(lastname='snookums1');
        insert newContact;
        newAccount = new Account(name='test');
        insert newAccount;
        T = new Task(subject='test', status='not started', priority='normal', whatid=newAccount.id, whoid=newContact.id);
        // Three DML tests for our trigger
        insert T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 5 - insert - newContact.Task_Count__c does not equal 1');

        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Task_Count__c, 'test 5 - insert - newAccount.Task_Count__c does not equal 1');

        delete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Task_Count__c, 'test 5 - delete - newContact.Task_Count__c does not equal 0');
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(0, checkAccount.Task_Count__c, 'test 5 - delete - newAccount.Task_Count__c does not equal 1');

        undelete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 5 - undelete - newContact.Task_Count__c does not equal 1');
        checkAccount = [SELECT a.Task_Count__c FROM Account a where id =:NewAccount.id];
        system.assertequals(1, checkAccount.Task_Count__c, 'test 5 - undelete - newAccount.Task_Count__c does not equal 1');


        // Task Test #6 - account lead
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        T = new Task(subject='test', status='not started', priority='normal',  whoid=newLead.id);
        // Three DML tests for our trigger
        insert T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 6 - insert - newLead.Task_Count__c does not equal 1');

        delete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, checkLead.Task_Count__c, 'test 6 - delete - newLead.Task_Count__c does not equal 0');

        undelete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 6 - insert - newLead.Task_Count__c does not equal 1');

        // Task Test #7 - opportunity   contact
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        newContact = new Contact(lastname='snookums');
        insert newContact;
        T = new Task(subject='test', status='not started', priority='normal', whatid=newOpportunity.id, whoid=newContact.id);
        // Three DML tests for our trigger
        insert T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 7 - insert - newContact.Task_Count__c does not equal 1');
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(1, checkOpportunity.Task_Count__c, 'test 7 - insert - newAccount.Task_Count__c does not equal 1');

        delete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(0, checkContact.Task_Count__c, 'test 7 - delete - newContact.Task_Count__c does not equal 0');
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(0, checkOpportunity.Task_Count__c, 'test 7 - delete - newAccount.Task_Count__c does not equal 0');

        undelete T;
        checkContact = [SELECT c.Task_Count__c FROM Contact c where id =:newContact.id];
        system.assertequals(1, checkContact.Task_Count__c, 'test 7 - undelete - newContact.Task_Count__c does not equal 1');
        checkOpportunity = [SELECT o.Task_Count__c FROM Opportunity o where id =:NewOpportunity.id];
        system.assertequals(1, checkOpportunity.Task_Count__c, 'test 7 - undelete - newAccount.Task_Count__c does not equal 1');

        // Task Test #8 - opportunity lead
        newOpportunity = new Opportunity(name='million dollar deal', closedate=date.today()+10, StageName= 'prospecting');
        insert newOpportunity;
        newLead = new Lead(lastname='testlead', company='company x', status='Open - Not Contacted');
        insert newLead;
        T = new Task(subject='test', status='not started', priority='normal',  whoid=newLead.id);
        // Three DML tests for our trigger
        insert T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 8 - insert - newLead.Task_Count__c does not equal 1');

        delete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(0, checkLead.Task_Count__c, 'test 8 - insert - newLead.Task_Count__c does not equal 0');

        undelete T;
        checkLead = [SELECT l.Task_Count__c FROM Lead l where id =:newLead.id];
        system.assertequals(1, checkLead.Task_Count__c, 'test 8 - insert - newLead.Task_Count__c does not equal 1');


        // Task Test #9  null  null
        T = new Task(subject='test', status='not started', priority='normal');
        // Three DML tests for our trigger
        insert T;
        delete T;
        undelete T;
 */
    }


}