trigger criaPedidosAditivo on Aditivos_Contratuais__c (after update) {
    List<Order> ordersToInsert = new List<Order>();
    List<OrderItem> orderItemsToInsert = new List<OrderItem>();
    Map<String, Decimal> productCodeToQuantidade = new Map<String, Decimal>();
    Map<String, Decimal> productCodeToValor = new Map<String, Decimal>();
    Set<String> productCodesToQuery = new Set<String>();
    Set<Id> contratoIds = new Set<Id>();
    Map<String, String> produtoNomeMap = new Map<String, String>();
    String codigoIso;
    string emails = '';
    
    // Coleta os IDs dos contratos para consulta
    for (Aditivos_Contratuais__c contrato : Trigger.new) {
        Aditivos_Contratuais__c oldContrato = Trigger.oldMap.get(contrato.Id);
        
        if (contrato.Status__c == 'Aprovado' && oldContrato.Status__c != 'Aprovado') {
            contratoIds.add(contrato.Contrato_de_Servi_o_Relacionado__c);
        }
    }
    
    // Consulta os contratos e os dados relacionados
    Map<Id, Contrato_de_Servi_o__c> contratosMap = new Map<Id, Contrato_de_Servi_o__c>();
    if (!contratoIds.isEmpty()) {
        contratosMap = new Map<Id, Contrato_de_Servi_o__c>(
            [SELECT Id, Locat_rio_a__c, Locat_rio_a__r.BillingCity, Locat_rio_a__r.BillingCountry, 
             Locat_rio_a__r.BillingPostalCode, Locat_rio_a__r.BillingState, Locat_rio_a__r.BillingStreet,
             Locat_rio_a__r.ShippingCity, Locat_rio_a__r.ShippingCountry, Locat_rio_a__r.ShippingPostalCode,
             Locat_rio_a__r.ShippingState, Locat_rio_a__r.ShippingStreet, Unidade_Hospitalar__c, Condicao_de_pagamento__c,
             Vendedor_do_Contrato__c, Locador_a__c, Contato_do_Locat_rio__r.Id, Contato_do_Locat_rio__r.FirstName, Tipo_de_Entrega__c,
             Contato_do_Locat_rio__r.Email, Contato_do_Locat_rio__r.MobilePhone, Contato_do_Locat_rio__r.Phone, Forma_de_pagamento2__c, Emails_para_faturamento__c,CurrencyIsoCode
             FROM Contrato_de_Servi_o__c 
             WHERE Id IN :contratoIds]
        );
    }
    
    // Itera pelos contratos para criar pedidos e itens de pedido
    for (Aditivos_Contratuais__c contrato : Trigger.new) {
        Aditivos_Contratuais__c oldContrato = Trigger.oldMap.get(contrato.Id);
        
        if (contrato.Status__c == 'Aprovado' && oldContrato.Status__c != 'Aprovado') {
            Contrato_de_Servi_o__c contratoRel = contratosMap.get(contrato.Contrato_de_Servi_o_Relacionado__c);
            Contact contato = contratoRel.Contato_do_Locat_rio__r;
            emails = contratoRel.Emails_para_faturamento__c;
            
            // Data inicial como hoje
            Date initialDate = contrato.Inicio_da_vigencia__c;
            String telefone = (contato.MobilePhone != null && contato.MobilePhone != '') ? contato.MobilePhone : contato.Phone;
            
            // Consulta ao objeto Ativos_do_Contrato__c para agrupar as quantidades e valores por código do produto
            List<Ativos_do_Contrato__c> ativosDoContrato = [
                SELECT Ativo_Locado__r.Product2.ProductCode, Ativo_Locado__r.Product2.Name,
                Valor_Total_Mensal__c, Valor_Unitario_Mensal__c, 
                Quantidade__c
                FROM Ativos_do_Contrato__c
                WHERE Contrato_de_Servico__c = :contrato.Contrato_de_Servi_o_Relacionado__c
                AND Equipamento_no_cliente__c = true
            ];
            
            for (Ativos_do_Contrato__c ativo : ativosDoContrato) {
                String key = ativo.Ativo_Locado__r.Product2.ProductCode;
                produtoNomeMap.put(key, ativo.Ativo_Locado__r.Product2.Name);
                
                if (productCodeToQuantidade.containsKey(key)) {
                    productCodeToQuantidade.put(key, productCodeToQuantidade.get(key) + ativo.Quantidade__c);
                } else {
                    productCodeToQuantidade.put(key, ativo.Quantidade__c);
                    productCodeToValor.put(key, ativo.Valor_Unitario_Mensal__c);
                }
                productCodesToQuery.add(key + 'LOCACAO');
            }
            
            // Cria um pedido para cada mês de vigência do contrato
            for (Integer i = 0; i < contrato.Duracao_adicional_meses__c; i++) {
                Order order = new Order(
                    AccountId = contratoRel.Locat_rio_a__c,
                    Contrato_de_Servi_o__c = contrato.Contrato_de_Servi_o_Relacionado__c,
                    EffectiveDate = initialDate.addMonths(i),
                    Prazo_de_Entrega__c = initialDate.addMonths(i),
                    Periodo_do_contrato_inicio__c = initialDate.addMonths(i),
                    Per_odo_do_contrato_Fim__c = (initialDate.addMonths(i)).addMonths(1), 
                    Status = 'Rascunho',
                    BillingCity = contratoRel.Locat_rio_a__r.BillingCity,
                    BillingCountry = contratoRel.Locat_rio_a__r.BillingCountry,
                    BillingPostalCode = contratoRel.Locat_rio_a__r.BillingPostalCode,
                    BillingState = contratoRel.Locat_rio_a__r.BillingState,
                    BillingStreet = contratoRel.Locat_rio_a__r.BillingStreet,
                    Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do aditivo do contrato.',
                    Condicao_de_pagamento__c = contratoRel.Condicao_de_pagamento__c,
                    Departamento3__c = 'Locação',
                    E_mail_Contato__c = contato.Email,
                    Entrega_parcial__c = 'Não Autorizada',
                    Faturamento_Feito__c = contratoRel.Locador_a__c,
                    Forma_de_pagamento2__c = contratoRel.Forma_de_pagamento2__c,
                    Frete__c = contratoRel.Tipo_de_Entrega__c,
                    Ignora_validacao__c = true,
                    Locado_em__c = '-',
                    Natureza_de_Opera_o__c = 'LOCAÇÃO',
                    Necess_rio_Treinamento__c = 'NÃO',
                    Nome_Contato_Financeiro__c = contato.FirstName,
                    Pricebook2Id = '01s5A000004fbcR',
                    ShippingCity = contratoRel.Locat_rio_a__r.ShippingCity,
                    ShippingCountry = contratoRel.Locat_rio_a__r.ShippingCountry,
                    ShippingPostalCode = contratoRel.Locat_rio_a__r.ShippingPostalCode,
                    ShippingState = contratoRel.Locat_rio_a__r.ShippingState,
                    ShippingStreet = contratoRel.Locat_rio_a__r.ShippingStreet,
                    Telefone_Contato__c = telefone,
                    Unidade_Hospitalar__c = contratoRel.Unidade_Hospitalar__c,
                    Vendedor__c = contratoRel.Vendedor_do_Contrato__c,
                    Prioridade__c = 'NORMAL',
                    Entrega_liberada_pelo_financeiro__c = 'SIM',
                    Pedido_da_Linha_de_OPME__c = 'NÃO',
                    CurrencyIsoCode = contratoRel.CurrencyIsoCode
                );
                codigoIso = order.CurrencyIsoCode;
                ordersToInsert.add(order);
            }
        }
    }
    
    // Insere os pedidos
    if (!ordersToInsert.isEmpty()) {
        insert ordersToInsert;
        
        // Consulta os PricebookEntries para os códigos de produtos coletados
        Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
        List<PricebookEntry> pricebookEntries = [
            SELECT Id, Product2Id, Product2.ProductCode
            FROM PricebookEntry
            WHERE Product2.ProductCode IN :productCodesToQuery
            AND Pricebook2ID = '01s5A000004fbcR'
            AND CurrencyIsoCode = :codigoIso
        ];
        
        for (PricebookEntry pbe : pricebookEntries) {
            pricebookEntryMap.put(pbe.Product2.ProductCode, pbe); 
        }
        
        // Cria os itens de pedido para cada pedido criado com base nas quantidades e valores agrupados
        for (Order order : ordersToInsert) {
            Integer index = 1;
            for (String key : productCodeToQuantidade.keySet()) {
                String chave = key + 'LOCACAO';
                PricebookEntry pbe = pricebookEntryMap.get(chave);
                
                if (pbe != null) {
                    OrderItem orderItem = new OrderItem(
                        OrderId = order.Id,
                        Product2Id = pbe.Product2Id,
                        Quantity = productCodeToQuantidade.get(key),
                        UnitPrice = productCodeToValor.get(key),
                        Item__c = index,
                        PricebookEntryId = pbe.Id
                    );
                    orderItemsToInsert.add(orderItem);
                    index++;
                } else {
                    OrderItem orderItem = new OrderItem(
                        OrderId = order.Id,
                        Product2Id = '01t6e000009ZTsV',
                        Quantity = productCodeToQuantidade.get(key),
                        UnitPrice = productCodeToValor.get(key),
                        Item__c = index,
                        PricebookEntryId = '01u6e000019dnXM'
                    );
                    orderItemsToInsert.add(orderItem);
                    index++;
                }
            }
            String observacoes = 'REFERENTE A LOCAÇÃO DE ';
            for (String productCode : productCodeToQuantidade.keySet()) {
                observacoes += productCodeToQuantidade.get(productCode) + ' ' + produtoNomeMap.get(productCode) + '\n';
            }
            String formattedDate1 = (order.Periodo_do_contrato_inicio__c.day() < 10 ? '0' + order.Periodo_do_contrato_inicio__c.day() : String.valueOf(order.Periodo_do_contrato_inicio__c.day())) + '/' +
                (order.Periodo_do_contrato_inicio__c.month() < 10 ? '0' + order.Periodo_do_contrato_inicio__c.month() : String.valueOf(order.Periodo_do_contrato_inicio__c.month())) + '/' +
                String.valueOf(order.Periodo_do_contrato_inicio__c.year());
            String formattedDate2 = (order.Per_odo_do_contrato_Fim__c.day() < 10 ? '0' + order.Per_odo_do_contrato_Fim__c.day() : String.valueOf(order.Per_odo_do_contrato_Fim__c.day())) + '/' +
                (order.Per_odo_do_contrato_Fim__c.month() < 10 ? '0' + order.Per_odo_do_contrato_Fim__c.month() : String.valueOf(order.Per_odo_do_contrato_Fim__c.month())) + '/' +
                String.valueOf(order.Per_odo_do_contrato_Fim__c.year());
            
            observacoes += 'PERÍODO: ' + formattedDate1 + ' A ' + formattedDate2 + '\n'
                + 'Empresa: GDB COMÉRCIO E SERVIÇOS \n'
                + 'Banco: BANCO DO BRASIL \n'
                + 'Agência: 1610-1 \n'
                + 'Conta Corrente: 128057-0 \n'
                + 'CNPJ: 23.813.386/0001-56 \n'
                + 'ENVIAR PARA : ' + emails + '\n';
            
            order.Observacoes_Gerais__c = observacoes;
        }
        
        // Insere os itens de pedido
        if (!orderItemsToInsert.isEmpty()) {
            update ordersToInsert;
            insert orderItemsToInsert;
        }
    }
}