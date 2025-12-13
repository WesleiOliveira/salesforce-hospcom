@isTest(seeAllData=true)
public class AutentiqueContratosTest {
	@isTest
    private static void teste(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        Contrato_de_Servi_o__c Contrato = [SELECT ID, Name, Cliente__r.Name, Valor_Total_do_Contrato__c, Cliente__r.PersonEmail, Valor_Global__c, idDocAutentique__c FROM Contrato_de_Servi_o__c WHERE ID = 'a1Y5A00000AqOn9'];
        
        AutentiqueContratos AC = new AutentiqueContratos(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        
    }
    @isTest
    private static void teste3(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        Contrato_de_Servi_o__c Contrato = [SELECT ID, Name, Cliente__r.Name, Cliente__r.PersonEmail, Valor_Total_do_Contrato__c, Valor_Global__c, idDocAutentique__c FROM Contrato_de_Servi_o__c WHERE ID = 'a1Y6e00000C3Ss5'];
        
        AutentiqueContratos AC = new AutentiqueContratos(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        AC.enviar();
        
    }
    @isTest
    private static void teste2(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
        Contrato_de_Servi_o__c Contrato = [SELECT ID, Name, Cliente__r.Name, Cliente__r.PersonEmail, Valor_Total_do_Contrato__c, Valor_Global__c, idDocAutentique__c FROM Contrato_de_Servi_o__c WHERE ID = 'a1Y5A00000AqOn9'];
        
        AutentiqueContratos AC = new AutentiqueContratos(new ApexPages.StandardController(Contrato));
        
        AC.enviar();
        
    }
    @isTest
    private static void teste4(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
        Contrato_de_Servi_o__c Contrato = [SELECT ID, Name, Cliente__r.Name, Cliente__r.PersonEmail, Valor_Total_do_Contrato__c, Valor_Global__c, idDocAutentique__c FROM Contrato_de_Servi_o__c WHERE ID = 'a1Y6e00000C3V6I'];
        
        AutentiqueContratos AC = new AutentiqueContratos(new ApexPages.StandardController(Contrato));
        
        AC.enviar();
        AC.inserir();
        
    }
}