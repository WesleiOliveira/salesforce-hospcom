@isTest(seeAllData=true)
public class AutentiqueOTtest {
	@isTest
    private static void teste(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        WorkOrder Contrato = [SELECT WorkOrderNumber, Account.Name, Account.PersonEmail, idDocAutentique__c, E_mail__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM WorkOrder WHERE ID = '0WO5A000000jjjX' ];
        
        AutentiqueOT AC = new AutentiqueOT(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        
    }
    @isTest
    private static void teste3(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos());
        
        
        WorkOrder Contrato = [SELECT WorkOrderNumber, Account.Name, Account.PersonEmail, idDocAutentique__c, E_mail__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM WorkOrder WHERE ID = '0WO5A000000jjjX' ];
        
        AutentiqueOT AC = new AutentiqueOT(new ApexPages.StandardController(Contrato));
        
        AC.atualizar();
        AC.inserir();
        AC.enviar();
        
    }
    @isTest
    private static void teste2(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
        WorkOrder Contrato = [SELECT WorkOrderNumber, Account.Name, Account.PersonEmail, idDocAutentique__c, E_mail__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM WorkOrder WHERE ID = '0WO5A000000jjjX' ];
        
        AutentiqueOT AC = new AutentiqueOT(new ApexPages.StandardController(Contrato));
        
        AC.enviar();
        
    }
    @isTest
    private static void teste4(){
        
        Test.setMock(HttpCalloutMock.class, new MockAutentiqueContratos2());
        
        
        WorkOrder Contrato = [SELECT WorkOrderNumber, Account.Name, Account.PersonEmail, idDocAutentique__c, E_mail__c, Nome_da_Testemunha__c, E_mail_da_Testemunha__c, Documento_Assinado__c FROM WorkOrder WHERE ID = '0WO6e000003rQ6f' ];
        
        AutentiqueOT AC = new AutentiqueOT(new ApexPages.StandardController(Contrato));
        
        //AC.enviar();
        
    }
}