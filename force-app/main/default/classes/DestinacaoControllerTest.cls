@isTest(SeeAllData=true)
private class DestinacaoControllerTest {
	@isTest
    private static void up(){
        PageReference testPage = Page.Destinacao2;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1b5A000002dFrI'));
        Test.startTest();
        DestinacaoController obj = new DestinacaoController(new ApexPages.StandardController(new Fornecedor__c()));
        obj.upd();
        Test.stopTest();
    } 
	@isTest
    private static void delt(){
        PageReference testPage = Page.Destinacao2;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1b5A000002dFrI'));
        Test.startTest();
        DestinacaoController obj = new DestinacaoController(new ApexPages.StandardController(new Fornecedor__c()));
        obj.reqId = 'a1g5A000005GJOg';
        obj.deleteRecord();
        Test.stopTest();
    }  
}