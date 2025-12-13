@RestResource(urlMapping='/botListener')
global without sharing class Bot {
    @HttpPost
    global static void doPost() {
        // Obtém os dados da requisição
        String requestBody = RestContext.request.requestBody.toString();
        
        // Deserializa o corpo da requisição para o objeto BotRequest
        BotRequest request = (BotRequest)JSON.deserialize(requestBody, BotRequest.class);
        
        Map<String, String> responseMap = new Map<String, String>();
        
        if(request.AccountId != null){
            // Aqui você pode utilizar os dados deserializados, como criar a oportunidade ou realizar outras ações
            Opportunity opp = new Opportunity();
            opp.AccountId = request.AccountId;
            opp.Name = request.OpportunityName;
            opp.CloseDate = date.valueOf(request.DataFechamento);
            opp.RecordTypeId = '0125A000000y34A';
            opp.StageName = 'OPEN';
            opp.Departamento__c = 'Comercial';
            opp.Sub_Fase__c = 'COTAÇÃO PRÉVIA';
            opp.Modalidade__c = 'COTAÇÃO PRÉVIA';
            opp.Pricebook2Id = '01s5A000004fbcR';
            opp.Faturamento_Feito2__c = '001i00000085QYb';
            
            try{
                insert opp;
                responseMap.put('status', 'success');
                responseMap.put('message', 'Opportunity created successfully');
                responseMap.put('id', opp.Id);
                String responseBody = JSON.serialize(responseMap);
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
            catch(Exception e){
                RestContext.response.responseBody = Blob.valueOf('ERRO: ' + e.getMessage());              
            }
            
        }
        if(request.feedback != null){
            Event compromisso = [SELECT ID FROM EVENT WHERE ID = : request.eventId];
            compromisso.checkInRealizado__c = true;
            compromisso.Feedback__c = request.feedback;
            compromisso.Contato__c = request.contato;
            try{
                update compromisso;
                responseMap.put('status', 'success');
                responseMap.put('message', 'Check-out realizado com sucesso');
                String responseBody = JSON.serialize(responseMap);
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
            catch(Exception e){
                RestContext.response.responseBody = Blob.valueOf('ERRO: ' + e.getMessage());              
            }
        }
        if(request.forma != null){
            quote cotacao = [SELECT ID FROM Quote WHERE ID = : request.cotacao];
            cotacao.Forma_de_pagamento__c = request.forma;
            cotacao.Condicao_de_pagamento__c = request.condicao;
            try{
                update cotacao;
              
                responseMap.put('status', 'success');
                String responseBody = JSON.serialize(responseMap);
                
                RestContext.response.responseBody = blob.valueOf(responseBody);
                
            }
            catch(Exception e){
                RestContext.response.responseBody = Blob.valueOf('ERRO: ' + e.getMessage());              
            }
        }
        
        if(request.produto != null && request.oportunidade != null){
            quote cotacao = new quote();
            cotacao.OpportunityId = request.oportunidade;
            cotacao.Name = 'COTAÇÃO TESTE';
            cotacao.Data_de_emissao__c = system.today();
            try{
                insert cotacao;
                responseMap.put('status', 'success');
                responseMap.put('message', 'Opportunity created successfully');
                responseMap.put('id', cotacao.Id);
                String responseBody = JSON.serialize(responseMap);
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
            catch(Exception e){
                RestContext.response.responseBody = Blob.valueOf('ERRO: ' + e.getMessage());              
            }
        }
        
        if(request.produto != null && request.cotacao != null){
            Boolean sincronizado = false;
            
            Product2 item = [SELECT ID, Name, Description FROM Product2 WHERE ID =: request.produto];
            AggregateResult result = [SELECT MAX(ITEM_PAI__C) maxItem FROM QuoteLineItem WHERE QuoteId =: request.cotacao];
            Integer max = (result != null && result.get('maxItem') != null) ? ((Decimal)result.get('maxItem')).intValue() : 0;
            Integer n_item = max + 1;
            
            // Busca a entrada da tabela de preços do produto pai
            PricebookEntry pbePai = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :request.produto AND Pricebook2Id IN (SELECT Pricebook2Id FROM Quote WHERE Id = :request.cotacao) AND CurrencyISOCode = 'BRL' LIMIT 1];
            
            // Insere o produto pai na cotação
            QuoteLineItem itemPai = new QuoteLineItem(
                QuoteId = request.cotacao,
                PricebookEntryId = pbePai.Id,
                UnitPrice = pbePai.UnitPrice,
                Descricao_da_linha__c = item.Description,
                Quantity = 1,
                Discount = 0,
                NaoAcionar__c = true,
                Item__c = n_item
            );
            
            try {
                insert itemPai;
                responseMap.put('status', 'success');
                String responseBody = JSON.serialize(responseMap);
                RestContext.response.responseBody = Blob.valueOf(responseBody);                
            } catch (DmlException e) {
                System.debug(e);
                responseMap.put('status', 'error');
                responseMap.put('erro', e.getMessage());
                String responseBody = JSON.serialize(responseMap);
                RestContext.response.responseBody = Blob.valueOf(responseBody);            
            }
            
            System.debug('ITEM: ' + itemPai.Id);
            
            // Busca a lista dos produtos filhos (acessórios do equipamento)
            List<Produto_Filho__c> produtosFilhos = [SELECT Produto_Filho__c, Quantidade__c FROM Produto_Filho__c WHERE Produto_Pai__c = :request.produto ORDER BY Produto_Filho__r.Id];
            
            if (!produtosFilhos.isEmpty()) {
                // Coleta os IDs dos produtos filhos e suas quantidades
                Set<Id> idsProdutosFilhos = new Set<Id>();
                List<Decimal> quantidades = new List<Decimal>();
                for (Produto_Filho__c produtoFilho : produtosFilhos) {
                    idsProdutosFilhos.add(produtoFilho.Produto_Filho__c);
                    quantidades.add(produtoFilho.Quantidade__c);
                }
                
                // Procura a entrada da tabela de preços dos produtos filhos
                List<PricebookEntry> entradasPBFs = [SELECT ID, UnitPrice FROM PricebookEntry WHERE Product2Id IN :idsProdutosFilhos AND Pricebook2Id IN (SELECT Pricebook2Id FROM Quote WHERE Id = :request.cotacao) AND CurrencyISOCode = 'BRL' ORDER BY Product2Id];
                
                // Insere cada acessório na cotação dentro do equipamento
                List<QuoteLineItem> produtosInserir = new List<QuoteLineItem>();
                Integer index = 0;
                for (PricebookEntry pbeFilho : entradasPBFs) {
                    QuoteLineItem itemFilho = new QuoteLineItem(
                        QuoteId = request.cotacao,
                        PricebookEntryId = pbeFilho.Id,
                        UnitPrice = pbeFilho.UnitPrice,
                        Quantity = quantidades[index],
                        NaoAcionar__c = true,
                        Discount = 0,
                        Item_Pai__c = itemPai.Item__c
                    );
                    produtosInserir.add(itemFilho);
                    index++;
                }
                
                try {
                    insert produtosInserir;
                    responseMap.put('status', 'success');
                    String responseBody = JSON.serialize(responseMap);
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                    
                } catch (DmlException error) {
                    System.debug(error);
                    responseMap.put('status', 'error');
                    responseMap.put('erro', error.getMessage());
                    String responseBody = JSON.serialize(responseMap);
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                    
                }
            }
            Opportunity opp = [SELECT ID, SyncedQuoteId FROM Opportunity WHERE ID IN (SELECT OpportunityId FROM Quote WHERE ID = :request.cotacao) LIMIT 1];
            
            if (sincronizado) {
                opp.SyncedQuoteId = request.cotacao;
                update opp; // Sincroniza
            }
        }
    }
    
    public class BotRequest {
        public String AccountId;
        public String OpportunityName;
        public String DataFechamento;        
        
        
        public String eventId;
        public String feedback;
        public String contato;
        
        public String oportunidade;
        public String produto;
        public String cotacao;
        public String forma;
        public String condicao;
    }
    
}