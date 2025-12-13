@IsTest
private class OportunidadeMembroCompartilhaTest {

    @testSetup
    static void setupData() {
        // Cria uma conta parceira SEM ativar IsPartner ainda
        Account partnerAccount = new Account(
            Name = 'Teste Acct',
            Phone = '85999999999',
            BillingStreet = 'Av. Goiás, 123',
            BillingCity = 'Lapa',
            BillingState = 'Goiás',
            BillingCountry = 'Brasil',
            BillingPostalCode = '74000-000',
            CNPJ__c =  '05.743.288/0001-08'
        );
        insert partnerAccount;

        // Cria contatos
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

        // Ativa IsPartner e cria usuários parceiros
        User dummyAdmin = [SELECT Id, name, isActive FROM User WHERE (Profile.Name = 'Administrador do sistema' OR Profile.Name = 'System Administrator' ) AND IsActive = true  LIMIT 1];

        System.runAs(dummyAdmin) {
            partnerAccount.IsPartner = true;
            update partnerAccount;

            Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User'];

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

        User colaboradorUser = [SELECT Id FROM User WHERE ContactId = :colaborador.Id];

        // Conta e oportunidade
        Account acc = new Account(
            Name = 'Conta Teste',
            BillingStreet = 'Rua das Palmeiras, 456',
            BillingCity = 'Lapa',
            BillingState = 'Goiás',
            BillingCountry = 'Brasil',
            BillingPostalCode = '74000-001',
            CNPJ__c = '11.328.248/0001-00'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Opp Teste',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        // Demonstracao
        Demonstracao__c demo = new Demonstracao__c(
            Oportunidade__c = opp.Id,
            OwnerId = colaboradorUser.Id,
            Contato__c = colaborador.Id,
            Fornecedor__c = partnerAccount.Id,
            Solicitante__c = colaboradorUser.Id,
            Departamento__c = 'Comercial',
            Conta__c = acc.id
        );
        insert demo;

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Hospcom' AND SobjectType = 'Order' LIMIT 1];
        // Pedido (Order)
        Order ped = new Order(
            Name = 'Pedido Teste',
            OpportunityId = opp.Id,
            AccountId = acc.Id,
            Status = 'Rascunho',
            EffectiveDate = Date.today(),
            OwnerId = colaboradorUser.Id,
            Nome_Contato_Financeiro__c = 'Financeiro',
            E_mail_Contato__c = 'contato@finaceiro.com',
            Telefone_Contato__c = '13999999999',
            Vendedor__c = colaboradorUser.Id,
            Faturamento_Feito__c = partnerAccount.Id,
            Forma_de_pagamento2__c = 'Sem Mov. Financeiro',
            RecordTypeId = rt.Id,
            Natureza_de_Opera_o__c = 'VENDA'
        );
        insert ped;

        // Pedido Item
       Order debug = [SELECT Id, RecordType.DeveloperName FROM Order WHERE Name = 'Pedido Teste' LIMIT 1];
       System.debug('RecordType: ' + debug.RecordType.DeveloperName);


        // Faturamento
        Faturamento__c fat = new Faturamento__c(
            Name = 'Fat Teste',
            Pedido__c = ped.Id,
            OwnerId = colaboradorUser.Id
        );
        insert fat;
    }

     @IsTest
    static void testInsertMembro() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opp Teste' LIMIT 1];

        // Pega o admin pelo DeveloperName (mais seguro que pelo Name)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema'  OR Profile.Name = 'System Administrator' LIMIT 1];
        User u = [SELECT Id FROM User WHERE ProfileId = :p.Id AND IsActive = true LIMIT 1];

        Test.startTest();
        OpportunityTeamMember m = new OpportunityTeamMember(
            OpportunityId = opp.Id,
            UserId = u.Id,
            OpportunityAccessLevel = 'Read'
        );
        insert m;
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Demonstracao__Share WHERE UserOrGroupId = :u.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM OrderShare WHERE UserOrGroupId = :u.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM Faturamento__Share WHERE UserOrGroupId = :u.Id]);
    }

    @IsTest
    static void testUpdateMembro() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opp Teste' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Profile.Name = 'System Administrator'  LIMIT 1];
        User u = [SELECT Id FROM User WHERE ProfileId = :p.Id AND IsActive = true LIMIT 1];

        OpportunityTeamMember m = new OpportunityTeamMember(
            OpportunityId = opp.Id,
            UserId = u.Id,
            OpportunityAccessLevel = 'Read'
        );
        insert m;

        Test.startTest();
        m.OpportunityAccessLevel = 'Edit';
        update m;
        Test.stopTest();

        System.assertEquals(1, [
            SELECT COUNT() FROM Demonstracao__Share 
            WHERE UserOrGroupId = :m.UserId AND AccessLevel = 'Edit'
        ]);
    }

    @IsTest
    static void testDeleteMembro() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opp Teste' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Profile.Name = 'System Administrator' LIMIT 1];
        User u = [SELECT Id FROM User WHERE ProfileId = :p.Id AND IsActive = true LIMIT 1];

        OpportunityTeamMember m = new OpportunityTeamMember(
            OpportunityId = opp.Id,
            UserId = u.Id,
            OpportunityAccessLevel = 'Read'
        );
        insert m;

        Test.startTest();
        delete m;
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Demonstracao__Share WHERE UserOrGroupId = :m.UserId]);
        System.assertEquals(0, [SELECT COUNT() FROM OrderShare WHERE UserOrGroupId = :m.UserId]);
        System.assertEquals(0, [SELECT COUNT() FROM Faturamento__Share WHERE UserOrGroupId = :m.UserId]);
    }

}