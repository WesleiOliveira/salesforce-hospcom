@isTest(SeeAllData=true)
public class OrdPrdTest { 

    static testMethod void testa_listagem_opp(){ 
        Opportunity opp = new Opportunity();
        opp = [
            SELECT 	Id
            FROM	Opportunity
            WHERE	Id = '0065A00000ipo7V'	//test:0063D000007xjxx prod:0065A00000ipo7V
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
            proposta_listagem listagem = new proposta_listagem(stdCtrl);
		test.stopTest();
    }
    
    static testMethod void testa_listagem_ot(){ 
        WorkOrder ot = new WorkOrder();
        ot = [
            SELECT 	Id
            FROM	WorkOrder
            WHERE	Id = '0WO5A000000XezU'	// test:0WO3D000000D2R7 prod:0WO5A000000XezU
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ot);
            proposta_listagem registro = new proposta_listagem(stdCtrl);
		test.stopTest();
    }
    
    static testMethod void OrdPrdOppTest(){ 
        Opportunity oportunidade = new Opportunity();
        oportunidade = [
            SELECT 	Id
            FROM	Opportunity
            WHERE	Id = '0065A00000ipo7V'
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(oportunidade);
            OrdPrdClass ordena = new OrdPrdClass(stdCtrl);
        	ordena.itens_de_opp_str = '00k5A00000bN1D7,00k5A00000bMx9t,_00k5A00000bMx9y';
        	ordena.SalvaItensOpp();
		test.stopTest();
    } 

    static testMethod void OrdPrdPedTest(){ 
        Order pedido = new Order();
        pedido = [
            SELECT 	Id
            FROM	Order
            WHERE	Id = '8015A000002hqac'
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(pedido);
            OrdPrdClass ordena = new OrdPrdClass(stdCtrl);
        	ordena.itens_de_ped_str = '8025A000003S0Ip,8025A000003S0Iq,_8025A000003S0Ir';
        	ordena.SalvaItensPed();
		test.stopTest();
    } 

}