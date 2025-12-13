@isTest(SeeAllData=true)

public class AssistenteDecisaoCompraTest {
	@isTest
    private static void up(){
		PageReference testPage = Page.AssistenteDecisaoCompra;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1e6e00001OdXEzAAN'));
        Test.startTest();
        Pedido_de_compra__c cotacao = [SELECT ID FROM Pedido_de_compra__c WHERE ID = 'a1e6e00001OdXEzAAN'];
        AssistenteDecisaoCompra obj = new AssistenteDecisaoCompra(new ApexPages.StandardController(cotacao));
        obj.Inicializa(new ApexPages.StandardController(cotacao));
        obj.Efetiva();
        obj.PreparaErros();
    }
}