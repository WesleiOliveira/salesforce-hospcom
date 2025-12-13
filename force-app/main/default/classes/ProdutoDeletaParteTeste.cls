@isTest(seeAllData=true)
private class ProdutoDeletaParteTeste {
	
    @isTest static void UpdateTeste(){
		
		Product2 produto = [SELECT Id, isActive FROM Product2 WHERE id = '01t5A0000089SnO'];
		produto.isActive = false;
		update produto;
		
	}	
	
    @isTest static void DeleteTeste(){
		
		Product2 produto = [SELECT Id, isActive FROM Product2 WHERE id = '01t5A0000089SnO'];
		delete produto;
		
	}	
	
}