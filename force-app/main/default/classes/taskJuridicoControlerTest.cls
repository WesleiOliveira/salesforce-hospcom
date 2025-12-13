@isTest
private class taskJuridicoControlerTest {

    @isTest
    static void testUpdateTask() {
        // Cria uma task de teste
        Task t = new Task(
            Subject = 'NDA',
            Status = 'Não iniciado',
            Priority = 'Normal'
        );
        insert t;

        // Prepara os campos a serem atualizados
        Map<String, Object> campos = new Map<String, Object>{
            'Subject' => 'Atualizado pelo teste',
            'Status' => 'Concluído'
        };

        // Executa o método
        taskJuridicoControler.updateTask(t.Id, campos);

        // Verifica se os valores foram atualizados
        Task atualizada = [SELECT Subject, Status FROM Task WHERE Id = :t.Id];
        System.assertEquals('Atualizado pelo teste', atualizada.Subject);
        System.assertEquals('Concluído', atualizada.Status);
    }

    @isTest
    static void testRenameFileAndDeleteFile() {
        // Cria um arquivo fake (ContentVersion)
        ContentVersion cv = new ContentVersion(
            Title = 'ArquivoTeste',
            PathOnClient = 'ArquivoTeste.pdf',
            VersionData = Blob.valueOf('Conteúdo fictício')
        );
        insert cv;

        // Recupera ContentDocumentId
        ContentVersion cvInserted = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id docId = cvInserted.ContentDocumentId;

        // Cria link com um registro qualquer (Task)
        Task t = new Task(Subject = 'NDA', Status = 'Não iniciado');
        insert t;

        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = t.Id,
            ContentDocumentId = docId,
            ShareType = 'V'
        );
        insert link;

        // Renomeia o arquivo
        taskJuridicoControler.renameFile('NovoNome', docId);
        ContentVersion renamed = [SELECT Title FROM ContentVersion WHERE ContentDocumentId = :docId ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals('NovoNome', renamed.Title);

        // Deleta o arquivo
        taskJuridicoControler.deleteFile(t.Id, 'NovoNome');

        // Confirma que o documento foi deletado
        List<ContentDocument> deleted = [SELECT Id FROM ContentDocument WHERE Id = :docId];
        System.assertEquals(0, deleted.size(), 'O documento deve ter sido deletado');
    }
    
    @isTest
    static void testarAtualizarAssunto() {
        // Cria uma Task de teste
        Task t = new Task(
            Subject = 'Departamento Juridico',
           	AssuntoJuridco__c = 'Denúncia',
            Status = 'Não iniciado',
            Priority = 'Normal'
        );
        insert t;

        // Chama o método que atualiza o assunto
        TaskJuridicoControler.atualizarAssunto(t.Id, 'NDA');

        // Verifica se foi atualizado
        Task atualizado = [SELECT AssuntoJuridco__c FROM Task WHERE Id = :t.Id];
    }    
    
}