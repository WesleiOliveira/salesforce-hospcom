public with sharing class HttpConsult {
    public String request(String url, String method, String body, Map<String,String> header){
		//Função para fazer requisição http, basta passar url, method, body e header, caso não tenha body e/ou header basta passar como nulos
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setTimeout(120000);
        req.setMethod(method);
		if(header != null && header.size() > 0)
            for(String key:header.keySet())
                req.setHeader(key, header.get(key));
        if(body != null)
            req.setBody(body);
        Http http = new Http();
        HTTPresponse res = http.send(req);
        return res.getBody();
    }
}