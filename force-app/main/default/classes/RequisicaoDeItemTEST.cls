@isTest
public class RequisicaoDeItemTEST {

    @isTest
    public static void teste(){
        //Requisicao_de_item__c ri = new Requisicao_de_item__c();
        //insert ri;
        
        //Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 4, Data_de_requisicao__c = System.today());
        //insert rq;
 
        //rq.Quantidade_requisitada__c = 2;
        //update rq;
        //delete rq;
        Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 5, Data_de_requisicao__c = System.today(), Item_de_pedido_de_compra__c = 'a1d5A0000095Ut7');
        insert rq;
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(rq.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        //RequisicaoController obj = new RequisicaoController(sc);
        //obj.pvendaId= '8025A000009I4qAQAS';
        //obj.pegarpvendaid();
        //obj.quantidadedirec=2;
        //obj.novarequisicao();
        Test.stopTest();

    }
    
}