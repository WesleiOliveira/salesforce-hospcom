@isTest(seeAllData=true)
public class DistribuicoesProjurisTest {
    
    @isTest
    static void testPesquisa() {
        
        // Configura mock de resposta para a obtenção do token
        HttpMock httpMock = new HttpMock();
        httpMock.respondWith(200, '{"access_token":"test_access_token"}');
        
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        // Chama o método de pesquisa
        Test.startTest();
        DistribuicoesProjuris.pesquisa();
        Test.stopTest();

    }
    
    @isTest
    static void testProcessarProcessos() {
        // Configura mock de resposta para a chamada da API de distribuições
        HttpMock httpMock = new HttpMock();
        String jsonResponse = '{"content": [' +
            '{' +
                '"id": 1,' +
                '"natureza": {"nome": "Natureza Teste"},' +
                '"comarca": {"nome": "Comarca Teste"},' +
                '"tribunal": {"nome": "Tribunal Teste"},' +
                '"jurisdicao": {"nome": "Jurisdicao Teste"},' +
                '"dataDistribuicao": "2024-09-15",' +
                '"classeNatureza": "Classe Teste",' +
                '"partes": "Partes Teste",' +
                '"valorCausa": 1000.00,' +
                '"tribunalOriginal": "Tribunal Original Teste",' +
                '"status": "Status Teste",' +
                '"numeroProcesso": "Numero Processo Teste",' +
                '"tipoDistribuicao": "Tipo Teste"' +
            '}' +
        ']}';
        httpMock.respondWith(200, jsonResponse);
        
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        // Chama o método de processamento de processos diretamente
        Test.startTest();
        DistribuicoesProjuris.processarProcessos('test_access_token');
        Test.stopTest();
        
    }
    
    private class HttpMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        void respondWith(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}