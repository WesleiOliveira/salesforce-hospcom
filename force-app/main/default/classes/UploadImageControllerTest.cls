/*@isTest
private class UploadImageControllerTest {

    // Classe de Mock para simular a resposta da API
    class MockHttpResponseGenerator implements HttpCalloutMock {
        // O método respond é chamado para simular a resposta HTTP
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            // Verifica o conteúdo da requisição e retorna uma resposta simulada adequada
            if (req.getEndpoint().contains('receberArquivo')) {
                res.setHeader('Content-Type', 'application/json');
                
                // Caso o status code seja 200, simula uma resposta de sucesso
                if (req.getBody().contains('base64Data')) {
                    res.setStatusCode(200);
                    res.setBody('{"success": true, "message": "Arquivo enviado com sucesso."}');
                } else {
                    // Simula um erro de requisição
                    res.setStatusCode(400);
                    res.setBody('{"error": "Bad Request"}');
                }
            }
            return res;
        }
    }

    @isTest
    static void testUploadImageSuccess() {
        // Configurar o mock de HTTP
        Test.startTest();
        
        // Definir o Mock HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Chamar o método de upload de imagem
        Map<String, Object> result = UploadImageController.uploadImage('base64Data', 'example.jpg');
        
        Test.stopTest();
        
        // Verificar se a resposta é sucesso
        System.assert(result.get('success') == true);
        System.assert(result.get('message') == 'Arquivo enviado com sucesso.');
    }*/
@isTest
private class UploadImageControllerTest {

    // Classe de Mock para simular a resposta da API
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('receberArquivo')) {
                res.setHeader('Content-Type', 'application/json');
                if (req.getBody().contains('base64Data')) {
                    res.setStatusCode(200);
                    res.setBody('{"success": true, "message": "Arquivo enviado com sucesso."}');
                } else {
                    res.setStatusCode(400);
                    res.setBody('{"error": "Bad Request"}');
                }
            }
            return res;
        }
    }

    @isTest
    static void testUploadImageSuccess() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, Object> result = UploadImageController.uploadImage('base64Data', 'example.jpg');
        Test.stopTest();
        System.assert(result.get('success') == true);
        System.assert(result.get('message') == 'Arquivo enviado com sucesso.');
    }



/*
    @isTest
    static void testUploadImageError() {
        // Configurar o mock de HTTP para simular erro
        Test.startTest();
        
        // Definir o Mock HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Chamar o método de upload de imagem
        Map<String, Object> result = UploadImageController.uploadImage('invalidData', 'example.jpg');
        
        Test.stopTest();
        
        // Verificar se o resultado é erro
        System.assert(result.get('success') == false);
        System.assert(result.get('message') == 'Erro de requisição (400). Verifique os dados enviados.');
    }*/
}










/*@isTest
public class UploadImageControllerTest {
    @isTest
    static void testUploadImage() {
        // Simular dados de teste
        String base64Data = 'data:image/png;base64,AAA...'; // Use um conteúdo base64 fictício
        String fileName = 'testImage.png';

        // Simular a chamada da API (Mock de Callout)
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Testar o método
        Test.startTest();
        UploadImageController.uploadImage(base64Data, fileName);
        Test.stopTest();

        // Validar o comportamento esperado
        System.assert(true, 'Teste concluído sem erros.');
    }
}
*/