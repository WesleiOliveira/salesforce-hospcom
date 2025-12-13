@IsTest
private class EvitaDuplicacaonotasentradasTest {
    @IsTest
    static void testeSimplesDeCobertura() {   
        // 🔹 Cria conta
        Account contaFake = new Account(
            Name = 'Pedido Teste - ' + String.valueOf(DateTime.now().getTime()),
            CNPJ__c = '00.000.000/0001-00'
        );
        insert contaFake;

        // 🔹 Cria pedido de compra
        Pedido_de_compra__c cotacao = new Pedido_de_compra__c(            
            Comprador__c = contaFake.Id
        );
        insert cotacao;

        // 🔹 Cria fornecedor
        Fornecedor__c pedidoFake = new Fornecedor__c(
            Comprador__c = contaFake.Id,
            Fornecedor__c = contaFake.Id,
            Pedido_de_compra__c = cotacao.Id
        );
        insert pedidoFake;

        // 🔹 Cria uma nota fiscal válida
        Nota_fiscal_de_pedido_de_compra__c nf1 = new Nota_fiscal_de_pedido_de_compra__c(
            Name = 'NF-GAMBIARA-' + String.valueOf(DateTime.now().getTime()),
            Pedido_de_Compra__c = pedidoFake.Id,
            Data_de_emissao__c = Date.today(),
            Data_de_lan_amento__c = Date.today(),
            Lancada__c = false
        );
        insert nf1;

        // 🔹 Cria uma nota duplicada (mesmo Name e mesmo Pedido)
        Nota_fiscal_de_pedido_de_compra__c nfDuplicada = new Nota_fiscal_de_pedido_de_compra__c(
            Name = nf1.Name,
            Pedido_de_Compra__c = pedidoFake.Id,
            Data_de_emissao__c = Date.today(),
            Data_de_lan_amento__c = Date.today(),
            Lancada__c = false
        );

        Test.startTest();
        try {
            insert nfDuplicada; // Deve gerar erro da trigger
            System.assert(false, 'Era esperado erro de duplicidade, mas não ocorreu.');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Já existe uma Nota Fiscal'), 'Mensagem de erro incorreta');
        }
        Test.stopTest();

        // 🔹 Verifica que a primeira nota foi inserida com sucesso
        System.assertNotEquals(null, nf1.Id, 'A nota original deveria ser inserida com sucesso');
    }
}














/*@IsTest
private class EvitaDuplicacaonotasentradasTest {
    @IsTest
    static void testeSimplesDeCobertura() {   
        
        
     Account contaFake = new Account(
            Name = 'Pedido Teste - ' + String.valueOf(DateTime.now().getTime()),
            CNPJ__c = '00.000.000/0001-00'
        );
        insert contaFake;

    Pedido_de_compra__c cotacao = new Pedido_de_compra__c(            
            Comprador__c = contaFake.Id
        );
        insert cotacao;

        Fornecedor__c pedidoFake = new Fornecedor__c(
            Comprador__c = contaFake.Id,
            Fornecedor__c = contaFake.Id,
            Pedido_de_compra__c = cotacao.Id
        );
        insert pedidoFake;

        // 🔹 Cria uma nota fiscal válida vinculada ao pedido
        Nota_fiscal_de_pedido_de_compra__c nf = new Nota_fiscal_de_pedido_de_compra__c(
            Name = 'NF-GAMBIARA-' + String.valueOf(DateTime.now().getTime()),
            Pedido_de_Compra__c = pedidoFake.Id, // campo obrigatório
            Data_de_emissao__c = Date.today(),
            Data_de_lan_amento__c = Date.today(),
            Lancada__c = false
        );

        Test.startTest();
        insert nf; // 🔹 Executa a trigger
        Test.stopTest();

        System.assertNotEquals(null, nf.Id, 'A nota deveria ser inserida com sucesso');
    }
}*/