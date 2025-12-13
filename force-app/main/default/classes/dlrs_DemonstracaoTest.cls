/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_DemonstracaoTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_DemonstracaoTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Demonstracao__c());
    }
}