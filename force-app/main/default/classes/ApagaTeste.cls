@isTest(seeAllData=true)
private class ApagaTeste {
	
    @isTest static void Teste1(){
		Order pedido = new Order();
		pedido = [SELECT Id FROM Order WHERE Id = '8015A000002hqVN'];
		update pedido;
    }
 
    @isTest static void Teste2(){
		OrderItem item = new OrderItem();
		item = [SELECT Id FROM OrderItem WHERE Id = '8025A000003S0DK'];
		update item;
    }
	
}