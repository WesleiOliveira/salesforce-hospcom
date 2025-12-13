@IsTest(seeAllData=true)
public class criaPedidosDeConsumivelTest {
    
    @IsTest
    static void teste1(){
        Demonstracao__c demo = [SELECT ID, Status__c FROM Demonstracao__c WHERE ID = 'a0K6e00001ngJ4u'];
        demo.Status__c = 'Aprovado';
        update demo;
    }
    @IsTest
    static void teste2(){
        Demonstracao__c demo = [SELECT ID, Status__c FROM Demonstracao__c WHERE ID = 'a0KU400001HKYmQ'];
        demo.Status__c = 'Aprovado';
        update demo;
    }
}