/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Aditivo_RelacionadoTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Aditivo_RelacionadoTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Aditivo_Relacionado__c());
    }
}