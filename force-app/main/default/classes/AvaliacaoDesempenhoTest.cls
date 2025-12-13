@isTest(seeAllData=true)
public class AvaliacaoDesempenhoTest {
@isTest
    public static void teste(){
		PageReference testPage = Page.AvaliacaoDesempenhoPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1Q6e00000B3Olr'));
        Test.startTest();        
        Avaliacao_de_Desempenho__c rq = [SELECT ID FROM Avaliacao_de_Desempenho__c WHERE ID =: 'a1Q6e00000B3Olr'];
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
		AvaliacaoDesempenho ad = new AvaliacaoDesempenho(sc);
        Test.stopTest();
}
}