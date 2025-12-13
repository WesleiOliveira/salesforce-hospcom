@isTest
public with sharing class BacklogTriggerHandlerTest {
    
    @isTest
    public static void testInsert(){

        List<Backlog__c> backlogs = new List<Backlog__c>();
        for (Integer i = 0; i < 3; i++) {
            backlogs.add(new Backlog__c(
                Status__c = 'Novo'
            ));
        }

        Test.startTest();
        insert backlogs;
        Test.stopTest();
    }

    @isTest
    public static void testUpdate(){
        List<Backlog__c> backlogs = new List<Backlog__c>();
        for (Integer i = 0; i < 3; i++) {
            backlogs.add(new Backlog__c(
                Status__c = 'Novo'
            ));
        }

        insert backlogs;

        for (Backlog__c b : backlogs) {
            b.Status__c = 'Finalizado';
        }

        Test.startTest();
        update backlogs;
        Test.stopTest();
    }
}