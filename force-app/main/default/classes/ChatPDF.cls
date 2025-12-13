public class ChatPDF {
    //API Key: sec_vexyaM9KizzGxNlRksUtYCnTfr2lcfmM
        


    @AuraEnabled
    public static String sendMessage(String sourceId,  String apiKey,String pergunta) {
        String endpoint = 'https://api.chatpdf.com/v1/chats/message';
        try{
        Map<String, Object> requestBody = new Map<String, Object>{
            'sourceId' => sourceId,
                'messages' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'role' => 'user',
                            'content' => pergunta
                            }
                }
        };
            
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('x-api-key', apiKey);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            String responseContent = res.getBody();
            System.debug('Result: ' + responseContent);
            return responseContent;
        } else {
            String errorMessage = 'Error: ' + res.getStatus() ;
                System.debug(errorMessage);
            String responseContent = res.getBody();
            System.debug('Response: ' + responseContent);  
            throw new AuraHandledException('Error: ' + responseContent); 
            
            
        }
        }catch(Exception e){
             throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }   
    /*public static String createAndReturnExternalFileUrl(String externalFileBase64, String fileName) {
        // Converte o conteúdo base64 em um blob
        Blob fileBlob = EncodingUtil.base64Decode(externalFileBase64);

        // Cria um novo documento personalizado no Salesforce para representar o arquivo externo
        Document customDocument = new Document();
        customDocument.Name = fileName;
        customDocument.Body = fileBlob;
        customDocument.FolderId = '00l53000000vEEw'; // Substitua pelo ID da pasta de documentos personalizados apropriada
        customDocument.ContentType = 'application/pdf'; // Substitua pelo tipo de conteúdo apropriado

        insert customDocument;

        // Obtém o ID do documento personalizado recém-criado
        String customDocumentId = customDocument.Id;

        // Gera o URL público com base no ID do documento personalizado
        String customDocumentUrl = 'https://hospcom--nova3.sandbox.file.force.com' + '/servlet/servlet.FileDownload?file=' + customDocumentId;

        return customDocumentUrl;
    }
    public static void uploadFile() {
        // Seu arquivo base64
        String base64Data = 'JVBERi0xLjMNCiXi48/TDQoNCjEgMCBvYmoNCjw8DQovVHlwZSAvQ2F0YWxvZw0KL091dGxpbmVzIDIgMCBSDQovUGFnZXMgMyAwIFINCj4+DQplbmRvYmoNCg0KMiAwIG9iag0KPDwNCi9UeXBlIC9PdXRsaW5lcw0KL0NvdW50IDANCj4+DQplbmRvYmoNCg0KMyAwIG9iag0KPDwNCi9UeXBlIC9QYWdlcw0KL0NvdW50IDINCi9LaWRzIFsgNCAwIFIgNiAwIFIgXSANCj4+DQplbmRvYmoNCg0KNCAwIG9iag0KPDwNCi9UeXBlIC9QYWdlDQovUGFyZW50IDMgMCBSDQovUmVzb3VyY2VzIDw8DQovRm9udCA8PA0KL0YxIDkgMCBSIA0KPj4NCi9Qcm9jU2V0IDggMCBSDQo+Pg0KL01lZGlhQm94IFswIDAgNjEyLjAwMDAgNzkyLjAwMDBdDQovQ29udGVudHMgNSAwIFINCj4+DQplbmRvYmoNCg0KNSAwIG9iag0KPDwgL0xlbmd0aCAxMDc0ID4+DQpzdHJlYW0NCjIgSg0KQlQNCjAgMCAwIHJnDQovRjEgMDAyNyBUZg0KNTcuMzc1MCA3MjIuMjgwMCBUZA0KKCBBIFNpbXBsZSBQREYgRmlsZSApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY4OC42MDgwIFRkDQooIFRoaXMgaXMgYSBzbWFsbCBkZW1vbnN0cmF0aW9uIC5wZGYgZmlsZSAtICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjY0LjcwNDAgVGQNCigganVzdCBmb3IgdXNlIGluIHRoZSBWaXJ0dWFsIE1lY2hhbmljcyB0dXRvcmlhbHMuIE1vcmUgdGV4dC4gQW5kIG1vcmUgKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NTIuNzUyMCBUZA0KKCB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDYyOC44NDgwIFRkDQooIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjE2Ljg5NjAgVGQNCiggdGV4dC4gQW5kIG1vcmUgdGV4dC4gQm9yaW5nLCB6enp6ei4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjA0Ljk0NDAgVGQNCiggbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDU5Mi45OTIwIFRkDQooIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNTY5LjA4ODAgVGQNCiggQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA1NTcuMTM2MCBUZA0KKCB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBFdmVuIG1vcmUuIENvbnRpbnVlZCBvbiBwYWdlIDIgLi4uKSBUag0KRVQNCmVuZHN0cmVhbQ0KZW5kb2JqDQoNCjYgMCBvYmoNCjw8DQovVHlwZSAvUGFnZQ0KL1BhcmVudCAzIDAgUg0KL1Jlc291cmNlcyA8PA0KL0ZvbnQgPDwNCi9GMSA5IDAgUiANCj4+DQovUHJvY1NldCA4IDAgUg0KPj4NCi9NZWRpYUJveCBbMCAwIDYxMi4wMDAwIDc5Mi4wMDAwXQ0KL0NvbnRlbnRzIDcgMCBSDQo+Pg0KZW5kb2JqDQoNCjcgMCBvYmoNCjw8IC9MZW5ndGggNjc2ID4+DQpzdHJlYW0NCjIgSg0KQlQNCjAgMCAwIHJnDQovRjEgMDAyNyBUZg0KNTcuMzc1MCA3MjIuMjgwMCBUZA0KKCBTaW1wbGUgUERGIEZpbGUgMiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY4OC42MDgwIFRkDQooIC4uLmNvbnRpbnVlZCBmcm9tIHBhZ2UgMS4gWWV0IG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NzYuNjU2MCBUZA0KKCBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY2NC43MDQwIFRkDQooIHRleHQuIE9oLCBob3cgYm9yaW5nIHR5cGluZyB0aGlzIHN0dWZmLiBCdXQgbm90IGFzIGJvcmluZyBhcyB3YXRjaGluZyApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY1Mi43NTIwIFRkDQooIHBhaW50IGRyeS4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NDAuODAwMCBUZA0KKCBCb3JpbmcuICBNb3JlLCBhIGxpdHRsZSBtb3JlIHRleHQuIFRoZSBlbmQsIGFuZCBqdXN0IGFzIHdlbGwuICkgVGoNCkVUDQplbmRzdHJlYW0NCmVuZG9iag0KDQo4IDAgb2JqDQpbL1BERiAvVGV4dF0NCmVuZG9iag0KDQo5IDAgb2JqDQo8PA0KL1R5cGUgL0ZvbnQNCi9TdWJ0eXBlIC9UeXBlMQ0KL05hbWUgL0YxDQovQmFzZUZvbnQgL0hlbHZldGljYQ0KL0VuY29kaW5nIC9XaW5BbnNpRW5jb2RpbmcNCj4+DQplbmRvYmoNCg0KMTAgMCBvYmoNCjw8DQovQ3JlYXRvciAoUmF2ZSBcKGh0dHA6Ly93d3cubmV2cm9uYS5jb20vcmF2ZVwpKQ0KL1Byb2R1Y2VyIChOZXZyb25hIERlc2lnbnMpDQovQ3JlYXRpb25EYXRlIChEOjIwMDYwMzAxMDcyODI2KQ0KPj4NCmVuZG9iag0KDQp4cmVmDQowIDExDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMTkgMDAwMDAgbg0KMDAwMDAwMDA5MyAwMDAwMCBuDQowMDAwMDAwMTQ3IDAwMDAwIG4NCjAwMDAwMDAyMjIgMDAwMDAgbg0KMDAwMDAwMDM5MCAwMDAwMCBuDQowMDAwMDAxNTIyIDAwMDAwIG4NCjAwMDAwMDE2OTAgMDAwMDAgbg0KMDAwMDAwMjQyMyAwMDAwMCBuDQowMDAwMDAyNDU2IDAwMDAwIG4NCjAwMDAwMDI1NzQgMDAwMDAgbg0KDQp0cmFpbGVyDQo8PA0KL1NpemUgMTENCi9Sb290IDEgMCBSDQovSW5mbyAxMCAwIFINCj4+DQoNCnN0YXJ0eHJlZg0KMjcxNA0KJSVFT0YNCg==';
        
        // Converte o arquivo base64 para um blob
        Blob fileBlob = EncodingUtil.base64Decode(base64Data);

        // Crie uma solicitação HTTP
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.chatpdf.com/v1/sources/add-file');
        req.setMethod('POST');
        req.setHeader('x-api-key', 'sec_vexyaM9KizzGxNlRksUtYCnTfr2lcfmM');

        // Construa o corpo da solicitação HTTP
        String body = '--boundary\r\n';
        body += 'Content-Disposition: form-data; name="file"; filename="file.pdf"\r\n';
        body += 'Content-Type: application/pdf\r\n\r\n';
        body += EncodingUtil.base64Encode(fileBlob) + '\r\n';
        body += '--boundary--';

        req.setBody(body);

        // Envie a solicitação HTTP
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Processar a resposta
        if (res.getStatusCode() == 200) {
            String responseJson = res.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
            String sourceId = (String) responseMap.get('sourceId');
            System.debug('Source ID: ' + sourceId);
        } else {
            System.debug('Error: ' + res.getStatus());
            System.debug('Response: ' + res.getBody());
        }
    }
    public static String uploadBS64(String bs64, String chaveKey){
        try{
        String endpoint = 'https://api.chatpdf.com/v1/sources/add-url';
        String apiKey = chaveKey;
        
        //chamar metodo para salvar o documento e retornar o link: 
        String url = bs64;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('x-api-key', apiKey);
        request.setHeader('Content-Type', 'application/json');

        Map<String, String> data = new Map<String, String>();
        data.put('url', url);

        String jsonBody = JSON.serialize(data);
        request.setBody(jsonBody);

        HttpResponse response = new Http().send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String sourceId = (String) responseBody.get('sourceId');
            System.debug('Source ID: ' + sourceId);
            
            Map<String,String> retornFunction = new Map<String,String>();
            
            return sourceId;
            
            
        } else {
            System.debug('Error: ' + response.getStatus() );
            System.debug('Response: ' + response.getBody());
             throw new AuraHandledException('Error: ' + response.getBody()); 
        }
        }catch(Exception e){
             throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
        
    }
    
    public static void deleteSource(String apiKey,String doc) {
        String endpoint = 'https://api.chatpdf.com/v1/sources/delete';
        String[] sources = new String[]{doc};
        Map<String, Object> requestData = new Map<String, Object>{
            'sources' => sources
        };

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('x-api-key', apiKey);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(requestData));

        HttpResponse response = new Http().send(request);

        if (response.getStatusCode() == 200) {
            // Sucesso
            System.debug('Success');
        } else {
            // Erro
            System.debug('Error: ' + response.getStatus());
            System.debug('Response: ' + response.getBody());
        }
    }*/
    
}