/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Produto_FilhoTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Produto_FilhoTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Produto_Filho__c());
    }
}