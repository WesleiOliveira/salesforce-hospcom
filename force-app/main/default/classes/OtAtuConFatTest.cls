@isTest(seeAllData=true)
public class OtAtuConFatTest { 
	
    static testMethod void OtAtuConFatOpp(){ 
        test.startTest();
       	
        WorkOrder ordem_de_trabalho = new WorkOrder();
        ordem_de_trabalho =[
            SELECT	Id, Oportunidade_Relacionada__c, ServiceContractId, AccountId, Faturamento_Feito2__c
            FROM	WorkOrder
            WHERE 	Id = '0WO5A000000XezU'				// prd:WO5A000000XezU
        ];
        
        ordem_de_trabalho.Oportunidade_Relacionada__c = '0065A00000ipo7V';	// prd:0065A00000ipo7V
        ordem_de_trabalho.ServiceContractId = null;
        
        ordem_de_trabalho.AccountId = null;
        ordem_de_trabalho.ContactId = null;
        ordem_de_trabalho.Faturamento_Feito2__c = null;
        
        update ordem_de_trabalho;
        
        test.stopTest();
    }
    
    static testMethod void OtAtuConFatContr(){ 
        test.startTest();
       	
        WorkOrder ordem_de_trabalho = new WorkOrder();
        ordem_de_trabalho =[
            SELECT	Id, Oportunidade_Relacionada__c, ServiceContractId, AccountId, Faturamento_Feito2__c
            FROM	WorkOrder
            WHERE 	Id = '0WO5A000000XezU'				// prd:WO5A000000XezU
        ];
        
        ordem_de_trabalho.Oportunidade_Relacionada__c = null;
        ordem_de_trabalho.ServiceContractId = '8105A000003GFST'; // prd:8105A000003GFST
        
        ordem_de_trabalho.AccountId = null;
        ordem_de_trabalho.ContactId = null;
        ordem_de_trabalho.Faturamento_Feito2__c = null;
        
        update ordem_de_trabalho;
        
        test.stopTest();
    }
    

}