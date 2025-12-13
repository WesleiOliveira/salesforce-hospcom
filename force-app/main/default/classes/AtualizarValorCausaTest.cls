@isTest
public class AtualizarValorCausaTest {
    @isTest
    static void testAtualizarValores() {
        // Preparando os dados de teste
        List<Processo_Judicial__c> processos = new List<Processo_Judicial__c>();
        
        // Criando um processo de exemplo
        Processo_Judicial__c processo = new Processo_Judicial__c(
            Valor_da_causa__c = 1000.00,
            Data_de_inicio__c = Date.today().addMonths(-6), // Data de início há 6 meses
            Indice_de_atualizacao__c = 'INPC' // Exemplo de índice
        );
        processos.add(processo);
        
        insert processos;
        
        // Configurando o mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Chamando o método a ser testado
        AtualizarValorCausa.atualizarValores();
        
        // Recuperando o processo atualizado
        Processo_Judicial__c processoAtualizado = [SELECT Valor_atualizado__c FROM Processo_Judicial__c WHERE Id = :processo.Id];
        
    }
    
    private static Decimal calcularValorEsperado(Decimal valorInicial, Date dataInicio) {
        Decimal valorAtualizado = valorInicial;
        Date dataAtual = Date.today();
        
        // Índices fictícios são gerados no mock
        Map<String, Decimal> indicesMensais = new Map<String, Decimal>{
            '202301' => 2.0, 
                '202302' => 3.0, 
                '202303' => 1.5  
                };
                    
                    while (dataInicio < dataAtual) {
                        String anoMes = String.valueOf(dataInicio.year()) + formatMes(dataInicio.month());
                        Decimal indiceMensal = indicesMensais.containsKey(anoMes) ? indicesMensais.get(anoMes) : 0;
                        valorAtualizado *= (1 + indiceMensal / 100);
                        dataInicio = dataInicio.addMonths(1);
                    }
        
        return valorAtualizado * (1 + (6 * 0.01)); // Supondo 6 meses de juros simples
    }
    
    private static String formatMes(Integer mes) {
        return mes < 10 ? '0' + String.valueOf(mes) : String.valueOf(mes);
    }
    
    public class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Criando um mock de resposta HTTP
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(200);
            mockResponse.setBody('[' +
                                 '{"resultados":[{"series":[{"serie":{"202301":"2.0","202302":"3.0","202303":"1.5"}}]}]}' +
                                 ']');
            return mockResponse;
        }
    }
}