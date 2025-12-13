trigger getAnexoFaturamento on ContentDocumentLink (after insert) {
    System.debug('Trigger getAnexoFaturamento chamada');
    
    // Obtenha o conjunto de IDs dos registros aos quais os anexos estão vinculados
    Set<Id> linkedEntityIds = new Set<Id>();
    for(ContentDocumentLink cdl : Trigger.New) {
        linkedEntityIds.add(cdl.LinkedEntityId);
    }

    // Faça uma consulta para obter os registros do tipo Faturamento__c
    Map<Id, Faturamento__c> linkedEntities = new Map<Id, Faturamento__c>(
        [SELECT Id, URL_Anexo__c FROM Faturamento__c WHERE Id IN :linkedEntityIds]
    );

    // Lista para armazenar os registros a serem atualizados
    List<Faturamento__c> faturamentoToUpdate = new List<Faturamento__c>();

    // Percorre os ContentDocumentLinks recém-inseridos
    for(ContentDocumentLink cdl : Trigger.New) {
        // Verifique se o registro vinculado é do tipo Faturamento__c
        if (linkedEntities.containsKey(cdl.LinkedEntityId)) {
            System.debug('Registro vinculado ao Faturamento__c encontrado: ' + cdl.LinkedEntityId);

            // Obtenha o ContentDocumentId associado ao ContentDocumentLink
            Id contentDocumentId = cdl.ContentDocumentId;
            
            // Construa a URL do anexo
            String baseUrl = 'https://hospcom.my.site.com/Sales/sfc/servlet.shepherd/document/download/';
            String anexoUrl = baseUrl + contentDocumentId;
            
            // Atualize o campo URL_Anexo__c do registro Faturamento__c
            Faturamento__c faturamentoRecord = linkedEntities.get(cdl.LinkedEntityId);
            faturamentoRecord.URL_Anexo__c = anexoUrl;
            faturamentoToUpdate.add(faturamentoRecord);

            // Debug logs para verificar o processo
            System.debug('Um anexo foi adicionado ao registro Faturamento__c com ID: ' + cdl.LinkedEntityId);
            System.debug('ContentDocumentId associado ao anexo: ' + contentDocumentId);
            System.debug('URL do anexo: ' + anexoUrl);
        }
    }

    // Atualize os registros Faturamento__c
    if (!faturamentoToUpdate.isEmpty()) {
        update faturamentoToUpdate;
    }
}