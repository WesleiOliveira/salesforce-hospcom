@IsTest
global class MockCriaVendedorSAP implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        // Cria uma resposta simulada
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success": true}');
        res.setStatusCode(200);
        return res;
    }
}