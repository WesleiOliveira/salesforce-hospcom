trigger ViajanteCompartilha on Viajante__c (after delete, after insert, after update) {

	Set<Id> viagens_id = new Set<Id>();
	for(Viajante__c viajante : (Trigger.isDelete ? Trigger.old : Trigger.new))
		viagens_id.add(viajante.Viagem__c);
	
	List<Viagem__c> viagens = [
		SELECT	Id, OwnerId, (
					SELECT	Id, Usuario__c
					FROM	Viajantes__r
				), (
					SELECT	Id
					FROM	Shares
					WHERE 	RowCause = 'Manual'
				)
		FROM	Viagem__c
		WHERE	Id IN :viagens_id
	];
	
	List<Viagem__Share> membros_del = new List<Viagem__Share>();
	List<Viagem__Share> membros_add = new List<Viagem__Share>();
	for(Viagem__c viagem : viagens){
		membros_del.addAll(viagem.Shares);
		for(Viajante__c viajante : viagem.Viajantes__r){
			if(viajante.Usuario__c != viagem.OwnerId)
				membros_add.add(new Viagem__Share(
					ParentId = viagem.Id,
					UserOrGroupId = viajante.Usuario__c,
					AccessLevel = 'Edit'
				));
		}
	}
	
	if(membros_del.size()>0)
		delete membros_del;
	if(membros_add.size()>0)
		insert membros_add;

}