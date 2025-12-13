@isTest(SeeAllData=true)
public class RequisicaoControllerTest {
    @isTest
    private static void search(){
        Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 5, Data_de_requisicao__c = System.today(), Item_de_pedido_de_compra__c = 'a1d5A0000095Ut7');
        insert rq;
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(rq.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        RequisicaoController obj = new RequisicaoController(sc);
        obj.nome='BOMBA DE INFUSAO';
        obj.marca='';
        obj.modelo='';
        obj.pedido='';
        obj.quantidadedirec=12;
        obj.search();
        Test.stopTest();
    }
     @isTest
    private static void search2(){
        Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 5, Data_de_requisicao__c = System.today(), Item_de_pedido_de_compra__c = 'a1d5A0000095Ut7');
        insert rq;
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(rq.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        RequisicaoController obj = new RequisicaoController(sc);
        obj.marca='Mindray';
        obj.nome='';
        obj.modelo='';
        obj.pedido='';
        obj.quantidadedirec=12;
        obj.search();
        Test.stopTest();
    }
	@isTest
    private static void search3(){
        Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 5, Data_de_requisicao__c = System.today(), Item_de_pedido_de_compra__c = 'a1d5A0000095Ut7');
        insert rq;
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(rq.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        RequisicaoController obj = new RequisicaoController(sc);
        obj.marca='';
        obj.nome='';
        obj.modelo='BENEFUSION';
        obj.pedido='';
        obj.quantidadedirec=12;
        obj.search();
        obj.filtros();
        obj.filtroscl();
        Test.stopTest();
    }
	@isTest
    private static void search4(){
        Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 5, Data_de_requisicao__c = System.today(), Item_de_pedido_de_compra__c = 'a1d5A0000095Ut7');
        insert rq;
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(rq.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        RequisicaoController obj = new RequisicaoController(sc);
        obj.marca='';
        obj.nome='';
        obj.modelo='';
        obj.pedido='5655';
        obj.quantidadedirec=12;
        obj.search();
        Test.stopTest();
    }    
    @isTest
    private static void novarequisicao(){
        Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 5, Data_de_requisicao__c = System.today(), Item_de_pedido_de_compra__c = 'a1d5A0000095Ut7');
        insert rq;
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(rq.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        RequisicaoController obj = new RequisicaoController(sc);
        obj.pvendaId= '8025A000009I4qAQAS';
        obj.pegarpvendaid();
        obj.quantidadedirec=2;
        obj.novarequisicao();
        Test.stopTest();
    }
	@isTest
    private static void novarequisicao2(){
        Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 4, Data_de_requisicao__c = System.today(), Item_de_pedido_de_compra__c = 'a1d5A0000095Ut7');
        insert rq;
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(rq.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        RequisicaoController obj = new RequisicaoController(sc);
        obj.pvendaId= '8025A000009I4qAQAS';
        obj.quantidadedirec=7;
        obj.novarequisicao();
        Test.stopTest();
    }
    @isTest
    private static void novarequisicao3(){
        Requisicao_de_item__c rq = new Requisicao_de_item__c(Quantidade_requisitada__c = 51, Data_de_requisicao__c = System.today(), Item_de_pedido_de_compra__c = 'a1d5A0000095Ut7');
        insert rq;
        PageReference testPage = Page.Requisicao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(rq.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        RequisicaoController obj = new RequisicaoController(sc);
        obj.pvendaId= '8025A000009I4qAQAS';
        obj.pegarpvendaid();
        obj.quantidadedirec=51;
        obj.novarequisicao();
        obj.closePopup();
        Test.stopTest();
    }    
}