@isTest(SeeAllData=true)
public class proposta_teste_v2 { 
	
	/*
    static testMethod void testa_opp(){ 
        Opportunity opp = new Opportunity();
        opp = [
            SELECT 	Id
            FROM	Opportunity
            WHERE	Id = '0065A00000ipo7V'	//test:0063D000007xjxx prod:0065A00000ipo7V
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
            proposta_registro registro = new proposta_registro(stdCtrl);
        	registro.salva_proposta_registro_opp();
		test.stopTest();
    }

    static testMethod void testa_ot(){ 
        WorkOrder ot = new WorkOrder();
        ot = [
            SELECT 	Id
            FROM	WorkOrder
            WHERE	Id = '0WO5A000000XezU'	// test:0WO3D000000D2R7 prod:0WO5A000000XezU
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ot);
            proposta_registro registro = new proposta_registro(stdCtrl);
        	registro.salva_proposta_registro_ot();
		test.stopTest();
    }
    */
	
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

    
}