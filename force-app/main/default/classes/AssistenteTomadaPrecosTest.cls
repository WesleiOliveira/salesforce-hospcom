@isTest(SeeAllData=true)
public class AssistenteTomadaPrecosTest {
	@isTest
    private static void up(){
		PageReference testPage = Page.AssistenteTomadaPrecos;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a1b6e000006QzHpAAK'));
        Test.startTest();
        Fornecedor__c cotacao = [SELECT ID FROM Fornecedor__c WHERE ID = 'a1b6e000006QzHpAAK'];
        AssistenteTomadaPrecos obj = new AssistenteTomadaPrecos(new ApexPages.StandardController(cotacao));
        obj.Inicializa(new ApexPages.StandardController(cotacao));
        obj.Efetiva();
        obj.PreparaErros();
    }
}