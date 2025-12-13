public without sharing class KanbanBacklogController {
    
    @AuraEnabled(cacheable=true)
    public static List<Backlog__c> getBacklog() {
        return [
            SELECT Id, 
                   Name, 
                   Atividade__c, 
                   Atribuido__c, 
                   Atribuido__r.Name, 
                   Status__c, 
                   Bandeira__c, 
                   Tipo__c, 
                   Tempo_de_Atendimento__c,
                   Departamento__c,
                   Tempo_de_Execucao__c,
                   Excedeu_Tempo_Estimado__c,
                   cssCard__c
            FROM Backlog__c
        ];
    }

    @AuraEnabled
    public static void updateStatus(Id recordId, String newStatus) {
        Backlog__c b = [SELECT Id, Status__c FROM Backlog__c WHERE Id = :recordId];
        b.Status__c = newStatus;
        update b;
    }
}