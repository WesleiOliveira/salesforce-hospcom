@isTest(seeAllData=true)
public with sharing class ContratoServicoTriggerHandlerTest {
    
    @isTest
    public static void testUpdateTrigger(){
        
        Contrato_de_servi_o__c contratoServico = [SELECT Id FROM Contrato_de_servi_o__c LIMIT 1];

        Test.startTest();
        update contratoServico;
        Test.stopTest();
    }
}