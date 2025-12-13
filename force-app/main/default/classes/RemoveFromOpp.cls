public with sharing class RemoveFromOpp{
    
    public 	String					url_base {get;set;}
    public 	String					url_prefixo {get;set;}
    public	Boolean					renderiza {get;set;}
    public OpportunityTeamMember 	opp_member {get;set;}
    

    public RemoveFromOpp(ApexPages.StandardController controller) {
        url_base = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
        url_prefixo = Site.getPathPrefix();
        
        opp_member = (OpportunityTeamMember)controller.getRecord();	
        opp_member = [
            SELECT 	Id, UserId, OpportunityId
            FROM 	OpportunityTeamMember
            WHERE	Id =  :opp_member.Id
        ];
        
        Opportunity opp = new Opportunity();
        opp = [
            Select 	Id, OwnerId
            From 	Opportunity
            Where 	Id = :opp_member.OpportunityId
        ];
        
        if(UserInfo.getUserId() == opp_member.UserId && opp_member.UserId != opp.OwnerId)
            renderiza = true;
        else 
           renderiza = false;
	}
    
    public PageReference RemoveNow(){
        
		List<OpportunitySplit> opp_splits = new List<OpportunitySplit>();     
        opp_splits = [
            SELECT 	Id, SplitOwnerId, OpportunityId
            FROM	OpportunitySplit
            WHERE	OpportunityId = :opp_member.OpportunityId	AND
            		SplitOwnerId = :opp_member.UserId
        ];
        delete opp_splits;
        delete opp_member;
        return new PageReference('/');
    }
}