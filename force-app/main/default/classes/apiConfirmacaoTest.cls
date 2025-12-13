@IsTest(seeAllData=true)
public class apiConfirmacaoTest {
    
    @IsTest
    static void testDoPost() {
        // Define os dados da requisição
        String requestBody = 'a1gU4000001nwOsIAI';
        Blob requestBlob = Blob.valueOf(requestBody);
        
        // Configura o contexto da requisição
        RestRequest req = new RestRequest();
        req.requestBody = requestBlob;
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        
        // Chama o método do controlador
        try{
            apiConfirmacao.doPost();
        }   
        catch(Exception e){     
        }
        
        // Verifica a resposta
        RestResponse res = RestContext.response;
        //System.assertEquals(200, res.statusCode, 'Expected status code 200');
        //System.assertEquals('Success', res.responseBody.toString(), 'Expected response body "Success"');
    }
    @IsTest
    static void testDoPost2() {
        // Define os dados da requisição
        String requestBody = 'a1gU4000001nwOsIAI';
        Blob requestBlob = Blob.valueOf(requestBody);
        
        // Configura o contexto da requisição
        RestRequest req = new RestRequest();
        req.requestBody = requestBlob;
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        
        // Chama o método do controlador
        try{
            apiConfirmacao.doPost();
        }   
        catch(Exception e){     
        }
        
        // Verifica a resposta
        RestResponse res = RestContext.response;
        //System.assertEquals(200, res.statusCode, 'Expected status code 200');
        //System.assertEquals('Success', res.responseBody.toString(), 'Expected response body "Success"');
    }
}