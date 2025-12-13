@isTest(SeeAllData=true)
public class ConverteAnexosTeste { 
	
    static testMethod void ConverteDocs(){ 
        test.startTest();    
		
        Documentos_Licita_ao__c reg_doc = [
            SELECT	Id, Name
            FROM 	Documentos_Licita_ao__c
            WHERE	Id = 'a035A00000WR19b'
        ];
        
        reg_doc.Name = 'Teste Prod';
        update reg_doc;
        
        test.stopTest();
    }
        
    static testMethod void ConverteOpps(){ 
        test.startTest();    

        // testa oportunidade 
        Opportunity reg_opp = [
            SELECT	Id, Name
            FROM 	Opportunity
            WHERE	Id = '0065A00000hbfo1'
        ];
        
        reg_opp.Name = 'Teste Opp';
        update reg_opp;
        
        test.stopTest();
    }
}