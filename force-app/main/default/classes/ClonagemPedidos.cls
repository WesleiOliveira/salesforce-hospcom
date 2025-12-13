public class ClonagemPedidos {
    
    public static void clonaPedido(Id pedidoId, String dataFinalFluxo, String origem){

        Map<Integer, List<String>> feriadosMoveis = new Map<Integer, List<String>>();     

        Order pedidoOriginal = [
            SELECT  Id, 
                    AccountId,
                    BillingCity,
                    BillingCountry,
                    BillingCountryCode,
                    BillingPostalCode,
                    BillingState,
                    BillingStateCode,
                    BillingStreet,
					Condicao_de_pagamento__c,
                    Comentarios__c,
                    Contrato__c,
                    CurrencyIsoCode,
                    Data_de_Entrega2__c,
                    Data_de_Vencimento__c,
                    Departamento3__c,
                    E_mail_Contato__c,
                    EffectiveDate,
					Entrega_liberada_pelo_financeiro__c,
                    Entrega_parcial__c,
                    Faturamento_Feito__c,
                    Forma_de_pagamento2__c,
                    Frete__c,
                    Ignora_validacao__c,
                    Motivo__c,
                    Natureza_de_Opera_o__c,
                    Necess_rio_Treinamento__c,
                    Nome_Contato_Financeiro__c,
                    Observacoes_Gerais__c,
                    Pedido_da_Linha_de_OPME__c,
                    Per_odo_do_contrato_Fim__c,
                    Periodo_do_contrato_inicio__c,
                    Prazo_de_entrega__c,
                    Pricebook2Id,
                    Prioridade__c,
                    RecordTypeId,
                    RegionalServico__c,
                    ShippingCity,
                    ShippingCountry,
                    ShippingCountryCode,
                    ShippingPostalCode,
                    ShippingState,
                    ShippingStateCode,
                    ShippingStreet,
                    Telefone_Contato__c,
                    Tipo_da_Compra__c,
                    Unidade_Hospitalar__c,
                    Valor_de_entrada__c,
                    Vendedor__c,
                    Contrato_de_Servi_o__c,
                    Locado_em__c
            FROM Order
            WHERE Id = :pedidoId
            LIMIT 1
        ];
        List<String> partes = dataFinalFluxo.split('/');
        Integer diaFinal = Integer.valueOf(partes[0]);
        Integer mesFinal = Integer.valueOf(partes[1]);
        Integer anoFinal = Integer.valueOf(partes[2]);
        Date dataFinalFluxoConvertido = Date.newInstance(anoFinal, mesFinal, diaFinal);
        Integer anoReferenciaFeriadoMovel = pedidoOriginal.EffectiveDate.year();
        while(anoReferenciaFeriadoMovel <= anoFinal) {
                List<String> feriadosAno = new List<String>();
                Integer a = Math.mod(anoReferenciaFeriadoMovel, 19);
                Integer b = Integer.valueOf(Math.floor(anoReferenciaFeriadoMovel / 100));
                Integer c = Math.mod(anoReferenciaFeriadoMovel, 100);
                Integer d = Integer.valueOf(Math.floor(b / 4));
                Integer e = Math.mod(b, 4);
                Integer f = Integer.valueOf(Math.floor((b + 8) / 25));
                Integer g = Integer.valueOf(Math.floor((b - f + 1) / 3));
                Integer h = Math.mod(19 * a + b - d - g + 15, 30);
                Integer i = Integer.valueOf(Math.floor(c / 4));
                Integer k = Math.mod(c, 4);
                Integer l = Math.mod(32 + 2 * e + 2 * i - h - k, 7);
                Integer m = Integer.valueOf(Math.floor((a + 11 * h + 22 * l) / 451));
                Integer mes = Integer.valueOf(Math.floor((h + l - 7 * m + 114) / 31));
                Integer dia = Math.mod(h + l - 7 * m + 114, 31) + 1;

                Date pascoa = Date.newInstance(anoReferenciaFeriadoMovel, mes, dia);
                String dataPascoa = (pascoa.day() < 10 ? '0' : '') + pascoa.day() + '/' + (pascoa.month() < 10 ? '0' : '') + pascoa.month();
                feriadosAno.add(dataPascoa);
                Date sextaFeiraSanta = pascoa.addDays(-2);
                String dataSextaFeiraSanta = (sextaFeiraSanta.day() < 10 ? '0' : '') + sextaFeiraSanta.day() + '/' + (sextaFeiraSanta.month() < 10 ? '0' : '') + sextaFeiraSanta.month();
                feriadosAno.add(dataSextaFeiraSanta);
                Date carnavalTerca = pascoa.addDays(-47);
                String dataCarnavalTerca = (carnavalTerca.day() < 10 ? '0' : '') + carnavalTerca.day() + '/' + (carnavalTerca.month() < 10 ? '0' : '') + carnavalTerca.month();
                feriadosAno.add(dataCarnavalTerca);
                Date carnavalSegunda = pascoa.addDays(-48);
                String dataCarnavalSegunda = (carnavalSegunda.day() < 10 ? '0' : '') + carnavalSegunda.day() + '/' + (carnavalSegunda.month() < 10 ? '0' : '') + carnavalSegunda.month();
                feriadosAno.add(dataCarnavalSegunda);              
                Date CorpusChristi = pascoa.addDays(60);
                String dataCorpusChristi = (CorpusChristi.day() < 10 ? '0' : '') + CorpusChristi.day() + '/' + (CorpusChristi.month() < 10 ? '0' : '') + CorpusChristi.month();
                feriadosAno.add(dataCorpusChristi);
                feriadosMoveis.put(anoReferenciaFeriadoMovel, feriadosAno);
                anoReferenciaFeriadoMovel++;
        }

        Date dataReferencia = pedidoOriginal.Periodo_do_contrato_inicio__c;
        String textoReferencia = pedidoOriginal.Observacoes_Gerais__c;
        Integer diaReferencia = pedidoOriginal.Periodo_do_contrato_inicio__c.day();
        List<String> listaFeriadosMoveis = feriadosMoveis.get(dataReferencia.year());
        Integer contador = 0;
        List<Order> novosPedidos = new List<Order>();

        while (true) {
            Date proximaData = dataReferencia.addMonths(contador + 1);
            if (proximaData > dataFinalFluxoConvertido) break;

            String texto = textoReferencia;
            Pattern p = Pattern.compile('PER[IÍ]ODO:\\s*(\\d{2}/\\d{2}/\\d{4})\\s*À\\s*(\\d{2}/\\d{2}/\\d{4})');
            Matcher m = p.matcher(texto);

            if (m.find()) {
                String dataInicialStr = m.group(1);
                String dataFinalStr = m.group(2);
                List<String> partes1 = dataInicialStr.split('/');
                List<String> partes2 = dataFinalStr.split('/');
                Date dataInicial;
                Date dataFinal;
                if(origem == 'Hapvida'){
                    dataInicial = Date.newInstance(Integer.valueOf(partes1[2]), Integer.valueOf(partes1[1]), Integer.valueOf(partes1[0]));
                    dataFinal = Date.newInstance(Integer.valueOf(partes2[2]), Integer.valueOf(partes2[1]), Integer.valueOf(partes2[0]));
                }else{
                    dataInicial = Date.newInstance(Integer.valueOf(partes1[2]), Integer.valueOf(partes1[1]), diaReferencia);
                    dataFinal = Date.newInstance(Integer.valueOf(partes2[2]), Integer.valueOf(partes2[1]), diaReferencia);
                }
                Date novaDataInicial = dataInicial.addMonths(1);
                Date novaDataFinal = dataFinal.addMonths(1);
                Date dataUtilInicial = novaDataInicial;
                Date dataUtilFinal = novaDataFinal;
                dataUtilFinal.addMonths(1);
                String novaDataInicialStr = (dataUtilInicial.day() < 10 ? '0' : '') + dataUtilInicial.day() + '/' + (dataUtilInicial.month() < 10 ? '0' : '') + dataUtilInicial.month() + '/' + dataUtilInicial.year();
                String novaDataFinalStr = (dataUtilFinal.day() < 10 ? '0' : '') + dataUtilFinal.day() + '/' + (dataUtilFinal.month() < 10 ? '0' : '') + dataUtilFinal.month() + '/' + dataUtilFinal.year();
                texto = texto.replace(dataFinalStr, novaDataFinalStr);
                texto = texto.replace(dataInicialStr, novaDataInicialStr);
                
                textoReferencia = texto;
            } 

            Order novo = pedidoOriginal.clone(false, true, false, false);
            novo.Status = 'Rascunho';
            novo.Observacoes_Gerais__c = textoReferencia;
            novo.ignora_validacao__c = true;
            novo.Chave_de_Clone__c = pedidoOriginal.Id;
            
            if (pedidoOriginal.EffectiveDate != null)
                novo.EffectiveDate = ajustarParaDiaUtil(pedidoOriginal.EffectiveDate.addMonths(contador + 1), listaFeriadosMoveis);
            if (pedidoOriginal.Periodo_do_contrato_inicio__c != null)
                novo.Periodo_do_contrato_inicio__c = pedidoOriginal.Periodo_do_contrato_inicio__c.addMonths(contador + 1);
            if (pedidoOriginal.Per_odo_do_contrato_Fim__c != null)
                novo.Per_odo_do_contrato_Fim__c = pedidoOriginal.Per_odo_do_contrato_Fim__c.addMonths(contador + 1);
            if (pedidoOriginal.Data_de_Entrega2__c != null)
                novo.Data_de_Entrega2__c = ajustarParaDiaUtil(pedidoOriginal.Data_de_Entrega2__c.addMonths(contador + 1), listaFeriadosMoveis);
            
            if(pedidoOriginal.Prazo_de_entrega__c != null)
                novo.Prazo_de_entrega__c = ajustarParaDiaUtil(pedidoOriginal.Prazo_de_entrega__c.addMonths(contador + 1), listaFeriadosMoveis);
            if (origem == 'Hapvida'){
                if(pedidoOriginal.prazo_de_entrega__c != null)
                    novo.Data_de_Vencimento__c =  novo.prazo_de_entrega__c.addDays(30);
            }else{
                if (pedidoOriginal.Data_de_Vencimento__c != null)
                    novo.Data_de_Vencimento__c = ajustarParaDiaUtil(pedidoOriginal.Data_de_Vencimento__c.addMonths(contador + 1), listaFeriadosMoveis); 
            }
                

            novosPedidos.add(novo);
            contador++;
        }
        if(!novosPedidos.isEmpty()){
            insert novosPedidos;
        }
    }

    public static Date ajustarParaDiaUtil(Date data, List<String> feriadosRotativos) {
            List<String> feriados = new List<String>{
            '01/01',
            '21/04',
            '01/05',
            '07/09',
            '12/10',
            '02/11',
            '15/11',
            '25/12'  
            };

            while (
                data != null && (
                    DateTime.newInstance(data, Time.newInstance(0, 0, 0, 0)).format('u') == '6' || // sábado
                    DateTime.newInstance(data, Time.newInstance(0, 0, 0, 0)).format('u') == '7' || // domingo
                    feriados.contains(String.valueOf(data.day()) + '/' + String.valueOf(data.month())) ||
                    feriadosRotativos.contains(String.valueOf(data.day()) + '/' + String.valueOf(data.month()))
                )
            ) {
                data = data.addDays(1);
            }
        return data;
    }

    public static void clonaItemPedido(Id pedidoOriginalId){
        //Script para clonagem de Produtos de Pedidos
        //Adicionar Pedido orignal para que seus OrderItems sejam clonados  
        System.debug('=== INÍCIO: Clonagem de OrderItems para o pedido original: ' + pedidoOriginalId);

        // Buscar o pedido original com seu Pricebook e moeda
        Order pedidoOriginal = [
            SELECT Id, Pricebook2Id, CurrencyIsoCode
            FROM Order 
            WHERE Id = :pedidoOriginalId
        ];
        System.debug('Pedido original encontrado: ' + pedidoOriginal);

        // Buscar todos os pedidos clones relacionados
        List<Order> pedidosClones = [
            SELECT Id, OrderNumber, Pricebook2Id, CurrencyIsoCode, EffectiveDate, RecordType.Name 
            FROM Order 
            WHERE Chave_de_clone__c = :pedidoOriginalId
        ];
        System.debug('Total de pedidos clones encontrados: ' + pedidosClones.size());

        // Atualizar Pricebook2Id dos clones, se diferente do original
        List<Order> pedidosParaAtualizar = new List<Order>();
        Set<Id> pricebookIds = new Set<Id>();
        for (Order pedido : pedidosClones) {
            if (pedido.Pricebook2Id != pedidoOriginal.Pricebook2Id) {
                System.debug('Atualizando Pricebook2Id do pedido clone: ' + pedido.OrderNumber);
                pedido.Pricebook2Id = pedidoOriginal.Pricebook2Id;
                pedidosParaAtualizar.add(pedido);
            }
            if (pedido.Pricebook2Id != null) {
                pricebookIds.add(pedido.Pricebook2Id);
            }
        }

        // Atualiza os pedidos clones se necessário
        if (!pedidosParaAtualizar.isEmpty()) {
            update pedidosParaAtualizar;
            System.debug('Pedidos clones atualizados: ' + pedidosParaAtualizar.size());
        }

        // Buscar os OrderItems do pedido original
        List<OrderItem> itensOriginais = [
            SELECT Id, Product2Id, Quantity, UnitPrice
            FROM OrderItem
            WHERE OrderId = :pedidoOriginalId
        ];
        System.debug('Itens do pedido original encontrados: ' + itensOriginais.size());

        if (itensOriginais.isEmpty()) {
            System.assert(false, 'O pedido original não possui itens para clonar.');
        }

        // Coleta os IDs de produtos usados nos itens originais
        Set<Id> produtoIds = new Set<Id>();
        for (OrderItem item : itensOriginais) {
            produtoIds.add(item.Product2Id);
        }

        // Buscar PricebookEntry válidos para os produtos em todos os Pricebooks usados
        List<PricebookEntry> entradas = [
            SELECT Id, Pricebook2Id, Product2Id, IsActive, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Product2Id IN :produtoIds
            AND Pricebook2Id IN :pricebookIds
            AND IsActive = true
        ];
        System.debug('Total de PricebookEntry ativos encontrados: ' + entradas.size());

        // Organiza os PricebookEntries em um Map de acesso rápido
        Map<Id, Map<Id, List<PricebookEntry>>> entriesPorPBPorProduto = new Map<Id, Map<Id, List<PricebookEntry>>>();
        for (PricebookEntry entry : entradas) {
            if (!entriesPorPBPorProduto.containsKey(entry.Pricebook2Id)) {
                entriesPorPBPorProduto.put(entry.Pricebook2Id, new Map<Id, List<PricebookEntry>>());
            }
            Map<Id, List<PricebookEntry>> produtosPorPricebook = entriesPorPBPorProduto.get(entry.Pricebook2Id);
            if (!produtosPorPricebook.containsKey(entry.Product2Id)) {
                produtosPorPricebook.put(entry.Product2Id, new List<PricebookEntry>());
            }
            produtosPorPricebook.get(entry.Product2Id).add(entry);
        }

        // Lista final de novos OrderItems a serem criados
        List<OrderItem> novosItens = new List<OrderItem>();

        // Para cada pedido clone, clonar os itens do pedido original
        for (Order clone : pedidosClones) {
            System.debug('Processando pedido clone: ' + clone.OrderNumber);

            for (OrderItem itemOriginal : itensOriginais) {
                List<PricebookEntry> possiveisEntries = entriesPorPBPorProduto
                    .get(clone.Pricebook2Id)
                    ?.get(itemOriginal.Product2Id);

                if (possiveisEntries == null) {
                    System.debug('→ Pedido ' + clone.OrderNumber + ' sem PricebookEntry para produto ' + itemOriginal.Product2Id);
                    continue;
                }

                // Busca entrada com moeda compatível
                PricebookEntry entryCompat = null;
                for (PricebookEntry pe : possiveisEntries) {
                    if (pe.CurrencyIsoCode == clone.CurrencyIsoCode) {
                        entryCompat = pe;
                        break;
                    }
                }

                if (entryCompat == null) {
                    System.debug('→ Pedido ' + clone.OrderNumber + ' não tem PricebookEntry com moeda compatível para produto ' + itemOriginal.Product2Id);
                    continue;
                }

                // Cria novo OrderItem com os dados clonados
                OrderItem novoItem = new OrderItem();
                novoItem.OrderId = clone.Id;
                novoItem.PricebookEntryId = entryCompat.Id;
                novoItem.Quantity = itemOriginal.Quantity;
                novoItem.UnitPrice = itemOriginal.UnitPrice;
                novosItens.add(novoItem);

                System.debug('Novo item preparado para o pedido ' + clone.OrderNumber + ' | Produto: ' + itemOriginal.Product2Id);
            }
        }

        // Inserção final dos OrderItems clonados
        if (!novosItens.isEmpty()) {
            try {
                insert novosItens;
                System.debug(' Sucesso! Total de OrderItems inseridos: ' + novosItens.size());
            } catch (Exception e) {
                System.debug(' Erro ao inserir OrderItems: ' + e.getMessage());
                system.assert(false, 'Erro ao inserir OrderItems: ' + e.getMessage());
            }
        } else {
            System.debug(' Nenhum OrderItem foi preparado para inserção.');
        }

        System.debug('=== FIM da execução do método clonarOrderItems ===');
    }
}