public class taskJuridicoControler {
    
    @AuraEnabled
    public static void updateTask(String recordId, Map<String, Object> fieldsValue) {
        System.debug('Início do método updateTask');
        System.debug('recordId: ' + recordId);
        System.debug('fieldsValue: ' + fieldsValue);
        
        if (String.isBlank(recordId)) {
            System.debug('Erro: ID da Tarefa é obrigatório');
            throw new AuraHandledException('O ID da Tarefa é obrigatório.');
        }
        
        if (fieldsValue == null || fieldsValue.isEmpty()) {
            System.debug('Erro: Nenhum campo fornecido para atualização');
            throw new AuraHandledException('Nenhum campo foi fornecido para atualização.');
        }
        
        Task taskToUpdate = [SELECT Id FROM Task WHERE Id = :recordId LIMIT 1];
        System.debug('Tarefa encontrada: ' + taskToUpdate);
        
        for (String fieldName : fieldsValue.keySet()) {
            try {
                Object fieldValue = fieldsValue.get(fieldName);
                Schema.SObjectField sfield = Task.SObjectType.getDescribe().fields.getMap().get(fieldName);
                Schema.DisplayType fieldType = sfield.getDescribe().getType();
                
                System.debug('Atualizando campo: ' + fieldName + ' com valor: ' + fieldValue + ' (Tipo: ' + fieldType + ')');
                
                // Conversão de tipos básicos
                if (fieldValue != null) {
                    switch on fieldType {
                        when DATE {
                            fieldValue = Date.valueOf((String)fieldValue);
                        }
                        when DATETIME {
                            fieldValue = DateTime.valueOf((String)fieldValue);
                        }
                        when BOOLEAN {
                            fieldValue = Boolean.valueOf(String.valueOf(fieldValue));
                        }
                        when DOUBLE {
                            fieldValue = Double.valueOf(String.valueOf(fieldValue));
                        }
                        when INTEGER {
                            fieldValue = Integer.valueOf(String.valueOf(fieldValue));
                        }
                        // Outros tipos podem ser adicionados conforme necessário
                        when else {
                            // mantém o valor como está
                        }
                    }
                }
                
                taskToUpdate.put(fieldName, fieldValue);
            } catch (Exception e) {
                System.debug('Erro ao atualizar o campo ' + fieldName + ': ' + e.getMessage());
                throw new AuraHandledException('Erro ao atualizar o campo "' + fieldName + '": ' + e.getMessage());
            }
        }
        
        update taskToUpdate;
        System.debug('Tarefa atualizada com sucesso: ' + taskToUpdate.Id);
    }
    
    @AuraEnabled
    public static void renameFile(String auraId, String contentDocumentId) {
        System.debug('Início do método renameFile');
        System.debug('auraId: ' + auraId);
        System.debug('contentDocumentId: ' + contentDocumentId);
        
        ContentVersion version = [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        System.debug('Versão do arquivo encontrada: ' + version);
        
        version.Title = auraId;
        update version;
        
        System.debug('Arquivo renomeado com sucesso. Novo título: ' + version.Title);
    }
    
    @AuraEnabled
    public static void deleteFile(Id recordId, String fileName) {
        System.debug('Início do método deleteFile');
        System.debug('recordId: ' + recordId);
        System.debug('fileName: ' + fileName);
        
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];
        
        System.debug('Links encontrados: ' + links);
        
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            docIds.add(link.ContentDocumentId);
        }
        
        System.debug('IDs de documentos: ' + docIds);
        
        if (docIds.isEmpty()) {
            System.debug('Nenhum documento vinculado ao registro');
            return;
        }
        
        List<ContentVersion> versions = [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :docIds
            AND Title LIKE :('%' + fileName + '%') 
            ORDER BY CreatedDate DESC
        ];
        
        System.debug('Versões encontradas: ' + versions);
        
        if (!versions.isEmpty()) {
            List<ContentDocument> toDelete = [
                SELECT Id FROM ContentDocument WHERE Id = :versions[0].ContentDocumentId
            ];
            System.debug('Deletando documento: ' + toDelete);
            delete toDelete;
            System.debug('Documento deletado com sucesso.');
        } else {
            System.debug('Nenhuma versão encontrada com o nome informado.');
        }
    }

    @AuraEnabled
    public static void atualizarAssunto(Id taskId, String novoAssunto) {
        system.debug('taskId: ' + taskId);
        system.debug('novoAssunto: ' + novoAssunto);
        try {
            Task t = [SELECT Id, AssuntoJuridco__c FROM Task WHERE Id = :taskId LIMIT 1];
            t.AssuntoJuridco__c = novoAssunto;
            update t;
        } catch (Exception e) {
            // Lança erro personalizado para o componente Lightning
            throw new AuraHandledException('Erro ao atualizar o Assunto Jurídico: ' + e.getMessage());
        }
    }
}