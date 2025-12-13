@isTest
global class SapCronIntegrationSchedulerTEST implements Schedulable{

    public static void execute(SchedulableContext sc){
		Test.StartTest();
        System.schedule('Test Territory Check', '0 0 20 * * ?', new SapCronIntegrationScheduler());
        Test.stopTest();
    }
    
    @isTest
    public static void runSapCronIntegrationSchedulerTEST(){
        SchedulableContext sc;
        execute(sc);
    }
    
}