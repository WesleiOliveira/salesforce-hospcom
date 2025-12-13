/*public with sharing class UploadImageController {
    @AuraEnabled
    public static Map<String, Object> uploadImage(String base64Data, String fileName) {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        
            // Montando o corpo da requisição com a imagem em Base64
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://integracao.hospcom.net/receberArquivo');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            
            // Criando o JSON para enviar a imagem
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('fileName', fileName);
            payload.put('base64Data', base64Data);
            
            // Convertendo o payload em JSON
            String jsonBody = JSON.serialize(payload);
            request.setBody(jsonBody);

            // Enviando a requisição
            Http http = new Http();
            HttpResponse response = http.send(request);

            // Verificando a resposta da API
            Integer statusCode = response.getStatusCode();
            if (statusCode == 200) {
                responseMap.put('success', true);
                responseMap.put('message', 'Arquivo enviado com sucesso.');
            } 

        return responseMap;
    }
}*/



public with sharing class UploadImageController {
    @AuraEnabled
    public static Map<String, Object> uploadImage(String base64Data, String fileName) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://integracao.hospcom.net/receberArquivo');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('fileName', fileName);
            payload.put('base64Data', base64Data);
            
            String jsonBody = JSON.serialize(payload);
            request.setBody(jsonBody);

            Http http = new Http();
            HttpResponse response = http.send(request);

            Integer statusCode = response.getStatusCode();
            if (statusCode == 200) {
                responseMap.put('success', true);
                responseMap.put('message', 'Arquivo enviado com sucesso.');
            } else {
                responseMap.put('success', false);
                responseMap.put('message', 'Falha ao enviar arquivo.');
            }
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }
}






/*public with sharing class UploadImageController {
    @AuraEnabled
    public static Map<String, Object> uploadImage(String base64Data, String fileName) {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            // Montando o corpo da requisição com a imagem em Base64
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://integracao.hospcom.net/receberArquivo');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            
            // Criando o JSON para enviar a imagem
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('fileName', fileName);
            payload.put('base64Data', base64Data);
            
            // Convertendo o payload em JSON
            String jsonBody = JSON.serialize(payload);
            request.setBody(jsonBody);

            // Enviando a requisição
            Http http = new Http();
            HttpResponse response = http.send(request);

            // Verificando a resposta da API
            if (response.getStatusCode() == 200) {
                responseMap.put('success', true);
                responseMap.put('message', 'Arquivo enviado com sucesso.');
            } else {
                responseMap.put('success', false);
                responseMap.put('message', 'Erro ao enviar imagem. Código: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', 'Erro: ' + e.getMessage());
        }

        return responseMap;
    }
}*/