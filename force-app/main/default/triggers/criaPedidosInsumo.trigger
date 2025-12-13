trigger criaPedidosInsumo on Contrato_de_Fornecimento_de_Insumo__c (after update) {
    List<Order> ordersToCreate = new List<Order>();
    List<OrderItem> orderItemsToCreate = new List<OrderItem>();

    // Coletar todos os IDs de contratos que precisam ser processados
    Set<Id> contratoIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Set<Id> clienteIds = new Set<Id>();
    for (Contrato_de_Fornecimento_de_Insumo__c ctr : Trigger.new) {
        if (ctr.Status__c == 'Vigente' && Trigger.oldMap.get(ctr.Id).Status__c != 'Vigente') {
            contratoIds.add(ctr.Id);
            clienteIds.add(ctr.Cliente__c);
        }
    }

    // Consultar produtos relacionados
    Map<Id, List<Insumo_do_contrato__c>> contratoToProductsMap = new Map<Id, List<Insumo_do_contrato__c>>();
    for (Insumo_do_contrato__c product : [SELECT Produto__c, Quantidade__c, Valor_unitario__c, Contrato_de_Fornecimento_de_Insumo__c FROM Insumo_do_contrato__c WHERE Contrato_de_Fornecimento_de_Insumo__c IN :contratoIds]) {
        if (!contratoToProductsMap.containsKey(product.Contrato_de_Fornecimento_de_Insumo__c)) {
            contratoToProductsMap.put(product.Contrato_de_Fornecimento_de_Insumo__c, new List<Insumo_do_contrato__c>());
        }
        contratoToProductsMap.get(product.Contrato_de_Fornecimento_de_Insumo__c).add(product);
        productIds.add(product.Produto__c);
    }

    // Consultar contas
    Map<Id, Account> accountMap = new Map<Id, Account>([SELECT BillingCity, BillingStreet, BillingState, BillingPostalCode, ShippingCity, ShippingStreet, ShippingState, ShippingPostalCode FROM Account WHERE Id IN :clienteIds]);

    // Consultar entradas da tabela de preços
    Map<Id, PricebookEntry> pricebookEntryMap = new Map<Id, PricebookEntry>([SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds AND Pricebook2Id = '01si0000000I7SxAAK' AND CurrencyISOCode = 'BRL']);

    // Criar um mapa de Product2Id para PricebookEntryId
    Map<Id, Id> productToPricebookEntryIdMap = new Map<Id, Id>();
    for (PricebookEntry pbe : pricebookEntryMap.values()) {
        productToPricebookEntryIdMap.put(pbe.Product2Id, pbe.Id);
    }

    // Iterar sobre cada contrato e criar pedidos e itens de pedido
    for (Contrato_de_Fornecimento_de_Insumo__c ctr : Trigger.new) {
        if (ctr.Status__c == 'Vigente' && Trigger.oldMap.get(ctr.Id).Status__c != 'Vigente') {
            List<Insumo_do_contrato__c> products = contratoToProductsMap.get(ctr.Id);
            Account account = accountMap.get(ctr.Cliente__c);

            for (Integer i = 0; i < ctr.Prazo_de_vigencia__c; i++) {
                Order newOrder = new Order(
                    AccountId = ctr.Cliente__c,
                    Contrato_de_Fornecimento_de_Insumo__c = ctr.id,
                    Status = 'Rascunho',
                    EffectiveDate = Date.today().addMonths(i),
                    BillingCity = account.BillingCity,
                    BillingStreet = account.BillingStreet,
                    BillingPostalCode = account.BillingPostalCode,
                    BillingState = account.BillingState,
                    Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do Contrato de Fornecimento de Insumos.',
                    Condicao_de_pagamento__c = ctr.Condicao_de_pagamento__c,
                    Departamento3__c = 'Comercial', //verificar
                    E_mail_Contato__c = ctr.Assinante__r.Email,
                    Entrega_parcial__c = 'Não Autorizada',
                    Faturamento_Feito__c = '001i00000085QYb',
                    Forma_de_pagamento2__c = ctr.Forma_de_pagamento__c,
                    Ignora_validacao__c = true,
                    Natureza_de_Opera_o__c = 'VENDA',
                    Frete__c = 'Contratação do Frete por conta do Remetente (CIF)',
                    Necess_rio_Treinamento__c = 'NÃO',
                    Nome_Contato_Financeiro__c = ctr.Assinante__r.FirstName,
                    Pricebook2Id = '01si0000000I7SxAAK',
                    Prioridade__c = 'NORMAL',
                    Entrega_liberada_pelo_financeiro__c = 'NÃO',
                    ShippingCity = account.ShippingCity,
                    ShippingStreet = account.ShippingStreet,
                    ShippingPostalCode = account.ShippingPostalCode,
                    Telefone_Contato__c = ctr.Assinante__r.MobilePhone,
                    Pedido_da_Linha_de_OPME__c = 'NÃO',
                    Vendedor__c = ctr.OwnerId
                );
                ordersToCreate.add(newOrder);
            }

            // Inserir pedidos para obter IDs
            insert ordersToCreate;

            Integer index = 1;
            for (Order order : ordersToCreate) {
                for (Insumo_do_contrato__c product : products) {
                    Id pricebookEntryId = productToPricebookEntryIdMap.get(product.Produto__c);

                    // Adicionar logs de depuração para verificar se a entrada foi encontrada
                    if (pricebookEntryId == null) {
                        System.debug('PricebookEntry não encontrada para Product2Id: ' + product.Produto__c);
                    } else {
                        System.debug('Found PricebookEntryId: ' + pricebookEntryId);
                    }

                    OrderItem newOrderItem = new OrderItem(
                        PricebookEntryId = pricebookEntryId,
                        Quantity = product.Quantidade__c,
                        UnitPrice = product.Valor_unitario__c,
                        OrderId = order.Id,
                        Product2Id = product.Produto__c,
                        Item__c = index,
                        Status__c = 'Novo'
                    );
                    orderItemsToCreate.add(newOrderItem);
                    index++;
                }
            }
        }
    }

    // Inserir itens de pedido
    insert orderItemsToCreate;
}