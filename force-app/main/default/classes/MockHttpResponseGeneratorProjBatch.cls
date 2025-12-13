@isTest
global class MockHttpResponseGeneratorProjBatch implements HttpCalloutMock {
    private HttpResponse response;
    
    public MockHttpResponseGeneratorProjBatch(HttpResponse response) {
        this.response = response;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        return response;
    }
}