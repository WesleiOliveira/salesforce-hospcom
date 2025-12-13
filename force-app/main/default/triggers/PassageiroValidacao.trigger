trigger PassageiroValidacao on Passageiro__c (before insert, before update, before delete) {

	if(!Util.IgnorarErros() && !Util.AcaoInterna()){
		
		Set<Id> trajetos_id = new Set<Id>();
		for(Passageiro__c passageiro : (Trigger.isDelete ? Trigger.old : Trigger.new))
			trajetos_id.add(passageiro.Trajeto__c);
		List<Trajeto__c> trajetos = [
			SELECT	Id, Viagem__c
			FROM	Trajeto__c
			WHERE 	Id IN :trajetos_id
		];
		
		Set<Id> viagens_id = new Set<Id>();
		for(Trajeto__c trajeto : trajetos)
			viagens_id.add(trajeto.Viagem__c);
		List<Viagem__c> viagens = [
			SELECT	Id, Status__c
			FROM	Viagem__c
			WHERE 	Id IN :viagens_id
		];
		
		for(Passageiro__c passageiro : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			for(Trajeto__c trajeto : trajetos){
				if(passageiro.Trajeto__c == trajeto.Id){
					for(Viagem__c viagem : viagens){
						if(trajeto.Viagem__c == viagem.Id && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação' && viagem.Status__c!='Em aprovação'){
							Boolean alterado = false;
							if(Trigger.isUpdate){
								Map<String, Object> item_old = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Trigger.oldMap.get(passageiro.Id)));
								Map<String, Object> item_new = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(passageiro));
								if(item_old != item_new)
									alterado = true;
							}else
								alterado = true;
							if(alterado)
								trajeto.addError('Para proceder com a operação, o status da viagem deve estar EM RASCUNHO/EM COTAÇÃO.');							
						}
					}
				}
			}
		}
		
	}

}