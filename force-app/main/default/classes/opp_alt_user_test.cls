@isTest(SeeAllData=true)
public class opp_alt_user_test { 
	
    static testMethod void opp_alt_user_full(){ 
        
        Opportunity opp = new Opportunity();
        opp = [
            SELECT 	Id
            FROM	Opportunity
            WHERE	Id = '0065A00000ipGtR'
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
            opp_alt_user alteracao = new opp_alt_user(stdCtrl);
		test.stopTest();
    }
}