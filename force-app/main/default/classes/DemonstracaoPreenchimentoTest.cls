@isTest(seeAllData=true)
public class DemonstracaoPreenchimentoTest {
    @isTest
    static void teste() {
        
        Demonstracao__c comodato = new Demonstracao__c(Conta__c = '001i00000085QYbAAM');
        
        comodato.Status__c = 'Retorno da demo';
        
        Test.startTest();
        
        try{
            insert comodato;
        }
        catch(DmlException e){
            
        }
        Test.stopTest();
    }
}