trigger ATIVIDADE_ENVIAEMAILS on Atividade__c (after insert) {
    
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    try{
        for (Atividade__c atividade : Trigger.new) {
            
            Task tarefa = [
                SELECT Id, WhoId,Membros_da_Atividade__c, Subject, Priority
                FROM Task 
                WHERE id =: atividade.Id_Tarefa__c
                LIMIT 1 
            ];
            
            List <String> membrosID = tarefa.Membros_da_Atividade__c.split(',');
            List<User> usuariosMembros = new List<User>();
            
            for(String membroID:membrosID){
                User usuarioMembro = [
                    SELECT Id, FirstName, Username
                    FROM User 
                    WHERE id =: membroID
                ];
                
                usuariosMembros.add(usuarioMembro);
                
            }
            
            for(User destinatario:usuariosMembros){
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {destinatario.userName});
                email.setSubject('Nova Atividade');
                email.setPlainTextBody('Um novo registro de Atividade foi criado:\n\n' +
                                       'Nome da Atividade: ' + atividade.Name + '\n' +
                                       'Nome da Tarefa: ' + tarefa.Subject + '\n' +
                                       'Prioridade: ' + tarefa.Priority + '\n' +
                                       'Link Tarefa: https://hospcom.my.site.com/Sales/s/task/' + tarefa.id + '\n'); 
                //'Descrição da Atividade: ' + atividade.Descricao__c
                
                emails.add(email);
            }
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }catch(Exception e){
        system.debug(e);
    }
}