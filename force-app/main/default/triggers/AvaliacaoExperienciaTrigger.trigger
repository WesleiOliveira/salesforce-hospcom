trigger AvaliacaoExperienciaTrigger on Avaliacao_de_Experiencia__c (before insert, after insert, before update, after update,  before delete, after delete, after undelete) {

    (new AvaliacaoExperienciaTriggerHandler()).run();
}