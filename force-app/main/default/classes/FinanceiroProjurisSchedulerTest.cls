@isTest(seeAllData=true)
public class FinanceiroProjurisSchedulerTest {
    @isTest
    static void testFinanceiroProjurisScheduler() {
        // Definir mock de resposta HTTP
        Test.setMock(HttpCalloutMock.class, new FinanceiroProjurisHttpMock());
        
        // Agendar o job
        FinanceiroProjurisScheduler scheduler = new FinanceiroProjurisScheduler();
        String cronExp = '0 0 0 17 9 ? 2024';
        System.schedule('Test FinanceiroProjurisScheduler Job', cronExp, scheduler);
        
        // Executar o job
        Test.startTest();
        
        // Avançar o tempo para forçar a execução do job
        Test.stopTest();
        
    }
    
    public class FinanceiroProjurisHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Mock para a requisição de autenticação
            if (req.getEndpoint().contains('api/auth-service/authenticate')) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token":"mock_token"}');
                res.setStatusCode(200);
                return res;
            }
            
            // Mock para a requisição dos dados financeiros
            if (req.getEndpoint().contains('/financeiro/pageable')) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"content":[{"id":123,"tipoLancamentoFinanceiro":"CRÉDITO","valor":100.00,"dataLancamento":"2023-09-01","valorBaixa":50.00,"dataVencimento":"2023-09-15"}]}');
                res.setStatusCode(200);
                return res;
            }
            
            // Retornar uma resposta vazia por padrão
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            return res;
        }
    }
}