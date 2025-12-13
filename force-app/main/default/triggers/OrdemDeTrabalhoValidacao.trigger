trigger OrdemDeTrabalhoValidacao on WorkOrder (before insert, before update) {
    
	if(!Util.IgnorarErros()){
		
		Set<Id> demonstracoes_id = new Set<Id>();
		for(WorkOrder ordem_de_trabalho : Trigger.new){
			if(ordem_de_trabalho.Demonstracao__c!=null)
				demonstracoes_id.add(ordem_de_trabalho.Demonstracao__c);
		}
		
		if(demonstracoes_id.size()>0){
			List<Demonstracao__c> demonstracoes = [
				SELECT	Id, (
							SELECT	Ativo__c
							FROM	Produtos_da_Demonstracao__r
						)
				FROM	Demonstracao__c
				WHERE 	Id IN :demonstracoes_id
			];
			
			for(WorkOrder ordem_de_trabalho : Trigger.new){
				for(Demonstracao__c demonstracao : demonstracoes){
					if(ordem_de_trabalho.Demonstracao__c == demonstracao.Id){
						if(ordem_de_trabalho.AssetId == null){
							ordem_de_trabalho.AssetId.addError('OT de demonstração deve ter um ativo associado.');
						}else{
							boolean valido = false;
							for(Produto_da_Demonstracao__c item_demo : demonstracao.Produtos_da_Demonstracao__r){
								if(ordem_de_trabalho.AssetId == item_demo.Ativo__c){
									valido = true;
								}
							}
							if(!valido){
								ordem_de_trabalho.AssetId.addError('O ativo selecionado não faz parte da demonstração vinculada.');
							}
						}
					}
				}
			}
		}
		
	}
	
}