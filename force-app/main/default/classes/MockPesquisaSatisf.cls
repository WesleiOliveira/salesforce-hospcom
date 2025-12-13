@isTest
global class MockPesquisaSatisf implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(201);
        return res;
    }
}