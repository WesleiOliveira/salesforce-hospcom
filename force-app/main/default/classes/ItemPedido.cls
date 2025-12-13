public class ItemPedido {
    
    @AuraEnabled            
    public static void inserirPai(String pedido, String produto, String descricao, Integer item){
        
        Order pv = [SELECT ID, CURRENCYISOCODE FROM ORDER WHERE ID =: pedido];
        
        List<Produto_Filho__c> ProdutosFilhos = new List<Produto_Filho__c>(); 
        List<OrderItem> ProdutosInserir = new List<OrderItem>(); 
        List<Decimal> qtd = New List<Decimal>();
        
        Set<Id> IdProdutosFilhos = New Set<ID>();
        
        //Busca a entrada da tabela de preços do produto pai
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id =: produto AND Pricebook2Id IN (SELECT Pricebook2Id FROM Order WHERE Id =: pedido) AND CurrencyISOCode =: pv.CurrencyISOCode ];
        
        //Busca a lista dos produtos filhos (acessórios do equipamento)        
        ProdutosFilhos = [SELECT Produto_Filho__c, Quantidade__c FROM Produto_Filho__c WHERE Produto_Pai__c =: produto ORDER BY Produto_Filho__r.Id];
        
        //Insere o produto pai na cotação        
        OrderItem ItemP = new OrderItem(
            OrderId = pedido,
            Product2Id = produto,
            PricebookEntryId = pbe.Id,
            UnitPrice = pbe.UnitPrice,
            Quantity = 1,
            Descricao_da_linha__c = descricao,    
            Status__c = 'Novo',
            Item__c = item); 
        
        try{
            insert ItemP;
        }
        catch(dmlException e){
            system.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
        
        system.debug('ITEM: ' + ItemP.Id);
        
        //Se o produto tiver acessórios
        if(ProdutosFilhos.size() > 0){
            for(Produto_Filho__c PF : ProdutosFilhos){
                IdProdutosFilhos.add(PF.Produto_Filho__c);
                qtd.add(PF.Quantidade__c);         
            }
            
            //Procura a entrada da tabela de preços dos produtos filhos
            List <PricebookEntry> PBFs = [SELECT ID, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN: IdProdutosFilhos AND Pricebook2Id IN (SELECT Pricebook2Id FROM Order WHERE Id =: pedido) AND CurrencyISOCode =: pv.CurrencyISOCode ORDER BY Product2Id];
            
            //Insere cada acessório na cotação dentro do equipamento
            integer index = 0; 
            for(PricebookEntry pbeFilho : PBFs){
                OrderItem prodFilho = new OrderItem(
                    OrderId = pedido,
                    PricebookEntryId = pbeFilho.Id,
                    Product2Id = pbeFilho.Product2Id,
                    UnitPrice = pbeFilho.UnitPrice,
                    Quantity =qtd[index],
                    Status__c = 'Novo',
                    Item_Pai__c = ItemP.Item__c);
                ProdutosInserir.add(ProdFilho);
                
                index ++;
            }
            try{
                insert ProdutosInserir;
            }
            catch(dmlException error){
                system.debug(error);
                throw new AuraHandledException(error.getMessage());
            }
        }
    }
    @AuraEnabled    
    public static void inserirFilho(String pedido, String produto, String descricao, Integer itemPai){
        Order pv = [SELECT ID, CURRENCYISOCODE FROM ORDER WHERE ID =: pedido];
        
        //Busca a entrada da tabela de preços do produto filho
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id =: produto AND Pricebook2Id IN (SELECT Pricebook2Id FROM Order WHERE Id =: pedido) AND CurrencyISOCode =: pv.CurrencyISOCode ];
        
        //Insere o produto filho no pedido        
        OrderItem ItemF = new OrderItem(
            OrderId = pedido,
            PricebookEntryId = pbe.Id,
            UnitPrice = pbe.UnitPrice,
            Descricao_da_linha__c = descricao,    
            Quantity = 1,
            Status__c = 'Novo',
            Item_Pai__c = itemPai);
        
        try{
            insert ItemF;
            
        }
        catch(dmlException error){
            system.debug(error);
            throw new AuraHandledException(error.getMessage());
            
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
        
        List<OrderItem>ItensPedido = new List<OrderItem>();
        
        Integer index = 0;
        for(id ide : mapa.keySet()){
            ItensPedido.add(new OrderItem(Id = ide, ordem__c = mapa.values()[index]));
            index++;
        }
        try{
            update ItensPedido; 
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled    
    public static void atualiza(string id, decimal valor, decimal qtd, string descricao, integer sinc){        
        
        OrderItem itemPedido = [SELECT ID, OrderId, Item__c, Item_pai__c FROM OrderItem WHERE ID =: id]; //Encontrar o registro para atualização
        List <OrderItem> itensFilhos = [SELECT ID, OrderId, Item__c, Item_pai__c FROM OrderItem WHERE OrderID =: itemPedido.OrderId AND Item_pai__c =: itemPedido.Item__c AND Item_pai__c != null AND Item_pai__c != 0]; //Encontrar os filhos para atualizar quantidade
        List <OrderItem> itensFilhosUp = new List <OrderItem>();   
        
        itemPedido.UnitPrice = valor;
        itemPedido.Quantity = qtd;
        itemPedido.Descricao_da_linha__c = descricao;
        
        if(itensFilhos.size() > 0 && sinc == 1){
            for(OrderItem filho : itensFilhos){
                filho.Quantity = qtd;
                itensFilhosUp.add(filho);
            }
        }
        try{
            update itemPedido; 
            update itensFilhosUp;
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled    
    public static void atualizaItem(string id, integer item, integer itemPai){
        
        
        OrderItem itemPedido = [SELECT ID FROM OrderItem WHERE ID =: id]; //Encontrar o registro para atualização
        
        itemPedido.Item__c = item;
        itemPedido.Item_Pai__c = itemPai;    
        try{
            update itemPedido; 
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
        
    } 
    @AuraEnabled    
    public static void deleta(string id){
        
        List<OrderItem>ItensFilhos = new List<OrderItem>();
        List<OrderItem>ItensPedidoDel = new List<OrderItem>();
        
        OrderItem Item = [SELECT ID, OrderId, Item__c, Item_Pai__c FROM OrderItem WHERE ID =: id];
        ItensFilhos = [SELECT ID, item_Pai__c FROM OrderItem WHERE OrderId =: Item.OrderId AND Item_Pai__c =: Item.Item__c];
        
        
        if(ItensFilhos.size() > 0 && Item.Item_Pai__c == null){
            for(OrderItem itemF : ItensFilhos){
                ItensPedidoDel.add(itemF);
            }
        }
        
        ItensPedidoDel.add(Item);
        System.debug(ItensPedidoDel);
        
        try{
            delete ItensPedidoDel; 
        }
        catch(DmlException e){
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
    @AuraEnabled    
    public static void unificaValores(string idItem){
        OrderItem itemPai = [SELECT ID, OrderId, Item__c, UnitPrice, Quantity FROM OrderItem WHERE ID =:idItem];
        List<OrderItem> itensFilhos = [SELECT ID, TotalPrice FROM OrderItem WHERE OrderId = :itemPai.OrderId AND Item_pai__c = :itemPai.Item__c];
        Decimal valorFilhos = 0;
        
        for(OrderItem itemFilho : itensFilhos){
            valorFilhos = valorFilhos + itemFilho.TotalPrice;
            itemFilho.UnitPrice = 0;
        }
        itemPai.UnitPrice = (valorFilhos/itemPai.Quantity) + itemPai.UnitPrice;
        
        try{
            update itemPai;
            update itensFilhos;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}