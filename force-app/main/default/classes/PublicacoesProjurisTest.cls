@isTest
public class PublicacoesProjurisTest {
    
    
    @isTest
    static void testCallApiAndProcessResponse() {
        
        Publicacao__c pub = new Publicacao__c(Name = '752425');
        insert pub;
        // Configura a simulação da resposta da API
        String jsonResponse = '{ "content": [{"createdBy":{"id":null,"name":null,"login":null,"status":null},"createdDate":"2024-09-02T15:00:02.649662Z","lastModifiedBy":null,"lastModifiedDate":"2024-09-02T15:00:02.649662Z","id":4784928,"message":null,"status":"NAO_ATRIBUIDA","numeroProcesso":"18.0014","processo":null,"codigo":"752425","dataPublicacao":"2024-09-03T00:00:00","dataLeitura":null,"ignorado":null,"atribuido":null,"lido":null,"responsaveis":[],"termoEncontrado":"COMERCIO DE ALIM","nomeRelacionado":"COMERCIO DE ALIMENTOS LTDA","comarca":"GOIANIA","estado":"Goiás - GO","vara":"14ª VARA DO TRABALHO DE GOIANIA","forum":"14A VARA DO TRABALHO","diario":"","oab":"","descricao":"teste","observacao":"","justificativa":null}] }';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorrr(200, jsonResponse));
        
        // Chama o método que faz a chamada da API e processa a resposta
        Test.startTest();
        PublicacoesProjuris.callApiAndProcessResponse();
        Test.stopTest();
        
        // Verifica se os dados foram processados corretamente
        Publicacao__c[] newProcessos = [SELECT Name FROM Publicacao__c WHERE Name = '752425'];
        System.assertEquals(1, newProcessos.size());
    }
    
    @isTest
    static void testCallApiAndProcessResponseWithExistingData() {
        // Configura a simulação da resposta da API com um número de documento já existente
        String jsonResponse = '{ "content": [{"createdBy":{"id":null,"name":null,"login":null,"status":null},"createdDate":"2024-09-02T15:00:02.649662Z","lastModifiedBy":null,"lastModifiedDate":"2024-09-02T15:00:02.649662Z","id":4784928,"message":null,"status":"NAO_ATRIBUIDA","numeroProcesso":"18.0014","processo":null,"codigo":"752425","dataPublicacao":"2024-09-03T00:00:00","dataLeitura":null,"ignorado":null,"atribuido":null,"lido":null,"responsaveis":[],"termoEncontrado":"COMERCIO DE ALIM","nomeRelacionado":"COMERCIO DE ALIMENTOS LTDA","comarca":"GOIANIA","estado":"Goiás - GO","vara":"14ª VARA DO TRABALHO DE GOIANIA","forum":"14A VARA DO TRABALHO","diario":"","oab":"","descricao":"teste","observacao":"","justificativa":null}] }';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorrr(200, jsonResponse));
        
        // Chama o método que faz a chamada da API e processa a resposta
        Test.startTest();
        PublicacoesProjuris.callApiAndProcessResponse();
        Test.stopTest();
        
        // Verifica se nenhum novo processo judicial foi criado
        Publicacao__c[] existingProcessos = [SELECT Name FROM Publicacao__c WHERE Name = '752425'];
        System.assertEquals(1, existingProcessos.size());
    }
    
    // Classe Mock para simular a resposta da API
    private class MockHttpResponseGeneratorrr implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseGeneratorrr(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}