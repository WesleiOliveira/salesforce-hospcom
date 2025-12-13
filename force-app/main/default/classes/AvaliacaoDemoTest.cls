@isTest(SeeAllData=true)
public class AvaliacaoDemoTest {
	@isTest
    public static void test(){
        PageReference testPage = Page.pdf_avaliacao_demonstracao;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a386e000002BqIeAAK'));
        Test.startTest();
        avaliacaoDeDemonstracao__c a = [Select ID FROM avaliacaoDeDemonstracao__c WHERE ID = 'a386e000002BqIeAAK'];
        AvaliacaoDemo obj = new AvaliacaoDemo(new ApexPages.StandardController(a));
    }   
}