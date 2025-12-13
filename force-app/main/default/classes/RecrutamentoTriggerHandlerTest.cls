@isTest
public with sharing class RecrutamentoTriggerHandlerTest {

    @testSetup
    static void makeData() {
        // Cria uma Account e um Contacto para associar aos Recrutamentos
        Account partnerAccount = new Account(
            Name = 'Teste Acct',
            Phone = '85999999999'
        );
        insert partnerAccount;

        // Cria o contato
        Contact colaborador = new Contact(
            FirstName='Colaborador',
            LastName='Teste',
            AccountId = partnerAccount.Id,
            Email = 'colaborardor@teste.com'
        );
        insert colaborador;

        // Recrutamento válido que deve gerar avaliações
        Recrutamento__c recrutamentoValido = new Recrutamento__c(
            Status__c = 'Aprovado',
            Data_de_Admissao__c = Date.today(),
            Contato_do_Colaborador__c = colaborador.Id,
            Telefone_emergencia__c = '85111111111'
        );
        insert recrutamentoValido;
    }

    @isTest
    public static void testUpdateTrigger(){
        
        Recrutamento__c Recrutamento = [SELECT Id FROM Recrutamento__c LIMIT 1];

        Test.startTest();
        update Recrutamento;
        Test.stopTest();
    }
}