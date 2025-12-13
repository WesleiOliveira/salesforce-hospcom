// Classe Mock para simular a resposta HTTP
@isTest
public class MockHttpResponseGenerato2r implements HttpCalloutMock {
    private String jsonResponse;

    public MockHttpResponseGenerato2r(String jsonResponse) {
        this.jsonResponse = jsonResponse;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonResponse);
        res.setStatusCode(200);
        return res;
    }
}