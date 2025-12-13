trigger criaPedidos on Contrato_de_servi_o__c (after update) {
    System.debug('Trigger iniciada - criaPedidos');
    List<Order> ordersToInsert = new List<Order>();
    List<OrderItem> orderItemsToInsert = new List<OrderItem>();
    Set<String> productCodesToQuery = new Set<String>();
    Map<String, String> produtoNomeMap = new Map<String, String>();
        string emails = '';    
        string result = 'a';
        string result1 = 'a';
        string result2 = 'a';
        string result3 = 'a';
        string result4 = 'a';
        string result5 = 'a';
        string result6 = 'a';
        string result7 = 'a';
        string result8 = 'a';
        string result9 = 'a';
        string result10 = 'a';
        string result11 = 'a';
        string result12 = 'a';
        string result13 = 'a';
        string result14 = 'a';
        string result15 = 'a';
        string result16 = 'a';
        string result17 = 'a';
        string result18 = 'a';
        string result19 = 'a';
        string result20 = 'a';
        string result21 = 'a';
        string result22 = 'a';
        string result23 = 'a';
        string result24 = 'a';
        string result25 = 'a';
        string result26 = 'a';
        string result27 = 'a';
        string result28 = 'a';
        string result29 = 'a';
    
    // Mapa para armazenar quantidades e valores por código do produto
    Map<String, Decimal> produtoQuantidadeMap = new Map<String, Decimal>();
    Map<String, Decimal> produtoValorTotalMap = new Map<String, Decimal>();
    
    System.debug('Total de contratos processados: ' + Trigger.new.size());
    
    for (Contrato_de_servi_o__c contrato : Trigger.new) {
        System.debug('Processando contrato ID: ' + contrato.Id);
        System.debug('Status atual: ' + contrato.Status_do_Contrato__c);
        System.debug('CurrencyIsoCode do contrato: ' + contrato.CurrencyIsoCode);
        
        Contrato_de_servi_o__c oldContrato = Trigger.oldMap.get(contrato.Id);
        System.debug('Status anterior: ' + (oldContrato != null ? oldContrato.Status_do_Contrato__c : 'null'));
        
        // Verifica se o status mudou para "CONTRATO VIGENTE"
        if (contrato.Status_do_Contrato__c == 'CONTRATO VIGENTE' && oldContrato.Status_do_Contrato__c != 'CONTRATO VIGENTE' && contrato.Id != 'a1YU4000000qY7FMAU') {
            System.debug('Contrato mudou para CONTRATO VIGENTE - processando...');
            
            String numeroStr = contrato.Condicao_de_pagamento__c.split(' ')[0];
            Integer numero; 
            
            if(contrato.Condicao_de_pagamento__c == 'À Vista'){
                numero = 0;          
            }
            else{
                numero = Integer.valueOf(numeroStr);            
            }
            System.debug('Número de dias para vencimento: ' + numero);
            
            Contact contato = [SELECT ID, FirstName, Email, MobilePhone, Phone FROM Contact WHERE ID = :contrato.Contato_do_Locat_rio__c];
            Account locatario = [SELECT ID, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                                ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, 
                                CurrencyIsoCode 
                                FROM Account WHERE ID = :contrato.Locat_rio_a__c];
            
            System.debug('CurrencyIsoCode da conta locatário: ' + locatario.CurrencyIsoCode);
            
            emails = contrato.Emails_para_faturamento__c;
            System.debug('Emails para faturamento: ' + emails);
            
            // Data inicial como hoje
            Date initialDate = Date.today();
            String telefone;
            if (contato.MobilePhone != null && contato.MobilePhone != '') {
                telefone = contato.MobilePhone;
            } else {
                telefone = contato.Phone;
            }
            System.debug('Telefone do contato: ' + telefone);
            
            // Consulta ao objeto Ativos_do_Contrato__c para agrupar as quantidades e valores por código do produto
            List<Ativos_do_Contrato__c> ativosDoContrato = [
                SELECT Ativo_Locado__r.Product2.ProductCode, Ativo_Locado__r.Product2.Name, 
                Valor_Total_Mensal__c, Valor_Unitario_Mensal__c,
                Quantidade__c, CurrencyIsoCode
                FROM Ativos_do_Contrato__c 
                WHERE Contrato_de_Servico__c = :contrato.Id AND Equipamento_no_cliente__c = true
            ];
            
            System.debug('Total de ativos do contrato encontrados: ' + ativosDoContrato.size());
            
            for (Ativos_do_Contrato__c ativo : ativosDoContrato) {
                System.debug('Processa  ndo ativo ID: ' + ativo.Id);
                System.debug('CurrencyIsoCode do ativo: ' + ativo.CurrencyIsoCode);
                
                String productCode = ativo.Ativo_Locado__r.Product2.ProductCode + 'LOCACAO';
                productCodesToQuery.add(productCode);
                produtoNomeMap.put(productCode, ativo.Ativo_Locado__r.Product2.Name);
                
                System.debug('Product Code: ' + productCode);
                System.debug('Product Name: ' + ativo.Ativo_Locado__r.Product2.Name);
                System.debug('Quantidade: ' + ativo.Quantidade__c);
                System.debug('Valor Total Mensal: ' + ativo.Valor_Total_Mensal__c);
                
                if (produtoQuantidadeMap.containsKey(productCode)) {
                    produtoQuantidadeMap.put(productCode, produtoQuantidadeMap.get(productCode) + ativo.Quantidade__c);
                    produtoValorTotalMap.put(productCode, produtoValorTotalMap.get(productCode) + ativo.Valor_Total_Mensal__c);
                } else {
                    produtoQuantidadeMap.put(productCode, ativo.Quantidade__c);
                    produtoValorTotalMap.put(productCode, ativo.Valor_Total_Mensal__c);
                }
            }
            
            System.debug('Total de produtos distintos: ' + produtoQuantidadeMap.size());
            System.debug('Produtos e quantidades: ' + produtoQuantidadeMap);
            System.debug('Produtos e valores totais: ' + produtoValorTotalMap);
           
            // Cria um pedido para cada mês de vigência do contrato
            for (Integer i = 0; i < contrato.Dura_o_do_Contrato_meses__c; i++) {
                Order order = new Order(
                    AccountId = contrato.Locat_rio_a__c,
                    Contrato_de_Servi_o__c = contrato.Id,
                    EffectiveDate = initialDate.addMonths(i),
                    Prazo_de_Entrega__c = contrato.Primeiro_faturamento__c.addMonths(i),
                    Periodo_do_contrato_inicio__c = contrato.Primeiro_faturamento__c.addMonths(i),
                    Per_odo_do_contrato_Fim__c = (contrato.Primeiro_faturamento__c.addMonths(i)).addMonths(1), 
                    Status = 'Rascunho',
                    Data_de_vencimento__c = (contrato.Primeiro_faturamento__c.addMonths(i)).addDays(numero),                    
                    BillingCity = locatario.BillingCity,
                    BillingCountry = locatario.BillingCountry,
                    BillingPostalCode = locatario.BillingPostalCode,
                    BillingState = locatario.BillingState,
                    BillingStreet = locatario.BillingStreet,
                    Comentarios__c = 'Pedido criado automaticamente a partir da aprovação do contrato.',
                    Condicao_de_pagamento__c = contrato.Condicao_de_pagamento__c,
                    Departamento3__c = 'Locação',
                    E_mail_Contato__c = contato.Email,
                    Entrega_parcial__c = 'Não Autorizada',
                    Faturamento_Feito__c = contrato.Locador_a__c,
                    Forma_de_pagamento2__c = contrato.Forma_de_pagamento2__c,
                    Frete__c = contrato.Tipo_de_Entrega__c,
                    Ignora_validacao__c = true,
                    Locado_em__c = '-',
                    Natureza_de_Opera_o__c = 'LOCAÇÃO',
                    Necess_rio_Treinamento__c = 'NÃO',
                    Nome_Contato_Financeiro__c = contato.FirstName,
                    Pricebook2Id = '01s5A000004fbcR',
                    ShippingCity = locatario.ShippingCity,
                    ShippingCountry = locatario.ShippingCountry,
                    ShippingPostalCode = locatario.ShippingPostalCode,
                    ShippingState = locatario.ShippingState,
                    ShippingStreet = locatario.ShippingStreet,
                    Telefone_Contato__c = telefone,
                    Unidade_Hospitalar__c = contrato.Unidade_Hospitalar__c,
                    Vendedor__c = contrato.Vendedor_do_Contrato__c,
                    Prioridade__c = 'NORMAL',
                    Entrega_liberada_pelo_financeiro__c = 'NÃO',
                    Pedido_da_Linha_de_OPME__c = 'NÃO',
                    CurrencyIsoCode = contrato.CurrencyIsoCode
                );
                System.debug('Order criado para o mês ' + (i+1) + ': ' + order);
                ordersToInsert.add(order);
            }
            System.debug('Contract Currency: ' + contrato.CurrencyIsoCode);
System.debug('Account Currency: ' + locatario.CurrencyIsoCode);
               if(contrato.CurrencyIsoCode != locatario.CurrencyIsoCode) {
    System.debug('Warning: Contract and Account currencies differaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    // Add your error handling logic here if needed
}
        }
    }
    
    // Insere os pedidos
    if (!ordersToInsert.isEmpty()) {
        System.debug('Total de pedidos a serem inseridos: ' + ordersToInsert.size());
        System.debug('CurrencyIsoCode dos pedidos:');
        for (Order o : ordersToInsert) {
            System.debug('Pedido ID (antes da inserção): ' + o.Id + ' - CurrencyIsoCode: ' + o.CurrencyIsoCode);
        }
     
        
        insert ordersToInsert;
        for(Order o : [SELECT Id, CurrencyIsoCode FROM Order WHERE Id IN :ordersToInsert]) {
            System.debug('Order '+o.Id+' has currency: '+o.CurrencyIsoCode);
        }
        
        
        System.debug('Pedidos inseridos com sucesso. IDs gerados:');
        for (Order o : ordersToInsert) {
            System.debug('Pedido ID: ' + o.Id + ' - CurrencyIsoCode: ' + o.CurrencyIsoCode);
        }
        
        // Consulta os PricebookEntries para os códigos de produtos coletados
        Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
        List<PricebookEntry> pricebookEntries = [
                SELECT Id, Product2Id, Product2.ProductCode, CurrencyIsoCode, UnitPrice 
                FROM PricebookEntry 
                WHERE Product2.ProductCode IN :productCodesToQuery 
                    AND Pricebook2ID = '01s5A000004fbcR'
        ];
        
        System.debug('Total de PricebookEntries encontrados: ' + pricebookEntries.size());
        for (PricebookEntry pbe : pricebookEntries) {
            pricebookEntryMap.put(pbe.Product2.ProductCode, pbe);
            System.debug('PricebookEntry: ' + pbe.Id + ' - ProductCode: ' + pbe.Product2.ProductCode + ' - CurrencyIsoCode: ' + pbe.CurrencyIsoCode);
        }
        
        // Cria os itens de pedido para cada pedido criado com base nas quantidades e valores agrupados
        for (Order order : ordersToInsert) {
            System.debug('Processando itens para o pedido ID: ' + order.Id);
            Integer index = 1;
            for (String productCode : produtoQuantidadeMap.keySet()) {
                PricebookEntry pbe = pricebookEntryMap.get(productCode);
                
                if (pbe != null) {
                    OrderItem orderItem = new OrderItem(
                        
                        OrderId = order.Id,
                        Product2Id = pbe.Product2Id,
                        Quantity = produtoQuantidadeMap.get(productCode),
                        UnitPrice = produtoValorTotalMap.get(productCode) / produtoQuantidadeMap.get(productCode),
                        Item__c = index,
                        Status__c = 'Novo',
                        PricebookEntryId = pbe.Id
                      
                    );
                    System.debug('OrderItem criado (com PBE): ' + orderItem);
                    orderItemsToInsert.add(orderItem);
                    index++;
                } else {
                    // Insere um item de pedido padrão se o PricebookEntry não for encontrado
                    OrderItem orderItem = new OrderItem(
                        OrderId = order.Id,
                        Product2Id = '01t6e000009ZTsV',
                        Quantity = produtoQuantidadeMap.get(productCode),
                        UnitPrice = produtoValorTotalMap.get(productCode) / produtoQuantidadeMap.get(productCode),
                        Item__c = index,
                        Status__c = 'Novo',                        
                        PricebookEntryId = '01u6e000019dnXM'
                                         
                    );
                    System.debug('OrderItem criado (sem PBE, usando padrão): ' + orderItem);
                    orderItemsToInsert.add(orderItem);
                    index++;
                }
            }           
            String observacoes = 'REFERENTE A LOCAÇÃO DE ';
            for (String productCode : produtoQuantidadeMap.keySet()) {
                observacoes += produtoQuantidadeMap.get(productCode) + ' ' + produtoNomeMap.get(productCode) + '\n';
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
            System.debug('Observações gerais atualizadas para o pedido ID: ' + order.Id);
        }
        
        // Insere os itens de pedido
        if (!orderItemsToInsert.isEmpty()) {
            System.debug('Total de itens de pedido a serem inseridos: ' + orderItemsToInsert.size());
            System.debug('CurrencyIsoCode dos itens de pedido:');
            for (OrderItem oi : orderItemsToInsert) {
                System.debug('OrderItem para o pedido ' + oi.OrderId + ' - CurrencyIsoCode: ' + oi.CurrencyIsoCode);
            }
            
            
            insert orderItemsToInsert;
            
            
            System.debug('Itens de pedido inseridos com sucesso');
            
            update ordersToInsert;
            System.debug('Pedidos atualizados com observações');

    } else {
        System.debug('Nenhum pedido para inserir');
    }
    System.debug('Trigger concluída');
}
}