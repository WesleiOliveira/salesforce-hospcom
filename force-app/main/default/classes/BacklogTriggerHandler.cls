public with sharing class BacklogTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        BacklogService.atualizaDataAbertura(Trigger.new);
        BacklogService.atualizadaHorasEstimadas(Trigger.new);
    }

    public override void beforeUpdate(){
        BacklogService.atualizaDataFinalizacao(Trigger.new, (Map<Id, Backlog__c>) Trigger.oldMap);
        BacklogService.atualizadaHorasEstimadas(Trigger.new);
    }
}