@isTest(seeAllData=true)
private class BotTest {
    
    @isTest
    static void testCreateOpportunity() {
        
        String clientId = '0016e00003FBzFG';
        String opportunityName = 'Mock Opportunity';
        String description = 'Mock Description';
        String closingDate = '2025-01-31';
        
        // Corpo da requisição JSON
        String requestBody = '{"AccountId": "' + clientId + '", "OpportunityName": "' + opportunityName + '", "Description": "' + description + '", "DataFechamento": "' + closingDate + '"}';
        
        // Simula a requisição REST
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Chama o método REST
        Bot.doPost();
    }
    
    @isTest
    static void testUpdateEventFeedback() {
        
        String eventId = '00UU400000BHRVKMA5';
        String feedback = 'Test feedback';
        
        // Corpo da requisição JSON
        String requestBody = '{"feedback": "' + feedback + '", "eventId": "' + eventId + '"}';
        
        // Simula a requisição REST
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Chama o método REST
        Bot.doPost();
        
        // Valida que o evento foi atualizado
        Event updatedEvent = [SELECT Id, Feedback__c, CheckInRealizado__c FROM Event WHERE Id = :eventId LIMIT 1];
        System.assertNotEquals(null, updatedEvent);
        System.assertEquals(feedback, updatedEvent.Feedback__c);
        System.assertEquals(true, updatedEvent.CheckInRealizado__c);
    }
    @isTest
    static void testInsereProduto() {
        
        String produto = '01t6e000009ZLkpAAG';
        String cotacao = '0Q06e00000407WACAY';
        
        // Corpo da requisição JSON
        String requestBody = '{"produto": "' + produto + '", "cotacao": "' + cotacao + '"}';
        
        // Simula a requisição REST
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Chama o método REST
        Bot.doPost();
        
    }
    @isTest
    static void testCriaCotacao() {
        
        String produto = '01t6e000009ZLkpAAG';
        String oportunidade = '006U400000FUOlp';
        
        // Corpo da requisição JSON
        String requestBody = '{"produto": "' + produto + '", "oportunidade": "' + oportunidade + '"}';
        
        // Simula a requisição REST
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Chama o método REST
        Bot.doPost();
        
    }
   @isTest
    static void testfinalizaCotacao() {
        
        String cotacao = '0Q06e00000407WACAY';
        String forma = 'Pix';
        String condicao = '5 Dias';
        
		String requestBody = '{"cotacao":"' + cotacao + '","forma":"' + forma + '","condicao":"' + condicao + '"}';
        
        
        // Simula a requisição REST
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Chama o método REST
        Bot.doPost();
        
    } 
}