trigger AddIntegration on Product2 (before update) {
    for(Product2 p : Trigger.new){
        if(Trigger.old[0].Integrado__c == true) p.Integrado__c = false;
    }
}