@isTest(seeAllData=true)
public class FinanceiroProjurisTest {

    @isTest
    static void testFutureMethod() {
        // Mockando a resposta da chamada de API de autenticação
        HttpResponse authResponse = new HttpResponse();
        authResponse.setStatusCode(200);
        authResponse.setBody('{"access_token":"mock_token"}');

        // Mockando a resposta da chamada de API de processo
        HttpResponse processoResponse = new HttpResponse();
        processoResponse.setStatusCode(200);
        processoResponse.setBody('{"content":[{"nota":"nota de exemplo","valor":100.0,"dataLancamento":"2023-01-01","valorBaixa":50.0,"dataVencimento":"2023-01-31"}]}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(authResponse, processoResponse));
        
        // Iniciar a execução do método @future
        Test.startTest();
        FinanceiroProjuris.pesquisa();
        Test.stopTest();

        // Verificar se os lançamentos financeiros foram criados ou atualizados
        List<Lancamento_Financeiro__c> updatedLancamentos = [SELECT ID, Name, Valor__c, Data_Lancamento__c, Valor_Baixa__c, Data_Vencimento__c, Processo_Judicial__c FROM Lancamento_Financeiro__c];
        

    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse authResponse;
        private HttpResponse processoResponse;

        public MockHttpResponseGenerator(HttpResponse authResponse, HttpResponse processoResponse) {
            this.authResponse = authResponse;
            this.processoResponse = processoResponse;
        }

        public HttpResponse respond(HttpRequest req) {
            if (req.getEndpoint().contains('authenticate')) {
                return authResponse;
            } else if (req.getEndpoint().contains('financeiro/pageable')) {
                return processoResponse;
            }
            return null;
        }
    }
}