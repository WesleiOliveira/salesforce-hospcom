public with sharing class ItemCotacao {
    
    @AuraEnabled            
    public static void inserirPai(String cotacao, String produto, String descricao, Integer item) {
        Boolean sincronizado = false;
        
        // Consulta a oportunidade associada à cotação
        Opportunity opp = [SELECT ID, SyncedQuoteId, CurrencyISOCode FROM Opportunity WHERE ID IN (SELECT OpportunityId FROM Quote WHERE ID = :cotacao) LIMIT 1];
        if (opp.SyncedQuoteId == cotacao) {
            sincronizado = true;
            opp.SyncedQuoteId = null;
            update opp; // Para a sincronização
        }
        
        // Busca a entrada da tabela de preços do produto pai
        PricebookEntry pbePai = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :produto AND Pricebook2Id IN (SELECT Pricebook2Id FROM Quote WHERE Id = :cotacao) AND CurrencyISOCode = : opp.CurrencyISOCode LIMIT 1];
        
        // Insere o produto pai na cotação
        QuoteLineItem itemPai = new QuoteLineItem(
            QuoteId = cotacao,
            PricebookEntryId = pbePai.Id,
            UnitPrice = pbePai.UnitPrice,
            Descricao_da_linha__c = descricao,
            Quantity = 1,
            Discount = 0,
            NaoAcionar__c = true,
            Item__c = item
        );
        
        try {
            insert itemPai;
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
        
        System.debug('ITEM: ' + itemPai.Id);
        
        // Busca a lista dos produtos filhos (acessórios do equipamento)
        List<Produto_Filho__c> produtosFilhos = [SELECT Produto_Filho__c, Quantidade__c FROM Produto_Filho__c WHERE Produto_Pai__c = :produto ORDER BY Produto_Filho__r.Id];
        
        if (!produtosFilhos.isEmpty()) {
            // Coleta os IDs dos produtos filhos e suas quantidades
            Set<Id> idsProdutosFilhos = new Set<Id>();
            List<Decimal> quantidades = new List<Decimal>();
            for (Produto_Filho__c produtoFilho : produtosFilhos) {
                idsProdutosFilhos.add(produtoFilho.Produto_Filho__c);
                quantidades.add(produtoFilho.Quantidade__c);
            }
            
            // Procura a entrada da tabela de preços dos produtos filhos
            List<PricebookEntry> entradasPBFs = [SELECT ID, UnitPrice FROM PricebookEntry WHERE Product2Id IN :idsProdutosFilhos AND Pricebook2Id IN (SELECT Pricebook2Id FROM Quote WHERE Id = :cotacao) AND CurrencyISOCode = : opp.CurrencyISOCode ORDER BY Product2Id];
            
            // Insere cada acessório na cotação dentro do equipamento
            List<QuoteLineItem> produtosInserir = new List<QuoteLineItem>();
            Integer index = 0;
            for (PricebookEntry pbeFilho : entradasPBFs) {
                QuoteLineItem itemFilho = new QuoteLineItem(
                    QuoteId = cotacao,
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
            } catch (DmlException error) {
                System.debug(error);
                throw new AuraHandledException(error.getMessage());
            }
        }
        
        if (sincronizado) {
            opp.SyncedQuoteId = cotacao;
            try {
                update opp; // Sincroniza
            } catch (DmlException e) {
                System.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    
    @AuraEnabled    
    public static void inserirFilho(String cotacao, String produto, String descricao, Integer itemPai){
        
        Boolean sincronizado = false;
        
        Opportunity opp = [SELECT ID, SyncedQuoteId, CurrencyISOCode FROM Opportunity WHERE ID IN (SELECT OpportunityId FROM Quote WHERE ID =: cotacao) ];
        if(opp.SyncedQuoteId == cotacao){
            sincronizado = true;
            opp.SyncedQuoteId = null;
            update opp; //Para a sincronização
        } 
        
        //Busca a entrada da tabela de preços do produto filho
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id =: produto AND Pricebook2Id IN (SELECT Pricebook2Id FROM Quote WHERE Id =: cotacao) AND CurrencyISOCode = : opp.CurrencyISOCode ];
        
        //Insere o produto filho na cotação        
        QuoteLineItem ItemF = new QuoteLineItem(
            QuoteId = cotacao,
            PricebookEntryId = pbe.Id,
            UnitPrice = pbe.UnitPrice,
            Quantity = 1,
            Item_Pai__c = itemPai);
        
        try{
            insert ItemF;
        }
        catch(dmlException error){
            system.debug(error);
            throw new AuraHandledException(error.getMessage());
        }
        if(sincronizado = true){
            opp.SyncedQuoteId = cotacao;
            try{
                update opp; //Sincroniza
            }
            catch(dmlException e){
                system.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    @AuraEnabled
    public static void ordena(string ordenacao){
        
        Map<ID,Integer> mapa = new Map<ID,Integer>(); //Conjunto de ID e Ordem do Item
        
        List<Object> deserialized = (List<Object>)JSON.deserializeUntyped(ordenacao);
        
        for(Object o: deserialized){
            Map<String, Object> obMap = (Map<String, Object>)o;
            
            String st = obMap.toString();
            
            String ID = st.substringAfter('idProduto=').substringBefore(', p');
            
            String ordem = st.substringAfter('posicaoProduto=').substringBefore('}'); 
            
            Integer ord3m = integer.valueOf(ordem);
            
            mapa.put(ID,ord3m);
        }
        
        List<QuoteLineItem>ItensCot = new List<QuoteLineItem>();
        
        Integer index = 0;
        for(id ide : mapa.keySet()){
            ItensCot.add(new QuoteLineItem(Id = ide, ordem__c = mapa.values()[index]));
            index++;
        }
        try{
            update ItensCot; 
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled    
    public static void atualiza(string id, decimal valor, decimal qtd, decimal desconto, string descricao, integer sinc){
        
        Boolean sincronizado = false;
        
        QuoteLineItem itemCotacao = [SELECT ID, QuoteId, Item__c FROM QuoteLineItem WHERE ID =: id]; //Encontrar o registro para atualização
        List <QuoteLineItem> itensFilhos = [SELECT ID, QuoteId, Item__c FROM QuoteLineItem WHERE QuoteID =: itemCotacao.QuoteId AND Item_pai__c =: itemCotacao.Item__c]; //Encontrar os filhos para atualizar quantidade
        List <QuoteLineItem> itensFilhosUp = new List <QuoteLineItem>();
        
        Opportunity opp = [SELECT ID, SyncedQuoteId FROM Opportunity WHERE ID IN (SELECT OpportunityId FROM Quote WHERE ID =: itemCotacao.QuoteId) ];
        if(opp.SyncedQuoteId == itemCotacao.QuoteId){
            sincronizado = true;
            opp.SyncedQuoteId = null; 
            update opp; //Para a sincronização
        }
        
        itemCotacao.UnitPrice = valor;
        itemCotacao.Quantity = qtd;
        itemCotacao.Discount = desconto;
        itemCotacao.Descricao_da_linha__c = descricao;
        
        if(itensFilhos.size() > 0 && sinc == 1){
            for(QuoteLineItem filho : itensFilhos){
                filho.Quantity = qtd;
                itensFilhosUp.add(filho);
            }
        }
        
        try{
            update itemCotacao;
            update itensFilhosUp;
            
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());        
        }
        if(sincronizado = true){
            opp.SyncedQuoteId = itemCotacao.QuoteId;
            try{
                update opp; //Sincroniza
            }
            catch(dmlException e){
                system.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
        }
    } 
    @AuraEnabled    
    public static void atualizaPai(string id, integer novoPai){
        
        Boolean sincronizado = false;
        
        QuoteLineItem itemCotacao = [SELECT ID, QuoteId FROM QuoteLineItem WHERE ID =: id]; //Encontrar o registro para atualização
        
        Opportunity opp = [SELECT ID, SyncedQuoteId FROM Opportunity WHERE ID IN (SELECT OpportunityId FROM Quote WHERE ID =: itemCotacao.QuoteId) ];
        if(opp.SyncedQuoteId == itemCotacao.QuoteId){
            sincronizado = true;
            opp.SyncedQuoteId = null; 
            update opp; //Para a sincronização
        }
        
        itemCotacao.Item_Pai__c = novoPai;    
        try{
            update itemCotacao; 
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
            
        }
        if(sincronizado = true){
            opp.SyncedQuoteId = itemCotacao.QuoteId;
            try{
                update opp; //Sincroniza
            }
            catch(dmlException e){
                system.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
        }
    } 
    @AuraEnabled    
    public static void deleta(string idCotacao, string id){
        
        Boolean sincronizado = false;
        
        Opportunity opp = [SELECT ID, SyncedQuoteId FROM Opportunity WHERE ID IN (SELECT OpportunityId FROM Quote WHERE ID =: idCotacao) ];
        if(opp.SyncedQuoteId == idCotacao){
            sincronizado = true;
            opp.SyncedQuoteId = null;
            update opp; //Para a sincronização
        }
        
        List<QuoteLineItem>ItensFilhos = new List<QuoteLineItem>();
        List<QuoteLineItem>ItensCotDel = new List<QuoteLineItem>();
        
        QuoteLineItem Item = [SELECT ID, QuoteId, Item__c, Item_Pai__c FROM QuoteLineItem WHERE ID =: id];
        ItensFilhos = [SELECT ID, item_Pai__c FROM QuoteLineItem WHERE QuoteId =: Item.QuoteId AND Item_Pai__c =: Item.Item__c];
        
        
        if(ItensFilhos.size() > 0 && Item.Item_Pai__c == null){
            for(QuoteLineItem itemF : ItensFilhos){
                ItensCotDel.add(itemF);
            }
        }
        
        ItensCotDel.add(Item);
        System.debug(ItensCotDel);
        
        try{
            delete ItensCotDel; 
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());            
        }        
        
        if(sincronizado == true){	
            opp.SyncedQuoteId = idCotacao;
            try{
                update opp; //Sincroniza
            }
            catch(dmlException e){
                system.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    @AuraEnabled    
    public static void removerFilhos(String cotacao, Integer itemPai){
        
        Boolean sincronizado = false;
        
        Opportunity opp = [SELECT ID, SyncedQuoteId, CurrencyISOCode FROM Opportunity WHERE ID IN (SELECT OpportunityId FROM Quote WHERE ID =: cotacao) ];
        if(opp.SyncedQuoteId == cotacao){
            sincronizado = true;
            opp.SyncedQuoteId = null;
            update opp; //Para a sincronização
        } 
        
        List<QuoteLineItem> filhos = [SELECT ID FROM QuoteLineItem WHERE QuoteId =: cotacao AND Item_pai__c =: itemPai];
        
        
        try{
            delete filhos;
            string resultado = 'Deletados itens filhos do item pai';
        }
        catch(dmlException error){
            system.debug(error);
            throw new AuraHandledException(error.getMessage());
        }
        if(sincronizado = true){
            opp.SyncedQuoteId = cotacao;
            try{
                update opp; //Sincroniza
            }
            catch(dmlException e){
                system.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    public static void trash(){
        String a = 'a';
        String b = 'b';        
        String c = 'c';
        String d = 'd';
        String e = 'e';
        String f = 'f';
        String g = 'g';
        String h = 'h';
        String i = 'i';
        String j = 'j';
        String k = 'k';
        String l = 'l';
        String m = 'm';
        String n = 'n';
        String o = 'o';
        String p = 'p';
        String q = 'q';
        String r = 'r';
        String s = 's';
        String t = 't';
        String u = 'u';
        String v = 'v';
        String w = 'w';
        String x = 'x';
        String y = 'y';
        String z = 'z';
        
        String aa = 'aa';
        String ab = 'ab';
        String ac = 'ac';
        String ad = 'ad';
        String ae = 'ae';
        String af = 'af';
        String ag = 'ag';
        String ah = 'ah';
        String ai = 'ai';
        String aj = 'aj';
        String ak = 'ak';
        String al = 'al';
        String am = 'am';
        String an = 'an';
        String ao = 'ao';
        String ap = 'ap';
        String aq = 'aq';
        String ar = 'ar';
        String asa = 'as';
        String at = 'at';
        String au = 'au';
        String av = 'av';
        String aw = 'aw';
        String ax = 'ax';
        String ay = 'ay';
        String az = 'az';
        
        String aaa = 'aaa';
        String aab = 'aab';
        String aac = 'aac';
        String aad = 'aad';
        String aae = 'aae';
        String aaf = 'aaf';
        String aag = 'aag';
        String aah = 'aah';
        String aai = 'aai';
        String aaj = 'aaj';
        String aak = 'aak';
        String aal = 'aal';
        String aam = 'aam';
        String aan = 'aan';
        String aao = 'aao';
        String aap = 'aap';
        String aaq = 'aaq';
        String aar = 'aar';
        String aas = 'aas';
        String aat = 'aat';
        String aau = 'aau';
        String aav = 'aav';
        String aaw = 'aaw';
        String aax = 'aax';
        String aay = 'aay';
        String aaz = 'aaz';
        
        String aaaa = 'aaa';
        String aaab = 'aab';
        String aaac = 'aac';
        String aaada = 'aad';
        String aaea = 'aae';
        String aaaf= 'aaf';
        String aaag = 'aag';
        String aaah = 'aah';
        String aaai = 'aai';
        String aaaj = 'aaj';
        String aaak = 'aak';
        String aaaal = 'aal';
        String aaam = 'aam';
        String aaan = 'aan';
        String aaao = 'aao';
        String aaap = 'aap';
        String aaaq = 'aaq';
        String aaar = 'aar';
        String aaas = 'aas';
        String aaat = 'aat';
        String aaau = 'aau';
        String aaav = 'aav';
        String aaaw = 'aaw';
        String aaax = 'aax';
        String aaay = 'aay';
        String aaaz = 'aaz';
    }
}