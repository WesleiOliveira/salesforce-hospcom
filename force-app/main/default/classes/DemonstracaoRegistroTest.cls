@isTest(SeeAllData=true)
public class DemonstracaoRegistroTest {
	@isTest
    public static void test(){
        PageReference testPage = Page.DemonstracaoRegistro2;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('8016e000007QaYNAA0'));
        Test.startTest();
        Order d = [Select ID FROM Order WHERE ID = '8016e000007QaYNAA0'];
        DemonstracaoRegistro2 obj = new DemonstracaoRegistro2(new ApexPages.StandardController(d));
    }
}