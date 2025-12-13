@isTest(SeeAllData=true)
public class ItensPCompraControllerTest {
	@isTest
    private static void search(){
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1b6e000003vXj0'));
        Test.startTest();
        Fornecedor__c rq = [SELECT Id FROM Fornecedor__c WHERE Id = 'a1b6e000003vXj0'];
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        ItensPCompraController obj = new ItensPCompraController(sc);
        obj.salvar();
        obj.todosAg();
        Test.stopTest();
    }
}