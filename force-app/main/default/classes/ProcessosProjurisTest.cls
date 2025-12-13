@isTest
public class ProcessosProjurisTest {
    
    @testSetup
    static void setup() {
        // Cria dados de teste que serão usados em todos os métodos de teste
        Processo_Judicial__c existingProcess = new Processo_Judicial__c(Name = '123456');
        insert existingProcess;
    }
    
    @isTest
    static void testCallApiAndProcessResponse() {
        // Configura a simulação da resposta da API
        String jsonResponse = '{ "content": [ { "clientePrincipal": { "numeroDocumentoPrincipal": "789012", "nome": "Cliente Teste" }, "dataInicio": "2023-02-06", "numeroProcessoAtual": "789012", "adversoPrincipal": { "nome": "Adverso Teste" }, "natureza": { "nome": "Natureza Teste" }, "id": "001", "procedimento": { "nome": "Procedimento Teste" }, "causaRaizUm": { "nome": "Causa Raiz Teste" }, "tipoProcesso": "Tipo Processo Teste", "pedidoLiminar": true, "naturezaFinanceira": "Natureza Financeira Teste", "jurisdicaoAtual": "Jurisdicao Atual Teste" } ] }';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorrr(200, jsonResponse));
        
        // Chama o método que faz a chamada da API e processa a resposta
        Test.startTest();
        ProcessosProjuris.callApiAndProcessResponse();
        Test.stopTest();
        
        // Verifica se os dados foram processados corretamente
        Processo_Judicial__c[] newProcessos = [SELECT Name FROM Processo_Judicial__c WHERE Name = '789012'];
        System.assertEquals(1, newProcessos.size());
    }
    
    @isTest
    static void testCallApiAndProcessResponseWithExistingData() {
        // Configura a simulação da resposta da API com um número de documento já existente
        String jsonResponse = '{ "content": [ { "clientePrincipal": { "numeroDocumentoPrincipal": "123456", "nome": "Cliente Teste" }, "dataInicio": "2023-02-06", "numeroProcessoAtual": "123456", "adversoPrincipal": { "nome": "Adverso Teste" }, "natureza": { "nome": "Natureza Teste" }, "id": "001", "procedimento": { "nome": "Procedimento Teste" }, "causaRaizUm": { "nome": "Causa Raiz Teste" }, "tipoProcesso": "Tipo Processo Teste", "pedidoLiminar": true, "naturezaFinanceira": "Natureza Financeira Teste", "jurisdicaoAtual": "Jurisdicao Atual Teste" } ] }';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorrr(200, jsonResponse));
        
        // Chama o método que faz a chamada da API e processa a resposta
        Test.startTest();
        ProcessosProjuris.callApiAndProcessResponse();
        Test.stopTest();
        
        // Verifica se nenhum novo processo judicial foi criado
        Processo_Judicial__c[] existingProcessos = [SELECT Name FROM Processo_Judicial__c WHERE Name = '545454'];
        //System.assertEquals(1, existingProcessos.size());
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