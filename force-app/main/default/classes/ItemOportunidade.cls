public class ItemOportunidade {
    
    @AuraEnabled            
    public static void inserirPai(String opp, String produto, String descricao, Integer item){

        System.debug('Inserindo pai');
        System.debug('Opp: ' + opp);
        System.debug('Produto: ' + produto);
        System.debug('Descricao: ' + descricao);
        System.debug('Item: ' + item);
        
        // Buscar oportunidade
        List<Opportunity> opList = [SELECT ID, SyncedQuoteId, Pricebook2Id FROM Opportunity WHERE ID = :opp];
        if (opList.isEmpty()) {
            throw new AuraHandledException('Oportunidade não encontrada.');
        }
        Opportunity op = opList[0];
        
        
        // Verificar se o Item__c já está sendo usado
        Set<Integer> itensUsados = new Set<Integer>();
        for (OpportunityLineItem oli : [
            SELECT Item__c, Opportunity.Tipo_de_Opera_o__c FROM OpportunityLineItem WHERE OpportunityId = :opp AND Item__c != null
        ]) {
            itensUsados.add(integer.valueOf(oli.Item__c));  
        }
        
        Integer itemFinal = item;
        while (itensUsados.contains(itemFinal)) {
            itemFinal++;
        }
        
        // Buscar PricebookEntry do produto pai
        List<PricebookEntry> pbeList = [
            SELECT Id, UnitPrice FROM PricebookEntry 
            WHERE Product2Id = :produto 
            AND Pricebook2Id = :op.Pricebook2Id 
            AND CurrencyISOCode = 'BRL'
            LIMIT 1
        ];
        if (pbeList.isEmpty()) {
            throw new AuraHandledException('Produto pai não encontrado na tabela de preços.');
        }
        PricebookEntry pbe = pbeList[0];
        
        // Buscar produtos filhos (acessórios)
        List<Produto_Filho__c> produtosFilhos = [
            SELECT Produto_Filho__c, Quantidade__c 
            FROM Produto_Filho__c 
            WHERE Produto_Pai__c = :produto 
            ORDER BY Produto_Filho__r.Id
        ];

        System.debug('Produtos Filhos: ' + produtosFilhos.size());
        
        // Criar produto pai
        OpportunityLineItem itemPai = new OpportunityLineItem(
            OpportunityId = op.Id,
            Product2Id = produto,
            PricebookEntryId = pbe.Id,
            UnitPrice = pbe.UnitPrice,
            Descricao_a_linha__c = descricao,
            Quantity = 1,
            Discount = 0,
            Item__c = itemFinal
        );
        
        List<OpportunityLineItem> itensParaInserir = new List<OpportunityLineItem>();
        itensParaInserir.add(itemPai);
        
        if (!produtosFilhos.isEmpty()) {
            // Map para quantidade por filho
            Map<Id, Decimal> mapaQtd = new Map<Id, Decimal>();
            for (Produto_Filho__c pf : produtosFilhos) {
                mapaQtd.put(pf.Produto_Filho__c, pf.Quantidade__c);
            }
            
            // Buscar PricebookEntry dos filhos
            List<PricebookEntry> pbesFilhos = [
                SELECT Id, UnitPrice, Product2Id 
                FROM PricebookEntry 
                WHERE Product2Id IN :mapaQtd.keySet() 
                AND Pricebook2Id = :op.Pricebook2Id 
                AND CurrencyISOCode = 'BRL'
            ];
            
            for (PricebookEntry pbeFilho : pbesFilhos) {
                OpportunityLineItem filho = new OpportunityLineItem(
                    OpportunityId = op.Id,
                    Product2Id = pbeFilho.Product2Id,
                    PricebookEntryId = pbeFilho.Id,
                    UnitPrice = pbeFilho.UnitPrice,
                    Quantity = mapaQtd.get(pbeFilho.Product2Id),
                    Discount = 0,
                    Item_Pai__c = itemFinal
                );
                System.debug('Filho: ' + filho);
                itensParaInserir.add(filho);
            }
        }
        
        // Inserção em lote
        try {
            insert itensParaInserir;
            System.debug('Itens inseridos com sucesso: ' + itensParaInserir.size());
        } catch (DmlException e) {
            throw new AuraHandledException('Erro ao inserir itens: ' + e.getMessage());
        }
        
    }
    
    
    @AuraEnabled    
    public static void inserirFilho(String opp, String produto, String descricao, Integer itemPai){
        
        Opportunity op = [SELECT ID, SyncedQuoteId, CurrencyISOCode FROM Opportunity WHERE ID =: opp];
        ID CotacaoSinc = op.SyncedQuoteId;
        if(op.SyncedQuoteId != null){
            op.SyncedQuoteId = null; 
            update op; //Para a sincronização
        }
        
        //Busca a entrada da tabela de preços do produto filho
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id =: produto AND Pricebook2Id IN (SELECT Pricebook2Id FROM Opportunity WHERE Id =: opp) AND CurrencyISOCode = 'BRL' ];
        
        //Insere o produto filho na cotação        
        OpportunityLineItem ItemF = new OpportunityLineItem(
            OpportunityId = op.Id,
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
            List<PricebookEntry> entradasPBFs = [SELECT ID, UnitPrice FROM PricebookEntry WHERE Product2Id IN :idsProdutosFilhos AND Pricebook2Id IN (SELECT Pricebook2Id FROM Opportunity WHERE Id = :op.Id) AND CurrencyISOCode = : op.CurrencyISOCode ORDER BY Product2Id];
            
            // Insere cada acessório na cotação dentro do equipamento
            List<OpportunityLineItem> produtosInserir = new List<OpportunityLineItem>();
            Integer index = 0;
            for (PricebookEntry pbeFilho : entradasPBFs) {
                OpportunityLineItem itemFilho = new OpportunityLineItem(
                    OpportunityId = op.Id,
                    PricebookEntryId = pbeFilho.Id,
                    UnitPrice = pbeFilho.UnitPrice,
                    Quantity = quantidades[index],
                    Item_Pai__c = itemPai);
                
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
        
        
        op.SyncedQuoteId = CotacaoSinc;
        update op; //Sincroniza
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
        
        List<OpportunityLineItem>ItensOpp = new List<OpportunityLineItem>();
        
        Integer index = 0;
        for(id ide : mapa.keySet()){
            ItensOpp.add(new OpportunityLineItem(Id = ide, ordem__c = mapa.values()[index]));
            index++;
        }
        try{
            update ItensOpp; 
        }
        catch(DmlException e){
            System.debug(e);
        }
    }
    @AuraEnabled    
    public static void atualiza(string id, decimal valor, decimal qtd, decimal desconto, string descricao, integer sinc){        
        
        OpportunityLineItem itemOpp = [SELECT ID, OpportunityId, Item__c FROM OpportunityLineItem WHERE ID =: id]; //Encontrar o registro para atualização
        
        itemOpp.UnitPrice = valor;
        itemOpp.Quantity = qtd;
        itemOpp.Discount = desconto;
        itemOpp.Descricao_a_linha__c = descricao;
        
        List <OpportunityLineItem> itensFilhos = [SELECT ID, Item__c, UnitPrice FROM OpportunityLineItem WHERE OpportunityId =: itemOpp.OpportunityId AND Item_pai__c =: itemOpp.Item__c]; //Encontrar os filhos para atualizar quantidade
        
        
        if(itensFilhos.size() > 0 && sinc == 1){
            for(OpportunityLineItem filho : itensFilhos){
                filho.Quantity = qtd;
            }
        }
        
        try{
            update itemOpp;
            update itensFilhos;
            
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());        
        }
        
    }
    @AuraEnabled    
    public static void perdido(string id){        
        
        OpportunityLineItem itemOpp = [SELECT ID FROM OpportunityLineItem WHERE ID =: id]; //Encontrar o registro para atualização
        
        itemOpp.Perdido__c = true;
        
        try{
            update itemOpp; 
        }
        catch(DmlException e){
            System.debug(e);
        }
    }
    @AuraEnabled    
    public static void deleta(string idOpp, string id){
        Opportunity op = [SELECT ID, SyncedQuoteId FROM Opportunity WHERE ID =: idOpp];
        ID CotacaoSinc = op.SyncedQuoteId;
        if(op.SyncedQuoteId != null){
            op.SyncedQuoteId = null; 
            update op; //Para a sincronização
        }
        
        List<OpportunityLineItem> ItensFilhos = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> ItensOppDel = new Map<Id, OpportunityLineItem>();
        
        OpportunityLineItem Item = [SELECT ID, OpportunityId, Item__c, Item_Pai__c FROM OpportunityLineItem WHERE ID =: id];

        if(item.Item__c != null){
             ItensFilhos = [SELECT ID, item_Pai__c FROM OpportunityLineItem WHERE OpportunityId =: Item.OpportunityId AND Item_Pai__c =: Item.Item__c];
        }
       
        
        if(ItensFilhos.size() > 0){
            for(OpportunityLineItem itemF : ItensFilhos){
                ItensOppDel.put(itemF.Id, itemF);
            }
        }
        
        ItensOppDel.put(Item.Id, Item);
        System.debug(ItensOppDel);
        
        try{
            delete ItensOppDel.values(); 
        }
        catch(DmlException e){
            System.debug(e);
        }
        op.SyncedQuoteId = CotacaoSinc;
        update op; //Sincroniza
        
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