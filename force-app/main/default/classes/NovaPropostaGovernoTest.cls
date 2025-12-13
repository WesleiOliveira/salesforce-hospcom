@isTest(SeeAllData=true)
public class NovaPropostaGovernoTest {
	
    static testMethod void proposta_teste_lista(){ 
        
        Opportunity opp = new Opportunity();
        opp = [
            SELECT 	Id
            FROM	Opportunity
            WHERE	Id = '0066e00001fwWaYAAU'
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
            NovaPropostaGoverno lista = new NovaPropostaGoverno(stdCtrl);
		test.stopTest();
    }
}