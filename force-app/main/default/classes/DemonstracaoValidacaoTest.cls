@isTest(seeAllData=true)
public class DemonstracaoValidacaoTest {
    @isTest
    static void teste() {
        
        Demonstracao__c comodato = [SELECT ID FROM Demonstracao__c WHERE ID = 'a0KU400000EJnHu'];
        
        comodato.Status__c = 'Retorno';
        
        Test.startTest();
        
        try{
            update comodato;
        }
        catch(DmlException e){
            
        }
        Test.stopTest();
    }
    @isTest
    static void teste2() {
        
        Demonstracao__c comodato = [SELECT ID FROM Demonstracao__c WHERE ID = 'a0KU400000EJnHu'];
        
        comodato.Status__c = 'Retorno';
        
        Test.startTest();
        
        try{
            delete comodato;
        }
        catch(DmlException e){
            
        }
        Test.stopTest();
    }
    @isTest
    static void teste3() {
        
        Demonstracao__c comodato = [SELECT ID FROM Demonstracao__c WHERE ID = 'a0KU400000EJnHu'];
        
        comodato.Status__c = 'Em demonstração';
        
        Test.startTest();
        
        try{
            update comodato;
        }
        catch(DmlException e){
            
        }
        Test.stopTest();
    }
    @isTest
    static void teste4() {
        
        Demonstracao__c comodato = [SELECT ID FROM Demonstracao__c WHERE ID = 'a0KU400000EJnHu'];
        
        comodato.Status__c = 'Finalizado';
        
        Test.startTest();
        
        try{
            update comodato;
        }
        catch(DmlException e){
            
        }
        Test.stopTest();
    }
    @isTest
    static void teste5() {
        
        Demonstracao__c comodato = [SELECT ID FROM Demonstracao__c WHERE ID = 'a0KU400000EJnHu'];
        
        comodato.Acao_interna__c = true;
        comodato.Status__c = 'Agendado';
        update comodato;
        
        comodato.Status__c = 'Em demonstração';
        Test.startTest();
        
        try{
        }
        catch(DmlException e){
            
        }
        Test.stopTest();
    }
    @isTest
    static void teste6() {
        
        Demonstracao__c comodato = [SELECT ID FROM Demonstracao__c WHERE ID = 'a0KU400000EJnHu'];
        
        comodato.Acao_interna__c = false;
        comodato.Status__c = 'Agendado';
        update comodato;
        
        comodato.Status__c = 'Em demonstração';
        Test.startTest();
        
        try{
        }
        catch(DmlException e){
            
        }
        Test.stopTest();
    }
}