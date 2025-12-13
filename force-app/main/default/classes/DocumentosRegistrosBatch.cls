public class DocumentosRegistrosBatch implements Database.Batchable<SObject>, Database.Stateful {

    private String comodatoId;
    private List<Map<String, String>> allAnexos = new List<Map<String, String>>();
    private String emailDestino;

    public DocumentosRegistrosBatch(String idComodato, String emailDestino) {
        this.comodatoId = idComodato;
        this.emailDestino = emailDestino;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Consulta inicial para obter todos os produtos associados ao comodato
        return Database.getQueryLocator([
            SELECT Id
            FROM Produto_da_demonstracao__c
            WHERE Demonstracao__c = :comodatoId
            ORDER BY CreatedDate
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Produto_da_demonstracao__c> scope) {
        // Chama o método documentosOts para obter os documentos associados ao comodato
        allAnexos.addAll(DocumentosRegistros.documentosOts(comodatoId));
    }

    public void finish(Database.BatchableContext bc) {
        // Convertendo os anexos para um arquivo ZIP
        Blob zipBlob = createZipFile(allAnexos);

        // Enviar o email com o arquivo ZIP em anexo
        sendEmailWithAttachment(zipBlob, emailDestino);
    }

    private Blob createZipFile(List<Map<String, String>> anexos) {
        // Simular a criação de um arquivo ZIP
        String boundary = '***Boundary***';
        String zipContent = '';
        for (Map<String, String> anexo : anexos) {
            zipContent += boundary + '\n';
            zipContent += 'Content-Disposition: attachment; filename="' + anexo.get('nome') + '.pdf"\n';
            zipContent += 'Content-Type: application/pdf\n';
            zipContent += 'Content-Transfer-Encoding: base64\n\n';
            zipContent += anexo.get('bs64') + '\n';
        } 
        zipContent += boundary + '--';
        Blob zipBlob = Blob.valueOf(zipContent);
        return zipBlob;
    }

    private void sendEmailWithAttachment(Blob zipBlob, String emailDestino) {
        // Criar o email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { emailDestino });
        email.setSubject('Documentos Processados');
        email.setPlainTextBody('Os documentos processados estão anexados a este email.');
        
        // Criar o anexo
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('documentos.zip');
        attachment.setBody(zipBlob);
        
        // Adicionar o anexo ao email
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        
        // Enviar o email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    @AuraEnabled
    public static void startBatch(String idComodato, String emailDestino) {
        DocumentosRegistrosBatch batch = new DocumentosRegistrosBatch(idComodato, emailDestino);
        Database.executeBatch(batch, 200);  // Ajuste o tamanho do lote conforme necessário
    }
}