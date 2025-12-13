public with sharing class AvaliacaoExperienciaTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        AvaliacaoExperienciaService.enviarNotificacoesColaborador(Trigger.new, (Map<Id, Avaliacao_de_Experiencia__c>) Trigger.oldMap);
        AvaliacaoExperienciaService.enviarNotificacaoDP(Trigger.new, (Map<Id, Avaliacao_de_Experiencia__c>) Trigger.oldMap);
    }
}