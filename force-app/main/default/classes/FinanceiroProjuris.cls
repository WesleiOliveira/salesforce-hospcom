public class FinanceiroProjuris {
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

    private static void processarProcessos(String token) {
        List<Processo_Judicial__c> processos = [SELECT ID, ID_Processo__c FROM Processo_Judicial__c WHERE Buscar__c = true];
        for(Processo_Judicial__c processo : processos){
            List<Lancamento_Financeiro__c> lancamentosParaInserirAtualizar = new List<Lancamento_Financeiro__c>();
            System.debug('Processando Processo: ' + processo.ID_Processo__c);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://hospcom.integracao.projuris.com.br/api/processo/' + processo.ID_Processo__c + '/financeiro/pageable?size=100');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + token);

            HttpResponse response = http.send(request);
            System.debug('Response Status: ' + response.getStatusCode());

            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                System.debug('Response Body: ' + responseBody);
                try {
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

                    if (jsonResponse.containsKey('content')) {
                        Object content = jsonResponse.get('content');

                        if (content instanceof List<Object>) {
                            List<Object> contentList = (List<Object>) content;

                            for (Object item : contentList) {
                                if (item instanceof Map<String, Object>) {
                                    Map<String, Object> itemMap = (Map<String, Object>) item;

                                    String nota = (String) itemMap.get('nota');
                                    if (nota == null) {
                                        nota = 'SEM IDENTIFICAÇÃO';
                                    }                                    
                                    Integer idLancamento = itemMap.containsKey('id') ? (Integer) itemMap.get('id') : null;
                                    String tipo = (String) itemMap.get('tipoLancamentoFinanceiro');
                                    Decimal valor = itemMap.containsKey('valor') ? (Decimal) itemMap.get('valor') : null;
                                    Date dataLancamento = itemMap.containsKey('dataLancamento') ? Date.valueOf((String) itemMap.get('dataLancamento')) : null;
                                    Decimal valorBaixa = itemMap.containsKey('valorBaixa') ? (Decimal) itemMap.get('valorBaixa') : null;
                                    Date dataVencimento = itemMap.containsKey('dataVencimento') ? Date.valueOf((String) itemMap.get('dataVencimento')) : null;

                                    // Verifica se o lançamento financeiro já existe
                                    String idLancamentoSt = idLancamento.toString();
                                    List<Lancamento_Financeiro__c> existingLancamentos = [SELECT Id, Name FROM Lancamento_Financeiro__c WHERE Id_Lancamento__c = :idLancamentoSt LIMIT 1];

                                    Lancamento_Financeiro__c lancamento;
                                    if (!existingLancamentos.isEmpty()) {
                                        lancamento = existingLancamentos[0];
                                    } else {
                                        lancamento = new Lancamento_Financeiro__c();
                                    }

                                    lancamento.Name = nota;
                                    lancamento.Id_Lancamento__c = idLancamentoSt;
                                    lancamento.Valor__c = valor;
                                    lancamento.Data_Lancamento__c = dataLancamento;
                                    lancamento.Valor_Baixa__c = valorBaixa;
                                    lancamento.Data_Vencimento__c = dataVencimento;
                                    lancamento.Processo_Judicial__c = processo.Id;
                                    lancamento.Tipo_de_Lancamento__c = tipo;

                                    lancamentosParaInserirAtualizar.add(lancamento);
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    System.debug('Erro ao processar JSON: ' + e.getMessage());
                }
            } else {
                System.debug('Erro ao obter dados financeiros. Status code: ' + response.getStatusCode());
            }

            if (!lancamentosParaInserirAtualizar.isEmpty()) {
                System.debug('Upserting ' + lancamentosParaInserirAtualizar.size() + ' lançamentos financeiros.');
                upsert lancamentosParaInserirAtualizar;
            }
        }
    }
}