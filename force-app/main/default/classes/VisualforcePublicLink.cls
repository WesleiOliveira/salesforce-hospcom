public class VisualforcePublicLink {
    @AuraEnabled
    public static String uploadPDF(String fileName, String pagina, String idPC) {
        PageReference pdf = new PageReference('/apex/' + pagina);
        pdf.getParameters().put('id', idPC);
        
        Blob pdfBody;
        
        if (!Test.isRunningTest()) {
            pdfBody = pdf.getContentAsPDF();
        } else {
            pdfBody = Blob.valueOf('Teste');
        }
        String base64PDF = EncodingUtil.base64Encode(pdfBody);
        system.debug(base64PDF);     
        
        // URL do endpoint do WordPress
        String url = 'http://apphospcom.kinghost.net:21220/uploadPDFWP';
        
        // Credenciais de autenticação
        
        // Configurar o HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        
        String body = '{"file":"' + base64PDF + '","nomeArquivo":"' + fileName + '"}';
        
        system.debug(body);
        
        req.setBody(body);
        
        // Enviar a solicitação HTTP
        Http http = new Http();
        HttpResponse res;
        
        try {
            res = http.send(req);
            System.debug('Response Status: ' + res.getStatus());
            System.debug('Response Body: ' + res.getBody());
            if (res.getStatusCode() == 200) { // Código de status 200 indica criação bem-sucedida
                string resposta = res.getBody();
                string link = resposta.substringAfter('"rendered":"').substringBefore('","r');
                return link;
            } else {
                throw new CalloutException('Failed to upload PDF: ' + res.getStatus());
            }
        } catch (Exception e) {
            throw new CalloutException('Exception: ' + e.getMessage());
        }
    }
}