@isTest(seeAllData=true)
public class PedidoPreenchimentoTest2 {
    @isTest
    public static void teste1(){
        Order order = new Order(
            AccountId = '0016e00003FBzFGAA1',
            Contrato_de_Servi_o__c = 'a1YU4000000lOF0MAM',
            EffectiveDate = system.today(),
            Status = 'Rascunho',
            Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do contrato.',
            Condicao_de_pagamento__c = '30 dias',
            Departamento3__c = 'Locação',
            E_mail_Contato__c = 'teste@dev.com',
            Entrega_parcial__c = 'Não Autorizada',
            Faturamento_Feito__c = '001i00000085QYbAAM',
            Forma_de_pagamento2__c = 'Cob. Boleto - Banco do Brasil - Ag: 1610-1 Cc: 128057-0 - GDB',
            Frete__c = 'Transporte Próprio por conta do Destinatário',
            Locado_em__c = '-',
            Natureza_de_Opera_o__c = 'LOCAÇÃO',
            Necess_rio_Treinamento__c = 'NÃO',
            Nome_Contato_Financeiro__c = 'Nome Contato',
            Pricebook2Id = '01s5A000004fbcR',
            Telefone_Contato__c = '62991004477',
            Vendedor__c = '005i0000005d2fF',
            Prioridade__c = 'NORMAL',
            Entrega_liberada_pelo_financeiro__c = 'NÃO',
            Pedido_da_Linha_de_OPME__c = 'NÃO'
        );
        insert order;
    }
    @isTest
    public static void teste2(){
        Order order = new Order(
            AccountId = '0016e00003FBzFGAA1',
            OpportunityId = '006U400000E57C9IAJ',
            Departamento3__c = 'Governo',
            EffectiveDate = system.today(),
            Status = 'Rascunho',
            Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do contrato.',
            Condicao_de_pagamento__c = '30 dias',
            E_mail_Contato__c = 'teste@dev.com',
            Entrega_parcial__c = 'Não Autorizada',
            Faturamento_Feito__c = '001i00000085QYbAAM',
            Forma_de_pagamento2__c = 'Cob. Boleto - Banco do Brasil - Ag: 1610-1 Cc: 128057-0 - GDB',
            Frete__c = 'Transporte Próprio por conta do Destinatário',
            Locado_em__c = '-',
            Natureza_de_Opera_o__c = 'VENDA',
            Necess_rio_Treinamento__c = 'NÃO',
            Nome_Contato_Financeiro__c = 'Nome Contato',
            Pricebook2Id = '01s5A000004fbcR',
            Telefone_Contato__c = '62991004477',
            Vendedor__c = '005i0000005d2fF',
            Prioridade__c = 'NORMAL',
            Entrega_liberada_pelo_financeiro__c = 'NÃO',
            Pedido_da_Linha_de_OPME__c = 'NÃO'
        );
        insert order;
    }
    @isTest
    public static void teste3(){
        Order order = new Order(
            AccountId = '0016e00003FBzFGAA1',
            Contrato_de_Servi_o__c = 'a1YU4000000lOF0MAM',
            Departamento3__c = 'Governo',
            EffectiveDate = system.today(),
            Status = 'Rascunho',
            Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do contrato.',
            Condicao_de_pagamento__c = '30 dias',
            E_mail_Contato__c = 'teste@dev.com',
            Entrega_parcial__c = 'Não Autorizada',
            Faturamento_Feito__c = '001i00000085QYbAAM',
            Forma_de_pagamento2__c = 'Cob. Boleto - Banco do Brasil - Ag: 1610-1 Cc: 128057-0 - GDB',
            Frete__c = 'Transporte Próprio por conta do Destinatário',
            Locado_em__c = '-',
            Natureza_de_Opera_o__c = 'LOCAÇÃO',
            Necess_rio_Treinamento__c = 'NÃO',
            Nome_Contato_Financeiro__c = 'Nome Contato',
            Pricebook2Id = '01s5A000004fbcR',
            Telefone_Contato__c = '62991004477',
            Vendedor__c = '005i0000005d2fF',
            Prioridade__c = 'NORMAL',
            Entrega_liberada_pelo_financeiro__c = 'NÃO',
            Pedido_da_Linha_de_OPME__c = 'NÃO'
        );
        insert order;
    }
    @isTest
    public static void teste4(){
        Order order = new Order(
            AccountId = '0016e00003FBzFGAA1',
            OpportunityId = '006U400000E57C9IAJ',
            QuoteId = '0Q06e00000407WACAY',
            Departamento3__c = 'Comercial',
            EffectiveDate = system.today(),
            Status = 'Rascunho',
            Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do contrato.',
            Condicao_de_pagamento__c = '30 dias',
            E_mail_Contato__c = 'teste@dev.com',
            Entrega_parcial__c = 'Não Autorizada',
            Faturamento_Feito__c = '001i00000085QYbAAM',
            Forma_de_pagamento2__c = 'Cob. Boleto - Banco do Brasil - Ag: 1610-1 Cc: 128057-0 - GDB',
            Frete__c = 'Transporte Próprio por conta do Destinatário',
            Locado_em__c = '-',
            Natureza_de_Opera_o__c = 'VENDA',
            Necess_rio_Treinamento__c = 'NÃO',
            Nome_Contato_Financeiro__c = 'Nome Contato',
            Pricebook2Id = '01s5A000004fbcR',
            Telefone_Contato__c = '62991004477',
            Vendedor__c = '005i0000005d2fF',
            Prioridade__c = 'NORMAL',
            Entrega_liberada_pelo_financeiro__c = 'NÃO',
            Pedido_da_Linha_de_OPME__c = 'NÃO'
        );
        insert order;
    }
    @isTest
    public static void teste5(){
        Order order = new Order(
            AccountId = '0016e00003FBzFGAA1',
            Ordem_de_trabalho__c = '0WOU4000000mwkrOAA',
            Departamento3__c = 'Comercial',
            EffectiveDate = system.today(),
            Status = 'Rascunho',
            Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do contrato.',
            Condicao_de_pagamento__c = '30 dias',
            E_mail_Contato__c = 'teste@dev.com',
            Entrega_parcial__c = 'Não Autorizada',
            Faturamento_Feito__c = '001i00000085QYbAAM',
            Forma_de_pagamento2__c = 'Cob. Boleto - Banco do Brasil - Ag: 1610-1 Cc: 128057-0 - GDB',
            Frete__c = 'Transporte Próprio por conta do Destinatário',
            Locado_em__c = '-',
            Natureza_de_Opera_o__c = 'SERVIÇO',
            Necess_rio_Treinamento__c = 'NÃO',
            Nome_Contato_Financeiro__c = 'Nome Contato',
            Pricebook2Id = '01s5A000004fbcR',
            Telefone_Contato__c = '62991004477',
            Vendedor__c = '005i0000005d2fF',
            Prioridade__c = 'NORMAL',
            Entrega_liberada_pelo_financeiro__c = 'NÃO',
            Pedido_da_Linha_de_OPME__c = 'NÃO'
        );
        insert order;
    }
    @isTest
    public static void teste6(){
        Order order = new Order(
            AccountId = '0016e00003FBzFGAA1',
            Demonstracao__c = 'a0KU400001cjShhMAE',
            Departamento3__c = 'Comercial',
            EffectiveDate = system.today(),
            Status = 'Rascunho',
            Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do contrato.',
            Condicao_de_pagamento__c = '30 dias',
            E_mail_Contato__c = 'teste@dev.com',
            Entrega_parcial__c = 'Não Autorizada',
            Faturamento_Feito__c = '001i00000085QYbAAM',
            Forma_de_pagamento2__c = 'Cob. Boleto - Banco do Brasil - Ag: 1610-1 Cc: 128057-0 - GDB',
            Frete__c = 'Transporte Próprio por conta do Destinatário',
            Locado_em__c = '-',
            Natureza_de_Opera_o__c = 'VENDA',
            Necess_rio_Treinamento__c = 'NÃO',
            Nome_Contato_Financeiro__c = 'Nome Contato',
            Pricebook2Id = '01s5A000004fbcR',
            Telefone_Contato__c = '62991004477',
            Vendedor__c = '005i0000005d2fF',
            Prioridade__c = 'NORMAL',
            Entrega_liberada_pelo_financeiro__c = 'NÃO',
            Pedido_da_Linha_de_OPME__c = 'NÃO'
        );
        insert order;
    }
}