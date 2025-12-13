@isTest(SeeAllData=true)
public class DemonstracaoCheckListTest {
	@isTest
    public static void test(){
        PageReference testPage = Page.DemonstracaoCheckList;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a0K5A00000MW4EQUA1'));
        Test.startTest();
        Demonstracao__c d = [Select ID FROM Demonstracao__c WHERE ID = 'a0K5A00000MW4EQUA1'];
        DemonstracaoCheckList obj = new DemonstracaoCheckList(new ApexPages.StandardController(d));
    }
}