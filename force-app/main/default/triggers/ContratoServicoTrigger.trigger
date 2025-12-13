trigger ContratoServicoTrigger on Contrato_de_servi_o__c (before insert, after insert, before update, after update,  before delete, after delete, after undelete) {
     (new ContratoServicoTriggerHandler()).run();
}