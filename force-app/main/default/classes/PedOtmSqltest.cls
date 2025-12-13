@isTest(seeAllData=true)
public class PedOtmSqltest { 
	
    static testMethod void testaPedido(){ 
        test.startTest();
        	
		Order pedido = new Order(
            OpportunityId = '0065A00000ipo7VQAQ',			// test:006f000000HTDtY prod:0065A00000ipo7VQAQ
            EffectiveDate = System.today(),
            Prazo_Prometido__c = System.today()+3,
            Status = 'Ativo',
            Faturamento_Feito__c = '001i00000085QYbAAM',	// test:001i00000085QYb prod:001i00000085QYbAAM
            AccountId = '001i000000UYewbAAD',				// test:001i000000UYewb prod:001i000000UYewbAAD
            Forma_de_pagamento__c = 'OPEN ACCOUNT',
            Descricao_de_Pagamento__c = 'em 3 vezes',
            Tipo_de_Frete__c = 'CIF',
            Entrega_Parcial_Autorizada__c = 'Não Autorizada'
        );
        
        insert pedido;
        
        test.stopTest();
    }
    
    static testMethod void testaItemPedido(){ 
        test.startTest();
        	
		OrderItem item_pedido = new OrderItem();
        item_pedido = [
            SELECT	Id, Status__c, Data_de_Entrega_Fornecedor__c
            FROM	OrderItem
            WHERE 	Id = '8025A000003S0MF'		//test:802f00000001TGg prod:8025A000003S0MF
        ];
        
        item_pedido.Status__c = 'Aguardando Entrega Fornecedor';
        item_pedido.Data_de_Entrega_Fornecedor__c = System.today()+3;
        update item_pedido;
        
        test.stopTest();
    }
    

    static testMethod void testaItemPedido2(){ 
        test.startTest();
        	
		OrderItem item_pedido = new OrderItem();
        item_pedido = [
            SELECT	Id, Status__c, Data_de_Entrega_Fornecedor__c
            FROM	OrderItem
            WHERE 	Id = '8025A000003S0MF'		//test:802f00000001TGg prod:8025A000003S0MF
        ];
        
        item_pedido.Status__c = 'Entregue';
        item_pedido.Data_de_Entrega_Fornecedor__c = System.today()+3;
        update item_pedido;
        
        test.stopTest();
    }
    

}