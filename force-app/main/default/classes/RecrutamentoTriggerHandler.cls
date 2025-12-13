public with sharing class RecrutamentoTriggerHandler extends TriggerHandler {
    
    public override void afterUpdate() {
        RecrutamentoService.inserirAvaliacaoExperiencia(Trigger.new);
    }
}