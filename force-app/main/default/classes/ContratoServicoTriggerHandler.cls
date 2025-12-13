public with sharing class ContratoServicoTriggerHandler extends TriggerHandler{
    
    public override void afterUpdate() {
        ContratoServicoService.processaContratos((List<Contrato_de_servi_o__c>) Trigger.new, (Map<Id, Contrato_de_servi_o__c>) Trigger.oldMap);
    }
}