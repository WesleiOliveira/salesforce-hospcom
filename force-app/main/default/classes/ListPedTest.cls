@isTest(SeeAllData=true)
public class ListPedTest{ 
	
    static testMethod void ListPedTest1(){ 
	
        Order pedido = new Order();
        pedido = [
            SELECT 	Id
            FROM	Order
            WHERE	Id = '8015A000002fQTw'	//test:801f0000000S8Ao prod:8015A000002hqeZ
        ];

        test.startTest();
		
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(pedido);
		listagem_pedido listagem = new listagem_pedido(stdCtrl);
		
		test.stopTest();
    }
    
}