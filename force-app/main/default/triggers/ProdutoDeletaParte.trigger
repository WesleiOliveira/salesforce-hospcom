trigger ProdutoDeletaParte on Product2 (before update, before delete) {
	
    List<Id> produtos_id = new List<Id>();
	List<MktParte__c> partes;
	
	if (Trigger.isUpdate){
		for(Product2 produto : Trigger.old)
			if(produto.isActive == false)
				produtos_id.add(produto.id);
	}else if (Trigger.isDelete){
		for(Product2 produto : Trigger.old)
			produtos_id.add(produto.id);
	}
    
    partes = [
		SELECT 	Id
		FROM	MktParte__c
		WHERE	Parte__c IN :produtos_id
	];
	
	if(partes.size()>0)
		delete partes;
	
}