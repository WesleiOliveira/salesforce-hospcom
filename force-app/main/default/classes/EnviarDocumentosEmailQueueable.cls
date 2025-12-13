public class EnviarDocumentosEmailQueueable implements Queueable, Database.AllowsCallouts {

    private String destinatario;
    private List<Map<String, String>> anexos;
    private static final Integer MAX_ANEXOS = 10; // Dividir em partes menores
    private static final Integer MAX_EMAIL_SIZE = 5; // Limite máximo de anexos por e-mail

    // Construtor
    public EnviarDocumentosEmailQueueable(String destinatario, List<Map<String, String>> anexos) {
        this.destinatario = destinatario;
        this.anexos = anexos;
    }

    // Método executado de forma assíncrona
    public void execute(QueueableContext context) {
        Integer totalAnexos = anexos.size();
        System.debug('Total de anexos recebidos na execução: ' + totalAnexos);

        List<Map<String, String>> currentBatch = new List<Map<String, String>>();

        for (Integer i = 0; i < totalAnexos; i++) {
            currentBatch.add(anexos.get(i));

            // Se o número de anexos no lote atingir o limite ou se for o último anexo, envie o e-mail
            if (currentBatch.size() == MAX_EMAIL_SIZE || i == totalAnexos - 1) {
                System.debug('Enviando e-mail com ' + currentBatch.size() + ' anexos.');
                sendEmailWithAttachments(currentBatch);
                currentBatch.clear(); // Limpar o lote para o próximo conjunto de anexos
            }
        }
    }

    private void sendEmailWithAttachments(List<Map<String, String>> anexos) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { destinatario });
        email.setSubject('Documentos');
        email.setPlainTextBody('Anexos do contrato:');
        System.debug('Email básico configurado.');

        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

        for (Map<String, String> anexo : anexos) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(anexo.get('nome'));
            efa.setBody(EncodingUtil.base64Decode(anexo.get('bs64')));
            fileAttachments.add(efa);
            System.debug('Anexo adicionado: ' + anexo.get('nome'));
        }
        email.setFileAttachments(fileAttachments);
        emails.add(email);
        Messaging.sendEmail(emails);
        System.debug('Email enviado com ' + fileAttachments.size() + ' anexos.');
    }
}