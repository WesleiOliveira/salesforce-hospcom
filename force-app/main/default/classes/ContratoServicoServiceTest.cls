@isTest(seeAllData=true)
private class ContratoServicoServiceTest {

   @isTest
    static void testProcessaContratos() {
        // Conta locatário e locador
        Account locatario = new Account(Name = 'Locatário Teste');
        insert locatario;

        Account locador = new Account(Name = 'Locador Teste', Raz_o_Social__c = 'Empresa Teste', CNPJ__c = '00.000.000/0001-00');
        insert locador;

        // Contato do locatário
        Contact contato = new Contact(FirstName = 'João', LastName = 'Teste', Email = 'joao@teste.com', MobilePhone = '11999999999', AccountId = locatario.Id);
        insert contato;

        // Criar Pricebook (catálogo de preços) personalizado
        Pricebook2 customPB = new Pricebook2(Name = 'Custom PB', IsActive = true);
        insert customPB;

        // Produto
        Product2 prod = [SELECT id FROM Product2 LIMIT 1];

        // PricebookEntry vinculado ao produto
        PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = customPB.Id, UnitPrice = 100, IsActive = true, UseStandardPrice = false);
        insert pbe;

        // Ativo simulado
        Asset ativo = new Asset(Name = 'Ativo Teste', Product2Id = prod.Id, AccountId = locatario.Id);
        insert ativo;

        // Contrato de Serviço
        Contrato_de_servi_o__c contrato = new Contrato_de_servi_o__c(
            Name = 'Contrato Teste',
            Status_do_Contrato__c = 'CONTRATO VIGENTE',
            Contato_do_Locat_rio__c = contato.Id,
            Locat_rio_a__c = locatario.Id,
            Locador_a__c = locador.Id,
            Primeiro_faturamento__c = Date.today(),
            Dura_o_do_Contrato_meses__c = 1,
            Condicao_de_pagamento__c = '30 dias',
            Forma_de_pagamento2__c = 'Cob. Boleto - Banco do Brasil - Ag: 1242-4 Cc: 69869-5 - Hospcom',
            Unidade_Hospitalar__c = locatario.Id,
            Vendedor_do_Contrato__c = UserInfo.getUserId(),
            Tipo_de_Entrega__c = 'Contratação do Frete por conta do Remetente (CIF)',
            Emails_para_faturamento__c = 'faturamento@teste.com',
            CurrencyIsoCode = 'BRL'
        );
        insert contrato;

        // Ativo do Contrato
        Ativos_do_Contrato__c ativoContrato = new Ativos_do_Contrato__c(
            Contrato_de_Servico__c = contrato.Id,
            Equipamento_no_cliente__c = true,
            Valor_Unitario_Mensal__c = 100,
            Quantidade__c = 3,
            Ativo_Locado__c = ativo.Id,
            CurrencyIsoCode = 'BRL'
        );
        insert ativoContrato;
    

        Contrato_de_servi_o__c contratoAntigo = contrato.clone(false, true, false, false);
        contratoAntigo.Status_do_Contrato__c = 'EM NEGOCIAÇÃO';

        Test.startTest();
        ContratoServicoService.processaContratos(
            new List<Contrato_de_servi_o__c>{ contrato },
            new Map<Id, Contrato_de_servi_o__c>{ contrato.Id => contratoAntigo }
        );
        Test.stopTest();

        // Asserts básicos
        List<Order> pedidos = [SELECT Id FROM Order WHERE Contrato_de_Servi_o__c = :contrato.Id];
        System.assert(!pedidos.isEmpty(), 'Deveria ter criado ao menos um pedido');

        List<OrderItem> itens = [SELECT Id FROM OrderItem WHERE OrderId = :pedidos[0].Id];
        System.assert(!itens.isEmpty(), 'Deveria ter criado ao menos um item de pedido');
    }
}