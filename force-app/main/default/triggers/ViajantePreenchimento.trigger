trigger ViajantePreenchimento on Viajante__c (after insert, after update, after delete) {

	Set<Id> viagens_id = new Set<Id>();
	for(Viajante__c viajante : (Trigger.isDelete ? Trigger.old : Trigger.new))
		viagens_id.add(viajante.Viagem__c);
	
	List<Viagem__c> viagens = [
		SELECT	Id, (
					SELECT	Id
					FROM	Viajantes__r
				)
		FROM	Viagem__c
		WHERE	Id IN :viagens_id
	];
	List<Trajeto__c> trajetos = [
		SELECT	Id, Viagem__c, (
					SELECT	Id, Viajante__c
					FROM	Passageiros__r
				)
		FROM	Trajeto__c
		WHERE	Viagem__c IN :viagens_id 		AND 
				Incluir_todos_os_viajantes__c = true
	];
	
	List<Passageiro__c> passageiros = new List<Passageiro__c>();
	Set<String> passageiros_existentes_id = new Set<String>();
	
	for(Trajeto__c trajeto : trajetos){
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
	if(passageiros.size()>0)
		insert passageiros;

}