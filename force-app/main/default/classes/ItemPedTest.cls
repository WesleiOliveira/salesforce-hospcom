@isTest(seeAllData=true)
public class ItemPedTest { 
	
    static testMethod void ItemPedAtuStaDat(){ 
        test.startTest();
        	
		OrderItem item_pedido = new OrderItem();
        item_pedido = [
            SELECT	Status__c, Data_de_Entrega_Fornecedor__c, OrderId
            FROM	OrderItem
            WHERE 	Id = '8025A000003S0IV'		//test:8023D000000FaiC prod:8025A000003S0IV
        ];
        
        item_pedido.Status__c = 'Aguardando Entrega Fornecedor';
        item_pedido.Data_de_Entrega_Fornecedor__c = System.today()+10;

        update item_pedido;
        
        test.stopTest();
    }
    
    static testMethod void ItemPedAtuStaEntr(){ 
        test.startTest();
        	
		OrderItem item_pedido = new OrderItem();
        item_pedido = [
            SELECT	Status__c, Data_de_Entrega_Fornecedor__c, OrderId
            FROM	OrderItem
            WHERE 	Id = '8025A000003S0IV'		//test:8023D000000FaiC prod:8025A000003S0IV
        ];
        
        item_pedido.Status__c = 'Entregue';

        update item_pedido;
        
        test.stopTest();
    }

    static testMethod void ItemPedDel(){ 
        test.startTest();
        	
		OrderItem item_pedido = new OrderItem();
        item_pedido = [
            SELECT	Status__c, Data_de_Entrega_Fornecedor__c, OrderId
            FROM	OrderItem
            WHERE 	Id = '8025A000003S0IV'		//test:8023D000000FaiC prod:8025A000003S0IV
        ];
        
        delete item_pedido;
        
        test.stopTest();
    }
    
}