@isTest
public class VisualforcePublicLinkTest {
    
    @isTest
    static void testUploadPDF() {
        // Preparação dos dados de teste
        String fileName = 'TestFile';
        String pagina = 'MinhaPagina';
        String idPC = '12345';
        
        // Mock da lógica de obtenção de PDF
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Chamada ao método de uploadPDF
        String link = VisualforcePublicLink.uploadPDF(fileName, pagina, idPC);
        
        // Verificações de assert
        System.assertNotEquals(null, link, 'Link não deveria ser nulo');
        System.assert(link.startsWith('http') || link.startsWith('https'), 'Link deveria começar com "http" ou "https"');
    }
    
    // Mock para simular a chamada HTTP e resposta
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simular retorno de PDF como conteúdo
            Blob pdfBlob = Blob.valueOf('PDF Content');
            String base64PDF = EncodingUtil.base64Encode(pdfBlob);
            
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"rendered":"http://example.com/pdf-link","r');
            return res;
        }
    }
}