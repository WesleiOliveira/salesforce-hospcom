@isTest(SeeAllData=true)
private class CotacaoPropostaTest {

    @isTest
    static void testCotacaoPropostaController() {
        
        // Conta principal com endereço (cliente)
        Account acc = new Account(
            Name = 'Conta Teste',
            CNPJ__c = '13.512.358/0001-45',
            BillingStreet = 'Rua dos Testes, 123',
            BillingCity = 'Goiânia',
            BillingStateCode = 'GO',
            BillingCountry = 'Brasil',
            BillingPostalCode = '74000-000',
            ShippingStreet = 'Rua das Entregas, 456',
            ShippingCity = 'Goiânia',
            ShippingStateCode = 'GO',
            ShippingCountry = 'Brasil',
            ShippingPostalCode = '74000-001'
        );
        insert acc;

        // Contato vinculado à conta
        Contact contato = new Contact(
            FirstName = 'João',
            LastName = 'Silva',
            CPF__c = '783.846.681-40',
            AccountId = acc.Id
        );
        insert contato;

        // Usuário dono da oportunidade
        User u = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do sistema' OR Profile.Name = 'System Administrator' LIMIT 1];
        RecordType rtOpp = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Comercial' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2Id = :pb.Id LIMIT 1];

        // CNPJs a serem testados
        List<String> cnpjs = new List<String>{
            '05.743.288/0001-08', // Hospcom
            '27.476.124/0001-02', // Health
            '23.813.386/0001-56'  // GDB
        };

        // Buscar as contas existentes com esses CNPJs
        Map<String, Account> contasFaturamento = new Map<String, Account>();
        for (Account a : [SELECT Id, CNPJ__c, Name FROM Account WHERE CNPJ__c IN :cnpjs]) {
            contasFaturamento.put(a.CNPJ__c, a);
        }

        // Garantir que todas foram encontradas
        for (String cnpj : cnpjs) {
            System.assert(contasFaturamento.containsKey(cnpj), 'Conta de faturamento com CNPJ ' + cnpj + ' não encontrada em produção.');
        }

        List<Quote> quotesToTest = new List<Quote>();

        for (String cnpj : cnpjs) {
            Account faturamento = contasFaturamento.get(cnpj);

            Opportunity opp = new Opportunity(
                Name = 'Oportunidade ' + cnpj,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                OwnerId = u.Id,
                RecordTypeId = rtOpp.Id,
                AccountId = acc.Id,
                Faturamento_Feito2__c = faturamento.Id
            );
            insert opp;

            Quote quote = new Quote(
                Name = 'Cotação ' + cnpj,
                OpportunityId = opp.Id,
                ContactId = contato.Id,
                ExpirationDate = Date.today().addDays(15),
                Prazo_de_garantia__c = 'Equipamento 12 meses, Peça 6 meses',
                CurrencyISOCode = 'BRL',
                Pricebook2Id = pb.Id
            );
            insert quote;
            quotesToTest.add(quote);

            QuoteLineItem qli = new QuoteLineItem(
                QuoteId = quote.Id,
                Product2Id = prod.Id,
                PricebookEntryId = pbe.Id,
                UnitPrice = 100,
                Quantity = 2,
                Item__c = 1
            );
            insert qli;

            OpportunityContactRole ocr = new OpportunityContactRole(
                OpportunityId = opp.Id,
                ContactId = contato.Id,
                Role = 'Signatário da proposta (Hospcom)'
            );
            insert ocr;
        }

        Test.startTest();
        for (Quote qt : quotesToTest) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(qt);
            CotacaoProposta controller = new CotacaoProposta(stdCtrl);

            System.assertNotEquals(null, controller.cotacao, 'Cotação não pode ser nula');
            System.assert(controller.produtos.size() > 0, 'Deve haver produtos');
            System.assertNotEquals(null, controller.documento, 'Documento não pode ser nulo');
            System.assertNotEquals(null, controller.documento.timbrado, 'Timbrado deve estar preenchido');
        }
        Test.stopTest();
    }
}