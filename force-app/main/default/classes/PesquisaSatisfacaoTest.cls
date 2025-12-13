@isTest
private class PesquisaSatisfacaoTest {

    /* ---------------------------------------------------------
       HELPERS
    --------------------------------------------------------- */

    // Busca dinamicamente um recordType válido de Order
    private static Id getOrderRecordType() {
        return [
            SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Order'
            AND DeveloperName = 'Hospcom'
            LIMIT 1
        ].Id;
    }

    private static Account buildAccount() {
        return new Account(
            Name = 'Conta Teste',
            CNPJ__c = '11.111.111/0001-11',
            BillingCountry = 'Brasil',
            BillingState = 'Goiás',
            BillingCity = 'Goiânia',
            BillingStreet = 'Rua Teste 123',
            BillingPostalCode = '74000-000'
        );
    }

    private static Opportunity buildOpportunity(Id accId) {
        return new Opportunity(
            Name = 'Oportunidade Teste',
            AccountId = accId,
            StageName = '01 - Lead',
            CloseDate = Date.today()
        );
    }

    private static Contact buildContact(Id accId) {
        return new Contact(
            FirstName = 'Fulano',
            LastName  = 'Teste',
            AccountId = accId,
            MobilePhone = '62988887777'
        );
    }

    private static Quote buildQuote(Id oppId, Id contactId) {
        return new Quote(
            Name = 'Cotação Teste',
            Status = 'Rascunho',
            OpportunityId = oppId,
            ContactId = contactId,
            Forma_de_pagamento__c  = 'Pix',
            Condicao_de_pagamento__c = 'À Vista'
        );
    }

    private static Order buildOrder(Id accId, Id vendedorId, String natureza) {
        return new Order(
            RecordTypeId = getOrderRecordType(),
            Status = 'Em andamento',           // ← IMPORTANTE PARA COBERTURA
            Name = 'Pedido Teste ' + natureza,
            AccountId = accId,
            Faturamento_Feito__c = accId,
            Condicao_de_pagamento__c = 'À Vista',
            Forma_de_pagamento2__c = 'Pix',
            Referente_a_Demonstra_o_loca_o__c = 'NÃO',
            Natureza_de_Opera_o__c = natureza,
            Vendedor__c = vendedorId,
            EffectiveDate = Date.today(),
            OwnerId = vendedorId,
            Nome_Contato_Financeiro__c = 'Teste',
            Telefone_Contato__c = '1122223333',
            E_mail_Contato__c = 'teste@teste.com',
            Ignora_validacao__c = true
        );
    }

    /* ---------------------------------------------------------
       TESTES
    --------------------------------------------------------- */

    @isTest
    static void testVendaComQuote() {

        User u = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'Administrador do sistema')
            AND IsActive = true
            LIMIT 1
        ];

        System.runAs(u) {

            Account a = buildAccount();
            insert a;

            Contact c = buildContact(a.Id);
            insert c;

            Opportunity opp = buildOpportunity(a.Id);
            insert opp;

            Quote q = buildQuote(opp.Id, c.Id);
            insert q;

            Order o = buildOrder(a.Id, u.Id, 'VENDA');
            o.QuoteId = q.Id;
            insert o;

            Test.startTest();
            RecursiveHandler.IsNotRecursive2 = true;
            o.Status = 'Entregue Total';
            update o;
            Test.stopTest();

            System.assertEquals('Entregue Total', o.Status);
        }
    }

    @isTest
    static void testLocacaoComContrato() {

        User u = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'Administrador do sistema')
            AND IsActive = true
            LIMIT 1
        ];

        System.runAs(u) {

            Account a = buildAccount();
            insert a;

            Contact c = buildContact(a.Id);
            insert c;

            Contrato_de_Servi_o__c contrato = new Contrato_de_Servi_o__c(
                Contato_do_Locat_rio__c = c.Id
            );
            insert contrato;

            Order o = buildOrder(a.Id, u.Id, 'LOCAÇÃO');
            o.Contrato_de_Servi_o__c = contrato.Id;
            insert o;

            Test.startTest();
            RecursiveHandler.IsNotRecursive2 = true;
            o.Status = 'Entregue Total';
            update o;
            Test.stopTest();

            System.assertEquals('Entregue Total', o.Status);
        }
    }

    @isTest
    static void testServicoComWorkOrder() {

        User u = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'Administrador do sistema')
            AND IsActive = true
            LIMIT 1
        ];

        System.runAs(u) {

            Account a = buildAccount();
            insert a;

            Contact c = buildContact(a.Id);
            insert c;

            WorkOrder wo = new WorkOrder(
                ContactId = c.Id,
                Tecnico_executor__c = '0035A00003gVl4tQAC' 
            );
            insert wo;

            Order o = buildOrder(a.Id, u.Id, 'SERVIÇO');
            o.Ordem_de_trabalho__c = wo.Id;
            insert o;

            Test.startTest();
            RecursiveHandler.IsNotRecursive2 = true;
            o.Status = 'Entregue Total';
            update o;
            Test.stopTest();

            System.assertEquals('Entregue Total', o.Status);
        }
    }

    // Sem quote
    @isTest
    static void testVendaSemQuote() {

       User u = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'Administrador do sistema')
            AND IsActive = true
            LIMIT 1
        ];

        System.runAs(u) {

            Account a = buildAccount();
            insert a;

            Order o = buildOrder(a.Id, u.Id, 'VENDA');
            insert o;

            Test.startTest();
            RecursiveHandler.IsNotRecursive2 = true;
            o.Status = 'Entregue Total';
            update o;
            Test.stopTest();
        }
    }

    // Sem contrato
    @isTest
    static void testLocacaoSemContrato() {

        User u = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'Administrador do sistema')
            AND IsActive = true
            LIMIT 1
        ];

        System.runAs(u) {

            Account a = buildAccount();
            insert a;

            Order o = buildOrder(a.Id, u.Id, 'LOCAÇÃO');
            insert o;

            Test.startTest();
            RecursiveHandler.IsNotRecursive2 = true;
            o.Status = 'Entregue Total';
            update o;
            Test.stopTest();
        }
    }

    // Sem WorkOrder
    @isTest
    static void testServicoSemWorkOrder() {

        User u = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'Administrador do sistema')
            AND IsActive = true
            LIMIT 1
        ];

        System.runAs(u) {
            
            Account a = buildAccount();
            insert a;

            Order o = buildOrder(a.Id, u.Id, 'SERVIÇO');
            insert o;

            Test.startTest();
            RecursiveHandler.IsNotRecursive2 = true;
            o.Status = 'Entregue Total';
            update o;
            Test.stopTest();
        }
    }
}