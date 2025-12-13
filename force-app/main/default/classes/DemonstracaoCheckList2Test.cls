@isTest(SeeAllData=true)
public class DemonstracaoCheckList2Test {
	@isTest
    public static void test(){
        PageReference testPage = Page.DemonstracaoCheckList2;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('8016e000007b60mAAA'));
        Test.startTest();
        Order d = [Select ID FROM Order WHERE ID = '8016e000007b60mAAA'];
        DemonstracaoCheckList2 obj = new DemonstracaoCheckList2(new ApexPages.StandardController(d));
    }
}

//8016e000007b60mAAA
//8016e000007J7RQAA0