@isTest(SeeAllData=true)
public class AssistPedCompraPDFTest {
	@isTest
    public static void up(){
        PageReference testPage = Page.AssistenteRecebimentoProduto;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1b6e000003nqrs'));
        Test.startTest();
        Fornecedor__c pc = [SELECT ID FROM Fornecedor__c where ID = 'a1b6e000003nqrs'];
     	AssistenteRecebimentoProduto obj = new AssistenteRecebimentoProduto(new ApexPages.StandardController(pc));
        for(AssistenteRecebimentoProduto.ItemCompra item : obj.itens){
            			for(AssistenteRecebimentoProduto.ReqItem req_item : item.reqs_item){
                            req_item.receb_item.Quantidade_recebida__c = 1;
                        }

        }
        obj.Efetiva();
		AssistenteRecebimentoProduto.ItemCompra item_compra = new AssistenteRecebimentoProduto.ItemCompra(new Item_de_pedido_de_compra__c());
		AssistenteRecebimentoProduto.CRecebimentoDeItem c_rec_item = new AssistenteRecebimentoProduto.CRecebimentoDeItem(new Requisicao_de_item__c(), new Recebimento_de_item__c());
        AssistenteRecebimentoProduto.CDivide C_Divide = new AssistenteRecebimentoProduto.CDivide('a1g6e000005GUvP', 'a1c6e000009gHct', 'a1d6e0000095gOI', 2.0, 'a', system.today(), 2.0);
        obj.ObtemDados();
        
        Test.stopTest();
    }
}