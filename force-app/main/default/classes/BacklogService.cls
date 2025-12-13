public with sharing class BacklogService {

    public static void atualizaDataAbertura(List<Backlog__c> novosTickets){
        
        for(Backlog__c b : novosTickets){
                b.Ticket_Criado_Em__c = Datetime.now(); 
        }      
    }
    
    public static void atualizaDataFinalizacao(List<Backlog__c> novosTickets, Map<Id, Backlog__c> velhosTickets){

        for(Backlog__c b : novosTickets){
            if(b.Status__c == 'Finalizado' && velhosTickets.get(b.Id).Status__c != 'Finalizado'){
                b.Ticket_Finalizado_Em__c = Datetime.now(); 
            }
        }
    }

    public static void atualizadaHorasEstimadas(List<Backlog__c> novosTickets) {
        Id bhId = [SELECT Id FROM BusinessHours WHERE Name = 'Brasilia' LIMIT 1].Id;

        for (Backlog__c ticket : novosTickets) {
            if (ticket.Ticket_Criado_Em__c != null && ticket.Data_Estimada_de_T_rmino__c != null) {
                Long diffMillis = BusinessHours.diff(
                    bhId,
                    ticket.Ticket_Criado_Em__c,
                    ticket.Data_Estimada_de_T_rmino__c
                );

                Decimal horasUteis = diffMillis != null 
                    ? diffMillis / (1000 * 60 * 60) 
                    : 0;

                ticket.Tempo_de_Execucao__c = horasUteis;
            } else {
                ticket.Tempo_de_Execucao__c = 0;
            }
        }
    }
}