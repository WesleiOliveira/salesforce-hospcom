trigger PSQ on PSQ__c (before update, after update) {
    
    List<PSQ__c> psqVigente = [
        SELECT Id, Name, Procedimento_do_Sistema_de_Qualidade__c 
        FROM PSQ__c 
    ];
    
    List<PSQ__c> psqFiltrado = new List<PSQ__c>();
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (PSQ__c psqNEW : Trigger.new) {
            
            
            
            
            
            PSQ__c psqOLD = Trigger.oldMap.get(psqNEW.Id);
            
            String revisor_id =  psqNEW.Revisor__c;
            String elaborador_id =  psqNEW.Elaborador__c;  
            
            Set<String> recipientesId = new Set<String> {elaborador_id}; 
                Set<String> recipientesId_revisor = new Set<String> {revisor_id}; 
                    
                    if (psqNEW.Status__c == 'Elaboração' && psqOLD.Status__c == 'Revisão') {
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle('PSQ');
                        notification.setBody('O novo Procedimento do Sistema de Qualidade foi revisado, e há alterações a serem feitas descritas pelo revisor. Clique aqui para conferir mais informações');
                        notification.setNotificationTypeId('0ML5A0000004CA6WAM');
                        notification.setTargetId(psqNEW.Id); 
                        try {
                            notification.send(recipientesId);
                        }catch (Exception e) {
                            System.debug('Problem sending notification: ' + e.getMessage());
                        }
                    }
            else if (psqNEW.Status__c == 'Revisão' && psqOLD.Status__c == 'Aprovação') {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('PSQ');
                notification.setBody('O novo Procedimento do Sistema de Qualidade foi rejeitado, e há alterações a serem feitas descritas pelo aprovador. Clique aqui para conferir mais informações');
                notification.setNotificationTypeId('0ML5A0000004CA6WAM');
                notification.setTargetId(psqNEW.Id); 
                
                try {
                    notification.send(recipientesId_revisor);
                    System.debug('Enviado');
                } catch (Exception e) {
                    System.debug('Problem sending notification: ' + e.getMessage());
                }
            }else if (psqNEW.Status__c == 'Aprovação' && psqOLD.Status__c == 'Revisão') {
                
            // Crie uma solicitação de submissão para aprovação
            if (!Test.isRunningTest()) {
Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
req.setComments('Comentários Opcionais');
req.setObjectId(psqNEW.Id); 
Approval.ProcessResult result = Approval.process(req);
}           
    } 
} 
}
}