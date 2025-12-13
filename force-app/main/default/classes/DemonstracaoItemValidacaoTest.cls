@isTest(seeAllData=true)
public class DemonstracaoItemValidacaoTest {
    @isTest
    static void teste() {
        
       Produto_da_demonstracao__c pd = new Produto_da_demonstracao__c(Demonstracao__c = 'a0K6e00001ngmJI');
        
        Test.startTest();
        
        try{
            insert pd;
        }
        catch(DmlException e){
            
        }
        Test.stopTest();
    }
}