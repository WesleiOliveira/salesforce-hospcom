trigger ContaAnexos on ContentDocumentLink (after insert, after update) {
	
    String IdStr, Prefix;
    IdStr = String.valueOf(Trigger.new[0].LinkedEntityId);
    Prefix = IdStr.substring(0,3);
    
    // a03 = Documentos
    
    if(Prefix == 'a03'){
        Documentos_Licita_ao__c documento = new Documentos_Licita_ao__c();
        documento = [
            SELECT	Id, Quantidade_Documentos__c
            FROM	Documentos_Licita_ao__c
            WHERE	Id = :IdStr
        ];
        
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        links = [
            SELECT	id
            FROM	ContentDocumentLink
            WHERE	LinkedEntityId = :IdStr
        ];
        documento.Quantidade_Documentos__c = links.size();
        update documento;
    }
    
}