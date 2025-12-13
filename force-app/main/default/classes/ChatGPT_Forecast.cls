public class ChatGPT_Forecast {
    
    public String sendToChatGPT(String ownerId) {
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
    
}