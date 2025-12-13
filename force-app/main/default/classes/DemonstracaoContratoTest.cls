@isTest(SeeAllData=true)
public class DemonstracaoContratoTest {
	@isTest
    public static void test(){
        PageReference testPage = Page.ContratoComodato;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a0K6e00001ngJ4u'));
        Test.startTest();
        Demonstracao__c d = [Select ID FROM Demonstracao__c WHERE ID = 'a0K6e00001ngJ4u'];
        DemonstracaoContrato obj = new DemonstracaoContrato(new ApexPages.StandardController(d));
    }   
    @isTest
    public static void test2(){
        PageReference testPage = Page.ContratoComodato;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf('a0KU400000uAr2o'));
        Test.startTest();
        Demonstracao__c d = [Select ID FROM Demonstracao__c WHERE ID = 'a0KU400000uAr2o'];
        DemonstracaoContrato obj = new DemonstracaoContrato(new ApexPages.StandardController(d));
    }   
}