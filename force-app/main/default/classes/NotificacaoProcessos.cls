public class NotificacaoProcessos {
    public static void enviarNotificacoes() {
        // Buscar todos os registros de Processo_Judicial__c com Notificar__c = true
        List<Processo_Judicial__c> processos = [SELECT Id, Name, Cliente_Principal__c, Adverso_Principal__c, Valor_atualizado__c, Total_de_ganhos__c
                                                FROM Processo_Judicial__c 
                                                WHERE Notificar__c = true];
        
        // Map para armazenar processos por Id
        Map<Id, Processo_Judicial__c> processosMap = new Map<Id, Processo_Judicial__c>();
        for (Processo_Judicial__c processo : processos) {
            processosMap.put(processo.Id, processo);
        }
        
        // Map para armazenar usuários e seus respectivos processos
        Map<Id, List<Processo_Judicial__c>> usuarioParaProcessosMap = new Map<Id, List<Processo_Judicial__c>>();
        
        // Buscar todos os Compartilhamento_do_processo__c relacionados aos processos
        List<Compartilhamento_do_processo__c> compartilhamentos = [SELECT Usuario__c, Processo_Judicial__c 
                                                                   FROM Compartilhamento_do_processo__c 
                                                                   WHERE Processo_Judicial__c IN :processosMap.keySet()];
        
        // Preencher o Map com usuários e processos
        for (Compartilhamento_do_processo__c compartilhamento : compartilhamentos) {
            if (!usuarioParaProcessosMap.containsKey(compartilhamento.Usuario__c)) {
                usuarioParaProcessosMap.put(compartilhamento.Usuario__c, new List<Processo_Judicial__c>());
            }
            usuarioParaProcessosMap.get(compartilhamento.Usuario__c).add(processosMap.get(compartilhamento.Processo_Judicial__c));
        }
        
        // Preparar e enviar e-mails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Id usuarioId : usuarioParaProcessosMap.keySet()) {
            User usuario = [SELECT Email FROM User WHERE Id = :usuarioId LIMIT 1];
            if (usuario.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {usuario.Email});
                email.setSubject('Notificação de Processos Judiciais');
                
                String emailBody = 'Você possui atualizações nos seguintes processos judiciais:\n\n';
                for (Processo_Judicial__c processo : usuarioParaProcessosMap.get(usuarioId)) {
                    emailBody += 'Número do Processo: ' + processo.Name + '\n';
                    emailBody += 'Cliente Principal: ' + processo.Cliente_Principal__c + '\n';
                    emailBody += 'Adverso Principal: ' + processo.Adverso_Principal__c + '\n';
                    emailBody += 'Valor da causa atualizado: ' + processo.Valor_atualizado__c + '\n';
                    emailBody += 'Ganhos: ' + processo.Total_de_ganhos__c + '\n';
                    emailBody += '\n';
                }
                
                email.setPlainTextBody(emailBody);
                emails.add(email);
            }
        }
        
        // Enviar e-mails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}