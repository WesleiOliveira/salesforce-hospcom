/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Entrada_de_EstoqueTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Entrada_de_EstoqueTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Entrada_de_Estoque__c());
    }
}