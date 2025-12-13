@isTest(SeeAllData=true)
public class DemonstracaoContrato2TEST {
	@isTest
    public static void test(){
        PageReference testPage = Page.DemonstracaoContrato2;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('8016e000007wF2uAAE'));
        Test.startTest();
        Order d = [Select ID FROM Order WHERE ID = '8016e000007wF2uAAE'];
        DemonstracaoContrato2 obj = new DemonstracaoContrato2(new ApexPages.StandardController(d));
        
        
      GestaoDocumentos.obterDocumentosVigentes();
    }   
}
//8016u000000L379AAC
//8016e000007J7RQAA0

//8016e000007QFCzAAO