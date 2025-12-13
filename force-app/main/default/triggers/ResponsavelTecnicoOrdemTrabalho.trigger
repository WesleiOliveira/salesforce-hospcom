trigger ResponsavelTecnicoOrdemTrabalho on WorkOrder (before insert, before update) {
    
    for(WorkOrder o : Trigger.new){
        if(o.Ignorar_fluxos__c == false){
            if (o.T_cnico_Respons_vel__c == 'NILSON TORQUATO') { o.Tecnico_executor__c = '0036e000045KHN1'; } 
            else {
                List<User> responsavel = [SELECT contactId from User WHERE Id = :o.OwnerId];
                o.Tecnico_executor__c = responsavel[0].ContactId;
            }
        }
    }
    
}