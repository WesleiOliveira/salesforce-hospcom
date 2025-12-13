@isTest(seeAllData=true)
public class AutentiqueAditivoTest {
	@isTest
    private static void teste(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        Aditivos_Contratuais__c Contrato = [SELECT Name, N_do_Aditivo__c, Contrato_de_Servi_o_Relacionado__r.Name, Contrato_de_Servi_o_Relacionado__r.Cliente__r.Name, Contrato_de_Servi_o_Relacionado__r.Cliente__r.PersonEmail, Contrato_de_Servi_o_Relacionado__r.Locador_a__r.CNPJ__c, idDocAutentique__c, Contrato_de_Servi_o_Relacionado__r.Nome_da_Testemunha__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Name, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Email, Contrato_de_Servi_o_Relacionado__r.Timbre__c, Contrato_de_Servi_o_Relacionado__r.E_mail_da_Testemunha__c, Contrato_de_Servi_o_Relacionado__r.Documento_Assinado__c FROM Aditivos_Contratuais__c WHERE ID= 'a1j6e000009ti8F'];        
        
        AutentiqueAditivo AC = new AutentiqueAditivo(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        
    }
    @isTest
    private static void teste3(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        Aditivos_Contratuais__c Contrato = [SELECT Name, N_do_Aditivo__c, Contrato_de_Servi_o_Relacionado__r.Name, Contrato_de_Servi_o_Relacionado__r.Cliente__r.Name, Contrato_de_Servi_o_Relacionado__r.Cliente__r.PersonEmail, Contrato_de_Servi_o_Relacionado__r.Locador_a__r.CNPJ__c, idDocAutentique__c, Contrato_de_Servi_o_Relacionado__r.Nome_da_Testemunha__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Name, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Email, Contrato_de_Servi_o_Relacionado__r.Timbre__c, Contrato_de_Servi_o_Relacionado__r.E_mail_da_Testemunha__c, Contrato_de_Servi_o_Relacionado__r.Documento_Assinado__c FROM Aditivos_Contratuais__c WHERE ID= 'a1j6e000009ti8P'];        
        
        AutentiqueAditivo AC = new AutentiqueAditivo(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        AC.enviar();
        
    }
    @isTest
    private static void teste2(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
        Aditivos_Contratuais__c Contrato = [SELECT Name, N_do_Aditivo__c, Contrato_de_Servi_o_Relacionado__r.Name, Contrato_de_Servi_o_Relacionado__r.Cliente__r.Name, Contrato_de_Servi_o_Relacionado__r.Cliente__r.PersonEmail, Contrato_de_Servi_o_Relacionado__r.Locador_a__r.CNPJ__c, idDocAutentique__c, Contrato_de_Servi_o_Relacionado__r.Nome_da_Testemunha__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Name, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Email, Contrato_de_Servi_o_Relacionado__r.Timbre__c, Contrato_de_Servi_o_Relacionado__r.E_mail_da_Testemunha__c, Contrato_de_Servi_o_Relacionado__r.Documento_Assinado__c FROM Aditivos_Contratuais__c WHERE ID= 'a1j6e000009ti8P'];        
        
        AutentiqueAditivo AC = new AutentiqueAditivo(new ApexPages.StandardController(Contrato));
        
        AC.enviar();
        
    }
}