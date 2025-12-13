global class ForecastSalvoScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        Map<String, Decimal> byLinhaRegiao = new Map<String, Decimal>();
        Map<String, Decimal> byLinhaGeral = new Map<String, Decimal>();
        
        // Pega o mês atual no formato yyyy-MM
        Integer mes = Date.today().month();
        String mesStr = mes < 10 ? '0' + String.valueOf(mes) : String.valueOf(mes);
        String mesAtual = String.valueOf(Date.today().year()) + '-' + mesStr;
        
        
        // === Forecasts de oportunidades ===
        List<OpportunityLineItem> forecastItems = [
            SELECT Forecast_Item__c, Product2.Linha__c, Opportunity.Regiao_Nome__c
            FROM OpportunityLineItem
            WHERE Opportunity.CloseDate = THIS_MONTH
        ];
        
        for (OpportunityLineItem item : forecastItems) {
            String linha = item.Product2.Linha__c;
            String regiao = item.Opportunity.Regiao_Nome__c;
            Decimal valor = item.Forecast_Item__c != null ? item.Forecast_Item__c : 0;
            
            if (linha != null) {
                String key = linha + '||' + regiao;
                
                Decimal atualRegiao = byLinhaRegiao.containsKey(key) ? byLinhaRegiao.get(key) : 0;
                byLinhaRegiao.put(key, atualRegiao + valor);
                
                Decimal atualGeral = byLinhaGeral.containsKey(linha) ? byLinhaGeral.get(linha) : 0;
                byLinhaGeral.put(linha, atualGeral + valor);
            }
        }
        
        // === Pedidos com EffectiveDate e naturezas específicas ===
        List<OrderItem> orderItems = [
            SELECT TotalPrice, Linha__c, Order.Regi_o__c
            FROM OrderItem
            WHERE Order.Data_de_ativacao__c = THIS_MONTH
            AND Order.Natureza_de_Opera_o__c IN ('locação', 'serviço', 'venda')
            AND Order.Status IN ('Atendido Parcial', 'Atendido Total','Ativo','Em Andamento','Entregue Parcial', 'Entregue Total')
        ];
        
        for (OrderItem item : orderItems) {
            String linha = item.Linha__c;
            String regiao = item.Order.Regi_o__c;
            Decimal valor = item.TotalPrice != null ? item.TotalPrice : 0;
            
            if (linha != null) {
                String key = linha + '||' + regiao;
                
                Decimal atualRegiao = byLinhaRegiao.containsKey(key) ? byLinhaRegiao.get(key) : 0;
                byLinhaRegiao.put(key, atualRegiao + valor);
                
                Decimal atualGeral = byLinhaGeral.containsKey(linha) ? byLinhaGeral.get(linha) : 0;
                byLinhaGeral.put(linha, atualGeral + valor);
            }
        }
        
        // === Pedidos de locação com status específicos ===
        List<OrderItem> orderItensLocacao = [
            SELECT TotalPrice, Linha__c, Order.Regi_o__c, Order.Status, Order.Linha_Locacao__c
            FROM OrderItem
            WHERE Order.EffectiveDate = THIS_MONTH
            AND Order.Natureza_de_Opera_o__c = 'locação'
            AND Order.Status IN ('Aguardando Aprovação Financeira', 'Aprovado', 'Rascunho')
        ];
        
        for (OrderItem item : orderItensLocacao) {
            String linha = item.Order.Linha_Locacao__c;
            String regiao = item.Order.Regi_o__c;
            Decimal valor = item.TotalPrice != null ? item.TotalPrice : 0;
            
            if (linha != null) {
                String key = linha + '||' + regiao;
                
                Decimal atualRegiao = byLinhaRegiao.containsKey(key) ? byLinhaRegiao.get(key) : 0;
                byLinhaRegiao.put(key, atualRegiao + valor);
                
                Decimal atualGeral = byLinhaGeral.containsKey(linha) ? byLinhaGeral.get(linha) : 0;
                byLinhaGeral.put(linha, atualGeral + valor);
            }
        }
        
        // === Criar registros por Linha + Região ===
        List<Forecast_Salvo__c> registros = new List<Forecast_Salvo__c>();
        
        for (String key : byLinhaRegiao.keySet()) {
            List<String> partes = key.split('\\|\\|');
            String linha = partes[0];
            String regiao = partes.size() > 1 ? partes[1] : null;
            
            registros.add(new Forecast_Salvo__c(
                Linha__c = linha,
                Regiao__c = regiao,
                Valor__c = byLinhaRegiao.get(key)
                //Mes__c = mesAtual
            ));
        }
        
        // === Criar registros gerais (por Linha apenas) ===
        for (String linha : byLinhaGeral.keySet()) {
            registros.add(new Forecast_Salvo__c(
                Linha__c = linha,
                Valor__c = byLinhaGeral.get(linha)
                //Mes__c = mesAtual
            ));
        }
        
        if (!registros.isEmpty()) {
            insert registros;
        }
    }
}