@isTest(seeAllData=true)
private class publicLinkTest {
    
    @isTest
    static void testCreateOpportunity() {
        
        String idDoc = '069U4000000ACsnIAG';
        
        // Corpo da requisição JSON
        String requestBody = '{"idDoc": "' + idDoc + '"}';
        
        // Simula a requisição REST
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Chama o método REST
        publicLink.doPost();
    }
}