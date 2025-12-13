public class AtualizarValorCausa {
    public static List<Indice_de_Atualizacao_Monetaria__c> indicesIGPM = [SELECT Data__c, Variacao__c FROM Indice_de_Atualizacao_Monetaria__c WHERE Indice__c = 'IGPM'];
    public static List<Indice_de_Atualizacao_Monetaria__c> indicesIPCAE = [SELECT Data__c, Variacao__c FROM Indice_de_Atualizacao_Monetaria__c WHERE Indice__c = 'IPCA-E'];
    
    @future(callout=true)
    @AuraEnabled
    public static void atualizarValores() {
        List<Processo_Judicial__c> processos = [SELECT Id, Valor_da_causa__c, Data_de_inicio__c, Indice_de_atualizacao__c FROM Processo_Judicial__c WHERE Indice_de_atualizacao__c !=  ''];
        
        for (Processo_Judicial__c processo : processos) {
            if (processo.Data_de_inicio__c != null) {
                Map<String, Decimal> indicesMensais = obterIndicesMensais(processo.Indice_de_atualizacao__c);
                Decimal valorAtualizado = calcularValorAtualizado(processo.Valor_da_causa__c, processo.Data_de_inicio__c, indicesMensais, processo.Indice_de_atualizacao__c);
                processo.Valor_atualizado__c = valorAtualizado;
            }
        }
        update processos;
    }
    
    private static Decimal calcularValorAtualizado(Decimal valorInicial, Date dataInicio, Map<String, Decimal> indicesMensais, String indiceUtilizado) {
        Date dataAtual = Date.today();
        Decimal valorAtualizado = valorInicial;
        Integer numMeses = 0;
        
        while (dataInicio < dataAtual) {
            String anoMes = String.valueOf(dataInicio.year()) + formatMes(dataInicio.month());
            Decimal indiceMensal = indicesMensais.containsKey(anoMes) ? indicesMensais.get(anoMes) : 0;
            valorAtualizado *= (1 + indiceMensal / 100);
            dataInicio = dataInicio.addMonths(1);
            numMeses++;
        }
        
        return valorAtualizado * (1 + (numMeses * 0.01));
    }
    
    private static String formatMes(Integer mes) {
        return mes < 10 ? '0' + String.valueOf(mes) : String.valueOf(mes);
    }
    
    private static Map<String, Decimal> obterIndicesMensais(String indiceUtilizado) {
        Map<String, Decimal> indicesMensais = new Map<String, Decimal>();
        string codigo = '';        
        string variaveis = '';        
        if (indiceUtilizado == 'INPC' || indiceUtilizado == 'IPCA') {
            if(indiceUtilizado == 'INPC'){
                codigo = '7063';
                variaveis = '44';
            }
            else if (indiceUtilizado == 'IPCA'){
                codigo = '7060';
                variaveis = '63';
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://servicodados.ibge.gov.br/api/v3/agregados/' + codigo +'/periodos/202001|202002|202003|202004|202005|202006|202007|202008|202009|202010|202011|202012|202101|202102|202103|202104|202105|202106|202107|202108|202109|202110|202111|202112|202201|202202|202203|202204|202205|202206|202207|202208|202209|202210|202211|202212|202301|202302|202303|202304|202305|202306|202307|202308|202309|202310|202311|202312|202401|202402|202403|202404|202405|202406|202407|202408/variaveis/'+ variaveis +'?localidades=N1[all]&classificacao=315[7169]');
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
            
            String responseBody = response.getBody();
            
            List<Object> responseList = (List<Object>) JSON.deserializeUntyped(responseBody);
            if (responseList.size() > 0) {
                Map<String, Object> responseMap = (Map<String, Object>) responseList[0];
                List<Object> resultados = (List<Object>) responseMap.get('resultados');
                if (resultados.size() > 0) {
                    Map<String, Object> resultado = (Map<String, Object>) resultados[0];
                    List<Object> seriesList = (List<Object>) resultado.get('series');
                    if (seriesList.size() > 0) {
                        Map<String, Object> series = (Map<String, Object>) seriesList[0];
                        Map<String, Object> serie = (Map<String, Object>) series.get('serie');
                        for (String key : serie.keySet()) {
                            indicesMensais.put(key, Decimal.valueOf((String) serie.get(key)));
                        }
                    }
                }
            }
        } else if (indiceUtilizado == 'IGPM') {
            // Consultar os índices no objeto INDICE
            for (Indice_de_Atualizacao_Monetaria__c indice : indicesIGPM) {
                String anoMes = String.valueOf(indice.Data__c.year()) + formatMes(indice.Data__c.month());
                indicesMensais.put(anoMes, indice.Variacao__c);
            }
        } else if (indiceUtilizado == 'IPCA-E') {
            // Consultar os índices no objeto INDICE
            for (Indice_de_Atualizacao_Monetaria__c indice : indicesIPCAE) {
                String anoMes = String.valueOf(indice.Data__c.year()) + formatMes(indice.Data__c.month());
                indicesMensais.put(anoMes, indice.Variacao__c);
            }
        }
        
        return indicesMensais;
    }
}