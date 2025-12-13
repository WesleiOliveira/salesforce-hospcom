trigger ContaAnexos3 on Documentos_Licita_ao__c (before update) {
    /*
    List<ContentDocumentLink> links = new List<ContentDocumentLink>();
    String id_doc = String.valueOf(Trigger.new[0].Id);
    links = [
        SELECT	id
        FROM	ContentDocumentLink
        WHERE	LinkedEntityId = :id_doc
    ];
    Trigger.new[0].Quantidade_Documentos__c = links.size();
    */
}