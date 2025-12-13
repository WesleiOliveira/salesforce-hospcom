@isTest(seeAllData=true)
public class AutentiqueDemoTest {
	@isTest
    private static void teste(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        Demonstracao__c Contrato = [SELECT Name, Contato__r.Name, RecordTypeId, Contato__r.Email, idDocAutentique__c, Oportunidade__r.Faturamento_Feito2__r.CNPJ__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Demonstracao__c WHERE ID= 'a0K5A00000MVAKZ' ];
        
        AutentiqueDemo AC = new AutentiqueDemo(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        
    }
    @isTest
    private static void teste3(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        Demonstracao__c Contrato = [SELECT Name, Contato__r.Name, RecordTypeId, Contato__r.Email, idDocAutentique__c, Oportunidade__r.Faturamento_Feito2__r.CNPJ__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Demonstracao__c WHERE ID= 'a0K5A00000MVAKZ' ];
        
        AutentiqueDemo AC = new AutentiqueDemo(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        AC.enviar();
        
    }
    @isTest
    private static void teste2(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
        Demonstracao__c Contrato = [SELECT Name, Contato__r.Name, RecordTypeId, Contato__r.Email, idDocAutentique__c, Oportunidade__r.Faturamento_Feito2__r.CNPJ__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Demonstracao__c WHERE ID= 'a0K5A00000MVAKZ' ];
        
        AutentiqueDemo AC = new AutentiqueDemo(new ApexPages.StandardController(Contrato));
        
        AC.enviar();
        
    }
   // @isTest
   // private static void teste4(){
        
     //   Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
     //l   Demonstracao__c Contrato = [SELECT Name, Contato__r.Name, RecordTypeId, Contato__r.Email, idDocAutentique__c, Oportunidade__r.Faturamento_Feito2__r.CNPJ__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM Demonstracao__c WHERE ID= 'a0K6e00000qEHwnEAG' ];
        
     //   AutentiqueDemo AC = new AutentiqueDemo(new ApexPages.StandardController(Contrato));
        
        //AC.enviar();
        
    //}
}