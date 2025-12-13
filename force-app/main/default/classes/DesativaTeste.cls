@isTest(SeeAllData=true)
private class DesativaTeste { 
    
    static testMethod void teste_geral(){ 
        test.startTest();    
        
		Documentos_Licita_ao__c documento = [
            SELECT Id, Name
            FROM   Documentos_Licita_ao__c
            WHERE  Id='a035A00000WR19b'
        ];
        documento.Name = 'teste';
        update documento;
        
        Opportunity opp = [
            SELECT 	Id, Name
            FROM	Opportunity
            WHERE	Id='0065A00000hbfo1'
        ];
        opp.Name = 'teste';
        update opp;
        
		test.stopTest();
    }
}