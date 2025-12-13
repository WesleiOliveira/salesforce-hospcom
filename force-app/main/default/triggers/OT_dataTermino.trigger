trigger OT_dataTermino on WorkOrder (before update) {

    for(WorkOrder o : Trigger.new){
        if(o.Status == 'SERVIÇO CONCLUÍDO' && Trigger.old[0].Status != 'SERVIÇO CONCLUÍDO'){
            o.EndDate = Date.today();
        }
    }

}