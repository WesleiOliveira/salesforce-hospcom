@isTest(SeeAllData=true)
public class RemoveFromOppTest { 
	
    static testMethod void RemoveFromOppTest1(){ 
        
        OpportunityTeamMember opp_member = new OpportunityTeamMember();	
        opp_member = [
            SELECT 	Id, UserId, OpportunityId
            FROM 	OpportunityTeamMember
            WHERE	Id =  '00q5A000006VXsc'
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp_member);
            RemoveFromOpp alteracao = new RemoveFromOpp(stdCtrl);
			alteracao.RemoveNow();        
		test.stopTest();
    }
}