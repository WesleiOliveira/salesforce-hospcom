public with sharing class OtAgendaClass {
    
    public static void InsereCompromisso(WorkOrder OrdemTrabalho){
        Event compromisso = new Event(
            RECORDTYPEID = '01231000000tb28AAA',
            WHATID = OrdemTrabalho.Id,
            SUBJECT = 'OT ' + OrdemTrabalho.WorkOrderNumber + ': ' + OrdemTrabalho.Status,
            LOCATION = OrdemTrabalho.Local_de_Atendimento__c,
            ISALLDAYEVENT = false,
            ACTIVITYDATETIME = OrdemTrabalho.Data_Agendada_para_Servi_o__c,
            STARTDATETIME = OrdemTrabalho.Data_Agendada_para_Servi_o__c,
            ENDDATETIME = OrdemTrabalho.Data_Prevista_para_o_Fim_do_Servi_o__c,	
            DESCRIPTION = 'OT ' + OrdemTrabalho.WorkOrderNumber + ': ' + OrdemTrabalho.Status,
            OWNERID = OrdemTrabalho.OwnerId,
            TYPE = 'Atendimento de O.T',
            ISPRIVATE = false,
            SHOWAS = 'Busy',
            ISVISIBLEINSELFSERVICE = false,
            ISRECURRENCE = false,
            REMINDERDATETIME = OrdemTrabalho.Data_Agendada_para_Servi_o__c.addMinutes(-30),
            ISREMINDERSET = true,
            EVENTSUBTYPE = 'Event' 
        );
        insert compromisso;
    }
    
    public static void AtualizaCompromisso(WorkOrder OrdemTrabalho, Event Compromisso){
        Compromisso.ActivityDateTime = OrdemTrabalho.Data_Agendada_para_Servi_o__c;
        Compromisso.StartDateTime = OrdemTrabalho.Data_Agendada_para_Servi_o__c;
        Compromisso.EndDateTime = OrdemTrabalho.Data_Prevista_para_o_Fim_do_Servi_o__c;
        Compromisso.ReminderDateTime = OrdemTrabalho.Data_Agendada_para_Servi_o__c.addMinutes(-30);
        
        Update Compromisso;
    }
    
    
}