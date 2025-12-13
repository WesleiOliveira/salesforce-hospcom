@isTest(seeAllData=true)
public class PedInsFeedTest { 

    static testMethod void PedInsFeedTestUpdate(){ 
        test.startTest();
		
		OrderItem item_de_pedido = new OrderItem();
		item_de_pedido = [
			SELECT 	Id, Status__c
			FROM	OrderItem
			WHERE	Id = '8025A000003S0gM'	//test:8025A000003S0Je prod:8025A000003S0gM
		];
		
		item_de_pedido.Status__c = 'Entregue';
		update item_de_pedido;
        
        test.stopTest();
    }
	
    static testMethod void PedInsFeedTestDelete(){ 
        test.startTest();
		
		OrderItem item_de_pedido = new OrderItem();
		item_de_pedido = [
			SELECT 	Id
			FROM	OrderItem
			WHERE	Id = '8025A000003S0gM'	//test:8025A000003S0Je prod:8025A000003S0gM
		];
		
		delete item_de_pedido;
        
        test.stopTest();
    }
}