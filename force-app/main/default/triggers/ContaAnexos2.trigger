trigger ContaAnexos2 on ContentDocument (before delete) {
	
    List<ContentDocumentLink> link = new List<ContentDocumentLink>();
    
    link = [
        SELECT	Id, LinkedEntityId, ContentDocumentId
        FROM	ContentDocumentLink
        WHERE	ContentDocumentId = :Trigger.old[0].Id		AND
        		LinkedEntityId IN (
                	SELECT 	Id
                	FROM	Documentos_Licita_ao__c
                )
        LIMIT 	1
    ];
    
    if(link.size() > 0){
        
        Documentos_Licita_ao__c doc_empresa = new Documentos_Licita_ao__c();
        doc_empresa = [
            SELECT	id, Quantidade_Documentos__c
            FROM	Documentos_Licita_ao__c
            WHERE	id = :link[0].LinkedEntityId
        ];
           
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        links = [
            SELECT	Id
            FROM	ContentDocumentLink
            WHERE	LinkedEntityId = :doc_empresa.Id
        ];
        
        doc_empresa.Quantidade_Documentos__c = links.size()-1;
        update doc_empresa;
        
    }
       
}