global class AtualizaEstoqueJob implements Schedulable {

    global void execute(SchedulableContext sc) {
        HttpRequest req = new HttpRequest();
        String query = 'SELECT ITEMCODE, WHSCODE, ONHAND FROM DBINTEGRATIONONE2.INVENTORYINTEGRATION WHERE UPDATETS >= ADD_SECONDS(CURRENT_TIMESTAMP, -3600)';
        System.debug('Query executada: ' + query);

        req.setEndpoint('callout:HospcomNC/consultasql?sql=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');

        try {
            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() != 200) return;

            List<Object> dados = (List<Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('Dados recebidos: ' + dados);

            Set<String> chaves = new Set<String>();
            Set<String> codigosSku = new Set<String>();
            Set<String> codigosWhs = new Set<String>();

            for (Object obj : dados) {
                Map<String, Object> row = (Map<String, Object>) obj;
                String sku = String.valueOf(row.get('ITEMCODE'));
                String whs = String.valueOf(row.get('WHSCODE'));

                codigosSku.add(sku);
                codigosWhs.add(whs);
                chaves.add(sku + '-' + whs);
            }

            // Consulta otimizada: apenas registros que podem existir com os dados recebidos
            Map<String, Entrada_de_Estoque__c> mapa = new Map<String, Entrada_de_Estoque__c>();
            for (Entrada_de_Estoque__c e : [
                SELECT Id, Produto__r.ProductCode, Estoque__r.Codigo__c
                FROM Entrada_de_Estoque__c
                WHERE Produto__r.ProductCode IN :codigosSku
                AND Estoque__r.Codigo__c IN :codigosWhs
            ]) {
                String chave = e.Produto__r.ProductCode + '-' + e.Estoque__r.Codigo__c;
                if (chaves.contains(chave)) {
                    mapa.put(chave, e);
                }
            }

            // Prepara atualizações
            List<Entrada_de_Estoque__c> atualizacoes = new List<Entrada_de_Estoque__c>();
            for (Object obj : dados) {
                Map<String, Object> row = (Map<String, Object>) obj;
                String chave = row.get('ITEMCODE') + '-' + row.get('WHSCODE');

                if (mapa.containsKey(chave)) {
                    Entrada_de_Estoque__c est = mapa.get(chave);
                    est.Em_estoque__c = Decimal.valueOf(String.valueOf(row.get('ONHAND')));
                    atualizacoes.add(est);
                }
            }

            if (!atualizacoes.isEmpty()) {
                update atualizacoes;
                System.debug('Atualizações realizadas com sucesso: ' + atualizacoes.size());
            }

        } catch (Exception e) {
            System.debug('Erro ao atualizar estoque: ' + e.getMessage());
        }
    }

    public static void agendar() {
        // Executa a cada 30 minutos: 00:00, 00:30, 01:00...
        String cron = '0 0,30 * * * ?';
        System.schedule('Atualiza Estoque a cada 30 minutos', cron, new AtualizaEstoqueJob());
    }
}