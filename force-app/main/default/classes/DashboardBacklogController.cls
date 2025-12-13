public without sharing class DashboardBacklogController {

    // Classe DTO principal
    public class DashboardDTO {
        @AuraEnabled public Integer totalAbertos {get; set;}
        @AuraEnabled public Integer totalEmAndamento {get; set;}
        @AuraEnabled public Integer ticketsRapidos {get; set;}
        @AuraEnabled public Integer totalFinalizados {get; set;}
        @AuraEnabled public List<RecentFeedbackDTO> recentes {get; set;}
        @AuraEnabled public List<RecentFeedbackDTO> finalizados {get; set;}
        @AuraEnabled public List<AggregateResult> chartData {get; set;}
        @AuraEnabled public List<AggregateResult> chartDataStatus {get; set;}
        @AuraEnabled public List<AggregateResult> chartDataDepartamento {get; set;}
        @AuraEnabled public List<AggregateResult> chartDataExcedidos {get; set;}
    }

    // Classe para feedbacks recentes (separada)
    public class RecentFeedbackDTO {
        @AuraEnabled public String idTkt {get; set;}
        @AuraEnabled public String data {get; set;}
        @AuraEnabled public String titulo {get; set;}
        @AuraEnabled public String atribuido {get; set;}
    }

    // Método que retorna os dados
    @AuraEnabled(cacheable=true)
    public static DashboardDTO getDashboardData() {
        DashboardDTO dto = new DashboardDTO();

        // Totais
        dto.totalAbertos = [SELECT COUNT() FROM Backlog__c WHERE Status__c = 'Novo'];
        System.debug('Total abertos: ' + dto.totalAbertos);
        dto.totalEmAndamento = [SELECT COUNT() FROM Backlog__c WHERE Status__c = 'Em Desenvolvimento'];
        dto.ticketsRapidos = [SELECT COUNT() FROM Backlog__c WHERE Origem__c = 'Chatwoot'];
        dto.totalFinalizados = [SELECT COUNT() FROM Backlog__c WHERE Status__c = 'Finalizado'];

        // Recentes
        dto.recentes = new List<RecentFeedbackDTO>();
        for (Backlog__c tkt : [
            SELECT Id, Ticket_Criado_Em__c, Atividade__c, Atribuido__r.Name
            FROM Backlog__c
            ORDER BY Ticket_Criado_Em__c DESC 
            LIMIT 5
        ]) {
            RecentFeedbackDTO rf = new RecentFeedbackDTO();
            rf.idTkt = tkt.Id;
            rf.data = (String) tkt.Ticket_Criado_Em__c.format('dd/MM/yyyy');
            rf.titulo = tkt.Atividade__c;
            rf.atribuido = tkt.Atribuido__r.Name;
            dto.recentes.add(rf);
        }

        dto.finalizados = new List<RecentFeedbackDTO>();
        for (Backlog__c tkt : [
            SELECT Id, Ticket_Finalizado_Em__c, Atividade__c, Atribuido__r.Name
            FROM Backlog__c
            WHERE Status__c = 'Finalizado'
            ORDER BY Ticket_Finalizado_Em__c DESC 
            LIMIT 5
        ]) {
            RecentFeedbackDTO rf = new RecentFeedbackDTO();
            rf.idTkt = tkt.Id;
            rf.data = (String) tkt.Ticket_Finalizado_Em__c.format('dd/MM/yyyy');
            rf.titulo = tkt.Atividade__c;
            rf.atribuido = tkt.Atribuido__r.Name;
            dto.finalizados.add(rf);
        }

        // Dados para gráfico
        dto.chartData = [
            SELECT CALENDAR_MONTH(Ticket_Finalizado_Em__c) mes, COUNT(Id) total
            FROM Backlog__c
            WHERE Status__c = 'Finalizado'
            GROUP BY CALENDAR_MONTH(Ticket_Finalizado_Em__c)
            ORDER BY CALENDAR_MONTH(Ticket_Finalizado_Em__c)
        ];

        dto.chartDataStatus = [
            SELECT Status__c , COUNT(Id) total 
            FROM Backlog__c 
            GROUP BY Status__c
        ];

        dto.chartDataDepartamento = [
            SELECT Departamento__c , COUNT(Id) total 
            FROM Backlog__c 
            GROUP BY Departamento__c
        ];

        dto.chartDataExcedidos = [
            SELECT Excedeu_Tempo_Estimado__c , COUNT(Id) total 
            FROM Backlog__c 
            GROUP BY Excedeu_Tempo_Estimado__c
        ];

        return dto;
    }
}