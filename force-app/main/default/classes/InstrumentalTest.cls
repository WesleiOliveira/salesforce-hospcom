@isTest(seeAllData=true)
public class InstrumentalTest {
	@isTest
    private static void up(){
        PageReference testPage = Page.PDF_CHECKLIST_INSTRUMENTAL;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('01t6e000009aOuo'));
        Test.startTest();
        Product2 PROD = [SELECT ID FROM Product2 WHERE ID = '01t6e000009aOuo'];
        Instrumental obj = new Instrumental(new ApexPages.StandardController(PROD));
        Test.stopTest();
    } 
}