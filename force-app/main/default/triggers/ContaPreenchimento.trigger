trigger ContaPreenchimento on Account (before insert, before update, after insert, after update) {

	if(Trigger.IsBefore){
		
		// de lead
		Set<String> leads_num = new Set<String>();
		for(Account conta : Trigger.new){
			if(conta.Lead__c!=null)
				leads_num.add(conta.Lead__c);
		}
		if(leads_num.size()>0){
			Util.AcaoInterna(true);
			for(Lead lead : [SELECT Numero__c, Tipo__c FROM Lead WHERE Numero__c IN:leads_num])
				for(Account conta : Trigger.new)
					
					// descrição <= lead.interesse
					if(lead.Numero__c == conta.Lead__c){
						conta.Type = lead.Tipo__c;
						conta.Lead__c = null;
					}
		}
		
	}
	
	else if(Trigger.IsAfter){
		
		// da receita
		// somente unitário (limite da API)
		if(Trigger.new.size()==1 &&  Trigger.new[0].CNPJ__c != null && 
		  (Trigger.isInsert || (Trigger.isUpdate && 
		  (Trigger.old[0].CNPJ__c != Trigger.new[0].CNPJ__c || Trigger.new[0].Status_receita__c == null)))){
			
			// chama método da API
			if(Util.ObterTipoRegistro(Trigger.new[0].RecordTypeId) == 'Conta comercial')
				ContaPreenchimento.ChamarReceita(Trigger.new[0].Id, Trigger.new[0].CNPJ__c);
		}
		
	}
	
}