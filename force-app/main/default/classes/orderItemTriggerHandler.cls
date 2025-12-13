public with sharing class orderItemTriggerHandler extends TriggerHandler {
    
    public override void afterUpdate() {            
        orderItemService.recalculaStatusDoPedido(Trigger.new);
    }
}