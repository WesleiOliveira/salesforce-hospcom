trigger EvitaDuplicarAtivo on Asset (before insert, before update) {
    
    // valida nº série
    if(Trigger.new[0].SerialNumber != '' && Trigger.new[0].SerialNumber != null){
        List<Asset> ativo = new List<Asset>();
        if(Trigger.isInsert)
            ativo = [
                SELECT	Id
                FROM	Asset
                WHERE	SerialNumber = :Trigger.new[0].SerialNumber	AND
                        Marca__c     = :Trigger.new[0].Marca__c
            ];
        else if(Trigger.isUpdate)
            ativo = [
                SELECT	Id
                FROM	Asset
                WHERE	SerialNumber = :Trigger.new[0].SerialNumber	AND
                        Marca__c     = :Trigger.new[0].Marca__c		AND
                		Id			!= :Trigger.old[0].Id
            ];
        if(ativo.size()!=0)
            Trigger.new[0].SerialNumber.addError('Este Número de Série já foi cadastrado para esta Marca');
    }
    
    // valida ID / Tag
    if(Trigger.new[0].ID_Tag__c != '' && Trigger.new[0].ID_Tag__c != null){
        List<Asset> ativo = new List<Asset>();
        if(Trigger.isInsert)        
            ativo = [
                SELECT	Id
                FROM	Asset
                WHERE	ID_Tag__c = :Trigger.new[0].ID_Tag__c	AND
                        AccountId = :Trigger.new[0].AccountId
            ];
        else if(Trigger.isUpdate)
            ativo = [
                SELECT	Id
                FROM	Asset
                WHERE	ID_Tag__c = :Trigger.new[0].ID_Tag__c	AND
                        AccountId = :Trigger.new[0].AccountId	AND
                		Id 		 != :Trigger.old[0].Id
            ];
        if(ativo.size()!=0)
            Trigger.new[0].ID_Tag__c.addError('Este ID/Tag já foi cadastrado nesta Conta');
    }
    
    // valida Patrimônio
    if(Trigger.new[0].patrimonio__c != '' && Trigger.new[0].patrimonio__c != null){
        List<Asset> ativo = new List<Asset>();
        if(Trigger.isInsert)                
            ativo = [
                SELECT	Id
                FROM	Asset
                WHERE	patrimonio__c = :Trigger.new[0].patrimonio__c	AND
                        AccountId 	  = :Trigger.new[0].AccountId
            ];
        else if(Trigger.isUpdate)
            ativo = [
                SELECT	Id
                FROM	Asset
                WHERE	patrimonio__c = :Trigger.new[0].patrimonio__c	AND
                        AccountId 	  = :Trigger.new[0].AccountId		AND
                		Id			 != :Trigger.old[0].Id
            ];
        if(ativo.size()!=0)
            Trigger.new[0].patrimonio__c.addError('Este Patrimônio já foi cadastrado nesta Conta');
    }
	
}