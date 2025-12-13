trigger getAnexoNfCompra on ContentDocumentLink (after insert) {
    // Obtenha o conjunto de IDs dos registros aos quais os anexos estão vinculados
    Set<Id> linkedEntityIds = new Set<Id>();
    for(ContentDocumentLink cdl : Trigger.New) {
        linkedEntityIds.add(cdl.LinkedEntityId);
    }

    // Faça uma consulta para obter os registros do tipo Nota_fiscal_de_pedido_de_compra__c
    Map<Id, Nota_fiscal_de_pedido_de_compra__c> linkedEntities = new Map<Id, Nota_fiscal_de_pedido_de_compra__c>(
        [SELECT Id, URL_Anexo__c FROM Nota_fiscal_de_pedido_de_compra__c WHERE Id IN :linkedEntityIds]
    );

    // Lista para armazenar os registros a serem atualizados
    List<Nota_fiscal_de_pedido_de_compra__c> nfToUpdate = new List<Nota_fiscal_de_pedido_de_compra__c>();

    for(ContentDocumentLink cdl : Trigger.New) {
        // Verifique se o registro vinculado é do tipo Nota_fiscal_de_pedido_de_compra__c
        if (linkedEntities.containsKey(cdl.LinkedEntityId)) {
            // Obtenha o ContentDocumentId associado ao ContentDocumentLink
            Id contentDocumentId = cdl.ContentDocumentId;
            
            // Construa a URL do anexo
            String baseUrl = 'https://hospcom.my.site.com/Sales/sfc/servlet.shepherd/document/download/';
            String anexoUrl = baseUrl + contentDocumentId;
            
            // Atualize o campo URL_Anexo__c do registro Nota_fiscal_de_pedido_de_compra__c
            Nota_fiscal_de_pedido_de_compra__c nfRecord = linkedEntities.get(cdl.LinkedEntityId);
            nfRecord.URL_Anexo__c = anexoUrl;
            nfToUpdate.add(nfRecord);

            // Debug logs
            System.debug('Um anexo foi adicionado ao registro Nota_fiscal_de_pedido_de_compra__c com ID: ' + cdl.LinkedEntityId);
            System.debug('ContentDocumentId associado ao anexo: ' + contentDocumentId);
            System.debug('URL do anexo: ' + anexoUrl);
        }
    }

    // Atualize os registros Nota_fiscal_de_pedido_de_compra__c
    if (!nfToUpdate.isEmpty()) {
        update nfToUpdate;
    }
}