public class OtAgendaFluxo {

    public static void FluxoUpdate(WorkOrder OrdemOld, WorkOrder OrdemNew){
        
        // COMPROMISSOS =====================================================================
        
		If(((OrdemOld.Status != OrdemNew.Status) &&
            (OrdemNew.Status == 'AGENDADO' ||
             OrdemNew.Status == 'AGUARDANDO ATENDIMENTO'))
           || 
           ((OrdemOld.Status == OrdemNew.Status) &&
            (OrdemNew.Status == 'AGENDADO' ||
             OrdemNew.Status == 'AGUARDANDO ATENDIMENTO') &&
            (OrdemOld.Data_Agendada_para_Servi_o__c == null ||
             OrdemOld.Data_Prevista_para_o_Fim_do_Servi_o__c == null))){
                 OtAgendaClass.InsereCompromisso(OrdemNew);                 
		}
        
        If((OrdemOld.Status == OrdemNew.Status) &&
           (OrdemNew.Status == 'AGENDADO' ||
            OrdemNew.Status == 'AGUARDANDO ATENDIMENTO') &&
           (OrdemOld.Data_Agendada_para_Servi_o__c != null &&
            OrdemOld.Data_Prevista_para_o_Fim_do_Servi_o__c != null)){
                
                List<Event> Compromissos = new List<Event>();
                String Status = '%' + OrdemNew.Status + '%';
                Compromissos = [
                    SELECT 	Id
                    FROM	Event
                    WHERE   WhatId = :OrdemNew.Id 	AND
                    Subject LIKE :Status
                    LIMIT   1
                ];
                
                If(Compromissos.size() == 0)
                    OtAgendaClass.InsereCompromisso(OrdemNew); 
                
                else if((OrdemOld.Data_Agendada_para_Servi_o__c != OrdemNew.Data_Agendada_para_Servi_o__c) ||
                        (OrdemOld.Data_Prevista_para_o_Fim_do_Servi_o__c != OrdemNew.Data_Prevista_para_o_Fim_do_Servi_o__c))
                    OtAgendaClass.AtualizaCompromisso(OrdemNew, Compromissos[0]);               
		}
        
        
        // TAREFA ===========================================================================  
       
		// conclui tarefas anteriores ao se alterar o status
		if((OrdemOld.Status != OrdemNew.Status) &&
           (OrdemOld.Status == 'AGUARDANDO ENVIO DA PROPOSTA' ||
            OrdemOld.Status == 'NÃO ATRIBUÍDAS' ||
            OrdemOld.Status == 'AUTORIZADO' ||
            OrdemOld.Status == 'AGUARDANDO PEÇA' ||
            OrdemOld.Status == 'ESCALADA' ||
            OrdemOld.Status == 'VERIFICAÇÃO DE SERVIÇO' ||
            OrdemOld.Status == 'AGUARDANDO FATURAMENTO' ||
            OrdemOld.Status == 'NÃO AUTORIZADO' ||
            OrdemOld.Status == 'DISPONIVEL PARA ENTREGA' ||
            OrdemOld.Status == 'ENTREGUE' ||
            OrdemOld.Status == 'FECHADO CONCLUÍDO' ||
            OrdemOld.Status == 'AGUARDANDO AUTORIZAÇÃO') 
          ){
			list<Task> tarefas = new LIST<task>();
            String Status = '%' + OrdemOld.Status + '%';
            tarefas = [
                SELECT		Id, Status
                FROM		Task
                WHERE		WhatId = :OrdemNew.Id	AND
                       		Subject LIKE :Status	AND
                			Status != 'Concluído'
            ];
             
            If(tarefas.size() > 0){
                for(Integer cont=0; cont < tarefas.size(); cont++)
                	tarefas[cont].Status = 'Concluído';
                update tarefas;
            }
		} 
	} // fim: se UPDATE
    
    
    
    
    public static void FluxoInsert(WorkOrder OrdemNew){
    
        // COMPROMISSOS =====================================================================
        
        if(OrdemNew.Status == 'AGENDADO' ||
           OrdemNew.Status == 'AGUARDANDO ATENDIMENTO'){
               OtAgendaClass.InsereCompromisso(OrdemNew);
		}
    
    }// fim: se INSERT
    
    
    public static void SincronizaOwner(WorkOrder OrdemNew){
        List<Event> Compromissos = new List<Event>();
        Compromissos = [
            SELECT 		Id, OwnerId
            FROM		Event
            WHERE		WhatId = :OrdemNew.Id			AND
            			OwnerId != :OrdemNew.OwnerId	AND
            			ENDDATETIME >= :System.now()
        ];
        If(Compromissos.size() > 0){
            for(Integer cont=0; cont < Compromissos.size(); cont++)
                Compromissos[cont].OwnerId = OrdemNew.OwnerId;
            update Compromissos;
        }
    }
    
    
}