/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Item_de_pedido_de_compraTrigger on Item_de_pedido_de_compra__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Item_de_pedido_de_compra__c.SObjectType);
}