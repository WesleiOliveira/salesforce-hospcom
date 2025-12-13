@isTest
public with sharing class FormularioAvaliacaoExperienciaTest {

    @testSetup
    static void makeData(){

        // Cria uma conta parceira SEM ativar IsPartner ainda
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
            Data_Fim__c = Date.today().addDays(1)
        );
        insert avaliacao;

        Avaliacao_de_Experiencia__c avaliacaoVencendo = new Avaliacao_de_Experiencia__c(
            Nome_do_Colaborador__c = colaborador.Id, 
            Avaliacao_Finalizada__c = false,
            Gestor2__c = gestor.Id,
            Data_Fim__c = Date.today().addDays(1)
        );
        insert avaliacaoVencendo;
    }
    
    @isTest
    public static void testeSaveRespostas(){

        Avaliacao_de_Experiencia__c avaliacao = [SELECT Id FROM Avaliacao_de_Experiencia__c LIMIT 1];
       
        String respostasJSON = JSON.serialize(new Map<String, String>{
            'Pergunta_1__c' => 'Superou',
            'Pergunta_2__c' => 'Superou',
            'Pergunta_3__c' => 'Superou',
            'Pergunta_4__c' => 'Superou',
            'Pergunta_5__c' => 'Superou',
            'Pergunta_6__c' => 'Superou',
            'Pergunta_7__c' => 'Superou',
            'Pergunta_8__c' => 'Superou'
        });

        String justificativasJSON = JSON.serialize(new Map<String, String>{
            'Justificativa_1__c' => 'teste',
            'Justificativa_2__c' => 'teste',
            'Justificativa_3__c' => 'teste',
            'Justificativa_4__c' => 'teste',
            'Justificativa_5__c' => 'teste',
            'Justificativa_6__c' => 'teste',
            'Justificativa_7__c' => 'teste',
            'Justificativa_8__c' => 'teste'
        });

        Test.startTest();
        String resultado = FormularioAvaliacaoExperienciaController.saveRespostas(avaliacao.Id, respostasJSON, justificativasJSON, 'Sim', 'observação');
        Test.stopTest();

        Avaliacao_de_Experiencia__c atualizado = [
            SELECT Pergunta_1__c, Pergunta_2__c, Pergunta_3__c, Pergunta_4__c,
                   Pergunta_5__c, Pergunta_6__c, Pergunta_7__c, Pergunta_8__c,
                   Justificativa_1__c, Justificativa_2__c, Justificativa_3__c,
                    Justificativa_4__c, Justificativa_5__c, Justificativa_6__c,
                     Justificativa_7__c, Justificativa_8__c,
                   Avaliacao_Finalizada__c
            FROM Avaliacao_de_Experiencia__c
            WHERE Id = :avaliacao.Id
        ];

        System.assertEquals('success', resultado);
        System.assertEquals('Superou', atualizado.Pergunta_1__c);
        System.assertEquals('Superou', atualizado.Pergunta_2__c);
        System.assertEquals('Superou', atualizado.Pergunta_3__c);
        System.assertEquals('Superou', atualizado.Pergunta_4__c);
        System.assertEquals('Superou', atualizado.Pergunta_5__c);
        System.assertEquals('Superou', atualizado.Pergunta_6__c);
        System.assertEquals('Superou', atualizado.Pergunta_7__c);
        System.assertEquals('Superou', atualizado.Pergunta_8__c);

        System.assertEquals('teste', atualizado.Justificativa_1__c);
        System.assertEquals('teste', atualizado.Justificativa_2__c);
        System.AssertEquals('teste', atualizado.Justificativa_3__c);
        System.AssertEquals('teste', atualizado.Justificativa_4__c);
        System.AssertEquals('teste', atualizado.Justificativa_5__c);
        System.AssertEquals('teste', atualizado.Justificativa_6__c);
        System.AssertEquals('teste', atualizado.Justificativa_7__c);
        System.AssertEquals('teste', atualizado.Justificativa_8__c);

        System.assertEquals(true, atualizado.Avaliacao_Finalizada__c);
    }

    @IsTest
    public static void testeGetRespostas(){

        Avaliacao_de_Experiencia__c avaliacao = [SELECT Id FROM Avaliacao_de_Experiencia__c LIMIT 1];
       
        Test.startTest();
        Avaliacao_de_Experiencia__c resultado = FormularioAvaliacaoExperienciaController.getRespostas(avaliacao.Id);
        Test.stopTest();

        System.Assert.areNotEqual(null, resultado);
    }
}