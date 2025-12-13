@isTest
public with sharing class AvaliacaoExperienciaTriggerHandlerTest {

    @isTest
    public static void testUpdateTrigger(){
        
        Avaliacao_de_Experiencia__c avaliacao = new Avaliacao_de_Experiencia__c();
        insert avaliacao;

        Test.startTest();
        update avaliacao;
        Test.stopTest();
    }
}