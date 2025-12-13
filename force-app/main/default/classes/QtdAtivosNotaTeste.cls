@isTest(SeeAllData=true)
private class QtdAtivosNotaTeste { 
    
    static testMethod void Teste1(){ 
        test.startTest();    
        
		Asset ativo = new Asset(
        	
        );
        ativo = [
            SELECT 	Id, Faturamento__c
            FROM	Asset
            WHERE	id = '02i5A000007zn9W'
        ];
        ativo.Faturamento__c = Id.valueof('a085A00001lpPDj');
        update ativo;

    	test.stopTest();
    }
    
}