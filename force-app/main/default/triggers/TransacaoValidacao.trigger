trigger TransacaoValidacao on Transacao__c (before insert, before update, before delete) {

	if(!Util.IgnorarErros() && !Util.AcaoInterna()){
		
		Set<Id> viagens_id = new Set<Id>();
		for(Transacao__c transacao : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			viagens_id.add(transacao.Viagem__c);
		}
		List<Viagem__c> viagens = [
			SELECT	Id, Status__c
			FROM	Viagem__c
			WHERE 	Id IN :viagens_id
		];
		
		Set<String> usuarios_valicacao_id = new Set<String>();
		for(GroupMember usuario_valicacao : [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name LIKE '%Financeiro (adiantamento)%'])
			usuarios_valicacao_id.add(String.valueOf(usuario_valicacao.UserOrGroupId));
		
		for(Transacao__c transacao : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			
			for(Viagem__c viagem : viagens){
				if(transacao.Viagem__c == viagem.Id){
					
					// bloqueia edição
					if(transacao.Tipo__c == 'Requisição' && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação' && viagem.Status__c!='Em aprovação'){
						Boolean alterado = false;
						if(Trigger.isUpdate){
							Map<String, Object> trans_old = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Trigger.oldMap.get(transacao.Id)));
							Map<String, Object> trans_new = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(transacao));
							trans_old.put('Adiantamento__c', null);    trans_new.put('Adiantamento__c', null);						
							if(trans_old != trans_new)
								alterado = true;
						}else
							alterado = true;
						if(alterado)
							transacao.addError('Para proceder com a operação, o status da viagem deve estar EM RASCUNHO/EM COTAÇÃO.');
					}
					else if(transacao.Tipo__c == 'Quitação' && transacao.Categoria__c != 'Estorno' &&
							viagem.Status__c!='Em prestação de contas' && viagem.Status__c!='Em quitação de valores'){
						Boolean alterado = false;
						if(Trigger.isUpdate){
							Map<String, Object> trans_old = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Trigger.oldMap.get(transacao.Id)));
							Map<String, Object> trans_new = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(transacao));
							trans_old.put('Adiantamento__c', null);    trans_new.put('Adiantamento__c', null);						
							if(trans_old != trans_new)
								alterado = true;
						}else
							alterado = true;
						if(alterado)
							transacao.addError('Para proceder com a operação, o status da viagem deve estar EM PRESTAÇÃO DE CONTAS/EM QUITAÇÃO DE VALORES.');
					}
					else if(transacao.Tipo__c == 'Quitação' && transacao.Categoria__c == 'Estorno' && 
							viagem.Status__c!='Em prestação de contas' && viagem.Status__c!='Em quitação de valores' && viagem.Status__c!='Concuída'){
						Boolean alterado = false;
						if(Trigger.isUpdate){
							Map<String, Object> trans_old = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Trigger.oldMap.get(transacao.Id)));
							Map<String, Object> trans_new = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(transacao));
							trans_old.put('Adiantamento__c', null);    trans_new.put('Adiantamento__c', null);						
							if(trans_old != trans_new)
								alterado = true;
						}else
							alterado = true;
						if(alterado)
							transacao.addError('Para proceder com a operação, o status da viagem deve estar EM PRESTAÇÃO DE CONTAS/EM QUITAÇÃO DE VALORES.');
					}
					
				}
			}
			
			// Valor válido
			if( !usuarios_valicacao_id.contains(String.valueOf(UserInfo.getUserId())) && 
			   ((Trigger.isInsert && transacao.Valor_valido__c!=null) || (Trigger.isUpdate && Trigger.oldMap.get(transacao.Id).Valor_valido__c != transacao.Valor_valido__c)))
				transacao.Valor_valido__c.addError('Apenas usuários do grupo Financeiro (adiantamento) alteram esse valor');
				
		}
	}

}