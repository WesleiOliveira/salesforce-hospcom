@isTest(seeAllData=true)
public class PedAutoStatusTest { 
	
    static testMethod void test1(){ 
        test.startTest();
        	
		OrderItem item_pedido = new OrderItem();
        item_pedido = [
            SELECT	Id, Status__c
            FROM	OrderItem
            WHERE 	Id = '8025A000003S0DK' //test/prod:8025A000003S0DK
        ];
        
        item_pedido.Status__c = 'Novo';
        update item_pedido;
        
        test.stopTest();
    }
    
}