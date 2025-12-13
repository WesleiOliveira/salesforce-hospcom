trigger criaPedidosDeConsumivel on Demonstracao__c (after update) {

    // === Guarda: só processa quem mudou para "Aprovado" ===
    List<Demonstracao__c> demosAprovadosComodato = new List<Demonstracao__c>();
    List<Demonstracao__c> demosAprovadosEmprestimoRapido = new List<Demonstracao__c>();

    for (Demonstracao__c dNew : Trigger.new) {
        Demonstracao__c dOld = Trigger.oldMap.get(dNew.Id);
        Boolean mudouParaAprovado = (dNew.Status__c == 'Aprovado') && (dOld == null || dOld.Status__c != 'Aprovado');
        if (!mudouParaAprovado) continue;

        // RecordType "Empréstimo para demos rápidas"
        if (dNew.RecordTypeId == '012U4000002zg7dIAA') {
            demosAprovadosEmprestimoRapido.add(dNew);
        } else {
            demosAprovadosComodato.add(dNew);
        }
    }
    if (demosAprovadosComodato.isEmpty() && demosAprovadosEmprestimoRapido.isEmpty()) return;

    // === Coletar IDs das contas e das demos (por fluxo) ===
    Set<Id> contaIds = new Set<Id>();
    Set<Id> demoIdsComodato = new Set<Id>();
    Set<Id> demoIdsEmprestimo = new Set<Id>();

    for (Demonstracao__c d : demosAprovadosComodato) {
        if (d.Conta__c != null) contaIds.add(d.Conta__c);
        demoIdsComodato.add(d.Id);
    }
    for (Demonstracao__c d : demosAprovadosEmprestimoRapido) {
        if (d.Conta__c != null) contaIds.add(d.Conta__c);
        demoIdsEmprestimo.add(d.Id);
    }

    // === Accounts em massa ===
    Map<Id, Account> contasMap = new Map<Id, Account>(
        [SELECT Id, BillingCity, BillingStreet, BillingState, BillingPostalCode,
                ShippingCity, ShippingStreet, ShippingState, ShippingPostalCode
         FROM Account
         WHERE Id IN :contaIds]
    );

    // === PRODUTOS DO COMODATO (correção aqui: IN :demoIdsComodato) ===
    Map<Id, List<Consumivel_de_comodato__c>> consumiveisPorDemo = new Map<Id, List<Consumivel_de_comodato__c>>();
    if (!demoIdsComodato.isEmpty()) {
        for (Consumivel_de_comodato__c c : [
            SELECT Comodato__c, Produto__c, Entrada_da_tabela_de_pre_os__c, Quantidade__c, Valor_unitario__c
            FROM Consumivel_de_comodato__c
            WHERE Comodato__c IN :demoIdsComodato
        ]) {
            List<Consumivel_de_comodato__c> lst = consumiveisPorDemo.get(c.Comodato__c);
            if (lst == null) {
                lst = new List<Consumivel_de_comodato__c>();
                consumiveisPorDemo.put(c.Comodato__c, lst);
            }
            lst.add(c);
        }
    }

    // === PRODUTOS DO "EMPRÉSTIMO RÁPIDO" ===
    Map<Id, List<Produto_da_demonstracao__c>> produtosPorDemo = new Map<Id, List<Produto_da_demonstracao__c>>();
    Set<Id> product2Ids = new Set<Id>();

    if (!demoIdsEmprestimo.isEmpty()) {
        for (Produto_da_demonstracao__c p : [
            SELECT Demonstracao__c, Ativo__r.Product2Id, Ativo__r.Product2.Valor_de_Venda__c
            FROM Produto_da_demonstracao__c
            WHERE Demonstracao__c IN :demoIdsEmprestimo
        ]) {
            List<Produto_da_demonstracao__c> lst = produtosPorDemo.get(p.Demonstracao__c);
            if (lst == null) {
                lst = new List<Produto_da_demonstracao__c>();
                produtosPorDemo.put(p.Demonstracao__c, lst);
            }
            lst.add(p);
            if (p.Ativo__r != null && p.Ativo__r.Product2Id != null) {
                product2Ids.add(p.Ativo__r.Product2Id);
            }
        }
    }

    // PricebookEntries (só para o fluxo de Empréstimo Rápido)
    Map<Id, PricebookEntry> pbePorProduct2 = new Map<Id, PricebookEntry>();
    if (!product2Ids.isEmpty()) {
        pbePorProduct2 = new Map<Id, PricebookEntry>([
            SELECT Id, Product2Id
            FROM PricebookEntry
            WHERE Product2Id IN :product2Ids
              AND Pricebook2Id = '01si0000000I7SxAAK'
              AND CurrencyISOCode = 'BRL'
        ]);
    }

    // === Montar ORDERS (ainda sem itens) ===
    List<Order> ordersToInsert = new List<Order>();

    // Comodato → pode gerar N pedidos por demo (um por mês)
    for (Demonstracao__c d : demosAprovadosComodato) {
        Account acc = contasMap.get(d.Conta__c);
        List<Consumivel_de_comodato__c> itens = consumiveisPorDemo.get(d.Id);
        if (acc == null || itens == null || itens.isEmpty()) continue;

        Integer meses = (d.Quantidade_de_meses__c == null ? 0 : Integer.valueOf(d.Quantidade_de_meses__c));
        for (Integer i = 0; i < meses; i++) {
            ordersToInsert.add(new Order(
                AccountId = d.Conta__c,
                Status = 'Rascunho',
                EffectiveDate = Date.today().addMonths(i),
                BillingCity = acc.BillingCity,
                BillingStreet = acc.BillingStreet,
                BillingPostalCode = acc.BillingPostalCode,
                BillingState = acc.BillingState,
                Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do comodato.',
                Condicao_de_pagamento__c = d.Condi_o_de_pagamento__c,
                Demonstracao__c = d.Id,                      // chave para mapear itens depois
                Departamento3__c = d.Departamento__c,
                E_mail_Contato__c = (d.Contato__r != null ? d.Contato__r.Email : null),
                Entrega_parcial__c = 'Não Autorizada',
                Faturamento_Feito__c = d.Fornecedor__c,
                Forma_de_pagamento2__c = d.Forma_de_pagamento__c,
                Ignora_validacao__c = true,
                Natureza_de_Opera_o__c = 'VENDA',
                Frete__c = 'Contratação do Frete por conta do Remetente (CIF)',
                Necess_rio_Treinamento__c = 'NÃO',
                Nome_Contato_Financeiro__c = (d.Contato__r != null ? d.Contato__r.FirstName : null),
                Pricebook2Id = '01si0000000I7SxAAK',
                Prioridade__c = 'NORMAL',
                Entrega_liberada_pelo_financeiro__c = 'NÃO',
                ShippingCity = acc.ShippingCity,
                ShippingStreet = acc.ShippingStreet,
                ShippingPostalCode = acc.ShippingPostalCode,
                Telefone_Contato__c = (d.Contato__r != null ? d.Contato__r.MobilePhone : null),
                Vendedor__c = d.Solicitante__c
            ));
        }
    }

    // Empréstimo para demos rápidas → 1 pedido por demo
    for (Demonstracao__c d : demosAprovadosEmprestimoRapido) {
        Account acc = contasMap.get(d.Conta__c);
        List<Produto_da_demonstracao__c> produtos = produtosPorDemo.get(d.Id);
        if (acc == null || produtos == null || produtos.isEmpty()) continue;

        ordersToInsert.add(new Order(
            AccountId = d.Conta__c,
            Status = 'Aprovado',
            EffectiveDate = Date.today(),
            BillingCity = acc.BillingCity,
            BillingStreet = acc.BillingStreet,
            BillingPostalCode = acc.BillingPostalCode,
            BillingState = acc.BillingState,
            Comentarios__c = 'Pedido criado automaticamente a partir da aprovação da demonstração (Empréstimo rápido).',
            Condicao_de_pagamento__c = 'À vista - Paga e Retira',
            Demonstracao__c = d.Id,                          // chave para mapear itens depois
            Departamento3__c = d.Departamento__c,
            E_mail_Contato__c = (d.Solicitante__r != null ? d.Solicitante__r.Email : null),
            Entrega_parcial__c = 'Não Autorizada',
            Faturamento_Feito__c = d.Fornecedor__c,
            Forma_de_pagamento2__c = 'Recebimento via Transferência Bancária',
            Ignora_validacao__c = true,
            Natureza_de_Opera_o__c = 'REMESSA DE COMODATO',
            Frete__c = 'Contratação do Frete por conta do Remetente (CIF)',
            Necess_rio_Treinamento__c = 'NÃO',
            Nome_Contato_Financeiro__c = (d.Solicitante__r != null ? d.Solicitante__r.FirstName : null),
            Pricebook2Id = '01si0000000I7SxAAK',
            Prioridade__c = 'NORMAL',
            Entrega_liberada_pelo_financeiro__c = 'NÃO',
            ShippingCity = acc.ShippingCity,
            ShippingStreet = acc.ShippingStreet,
            ShippingPostalCode = acc.ShippingPostalCode,
            Telefone_Contato__c = (d.Solicitante__r != null ? d.Solicitante__r.MobilePhone : null),
            Vendedor__c = d.Solicitante__c,
            Pedido_da_Linha_de_OPME__c = 'NÃO',
            Acao_interna__c = true
        ));
    }

    // === Inserir pedidos primeiro ===
    if (ordersToInsert.isEmpty()) return;
    insert ordersToInsert;

    // Indexar pedidos por Demonstracao (pode haver vários por demo no Comodato)
    Map<Id, List<Order>> ordersPorDemo = new Map<Id, List<Order>>();
    for (Order o : ordersToInsert) {
        List<Order> lst = ordersPorDemo.get(o.Demonstracao__c);
        if (lst == null) {
            lst = new List<Order>();
            ordersPorDemo.put(o.Demonstracao__c, lst);
        }
        lst.add(o);
    }

    // === Agora sim: montar os OrderItems, com OrderId correto ===
    List<OrderItem> orderItemsToInsert = new List<OrderItem>();

    // Comodato: para cada pedido (um por mês), colocar todos os consumíveis da demo
    for (Demonstracao__c d : demosAprovadosComodato) {
        List<Order> pedidos = ordersPorDemo.get(d.Id);
        List<Consumivel_de_comodato__c> itens = consumiveisPorDemo.get(d.Id);
        if (pedidos == null || itens == null) continue;

        for (Order o : pedidos) {
            Integer idx = 1;
            for (Consumivel_de_comodato__c c : itens) {
                orderItemsToInsert.add(new OrderItem(
                    OrderId = o.Id,
                    PricebookEntryId = c.Entrada_da_tabela_de_pre_os__c, // já é PBE
                    Quantity = c.Quantidade__c,
                    UnitPrice = c.Valor_unitario__c,
                    Product2Id = c.Produto__c,
                    Item__c = idx++,
                    Status__c = 'Novo'
                ));
            }
        }
    }

    // Empréstimo rápido: 1 pedido por demo
    for (Demonstracao__c d : demosAprovadosEmprestimoRapido) {
        List<Order> pedidos = ordersPorDemo.get(d.Id);
        List<Produto_da_demonstracao__c> produtos = produtosPorDemo.get(d.Id);
        if (pedidos == null || pedidos.isEmpty() || produtos == null) continue;

        Order pedido = pedidos[0]; // único por demo
        Integer idx = 1;
        for (Produto_da_demonstracao__c p : produtos) {
            PricebookEntry pbe = pbePorProduct2.get(p.Ativo__r.Product2Id);
            if (pbe == null) continue;

            orderItemsToInsert.add(new OrderItem(
                OrderId = pedido.Id,
                PricebookEntryId = pbe.Id,
                Acao_interna__c = true,
                Quantity = 1,
                UnitPrice = p.Ativo__r.Product2.Valor_de_Venda__c,
                Product2Id = p.Ativo__r.Product2Id,
                Item__c = idx++,
                Status__c = 'Novo'
            ));
        }
    }

    if (!orderItemsToInsert.isEmpty()) {
        insert orderItemsToInsert;
    }
}