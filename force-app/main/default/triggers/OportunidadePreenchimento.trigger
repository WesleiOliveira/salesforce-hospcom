trigger OportunidadePreenchimento on Opportunity (before insert, before update) {
    
    // de lead
    Set<String> leads_num = new Set<String>();
    for(Opportunity oportunidade : Trigger.new){
        if(oportunidade.Lead__c!=null)
            leads_num.add(oportunidade.Lead__c);
    }
    if(leads_num.size()>0){
        Util.AcaoInterna(true);
        for(Lead lead : [SELECT Numero__c, Interesse__c FROM Lead WHERE Numero__c IN:leads_num])
            for(Opportunity oportunidade : Trigger.new)
                
                // descrição <= lead.interesse
                if(lead.Numero__c == oportunidade.Lead__c){
                    oportunidade.Description = (oportunidade.Description!=null?oportunidade.Description+'\n':'') + lead.Interesse__c;
                    oportunidade.Lead__c = null;
                }
    }
    
}