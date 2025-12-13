@isTest(SeeAllData=true)
public class MktTesteOrde { 
	
    static testMethod void MktTesteOrdeCate(){ 
        MktCategoria__c categoria = new MktCategoria__c();
        categoria = [
            SELECT 	Id
            FROM	MktCategoria__c
            WHERE	Id = 'a1R5A000005MNU3UAO'
        ];
        
        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(categoria);
			MktOrdeCate ordeCate = new MktOrdeCate(stdCtrl);  
        	ordeCate.stringFilhaNova = 'a1W5A000007Ia5S,a1W5A000008VvAs,a1W5A000008VvAx';
        	ordeCate.SalvarOrdem();
        test.stopTest();
    }  
}