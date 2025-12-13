public class anexaTaxasPC {
    
    // Etapa 1: Salva o arquivo PDF e retorna o link público
    @AuraEnabled
    public static String uploadPdfAndGetPublicUrl(String recordId, String fileName, String base64Data) {
        try {
            // Decode base64
            Blob fileBody = EncodingUtil.base64Decode(base64Data);
            
            // Step 1: Save the file as ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName + '.pdf';
            cv.VersionData = fileBody;
            insert cv;
            
            // Get ContentDocumentId
            ContentVersion insertedCv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            String contentDocId = insertedCv.ContentDocumentId;
            
            // Step 2: Link to record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V'; // Viewer
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            // Step 3: Create public distribution
            ContentDistribution cd = new ContentDistribution();
            cd.Name = fileName;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            insert cd;
            
            ContentDistribution cdd = [SELECT ID, ContentDownloadUrl FROM ContentDistribution WHERE ID =: cd.Id];
            
            return cdd.ContentDownloadUrl;
            
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao salvar e publicar o arquivo: ' + e.getMessage());
        }
    }
    // Etapa 2: Após o commit, o front ou outro processo deve chamar isso separadamente
    @AuraEnabled
    public static void processarPdfViaChatPdf(String publicUrl, String fileName, Id recordId) {
        // Faz a chamada ao ChatPDF
        List<Object> linhas = callChatPDF(publicUrl);
        
        if (linhas != null && !linhas.isEmpty()) {
            createPagamentosFromJson(linhas, fileName, recordId);
        }
    }
    
    // Chamada para o ChatPDF (add-url)
    private static List<Object> callChatPDF(String publicUrl) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.chatpdf.com/v1/sources/add-url');
        req.setMethod('POST');
        req.setHeader('x-api-key', 'sec_T95EmfGFExwyIVftNVu9ZZEJUF1rxiiu');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeOut(120000);
        req.setBody(JSON.serialize(new Map<String, Object>{ 'url' => publicUrl }));
        
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String sourceId = (String) parsed.get('sourceId');
            system.debug(sourceId);
            return perguntarImpostos(sourceId);
        } else {
            System.debug('Erro ao enviar URL para ChatPDF: ' + res.getBody());
            return null;
        }
    }
    
    // Chamada para extrair impostos
    private static List<Object> perguntarImpostos(String sourceId) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.chatpdf.com/v1/chats/message');
        req.setMethod('POST');
        req.setHeader('x-api-key', 'sec_T95EmfGFExwyIVftNVu9ZZEJUF1rxiiu');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeOut(120000);
        
        String prompt = 'Extraia todos os impostos e taxas que aparecem no PDF, especialmente os que estiverem em tabelas. ' +
            'Liste com dois campos: "descricao" e "valor" (em reais). Não retorne NADA ALÉM DO JSON, POR FAVOR NÃO RETORNE MARCADORES NEM QUEBRAS DE LINHA NO JSON. Exemplo: [{"descricao": "ICMS", "valor": 2500.00}]';
        
        req.setBody(JSON.serialize(new Map<String, Object>{
            'sourceId' => sourceId,
                'messages' => new List<Object>{
                    new Map<String, Object>{
                        'role' => 'user',
                            'content' => prompt
                            }
                }
        }));
        
        HttpResponse res = http.send(req);
        
        system.debug('Resposta chat com PDF: ' + res.getBody());
        
        if (res.getStatusCode() == 200) {
            try {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String content = String.valueOf(result.get('content'));
                //content = content.replaceAll('json', '').replaceAll('', '').replaceAll('\\n', '').trim();
                //content = content.substring(content.indexOf('['), content.lastIndexOf(']') + 1);
                List<Object> dados = (List<Object>) JSON.deserializeUntyped(content);
                
                return dados;
            } catch (Exception e) {
                System.debug('Erro ao interpretar resposta do ChatPDF: ' + e.getMessage());
            }
        }
        
        return null;
    }
    
    // Cria registros de pagamento a partir da resposta JSON
    private static void createPagamentosFromJson(List<Object> linhas, String nome, String idPedido) {
        List<Pagamento_importacao__c> pagamentos = new List<Pagamento_importacao__c>();
        
        for (Object itemObj : linhas) {
            Map<String, Object> item = (Map<String, Object>) itemObj;
            Pagamento_importacao__c pag = new Pagamento_importacao__c();
            pag.Pedido_de_compra__c = idPedido;
            
            if (item.containsKey('descricao')) {
                pag.Descricao__c = String.valueOf(item.get('descricao'));
            }
            if (item.containsKey('valor')) {
                try {
                    pag.Valor_previsto__c = Decimal.valueOf(String.valueOf(item.get('valor')));
                } catch (Exception e) {
                    System.debug('Erro ao converter valor: ' + item.get('valor'));
                }
            }
            
            pagamentos.add(pag);
        }
        
        if (!pagamentos.isEmpty()) {
            insert pagamentos;
        }
    }
}