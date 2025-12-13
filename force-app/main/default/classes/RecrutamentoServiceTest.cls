@isTest
public with sharing class RecrutamentoServiceTest {

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
    static void testInserirAvaliacaoExperiencia() {
        List<Recrutamento__c> recrutamentos = [
            SELECT Id, Status__c, Data_de_Admissao__c, Contato_do_Colaborador__c
            FROM Recrutamento__c
        ];

        Test.startTest();
        RecrutamentoService.inserirAvaliacaoExperiencia(recrutamentos);
        Test.stopTest();

        List<Avaliacao_de_Experiencia__c> avaliacoes = [
            SELECT Id, Periodo_da_Avaliacao__c, Nome_do_Colaborador__c, Data_Fim__c
            FROM Avaliacao_de_Experiencia__c
        ];

        // Valida se foram criadas 2 avaliações para o recrutamento válido
        System.assertEquals(2, avaliacoes.size(), 'Duas avaliações deveriam ter sido criadas');

        Set<String> periodosCriados = new Set<String>();
        for (Avaliacao_de_Experiencia__c av : avaliacoes) {
            periodosCriados.add(av.Periodo_da_Avaliacao__c);
        }

        System.assert(periodosCriados.contains('1º Período (45 Dias)'), 'Avaliação do 1º Período deveria existir');
        System.assert(periodosCriados.contains('2º Período (90 Dias)'), 'Avaliação do 2º Período deveria existir');
    }
}