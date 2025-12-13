trigger SetorUnico on Setor__c (before insert, before update) {

    List<Setor__c> setores = new List<Setor__c>();
    
    if(Trigger.isInsert)
        setores = [
            SELECT	Id
            FROM	Setor__c
            WHERE	Conta__c 	= :Trigger.new[0].Conta__c	AND
                    Name		= :Trigger.new[0].Name	
        ];
   	else if(Trigger.isUpdate)
        setores = [
            SELECT	Id
            FROM	Setor__c
            WHERE	Conta__c 	= :Trigger.new[0].Conta__c	AND
                    Name		= :Trigger.new[0].Name		AND
            		Id			!=:Trigger.old[0].Id
        ];
    
    if(setores.size() != 0)
        Trigger.new[0].Name.addError('Este Setor já foi cadastrado nesta Conta'); 
 
}