trigger ViajanteValidacao on Viajante__c (before insert, before update, before delete) {

	if(!Util.IgnorarErros() && !Util.AcaoInterna()){
		
		Set<Id> viagens_id = new Set<Id>();
		for(Viajante__c viajante : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			viagens_id.add(viajante.Viagem__c);
		}
		List<Viagem__c> viagens = [
			SELECT	Id, Status__c
			FROM	Viagem__c
			WHERE 	Id IN :viagens_id
		];
		
		for(Viajante__c viajante : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			for(Viagem__c viagem : viagens){
				
				// bloqueia edição
				if(viajante.Viagem__c == viagem.Id && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação' && viagem.Status__c!='Em aprovação'){
					Boolean alterado = false;
					if(Trigger.isUpdate){
						Map<String, Object> item_old = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Trigger.oldMap.get(viajante.Id)));
						Map<String, Object> item_new = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(viajante));
						if(item_old != item_new)
							alterado = true;
					}else
						alterado = true;
					if(alterado)
						viajante.addError('Para proceder com a operação, o status da viagem deve estar EM RASCUNHO/EM COTAÇÃO.');
				}
				
			}
		}
		
	}

}