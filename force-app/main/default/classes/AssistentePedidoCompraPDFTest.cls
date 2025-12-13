@isTest(SeeAllData=true)
public class AssistentePedidoCompraPDFTest {
    @isTest
    public static void up(){
		PageReference testPage = Page.AssistentePedidoCompra2;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1b6e000003nqrs'));
        Test.startTest();
        Fornecedor__c pc = [SELECT ID FROM Fornecedor__c where ID = 'a1b6e000003nqrs'];
     	AssistentePedidoCompraPDF obj = new AssistentePedidoCompraPDF(new ApexPages.StandardController(pc));
        obj.Inicializa(new ApexPages.StandardController(pc));
        obj.GeraPDF();
    }
}