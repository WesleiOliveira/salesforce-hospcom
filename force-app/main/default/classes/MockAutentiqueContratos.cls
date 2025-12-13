@isTest
global class MockAutentiqueContratos implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setStatusCode(200);
        res.setBody('0a0f9d77732d1c36e7e611d0b6f73715d6ec6a363e9acc4a0$6${"name":"CHRISLYNNEFLORENCIODESOUSA","email":"luizpeixoto93@gmail.com"}${"name":"NomeTestemunha","email":"suporteflint@gmail.com"}${"name":"NomeJuridico","email":"arrudawillyan31@gmail.com"}${"name":"NomeDiretoria","email":"luizfernandopeixoto@outlook.com"}${"name":"NomeTestemunhaDiretoria","email":"xicakof435@niekie.com"}${"name":"NomeFinanceiro","email":"arrudawillyan31@hotmail.com"}');
        return res;
    }
}