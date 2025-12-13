@isTest(seeAllData=true)
public class ChatGPT_ForecastTest {
    
    @isTest
    static void testSendToChatGPT() {
        
        // Configuração do Mock HTTP
        Test.setMock(HttpCalloutMock.class, new ChatGPTHttpMock());
        
        // Criar instância da classe ChatGPT_Forecast
        ChatGPT_Forecast chatIntegration = new ChatGPT_Forecast();
        
        // Chamar o método sendToChatGPT com o ID do vendedor
        Test.startTest();
        String response = chatIntegration.sendToChatGPT('0056e00000CU7Kl');
        Test.stopTest();
    }
    // Classe de Mock para simular a resposta da API do ChatGPT
    public class ChatGPTHttpMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            // Simulando uma resposta HTTP bem-sucedida da API do ChatGPT
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            String mockResponseBody = '{"choices":[{"message":{"role":"system","content":"Analisando dados financeiros. O vendedor João tem um forecast de 10000. Meta para o mês é 15000, falta 5000 para atingir a meta. A oportunidade está em aberto, e o vendedor é João."}}]}';
            response.setBody(mockResponseBody);
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }
}