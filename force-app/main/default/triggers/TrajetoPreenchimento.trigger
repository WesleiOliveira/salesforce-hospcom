trigger TrajetoPreenchimento on Trajeto__c (before insert, before update, after insert, after update) {

	if(Trigger.isBefore){
		Set<Id> trajetos_origem_id = new Set<Id>();
		Set<Id> viagens_id = new Set<Id>();
		for(Trajeto__c trajeto : Trigger.new){
			if(trajeto.Trajeto_de_origem__c != null)
				trajetos_origem_id.add(trajeto.Trajeto_de_origem__c);
			else
				viagens_id.add(trajeto.Viagem__c);
		}
		
		List<Trajeto__c> trajetos_origem = new List<Trajeto__c>();
		if(trajetos_origem_id.size()>0)
			trajetos_origem = [
				SELECT	Id, Estado_destino__c, Cidade_destino__c
				FROM	Trajeto__c
				WHERE	Id in :trajetos_origem_id
			];	
		List<Viagem__c> viagens = new List<Viagem__c>();
		if(viagens_id.size()>0){
			viagens = [
				SELECT	Id, (
							SELECT	 Id, Estado_destino__c, Cidade_destino__c, Data__c
							FROM	 Trajetos__r
							ORDER BY Data__c DESC
							LIMIT 	 1
						)
				FROM	Viagem__c
				WHERE	Id IN :viagens_id
			];
		}
		
		for(Trajeto__c trajeto : Trigger.new){
			
			// estado/cidade origem
			if(trajeto.Trajeto_de_origem__c!=null){
				for(Trajeto__c  trajeto_origem : trajetos_origem){
					if(trajeto.Trajeto_de_origem__c == trajeto_origem.Id){
						trajeto.Estado_origem__c = trajeto_origem.Estado_destino__c;
						trajeto.Cidade_origem__c = trajeto_origem.Cidade_destino__c;
					}
				}
			}
			else if(trajeto.Estado_origem__c==null && trajeto.Cidade_origem__c==null){
				for(Viagem__c  viagem : viagens){
					if(trajeto.Viagem__c==viagem.Id && viagem.Trajetos__r.size()==1){
						if(trajeto.Id!=viagem.Trajetos__r[0].Id && trajeto.Data__c > viagem.Trajetos__r[0].Data__c){
							trajeto.Trajeto_de_origem__c = viagem.Trajetos__r[0].Id;
							trajeto.Estado_origem__c = viagem.Trajetos__r[0].Estado_destino__c;
							trajeto.Cidade_origem__c = viagem.Trajetos__r[0].Cidade_destino__c;						
						}
					}
				}
			}
			
		}
	}
	
	else if(Trigger.isAfter){
		Set<Id> trajetos_id = new Set<Id>();
		Set<Id> viagens_id = new Set<Id>();
		for(Trajeto__c trajeto : Trigger.new){
			trajetos_id.add(trajeto.Id);
			if(trajeto.Incluir_todos_os_viajantes__c)
				viagens_id.add(trajeto.Viagem__c);
		}
		List<Trajeto__c> trajetos = [
			SELECT	Id, Viagem__c, Incluir_todos_os_viajantes__c, (
						SELECT	Viajante__c
						FROM	Passageiros__r
					)
			FROM	Trajeto__c
			WHERE	Id IN :trajetos_id
		];
		List<Viagem__c> viagens = [
			SELECT	Id, (
						SELECT	Id
						FROM	Viajantes__r
					)
			FROM	Viagem__c
			WHERE	Id IN :viagens_id
		];
		
		List<Passageiro__c> passageiros = new List<Passageiro__c>();
		Set<String> passageiros_existentes_id = new Set<String>();
		
		for(Trajeto__c trajeto : trajetos){
			if(trajeto.Incluir_todos_os_viajantes__c){
				passageiros_existentes_id.clear();
				for(Passageiro__c passageiro : trajeto.Passageiros__r)
					passageiros_existentes_id.add(String.valueOf(passageiro.Viajante__c));
				for(Viagem__c viagem : viagens){
					if(trajeto.Viagem__c == viagem.Id){
						for(Viajante__c viajante : viagem.Viajantes__r){
							if(!passageiros_existentes_id.contains(viajante.Id))
								passageiros.add(new Passageiro__c(
									Trajeto__c = trajeto.Id,
									Viajante__c = viajante.Id
								));
						}
					}
				}
			}
		}
		if(passageiros.size()>0)
			insert passageiros;
	}

}