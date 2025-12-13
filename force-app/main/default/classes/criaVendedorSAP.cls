public class criaVendedorSAP {
    @future(callout=true)
    public static void callEndpoint(Id userId) {
        // Cria a requisição HTTP
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://integracao.hospcom.net/sales-buyer/' + userId);
        req.setMethod('POST');        
        
        // Envia a requisição
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Processa a resposta 
        if (res.getStatusCode() == 200) {
            system.debug(res.getBody());
        } else {
            system.debug(res.getBody());
        }
    }
}