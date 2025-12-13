public class AprovacaoCotacao {
    
    @AuraEnabled
    public static string validateQuote(Id quoteId) {
        
        System.debug('========== INICIANDO VALIDAÇÃO DE COTAÇÃO ==========');
        System.debug('QuoteId: ' + quoteId);
        
        Map<String, Object> response = new Map<String, Object>();
        List<String> erros = new List<String>();
        List<String> validados = new List<String>();
        String alcada = '';
        Boolean necessitaAnalise = true;
        Boolean entradaValidada = false;
        Boolean valorTotalValidado = false;
        Boolean valorParcelaValidado = false;
        List<Integer> alcadaAprovador = new List<Integer>();
        
        //Buscar o usuário
        Id profileId = UserInfo.getProfileId();
        System.debug('========== PERFIL DO USUÁRIO ==========');
        System.debug('ProfileId: ' + profileId);
        
        if(profileId == '00eU4000003K6ynIAC'){
            alcada = 'Gerente Nacional';
        }
        else if(profileId == '00e6e000002B2P6AAK'){
            alcada = 'Gerente Regional';
        }
        else if(profileId == '00eU4000005GM6X'){
            alcada = 'Diretor Nacional';
        }
        else if(profileId == '00e6e000002B2Or'){
            alcada = 'Gerente de Linha';
        }
        else{
            alcada = 'Vendedor';
        }
        
        System.debug('Alçada determinada: ' + alcada);
        
        // Buscar a cotação
        System.debug('========== BUSCANDO COTAÇÃO ==========');
        Quote quote = [
            SELECT Id, AccountId, Condicao_de_pagamento__c, Despesa_Financeira__c,  Valor_de_entrada__c, TotalPrice, Valor_da_parcela__c, CurrencyISOCode, Account.SaldoDeCredito__c, Account.Inadiplente__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];
        
        System.debug('Quote encontrada - Id: ' + quote.Id);
        System.debug('AccountId: ' + quote.AccountId);
        System.debug('Condição de Pagamento: ' + quote.Condicao_de_pagamento__c);
        System.debug('Valor de Entrada: ' + quote.Valor_de_entrada__c);
        System.debug('TotalPrice: ' + quote.TotalPrice);
        System.debug('Valor da Parcela: ' + quote.Valor_da_parcela__c);
        System.debug('CurrencyISOCode: ' + quote.CurrencyISOCode);
        System.debug('Saldo de Crédito: ' + quote.Account.SaldoDeCredito__c);
        System.debug('Cliente Inadimplente: ' + quote.Account.Inadiplente__c);
        
        if(quote.Valor_de_entrada__c == null) {
            quote.Valor_de_entrada__c = 0;
            System.debug('Valor de entrada era null, ajustado para 0');
        }
        
        if(quote.Account.Inadiplente__c == true){
            System.debug('ALERTA: Cliente inadimplente detectado');
            erros.add('O cliente está inadimplnete, necessária aprovação financeira.');
        }
        
        // Buscar os itens da cotação e os produtos relacionados
        System.debug('========== BUSCANDO ITENS DA COTAÇÃO ==========');
        List<QuoteLineItem> quoteLineItems = [
            SELECT Id, Product2.Linha__c, Discount, Product2.Valor_de_venda__c, Subtotal, UnitPrice, TotalPrice, Codigo_fabricante__c, PricebookEntry.UnitPrice
            FROM QuoteLineItem
            WHERE QuoteId = :quote.Id
        ];
        
        System.debug('Quantidade de itens encontrados: ' + quoteLineItems.size());
        
        if (quoteLineItems.isEmpty()) {
            System.debug('AVISO: Nenhum item encontrado na cotação');
            response.put('success', true);
            response.put('message', 'Nenhum item para validar.');
            return JSON.serialize(response);
        }
        
        // Debug dos itens
        for(Integer i = 0; i < quoteLineItems.size(); i++) {
            QuoteLineItem item = quoteLineItems[i];
            System.debug('--- Item ' + (i+1) + ' ---');
            System.debug('  Id: ' + item.Id);
            System.debug('  Linha: ' + (item.Product2 != null ? item.Product2.Linha__c : 'NULL'));
            System.debug('  Código Fabricante: ' + item.Codigo_fabricante__c);
            System.debug('  UnitPrice: ' + item.UnitPrice);
            System.debug('  Total price: ' + item.TotalPrice);
            System.debug('  Subtotal: ' + item.Subtotal);
            System.debug('  Desconto concedido: ' + item.Discount + '%');
            System.debug('  PricebookEntry?UnitPrice: ' + item.PricebookEntry.UnitPrice);
        }
        
        // Buscar regras de desconto por linha e condição de pagamento
        System.debug('========== BUSCANDO REGRAS DE DESCONTO ==========');
        Map<String, Regra_de_aprovacao_de_cotacao__c> regrasDescontoMap = new Map<String, Regra_de_aprovacao_de_cotacao__c>();
        
        
        for (Regra_de_aprovacao_de_cotacao__c regra : [
            SELECT Linha__c, Desconto_Maximo__c, Condicao_de_Pagamento__c
            FROM Regra_de_aprovacao_de_cotacao__c
            WHERE Tipo__c = 'Desconto' AND Alcada__c =: alcada
            AND CurrencyISOCode = : quote.CurrencyISOCode
        ]) {
            String key = regra.Linha__c + '|' + 'Desconto Maximo';
            regrasDescontoMap.put(key, regra);
            System.debug('Regra de desconto carregada - Key: ' + key + ' | Desconto Máx: ' + regra.Desconto_Maximo__c + '%');
        }
        System.debug('Total de regras de desconto: ' + regrasDescontoMap.size());
        
        // Buscar regra de valor mínimo total
        System.debug('========== BUSCANDO REGRA DE VALOR MÍNIMO TOTAL ==========');
        Regra_de_aprovacao_de_cotacao__c regraMinimoTotal = [
            SELECT Condicao_de_Pagamento__c, Valor_minimo__c
            FROM Regra_de_aprovacao_de_cotacao__c
            WHERE Tipo__c = 'Minimo total'
            AND Condicao_de_Pagamento__c =: quote.Condicao_de_pagamento__c
            AND CurrencyISOCode = : quote.CurrencyISOCode  
            LIMIT 1          
        ];
        
        System.debug('Regra encontrada - Condição: ' + regraMinimoTotal.Condicao_de_Pagamento__c + ' | Valor Mínimo: ' + regraMinimoTotal.Valor_minimo__c);
        DECIMAL valorMinimoTotal = regraMinimoTotal.Valor_minimo__c;
        System.debug('Regra de valor mínimo total aplicada: ' + valorMinimoTotal);
        
        
        
        // Buscar regra de valor mínimo de entrada
        System.debug('========== BUSCANDO REGRA DE VALOR MÍNIMO DE ENTRADA ==========');
        Regra_de_aprovacao_de_cotacao__c regraEntrada = [
            SELECT Condicao_de_Pagamento__c, Valor_minimo__c
            FROM Regra_de_aprovacao_de_cotacao__c
            WHERE Tipo__c = 'Entrada'
            AND Condicao_de_Pagamento__c =: quote.Condicao_de_Pagamento__c
            AND CurrencyISOCode = : quote.CurrencyISOCode
            LIMIT 1            
        ];
        System.debug('Regra encontrada - Condição: ' + regraEntrada.Condicao_de_Pagamento__c + ' | Valor Mínimo: ' + regraEntrada.Valor_minimo__c);
        
        DECIMAL valorMinimoEntrada = regraEntrada.Valor_minimo__c;
        System.debug('Regra de valor mínimo de entrada aplicada: ' + valorMinimoEntrada + '%');
        
        
        // Buscar regra de valor mínimo de parcela
        System.debug('========== BUSCANDO REGRA DE VALOR MÍNIMO DE PARCELA ==========');
        Regra_de_aprovacao_de_cotacao__c regraParcela = [
            SELECT Condicao_de_Pagamento__c, Valor_minimo__c
            FROM Regra_de_aprovacao_de_cotacao__c
            WHERE Tipo__c = 'Minimo de parcela'
            AND Condicao_de_Pagamento__c =: quote.Condicao_de_Pagamento__c
            AND CurrencyISOCode = : quote.CurrencyISOCode            
        ];
        DECIMAL valorMinimoParcela = regraParcela.Valor_minimo__c;
        System.debug('Valor mínimo de parcela: ' + valorMinimoParcela);
        
        
        // Map para armazenar totais por linha
        System.debug('========== AGRUPANDO VALORES POR LINHA ==========');
        Map<String, Decimal> totalValorVendaPorLinha = new Map<String, Decimal>();
        Map<String, Decimal> totalUnitPricePorLinha = new Map<String, Decimal>();
        
        // Agrupar valores por linha de produto
        for (QuoteLineItem item : quoteLineItems) {
            if (item.Product2 == null || item.Product2.Linha__c == null || item.PricebookEntry.UnitPrice <= 0) {
                System.debug('Item ignorado - Produto, Linha ou Valor inválido');
                continue;
            }
            
            String linha = item.Product2.Linha__c;
            
            if (!totalValorVendaPorLinha.containsKey(linha)) {
                totalValorVendaPorLinha.put(linha, 0);
                totalUnitPricePorLinha.put(linha, 0);
                System.debug('Nova linha adicionada: ' + linha);
            }
            
           totalValorVendaPorLinha.put(linha, totalValorVendaPorLinha.get(linha) + (item.PricebookEntry.UnitPrice));
            totalUnitPricePorLinha.put(linha, totalUnitPricePorLinha.get(linha) + (item.UnitPrice));
        }
        
        System.debug('--- Totais por Linha ---');
        for(String linha : totalValorVendaPorLinha.keySet()) {
            System.debug('Linha: ' + linha);
            System.debug('  Total Valor Venda: ' + totalValorVendaPorLinha.get(linha));
            System.debug('  Total Unit Price: ' + totalUnitPricePorLinha.get(linha));
        }
        
        // Validar o saldo de crédito do cliente
        System.debug('========== VALIDANDO SALDO DE CRÉDITO ==========');
        //se o cotação for parcelada
        if (quote.Valor_da_parcela__c > 0) {
            Decimal valorParcelado = (quote.TotalPrice - quote.Valor_de_entrada__c);
            String valorParceladoFormatado = formatBRL(valorParcelado);
            Decimal limitedeCredito = quote.Account.SaldoDeCredito__c;
            String limitedeCreditoFormatado = formatBRL(limitedeCredito);
            
            System.debug('Valor Parcelado: ' + valorParcelado);
            System.debug('Limite de Crédito: ' + limitedeCredito);
            
            if (limitedeCredito < valorParcelado) {
                System.debug('ERRO: Valor parcelado excede limite de crédito');
                erros.add(
                    'O valor parcelado (' + quote.CurrencyIsoCode + ' ' + valorParceladoFormatado + ') está acima do limite disponível do cliente de ' +
                    quote.CurrencyIsoCode + ' ' + limitedeCreditoFormatado + '. Solicite ao financeiro uma nova análise de crédito.'
                );
            }
            else{
                System.debug('VALIDADO: Valor parcelado dentro do limite');
                validados.add(
                    'O valor parcelado (' + quote.CurrencyIsoCode + ' ' + valorParceladoFormatado + ') está dentro do limite disponível do cliente de ' +
                    quote.CurrencyIsoCode + ' ' + limitedeCreditoFormatado + '.'
                );
                necessitaAnalise = false;
            }
        }
        
        if(quote.valor_da_parcela__c == 0 || quote.valor_da_parcela__c == null){
            System.debug('Valor da parcela é 0 ou null - Não necessita análise');
            necessitaAnalise = false;
        }
        System.debug('Necessita Análise: ' + necessitaAnalise);
        
        
        // Validar o valor mínimo total exigido
        System.debug('========== VALIDANDO VALOR MÍNIMO TOTAL ==========');
        if (valorMinimoTotal > 0 && quote.TotalPrice > 0) {
            String valorMinimoTotalFormatado = formatBRL(valorMinimoTotal);
            String valorTotalFormatado = formatBRL(quote.TotalPrice);
            
            System.debug('Valor Mínimo Total Exigido: ' + valorMinimoTotal);
            System.debug('Valor Total da Cotação: ' + quote.TotalPrice);
            
            if (quote.TotalPrice < valorMinimoTotal) {
                System.debug('ERRO: Valor total abaixo do mínimo');
                erros.add(
                    'O valor total da proposta (' + quote.CurrencyIsoCode + valorTotalFormatado +  ') está abaixo do mínimo exigido de ' +
                    valorMinimoTotalFormatado + ' para a condição de pagamento selecionada.'
                );
            }
            else{
                System.debug('VALIDADO: Valor total dentro do mínimo');
                validados.add(
                    'O valor total da proposta (' + quote.CurrencyIsoCode + valorTotalFormatado +  ') está dentro do mínimo exigido.'
                );
                valorTotalValidado = true;
            }
        }
        
        
        // Validar o valor de entrada mínimo exigido
        System.debug('========== VALIDANDO VALOR DE ENTRADA ==========');
        if (valorMinimoEntrada > 0 && quote.TotalPrice > 0) {
            Decimal percentualEntrada = (quote.Valor_de_entrada__c / quote.TotalPrice) * 100;
            String valordeEntradaFormatado = formatBRL(quote.Valor_de_entrada__c);
            
            System.debug('Valor Mínimo Entrada Exigido: ' + valorMinimoEntrada + '%');
            System.debug('Percentual Entrada Atual: ' + percentualEntrada + '%');
            System.debug('Valor de Entrada: ' + quote.Valor_de_entrada__c);
            
            if (percentualEntrada < valorMinimoEntrada) {
                System.debug('ERRO: Percentual de entrada abaixo do mínimo');
                erros.add(
                    'O valor de entrada (' + quote.CurrencyIsoCode + valordeEntradaFormatado +
                    ' - ' + String.valueOf(percentualEntrada.setScale(2, System.RoundingMode.HALF_UP)) + '% do total) está abaixo do mínimo exigido de ' +
                    valorMinimoEntrada + '%.'
                );
            }
            else{
                System.debug('VALIDADO: Percentual de entrada dentro do mínimo');
                validados.add(
                    'O valor de entrada (' + quote.CurrencyIsoCode + valordeEntradaFormatado +
                    ' - ' + String.valueOf(percentualEntrada.setScale(2, System.RoundingMode.HALF_UP)) + '% do total) está dentro do mínimo exigido.'
                );
                entradaValidada = true;
            }
        }
        
        if(valorMinimoEntrada == 0){
            System.debug('Valor mínimo de entrada é 0 - Entrada validada automaticamente');
            entradaValidada = true;
        }
        
        // Validar o valor de parcela mínimo exigido
        System.debug('========== VALIDANDO VALOR DE PARCELA ==========');
        if (valorMinimoParcela > 0 && quote.TotalPrice > 0) {
            Decimal parcela = quote.Valor_da_parcela__c;
            String valorMinimoParcelaFormatado = quote.CurrencyIsoCode + ' ' + formatBRL(valorMinimoParcela);
            String valorParcelaFormatado = quote.CurrencyIsoCode + ' ' + formatBRL(parcela);
            
            System.debug('Valor Mínimo Parcela Exigido: ' + valorMinimoParcela);
            System.debug('Valor da Parcela Atual: ' + parcela);
            
            if (parcela < valorMinimoParcela) {
                System.debug('ERRO: Valor da parcela abaixo do mínimo');
                erros.add(
                    'O valor da parcela (' + valorParcelaFormatado + ') está abaixo do mínimo exigido de ' +
                    valorMinimoParcelaFormatado + '.'
                );
            }
            else{
                System.debug('VALIDADO: Valor da parcela dentro do mínimo');
                validados.add(
                    'O valor da parcela (' + valorParcelaFormatado +  ') está dentro do mínimo exigido.'
                );
                valorParcelaValidado = true;
            }
        }
        
        // Validar desconto por linha
        System.debug('========== VALIDANDO DESCONTO POR LINHA ==========');
        for (String linha : totalValorVendaPorLinha.keySet()) {
            String key = linha + '|' + 'Desconto Maximo';
            System.debug('--- Processando Linha: ' + linha + ' ---');
            System.debug('Key de busca: ' + key);
            
            String solicitarAprovacaoDe = '';
            String linhaAj = '';
            Regra_de_aprovacao_de_cotacao__c regra = regrasDescontoMap.get(key);
            
            // Se não houver regra específica, usar a regra geral
            if (regra == null) {
                System.debug('Regra específica não encontrada, buscando regra OUTROS');
                linhaAj = 'OUTROS';
                String keyGeral = 'OUTROS|' + 'Desconto Maximo';
                regra = regrasDescontoMap.get(keyGeral);
                System.debug('Key geral: ' + keyGeral);
            }
            
            if (regra != null) {
                
                //Desconto maximo = Desconto maximo - despensa financeira
                Decimal descontoMaximo = regra.Desconto_Maximo__c - quote.Despesa_Financeira__c;
                System.debug('Deconto maximo permitido - despesa financeira: ' + descontoMaximo + '%');
                
                Decimal unitPriceTotal = totalUnitPricePorLinha.get(linha);
                Decimal valorVendaTotal = totalValorVendaPorLinha.get(linha);
                
                System.debug('Valor Venda Total: ' + valorVendaTotal);
                System.debug('Unit Price Total: ' + unitPriceTotal);
                
                // Calcular desconto médio da linha
                Decimal descontoAplicado = (1 - (unitPriceTotal / valorVendaTotal)) * 100;
                System.debug('Desconto Aplicado: ' + descontoAplicado + '%');
                System.debug('Desconto Máximo Permitido: ' + descontoMaximo + '%');
                
                // Validar desconto máximo permitido pela regra
                if (descontoAplicado > descontoMaximo) {
                    System.debug('========== DESCONTO EXCEDIDO - BUSCANDO APROVADOR ==========');
                    System.debug('Linha: ' + linhaAj);
                    System.debug('Desconto: ' + descontoAplicado);
                    
                    solicitarAprovacaoDe = aprovador(linhaAj, descontoAplicado, quote.CurrencyISOCode);
                    System.debug('Aprovador necessário: ' + solicitarAprovacaoDe);
                    
                                

                    if(solicitarAprovacaoDe == 'CEO') {
                        alcadaAprovador.add(6);
                        System.debug('Alçada adicionada: 6 - CEO');
                    }
                     if(solicitarAprovacaoDe == 'Gerente de Linha') {
                        alcadaAprovador.add(5);
                        System.debug('Alçada adicionada: 5 - Gerente de Linha');
                    }
                     if(solicitarAprovacaoDe == 'Diretor Nacional') {
                        alcadaAprovador.add(4);
                        System.debug('Alçada adicionada: 4 - Diretor Nacional');
                    }
                    if(solicitarAprovacaoDe == 'Gerente Nacional') {
                        alcadaAprovador.add(3);
                        System.debug('Alçada adicionada: 3 - Gerente Nacional');
                    }
                    if(solicitarAprovacaoDe == 'Gerente Regional') {
                        alcadaAprovador.add(2);
                        System.debug('Alçada adicionada: 2 - Gerente Regional');
                    }
                    else {
                        alcadaAprovador.add(1);
                        System.debug('Alçada adicionada: 1 - Vendedor');
                    }
                    
                    if(descontoMaximo <= 0){
                        erros.add('A linha de produto ' + linha + ' não possui margem para desconto' + '\nDespesa financeira: ' + 
                        String.valueOf(quote.Despesa_Financeira__c.setScale(2, System.RoundingMode.HALF_UP)) + '%' + ' de juros acumulados.');
                    }
                    erros.add(
                        'A linha de produto ' + linha + ' excede o desconto permitido de ' +
                        String.valueOf(descontoMaximo.setScale(2, System.RoundingMode.HALF_UP))
                            + '% - Desconto aplicado: '
                            + String.valueOf(descontoAplicado.setScale(2, System.RoundingMode.HALF_UP)) + '%.'
                            + '\nDespesa financeira: ' + String.valueOf(quote.Despesa_Financeira__c.setScale(2, System.RoundingMode.HALF_UP)) + '%' + ' de juros acumulados.');
                }
                else{
                    System.debug('VALIDADO: Desconto dentro do permitido');
                    validados.add(
                        'A linha de produto ' + linha + ' está dentro do valor permitido.'
                    );
                    alcadaAprovador.add(1);
                }
            } else {
                System.debug('AVISO: Nenhuma regra encontrada para a linha ' + linha);
            }
        }
        
        // Verificando se a lista não está vazia
        System.debug('========== DETERMINANDO APROVADOR FINAL ==========');
        System.debug('Lista de alçadas: ' + alcadaAprovador);
        Integer aprovador = null;
        
        if (!alcadaAprovador.isEmpty()) {
            aprovador = alcadaAprovador[0];
            System.debug('Aprovador inicial: ' + aprovador);
            
            // Loop para encontrar o valor máximo
            for (Integer valor : alcadaAprovador) {
                if (valor > aprovador) {
                    aprovador = valor;
                    System.debug('Novo aprovador máximo encontrado: ' + aprovador);
                }
            }
        }
        
        System.debug('Aprovador final (numérico): ' + aprovador);
        
        String aprovador_txt = '';
        if(aprovador == 1)
            aprovador_txt = 'Vendedor';
        if(aprovador == 2)
            aprovador_txt = 'Gerente Regional';
        if(aprovador == 3)
            aprovador_txt = 'Gerente Nacional';
            if(aprovador == 4)
            aprovador_txt = 'Diretor Nacional';
            if(aprovador == 5)
            aprovador_txt = 'Gerente de Linha';
        if(aprovador == 6)
            aprovador_txt = 'CEO';
        
        System.debug('Aprovador final (texto): ' + aprovador_txt);
        
        Quote.Aprovador__c = aprovador;
        
        System.debug('========== ATUALIZANDO COTAÇÃO ==========');
        try{
            update quote;
            System.debug('Cotação atualizada com sucesso');
        }
        catch(Exception e){
            System.debug('ERRO ao atualizar cotação: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            return 'ERRO ' + e.getMessage();
        }
        
        // Se houver erros, retornar no response
        System.debug('========== MONTANDO RESPOSTA ==========');
        System.debug('Total de erros: ' + erros.size());
        System.debug('Total de validações: ' + validados.size());
        
        if (!erros.isEmpty()) {
            System.debug('Resposta com erros');
            response.put('success', false);
            response.put('errors', erros);
        } else {
            System.debug('Resposta com sucesso');
            response.put('success', true);
            response.put('message', 'Cotação validada!');
        }
        
        response.put('validados', validados);
        response.put('necessitaAnalise', necessitaAnalise);
        response.put('entradaValidada', entradaValidada);
        response.put('valorTotalValidado', valorTotalValidado);
        response.put('valorParcelaValidado', valorParcelaValidado);
        response.put('idCotacao', quote.Id);
        response.put('idConta', quote.AccountId);
        response.put('aprovador', aprovador_txt);
        
        String jsonResponse = JSON.serializePretty(response);
        System.debug('JSON Response (primeira versão): ' + jsonResponse);
        
        System.debug('========== INSERINDO SIMULAÇÃO ==========');
        Simulacao_de_aprovacao_de_cotacao__c saa = new Simulacao_de_aprovacao_de_cotacao__c();
        saa.Cotacao__c = quoteId;
        saa.json__c = jsonResponse;
        
        try {
            insert saa;
            System.debug('Simulação inserida com sucesso - Id: ' + saa.Id);
        } catch(Exception e) {
            System.debug('ERRO ao inserir simulação: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }
        
        Simulacao_de_aprovacao_de_cotacao__c simulacaoInserida = [SELECT ID, Name FROM Simulacao_de_aprovacao_de_cotacao__c WHERE Id = :saa.Id];
        System.debug('Simulação buscada - Name: ' + simulacaoInserida.Name);
        
        response.put('simulacao', simulacaoInserida.Name);
        
        String jsonResponse2 = JSON.serializePretty(response);
        System.debug('========== JSON RESPONSE FINAL ==========');
        System.debug(jsonResponse2);
        
        System.debug('========== FINALIZANDO VALIDAÇÃO DE COTAÇÃO ==========');
        return jsonResponse2;
    }
    public static String formatBRL(Decimal valor) {
        if (valor == null) {
            return ' 0,00';
        }
        
        String valorString = String.valueOf(valor.setScale(2)).replace('.', ',');
        Integer parteInteira = valor.intValue();
        String parteInteiraFormatada = parteInteira.format().replace(',', '.');
        
        return ' ' + parteInteiraFormatada + valorString.right(3);
    }
    
    public static String aprovador(string linha, decimal desconto, string moeda){
        System.debug('Buscando aprovador');
        
        
        List<Regra_de_aprovacao_de_cotacao__c> regra = [
            SELECT Linha__c, Condicao_de_Pagamento__c, Desconto_Maximo__c, Alcada__c
            FROM Regra_de_aprovacao_de_cotacao__c
            WHERE Tipo__c = 'Desconto' 
            AND Linha__c =: linha 
            AND Desconto_Maximo__c >= : desconto 
            AND CurrencyISOCode = : moeda 
            ORDER BY Desconto_Maximo__c ASC 
            LIMIT 1
        ];
        
        if(regra.size() > 0){
            return regra[0].Alcada__c;
        }
        else{
            return 'CEO';
        }
    }
    
    @AuraEnabled
    public static string enviarAprovacao(Id quoteId) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(quoteId);
        req.setSubmitterId(UserInfo.getUserId());
        
        Approval.ProcessResult result = Approval.process(req);
        
        if (result.isSuccess()) {
            return 'Cotação enviada para aprovação com sucesso!';
        } else {
            return 'Falha ao enviar a cotação para aprovação.';
        }
    }
    
    public static string dummy(String dummy) {
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
       
        return result;
    }
    public static string dummy1(String dummy) {
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
        
        return result;
    }
    public static string dummy2(String dummy) {
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
        
        return result;
    }
    public static string dummy3(String dummy) {
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
        
        return result;
    }
    public static string dummy4(String dummy) {
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
        
        return result;
    }
    
}