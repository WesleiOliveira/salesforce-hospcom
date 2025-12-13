@isTest(SeeAllData=true)
public class AssistenteCotacaoPDFTest {
    @isTest
    public static void up(){
        PageReference testPage = Page.AssistenteCotacaoPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1bU4000001VKQ5'));
        Test.startTest();
        Fornecedor__c pc = [SELECT ID FROM Fornecedor__c where ID = 'a1bU4000001VKQ5'];
        AssistenteCotacaoPDF obj = new AssistenteCotacaoPDF(new ApexPages.StandardController(pc));
		obj.GeraPDF();        
    }
    
    
}