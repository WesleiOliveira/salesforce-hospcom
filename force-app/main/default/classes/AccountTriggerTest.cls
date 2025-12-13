@isTest
public class AccountTriggerTest {
    
    @isTest
    static void criarDados(){
        Lead newLead = new Lead();
        newLead.LastName = 'HospCOm teste';
        insert newLead;

        Account contaSpe = new Account();
        contaSpe.Name = 'Hospcom Test';
        contaSpe.Type = 'CLIENTE FINAL';
        contaSpe.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Conta_comercial').getRecordTypeId();
        contaSpe.Phone = '(81) 99999-9991'; 
        contaSpe.Industry = 'ÓRGÃO GESTOR DE SAÚDE';
        contaSpe.Description = 'CÓDIGO E DESCRIÇÃO DA ATIVIDADE';
        contaSpe.CNPJ__c = '86.249.279/0001-67';
        contaSpe.Raz_o_Social__c = 'MUNICIPIO DE SINOP';
        contaSpe.Categoria__c = 'ORGÃO GESTOR';
        contaSpe.Status_receita__c = 'SUCESSO';
        contaSpe.Especialidade__c = 'PREFEITURA';
        contaSpe.Lead__c = 'blablablab';
        insert contaSpe;

        contaSpe.Phone = '(81) 99999-8221';
        update contaSpe;
    }
}