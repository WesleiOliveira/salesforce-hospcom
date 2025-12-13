@isTest(SeeAllData=true)
public class pdfEventoTest {
	@isTest
    private static void search(){
        PageReference testPage = Page.Pdf_Evento;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('701U400000C3p0mIAB'));
        Test.startTest();
        Campaign rq = [SELECT Id FROM Campaign WHERE Id = '701U400000C3p0mIAB'];
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        pdfEvento obj = new pdfEvento(sc);
        Test.stopTest();
    }
    private static void search2(){
        PageReference testPage = Page.Pdf_Evento;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('701U400000CoV9rIAF'));
        Test.startTest();
        Campaign rq = [SELECT Id FROM Campaign WHERE Id = '701U400000CoV9rIAF'];
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        pdfEvento obj = new pdfEvento(sc);
        Test.stopTest();
    }
}