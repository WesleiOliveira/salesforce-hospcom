@isTest(seeAllData=true)
public class CompartilhaSKATest {
    @isTest
    static void testShareRecordsWithGroup() {
        // Invocar o método a ser testado
        Test.startTest();
        CompartilhaSKA job = new CompartilhaSKA();
        job.compartilha();
        Test.stopTest();

    }
}