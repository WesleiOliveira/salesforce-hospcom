@isTest(seeAllData=true)
public class PedImpPrdTest { 
	
    static testMethod void PedImpPrdOpp(){ 
        test.startTest();
        	
        Order pedido = new Order();
        pedido.OpportunityId 	= '0065A00000ipo7V';		// 0063D000007xjxx 0065A00000ipo7V
        pedido.Status 			= 'Rascunho';
        pedido.EffectiveDate 	= System.today();
        
        insert pedido;
        
        test.stopTest();
    }
    
    static testMethod void PedImpPrdOt(){ 
        test.startTest();
        	
        Order pedido = new Order();
        pedido.Ordem_de_trabalho__c	= '0WO5A000000XezU';		// 0WO3D000000D2R7 0WO5A000000XezU
        pedido.Status 				= 'Rascunho';
        pedido.EffectiveDate 		= System.today();
        
        insert pedido;
        
        test.stopTest();
    }
    
}