public class DistribuicoesProjuris {
    @future(callout=true)
    public static void pesquisa() {
        String token = obterToken();
        if (token != null) {
            processarProcessos(token);
        }
    }
    
    private static String obterToken() {
        Token_Projuris__mdt clientId = [SELECT DeveloperName, Token__c FROM Token_Projuris__mdt WHERE DeveloperName ='Client_ID'];
        Token_Projuris__mdt clientSecret = [SELECT DeveloperName, Token__c FROM Token_Projuris__mdt WHERE DeveloperName ='Client_secret'];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://hospcom.integracao.projuris.com.br/api/auth-service/authenticate');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
        String body = '{' +
            '"username": "' + clientId.Token__c + '",' +
            '"password": "' + clientSecret.Token__c + '"' +
            '}';
        request.setBody(body);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            String resposta = response.getBody();
            return resposta.substringAfter('{"access_token":"').substringBefore('",');
        } else {
            System.debug('Erro ao obter token. Status code: ' + response.getStatusCode());
            return null;
        }
    }
    @TestVisible
    private static void processarProcessos(String token) {
        
        List<Distribuicao__c> lancamentosParaInserirAtualizar = new List<Distribuicao__c>();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://hospcom.integracao.projuris.com.br/api/distribuicao/pageable?query=%20lastModifiedDate%20%3D%20%23%7BCURRENT_DATE%7D&size=100');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            
            String responseBody = response.getBody();
            try {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                
                if (jsonResponse.containsKey('content')) {
                    Object content = jsonResponse.get('content');
                    
                    if (content instanceof List<Object>) {
                        List<Object> contentList = (List<Object>) content;
                        
                        for (Object item : contentList) {
                            if (item instanceof Map<String, Object>) {
                                Map<String, Object> itemMap = (Map<String, Object>) item;
                                
                                Integer idLancamento = itemMap.containsKey('id') ? (Integer) itemMap.get('id') : null;
                                String nat;
                                // Verifica se o itemMap contém a chave 'natureza' e acessa o nome da natureza
                                if (itemMap.containsKey('natureza')) {
                                    Map<String, Object> naturezaMap = (Map<String, Object>) itemMap.get('natureza');
                                    nat = naturezaMap.containsKey('nome') ? (String) naturezaMap.get('nome') : null;
                                }
                                string comarca;
                                if (itemMap.containsKey('comarca')) {
                                    Map<String, Object> comarcaMap = (Map<String, Object>) itemMap.get('comarca');
                                    comarca = comarcaMap.containsKey('nome') ? (String) comarcaMap.get('nome') : null;
                                }
                                string tribunal;
                                if (itemMap.containsKey('tribunal')) {
                                    Map<String, Object> tribunalMap = (Map<String, Object>) itemMap.get('tribunal');
                                    tribunal = tribunalMap.containsKey('nome') ? (String) tribunalMap.get('nome') : null;
                                }
                                string jurisdicao;
                                if (itemMap.containsKey('jurisdicao')) {
                                    Map<String, Object> jurisdicaoMap = (Map<String, Object>) itemMap.get('jurisdicao');
                                    jurisdicao = jurisdicaoMap.containsKey('nome') ? (String) jurisdicaoMap.get('nome') : null;
                                }
                                String dataDistStr = (String) itemMap.get('dataDistribuicao');
                                Date dataDist = date.valueOf(dataDistStr);
                                String classe = (String) itemMap.get('classeNatureza');                                
                                String partes = (String) itemMap.get('partes');
                                Decimal valorCausa = itemMap.containsKey('valorCausa') ? (Decimal) itemMap.get('valorCausa') : null;
                                String tribOriginal = (String) itemMap.get('tribunalOriginal');
                                String status = (String) itemMap.get('status');
                                String numeroProcesso = (String) itemMap.get('numeroProcesso');
                                String tipoDistribuicao = (String) itemMap.get('tipoDistribuicao');
                               
                                // Verifica se a distribuição já existe
                                String idLancamentoSt = idLancamento.toString();
                                
                                List<Distribuicao__c> existingDistribuicao = [SELECT Id, Name FROM Distribuicao__c WHERE Name = :idLancamentoSt LIMIT 1];
                                
                                Distribuicao__c distribuicao;
                                if (!existingDistribuicao.isEmpty()) {
                                    distribuicao = existingDistribuicao[0];
                                } else {
                                    distribuicao = new Distribuicao__c();
                                }
                                
                                distribuicao.Name = idLancamentoSt;
                                distribuicao.Data_de_distribuicao__c = dataDist;
                                distribuicao.Partes__c = partes;
                                distribuicao.Natureza__c = nat;
                                distribuicao.Comarca__c = comarca;
                                distribuicao.Classe_Natureza__c = classe;
                                distribuicao.Valor_da_causa__c = valorCausa;
                                distribuicao.Tribunal_original__c = tribOriginal;
                                distribuicao.Tribunal__c = tribunal;
                                distribuicao.Status__c = status;
                                distribuicao.Numero_do_processo__c = numeroProcesso;
                                distribuicao.Jurisdicao__c = jurisdicao;
                                distribuicao.Tipo_de_distribuicao__c = tipoDistribuicao;
                                
                                lancamentosParaInserirAtualizar.add(distribuicao);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Erro ao processar JSON: ' + e.getMessage());
            }
        } else {
            System.debug('Erro ao obter dados financeiros. Status code: ' + response.getBody());
        }
        
        if (!lancamentosParaInserirAtualizar.isEmpty()) {
            System.debug('Upserting ' + lancamentosParaInserirAtualizar.size() + ' lançamentos financeiros.');
            upsert lancamentosParaInserirAtualizar;
        }
    }
}