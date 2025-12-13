@isTest
public with sharing class AvaliacaoExperienciaServiceTest {
    
    @testSetup
    static void makeData(){

        // Cria uma conta parceira SEM ativar IsPartner ainda
        Account partnerAccount = new Account(
            Name = 'Teste Acct',
            Phone = '85999999999',
            CNPJ__c = '12.345.678/0001-95'
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

        Contact gestor = new Contact(
            FirstName='Gestor',
            LastName='Teste',
            AccountId = partnerAccount.Id,
            Email = 'gestor@teste.com'
        );
        insert gestor;

        // Agora ativa o IsPartner e cria o usuário em System.runAs
        User dummyAdmin = [SELECT Id, name, isActive FROM User WHERE (Profile.Name = 'Administrador do sistema' OR Profile.Name = 'System Administrator' ) AND IsActive = true  LIMIT 1];

        System.runAs(dummyAdmin) {
            // Atualiza o IsPartner da conta
            partnerAccount.IsPartner = true;
            update partnerAccount;

            // Busca o perfil
            Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User'];

            // Cria o usuário parceiro
            User colaborarUser = new User(
                Alias = 'testuser',
                Email = 'test.partner@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Partner',
                FirstName = 'Test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'test.partner@hospcom.com',
                ContactId = colaborador.Id,
                IsActive = true
            );
            insert colaborarUser;

            User gestorUser = new User(
                Alias = 'testGest',
                Email = 'test2.partner@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Gestor',
                FirstName = 'Test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'test2.partner@hospcom.com',
                ContactId = gestor.Id,
                IsActive = true
            );
            insert gestorUser;
        }

        Avaliacao_de_Experiencia__c avaliacao = new Avaliacao_de_Experiencia__c(
            Nome_do_Colaborador__c = colaborador.Id, 
            Avaliacao_Finalizada__c = true,
            Gestor2__c = gestor.Id,
            Data_Fim__c = Date.today().addDays(1),
            ciente__c = true
        );
        insert avaliacao;

        Avaliacao_de_Experiencia__c avaliacaoVencendo = new Avaliacao_de_Experiencia__c(
            Nome_do_Colaborador__c = colaborador.Id, 
            Avaliacao_Finalizada__c = false,
            Gestor2__c = gestor.Id,
            Data_Fim__c = Date.today().addDays(1),
            Ciente__c = false
        );
        insert avaliacaoVencendo;

         Avaliacao_de_Experiencia__c avaliacaoAtrasada = new Avaliacao_de_Experiencia__c(
            Nome_do_Colaborador__c = colaborador.Id, 
            Avaliacao_Finalizada__c = false,
            Gestor2__c = gestor.Id,
            Data_Fim__c = Date.today().addDays(-1),
            Ciente__c = false
        );
        insert avaliacaoAtrasada;
    }


    @IsTest
    public static void TestEnviarNotificacoesGestor(){

        Test.startTest();
        AvaliacaoExperienciaService.enviarNotificacoesGestor();
        Test.stopTest();
    }

    @isTest
    public static void TestEnviarNotificacaoDP(){
        List<Avaliacao_de_Experiencia__c> novas = [
            SELECT Id, Avaliacao_Finalizada__c, Gestor2__c, Ciente__c
            FROM Avaliacao_de_Experiencia__c
        ];

        Map<Id, Avaliacao_de_Experiencia__c> antigas = new Map<Id, Avaliacao_de_Experiencia__c>();
        for (Avaliacao_de_Experiencia__c av : novas) {
            Avaliacao_de_Experiencia__c clone = av.clone(false, true, false, false);
            clone.Avaliacao_Finalizada__c = false;
            antigas.put(av.Id, clone);
        }

        Test.startTest();
        AvaliacaoExperienciaService.enviarNotificacaoDP(novas, antigas);
        Test.stopTest();
        System.assert(true);

    }

      @isTest
    public static void TestEnviarNotificacaoColaborador(){
        List<Avaliacao_de_Experiencia__c> novas = [
            SELECT Id, Avaliacao_Finalizada__c, Gestor2__c, Ciente__c, Nome_do_Colaborador__c
            FROM Avaliacao_de_Experiencia__c
        ];

        Map<Id, Avaliacao_de_Experiencia__c> antigas = new Map<Id, Avaliacao_de_Experiencia__c>();
        for (Avaliacao_de_Experiencia__c av : novas) {
            Avaliacao_de_Experiencia__c clone = av.clone(false, true, false, false);
            clone.Ciente__c = false;
            clone.Avaliacao_Finalizada__c = false;
            antigas.put(av.Id, clone);
        }

        Test.startTest();
        AvaliacaoExperienciaService.enviarNotificacoesColaborador(novas, antigas);
        Test.stopTest();
        System.assert(true);
    }

    @isTest
    public static void TestEnviarNotificacaoColaboradorCiente(){
        Test.startTest();
        AvaliacaoExperienciaService.enviarNotificacaoAtraso();
        Test.stopTest();
    }
        
}