public with sharing class ApexHelperController {
    @AuraEnabled
    public static List<sObject> executeSoql(String soql) {
        List<sObject> result = Database.query(soql);
        return result;
        
    }
    
    @AuraEnabled
    public static Map<String, String> obterTiposDeRegistros(String nomeObjeto) {
        Map<String, String> tiposDeRegistros = new Map<String, String>();
        
        // Consultar os metadados do objeto
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = globalDescribe.get(nomeObjeto);
        if (objectType != null) {
            Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
            
            // Obter informações sobre os tipos de registros
            Map<String, Schema.RecordTypeInfo> recordTypes = objDescribe.getRecordTypeInfosByName();
            
            for (String recordTypeName : recordTypes.keySet()) {
                Schema.RecordTypeInfo recordTypeInfo = recordTypes.get(recordTypeName);
                tiposDeRegistros.put(recordTypeName, recordTypeInfo.getRecordTypeId());
            }
        }
        
        return tiposDeRegistros;
    }
    
    
    
    
    
    
    @AuraEnabled
    public static List<String> listagem(String nomeObjeto,  String nomeCampo){
        // String nomeObjeto = 'WorkOrder';
        //String nomeCampo = 'T_cnico_Respons_vel__c';
        List<String> valoresListaOpcao = new List<String>();
        
        // Consultar os metadados do campo
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = globalDescribe.get(nomeObjeto);
        if (objectType != null) {
            Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
            Map<String, Schema.SObjectField> fields = objDescribe.fields.getMap();
            
            // Verificar se o campo existe e é do tipo picklist
            if (fields.containsKey(nomeCampo)) {
                Schema.DescribeFieldResult fieldDescribe = fields.get(nomeCampo).getDescribe();
                
                if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
                    List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
                    
                    // Adicionar valores à lista
                    for (Schema.PicklistEntry entry : picklistValues) {
                        valoresListaOpcao.add(entry.getValue());
                    }
                } else {
                    System.debug('O campo não é um picklist.');
                }
            } else {
                System.debug('O campo não existe no objeto.');
            }
        }
        
        System.debug(valoresListaOpcao);
        
        return valoresListaOpcao;
    }
    
    
    @AuraEnabled
    public static string saveDoc(String text, String name, String dataType, String contentType, String folderName){
        
        List<Folder> pastaLog = ([SELECT id FROM Folder WHERE Name = :folderName]);
        
        Document doc = new Document(
            Name = name,
            Body = Blob.valueOf(text),
            ContentType = contentType,
            Type = dataType,
            IsPublic = true,
            FolderId = pastaLog[0].Id        
        );
        insert doc;
        
        return doc.Id;
    }    
    
    
    
    
    @AuraEnabled
    public static void changeStatusPurchaseOrder(String id){
        Fornecedor__c f = new Fornecedor__c();
        f.id = id;
        f.Status_do_PC__c = 'Ativo';
        update f;
    }
    
    @AuraEnabled
    public static void changeStatusSalesOrder(String id){
        Order o = new Order();
        o.id = id;
        //o.Acao_interna__c = true;
        //update o;
        
        o.Status = 'Ativo';
        
        Util.AcaoInterna(true);
        update o;
        
        if(o.OpportunityId != null) {
            Opportunity opp = new Opportunity();
            opp.id = o.OpportunityId;
            opp.StageName = 'WIN';
            opp.Sub_Fase__c = 'FINALIZADO TOTAL';
            update opp;
        }
        
        Util.AcaoInterna(false);
        
        
        //update o;
        
        //o.Acao_interna__c = false;
        //update o;
    }
    
    @AuraEnabled
    public static void updateOrderAdress(string id, string type, string street, string city, string state, string postalcode){
        Order o = new Order();
        o.Id = id;
        if (type == 'Cobranca') {
            o.BillingStreet = street;
            o.BillingCity = city;
            o.BillingState = state;
            o.BillingPostalCode = postalcode;
        }
        if (type == 'Entrega') {
            o.ShippingStreet = street;
            o.ShippingCity = city;
            o.ShippingState = state;
            o.ShippingPostalCode = postalcode;
        }
        update o;
    }
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
        String url = 'http://integracao.hospcom.net:21220/uploadPDFWP';
        
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
    @AuraEnabled
    public static String sendToChatGPT(String ownerId) {
        try {
            // Get the current month
            Date today = Date.today();
            Date startOfMonth = today.toStartOfMonth();
            Date endOfMonth = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
            
            // Query opportunities
            List<Opportunity> opportunities = [
                SELECT Id, Account.Name, Forecast__c, CloseDate, Owner.Name, StageName
                FROM Opportunity
                WHERE CloseDate >= :startOfMonth
                AND CloseDate <= :endOfMonth
                AND OwnerId = :ownerId
                AND StageName NOT IN('LOSS')
            ];
            
            // Query goals
            List<Goal__c> goals = [
                SELECT Id, Meta__c
                FROM Goal__c
                WHERE Vendedor__c = :ownerId
                AND Inicio__c >= :startOfMonth
                AND Final__c <= :endOfMonth
                AND Periodo__c = 'Mensal'
                AND Linha__c = ''
            ];
            
            // Query orders to get total sales
            List<Order> orders = [
                SELECT TotalAmount
                FROM Order
                WHERE Vendedor__c = :ownerId
                AND Status IN ('Ativo', 'Em Andamento', 'Entregue Parcial', 'Entregue Total')
                AND Data_de_ativacao__c >= :startOfMonth
                AND Data_de_ativacao__c <= :endOfMonth
            ];
            
            // Calculate total sales from orders
            Decimal totalSales = 0;
            for (Order ord : orders) {
                totalSales += ord.TotalAmount;
            }
            
            // Create JSON data
            Map<String, Object> jsonData = new Map<String, Object>();
            List<Map<String, Object>> oppDetails = new List<Map<String, Object>>();
            
            for (Opportunity opp : opportunities) {
                oppDetails.add(new Map<String, Object> {
                    'Id' => opp.Id,
                        'AccountName' => opp.Account.Name,
                        'StageName' => opp.StageName,
                        'Forecast' => opp.Forecast__c,
                        'CloseDate' => opp.CloseDate.format(), // Format Date to String
                        'Vendedor' => opp.Owner.Name // Format Date to String
                        });
            }
            
            jsonData.put('opportunities', oppDetails);
            Decimal goal = (goals.size() > 0) ? goals[0].Meta__c : 0;
            jsonData.put('goal', goal);
            jsonData.put('totalSales', totalSales); // Add total sales to the JSON data
            
            String jsonPayload = JSON.serialize(jsonData);
            System.debug('JSON Payload: ' + jsonPayload);
            
            // Configure request for ChatGPT
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.openai.com/v1/chat/completions');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer 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'); // Replace with your API key
            request.setTimeout(120000);  // Set timeout to 120 seconds (in milliseconds)
            
            // Messages for ChatGPT
            List<Map<String, String>> messages = new List<Map<String, String>>();
            messages.add(new Map<String, String>{ 'role' => 'system', 'content' => 'Você é um assistente útil que analisa dados financeiros.' });
            messages.add(new Map<String, String>{ 'role' => 'user', 'content' => 'Analise os dados fornecidos. Determine o total do forecast para o mês atual e compare com a meta (que é o ' + goal +', informando quanto falta para atingi-la. Os dados informam o nome do vendedor, o StageName da opp (OPEN, UPSIDE, UPSIDE HIGH, COMITED) quanto mais próximo de committed, melhor, realce as fases em que a opp está, e diga o nome do vendedor na análise retornada. Sua análise deve ser estritamente relacionada com os dados fornecidos, caso voce nao saiba, consulte novamente sua base e entenda do assunto, nao gere informações aleatorias. O correto é analisar o valor já vendido e somá-lo com o forecast (que é a previsão do que vai vender ainda).  O total de vendas já realizadas é: ' + totalSales + '. Aqui estão os dados: ' + jsonPayload });
            
            Map<String, Object> body = new Map<String, Object> {
                'model' => 'gpt-4',
                    'messages' => messages,
                    'max_tokens' => 150
                    };
                        
                        request.setBody(JSON.serialize(body));
            System.debug('Request Body: ' + JSON.serialize(body));
            
            // Send the request
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Deserialize the response to access only the content
                ChatGPTResponse chatResponse = (ChatGPTResponse)JSON.deserialize(response.getBody(), ChatGPTResponse.class);
                
                // Debugging only the content of the first choice message
                if (chatResponse.choices != null && !chatResponse.choices.isEmpty()) {
                    System.debug('ChatGPT Response Content: ' + chatResponse.choices[0].message.content);
                    return chatResponse.choices[0].message.content; // Return the content of the response
                } else {
                    System.debug('No content found in the response');
                    return 'Nenhuma resposta recebida.';
                }
            } else {
                System.debug('Response Error: ' + response.getBody());
                return 'Erro: ' + response.getStatusCode() + ' - ' + response.getBody();
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return 'Erro ao enviar requisição: ' + e.getMessage();
        }
    }
    // Top-level class for ChatGPTResponse
    public class ChatGPTResponse {
        public List<ChatGPTChoice> choices;
    }
    
    // Top-level class for ChatGPTChoice
    public class ChatGPTChoice {
        public ChatGPTMessage message;
    }
    
    // Top-level class for ChatGPTMessage
    public class ChatGPTMessage {
        public String role;
        public String content;
    }
    //Devolução de itens
    @AuraEnabled
    public static void updateRecords(String recordsJson) {
        List<Item_da_Solicita_o_de_devolu_o__c> records = 
            (List<Item_da_Solicita_o_de_devolu_o__c>)JSON.deserialize(recordsJson, List<Item_da_Solicita_o_de_devolu_o__c>.class);
        
        update records;
    }
    @AuraEnabled
    public static void saveConcorrentesApex(String concorrentes, Id oportunidadeId, id produto) {
        system.debug(concorrentes + ' ' + oportunidadeId + ' ' + produto);
        List<Analise_de_Mercado__c> analisesToInsert = new List<Analise_de_Mercado__c>();
        List<ConcorrenteData> concorrenteList = (List<ConcorrenteData>) JSON.deserialize(concorrentes, List<ConcorrenteData>.class);
        
        // Prepara os concorrentes para inserção
        for (ConcorrenteData conc : concorrenteList) {
            Analise_de_Mercado__c am = new Analise_de_Mercado__c();
            am.Concorrente__c = conc.accountId;  // ID da conta
            am.Oportunidade__c = oportunidadeId;
            am.Produto_da_oportunidade__c = produto;
            am.Situacao__c = conc.situacao;
            am.Motivo__c = conc.motivo;
            am.Modelo_ofertado__c = conc.modelo;
            if (conc.precoUnitario != null && !String.isBlank(conc.precoUnitario)) {
                try {
                    String precoStr = conc.precoUnitario.replaceAll('\\.', '').replaceAll(',', '.');
                    am.Preco_unitario__c = Decimal.valueOf(precoStr.trim());
                } catch (Exception e) {
                    throw new AuraHandledException('Valor unitário inválido: ' + conc.precoUnitario + ' -> ' + e.getMessage());
                }
            }
            
            if (conc.precoTotal != null && !String.isBlank(conc.precoTotal)) {
                try {
                    String precoTotalStr = conc.precoTotal.replaceAll('\\.', '').replaceAll(',', '.');
                    am.Valor_total__c = Decimal.valueOf(precoTotalStr.trim());
                } catch (Exception e) {
                    throw new AuraHandledException('Valor total inválido: ' + conc.precoTotal + ' -> ' + e.getMessage());
                }
            }
            am.Marca__c = conc.marca; 
            am.Observacoes__c = conc.obs;
            analisesToInsert.add(am);
            
        }
        
        // Insere os concorrentes no Salesforce
        if (!analisesToInsert.isEmpty()) {
            try{
                insert analisesToInsert;
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    
    // Classe interna para representar os dados do concorrente
    public class ConcorrenteData {
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String marca { get; set; }
        @AuraEnabled public String motivo { get; set; }
        @AuraEnabled public String situacao { get; set; }
        @AuraEnabled public String modelo { get; set; }
        @AuraEnabled public String precoUnitario { get; set; }
        @AuraEnabled public String precoTotal { get; set; }
        @AuraEnabled public String obs { get; set; }
    }
}