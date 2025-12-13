/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Item_de_pedido_de_compraTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Item_de_pedido_de_compraTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Item_de_pedido_de_compra__c());
    }
}