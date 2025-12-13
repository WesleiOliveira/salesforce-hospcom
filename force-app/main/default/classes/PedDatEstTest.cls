@isTest(seeAllData=true)
public class PedDatEstTest { 
	
    static testMethod void PedDatEstTestUpdate(){ 
        test.startTest();
        	
		OrderItem item_pedido = new OrderItem();
        item_pedido = [
            SELECT	OrderId
            FROM	OrderItem
            WHERE 	Id = '8025A000003S0CS'		//test:8023D000000FaiC prod:8025A000003S0CS
        ];
        
        item_pedido.Data_de_Entrega_Fornecedor__c = System.today();
        update item_pedido;
        
        test.stopTest();
    }
    
    static testMethod void PedDatEstTestDelete(){ 
        test.startTest();
        	
		OrderItem item_pedido = new OrderItem();
        item_pedido = [
            SELECT	OrderId
            FROM	OrderItem
            WHERE 	Id = '8025A000003S0CS'		//test:8023D000000FaiC prod:8025A000003S0CS
        ];
        
        delete item_pedido;
        
        test.stopTest();
    }
    
}