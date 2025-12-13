@isTest
global class MonkverificaWhatsapp implements HttpCalloutMock {
   
    global HTTPResponse respond(HTTPRequest req) {
       
        HttpResponse res = new HttpResponse();        
        res.setStatusCode(200);
        res.setBody('{"status": true,"error": "Número é WhatsApp"}');
           return res;
    }
}