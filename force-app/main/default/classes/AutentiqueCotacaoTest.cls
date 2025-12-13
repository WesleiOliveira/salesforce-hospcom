@isTest(seeAllData=true)
public class AutentiqueCotacaoTest {
	@isTest
    private static void teste(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        Quote Contrato = [SELECT Name, Account.Name, Account.PersonEmail, idDocAutentique__c, Email, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Quote WHERE ID= '0Q05A000002K66i'];
        
        AutentiqueCotacao AC = new AutentiqueCotacao(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        
    }
    @isTest
    private static void teste3(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        Quote Contrato = [SELECT Name, Account.Name, Account.PersonEmail, idDocAutentique__c, Email, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Quote WHERE ID= '0Q05A000002K66i'];
        
        AutentiqueCotacao AC = new AutentiqueCotacao(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        AC.enviar();
        
    }
    @isTest
    private static void teste2(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
        Quote Contrato = [SELECT Name, Account.Name, Account.PersonEmail, idDocAutentique__c, Email, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Quote WHERE ID = '0Q05A000002K66i'];
        
        AutentiqueCotacao AC = new AutentiqueCotacao(new ApexPages.StandardController(Contrato));
        
        AC.enviar();
        
    }
    @isTest
    private static void teste4(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
        Quote Contrato = [SELECT Name, Account.Name, Account.PersonEmail, idDocAutentique__c, Email, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Quote WHERE ID = '0Q06e000002r2vK'];
        
        AutentiqueCotacao AC = new AutentiqueCotacao(new ApexPages.StandardController(Contrato));
        
        AC.enviar();
        
    }
}