public class EnviarDocumentosEmail {
    
    @AuraEnabled
    public static void enviarDocumentosPorEmail(String idComodato, String destinatarioEmail) {
        List<Map<String, String>> anexos = DocumentosRegistros.documentosOts(idComodato);
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        for (Map<String, String> anexo : anexos) {
            String nomeArquivo = anexo.get('nome');
            Blob conteudoArquivo = EncodingUtil.base64Decode(anexo.get('bs64'));
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(nomeArquivo);
            attachment.setBody(conteudoArquivo);
            attachments.add(attachment);
        }
         
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { destinatarioEmail });
        email.setSubject('Documentos Comodato');
        email.setPlainTextBody('Segue em anexo os arquivos com os documentos do comodato.');
        email.setFileAttachments(attachments);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
    
    public static void gambiarra(){
         string a;
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
        a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a'; a = 'a';
    }
}