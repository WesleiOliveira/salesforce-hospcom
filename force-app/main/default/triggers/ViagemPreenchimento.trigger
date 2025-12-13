trigger ViagemPreenchimento on Viagem__c (before insert, before update) {

	Set<Id> oportunidades_id = new Set<Id>();
	Set<Id> ordens_de_trabalho_id = new Set<Id>();
	for(Viagem__c viagem : Trigger.new){
		if(viagem.Oportunidade__c != null)
			oportunidades_id.add(viagem.Oportunidade__c);
		if(viagem.Ordem_de_trabalho__c != null)
			ordens_de_trabalho_id.add(viagem.Ordem_de_trabalho__c);
	}
	List<Opportunity> oportunidades = new List<Opportunity>();
	if(oportunidades_id.size()>0)
		oportunidades = [
			SELECT	Id, AccountId
			FROM	Opportunity
			WHERE	Id in :oportunidades_id AND SyncedQuoteId!=null
		];	
	List<WorkOrder> ordens_de_trabalho = new List<WorkOrder>();
	if(ordens_de_trabalho_id.size()>0)
		ordens_de_trabalho = [
			SELECT	Id, AccountId
			FROM	WorkOrder
			WHERE	Id IN :ordens_de_trabalho_id
		];	
	
	for(Viagem__c viagem : Trigger.new){
		
		// status
		if(Trigger.IsInsert)
			viagem.Status__c = 'Em rascunho';
		
		if(viagem.Oportunidade__c!=null){
			for(Opportunity oportunidade : oportunidades){
				if(viagem.Oportunidade__c == oportunidade.Id){
					
					// conta
					if(viagem.Conta__c==null)
						viagem.Conta__c = oportunidade.AccountId;
						
				}
			}
		}
		
		if(viagem.Ordem_de_trabalho__c!=null){
			for(WorkOrder ordem_de_trabalho : ordens_de_trabalho){				
				if(viagem.Ordem_de_trabalho__c == ordem_de_trabalho.Id){
					
					// conta
					if(viagem.Conta__c==null)
						viagem.Conta__c = ordem_de_trabalho.AccountId;
					
				}			
			}
		}
		
	}

}