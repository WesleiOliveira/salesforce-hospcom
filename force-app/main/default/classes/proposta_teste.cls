@isTest(SeeAllData=true)
public class proposta_teste { 
	
    static testMethod void proposta_teste_lista(){ 
        
        Opportunity opp = new Opportunity();
        opp = [
            SELECT 	Id
            FROM	Opportunity
            WHERE	Id = '0065A00000ipGtR'
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
            proposta_listagem lista = new proposta_listagem(stdCtrl);
		test.stopTest();
    }
}