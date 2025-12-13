@IsTest(seeAllData=true)
public class SensoresTest {

    @IsTest
    static void testDoPost() {
        // Define os dados da requisição
        String requestBody = '"{"Temperatura__c":"31.4","Umidade__c":"40","Endereco_Mac__c":"11"}"';
        Blob requestBlob = Blob.valueOf(requestBody);

        // Configura o contexto da requisição
        RestRequest req = new RestRequest();
        req.requestBody = requestBlob;
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        // Chama o método do controlador
        Sensores.doPost();

        // Verifica a resposta
        RestResponse res = RestContext.response;
        //System.assertEquals(200, res.statusCode, 'Expected status code 200');
        //System.assertEquals('Success', res.responseBody.toString(), 'Expected response body "Success"');
    }
}