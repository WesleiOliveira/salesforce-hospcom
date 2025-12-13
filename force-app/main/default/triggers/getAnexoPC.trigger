trigger getAnexoPC on ContentDocumentLink (after insert) {
    // Obtenha o conjunto de IDs dos registros aos quais os anexos estão vinculados
    Set<Id> linkedEntityIds = new Set<Id>();
    for(ContentDocumentLink cdl : Trigger.New) {
        linkedEntityIds.add(cdl.LinkedEntityId);
    }

    // Faça uma consulta para obter os registros do tipo Fornecedor__c
    Map<Id, Fornecedor__c> linkedEntities = new Map<Id, Fornecedor__c>(
        [SELECT Id, URL_Anexo__c FROM Fornecedor__c WHERE Id IN :linkedEntityIds]
    );

    // Lista para armazenar os registros a serem atualizados
    List<Fornecedor__c> fornecedorToUpdate = new List<Fornecedor__c>();

    for(ContentDocumentLink cdl : Trigger.New) {
        // Verifique se o registro vinculado é do tipo Fornecedor__c
        if (linkedEntities.containsKey(cdl.LinkedEntityId)) {
            // Obtenha o ContentDocumentId associado ao ContentDocumentLink
            Id contentDocumentId = cdl.ContentDocumentId;
            
            // Construa a URL do anexo
            String baseUrl = 'https://hospcom.my.site.com/Sales/sfc/servlet.shepherd/document/download/';
            String anexoUrl = baseUrl + contentDocumentId;
            
            // Atualize o campo URL_Anexo__c do registro Fornecedor__c
            Fornecedor__c fornecedorRecord = linkedEntities.get(cdl.LinkedEntityId);
            fornecedorRecord.URL_Anexo__c = anexoUrl;
            fornecedorToUpdate.add(fornecedorRecord);

            // Debug logs
            System.debug('Um anexo foi adicionado ao registro Fornecedor__c com ID: ' + cdl.LinkedEntityId);
            System.debug('ContentDocumentId associado ao anexo: ' + contentDocumentId);
            System.debug('URL do anexo: ' + anexoUrl);
        }
    }

    // Atualize os registros Fornecedor__c
    if (!fornecedorToUpdate.isEmpty()) {
        update fornecedorToUpdate;
    }
}