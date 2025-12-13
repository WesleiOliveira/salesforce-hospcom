@isTest(SeeAllData=true)
public class NovoPDFdoPedidoTest {
	@isTest
    private static void search(){
        PageReference testPage = Page.listagem_pedido;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('801U400000MaF7qIAF'));
        Test.startTest();
        Order rq = [SELECT Id FROM Order WHERE Id = '801U400000MaF7qIAF'];
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        NovoPDFdoPedido obj = new NovoPDFdoPedido(sc);
        Test.stopTest();
    }
}