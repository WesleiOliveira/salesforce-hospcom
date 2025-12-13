trigger QuoteLineProdutoFilho on QuoteLineItem (after insert) {
    public List <QuoteLineItem> ItensLinha = new List <QuoteLineItem>();
    public List <QuoteLineItem> ItensLinhaFilhos = new List <QuoteLineItem>();
    public List<Produto_Filho__c> pf = new List<Produto_Filho__c>();
    public List<PricebookEntry> pbe = new List <PricebookEntry>();
    
    Set<Id> ids = New Set<Id>();
    List<Decimal> qtd = New List<Decimal>();
    
    for(QuoteLineItem IL : Trigger.new){
        if(IL.Item_Pai__c == null && (IL.NaoAcionar__c == false || IL.NaoAcionar__c == null)){
            pf = [SELECT Id, Produto_Pai__c, Produto_Filho__r.Id, Quantidade__c FROM Produto_Filho__c WHERE Produto_Pai__r.Id =: IL.Product2Id ORDER BY Produto_Filho__r.Id];
                
        for(Produto_Filho__c ProdFilho : pf){
            ids.add(ProdFilho.Produto_Filho__r.Id);         
            qtd.add(ProdFilho.Quantidade__c);         
        }
        system.debug(ids);

        id pbQ = IL.QuoteId;
        
        pbe = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN: ids and Pricebook2Id IN (SELECT Pricebook2Id FROM Quote WHERE ID =: pbQ) and CurrencyISOCode = 'BRL' ORDER BY Product2Id];
        
        system.debug(pbe);
            
        integer index = 0;
            if(pbe.size() > 0){
                for(PricebookEntry pb : pbe){
            
            QuoteLineItem ILC = new QuoteLineItem();
            ILC.QuoteId = IL.QuoteId;
            ILC.Item_Pai__c = IL.Item__c;
            ILC.Quantity =qtd[index];                      
            ILC.Product2Id = pb.Product2Id;
            ILC.PricebookEntryId = pb.Id;
            ILC.UnitPrice = pb.UnitPrice;
            ILC.NaoAcionar__c = true;
            try{
                insert ILC;
            }
            catch(dmlException e){
                system.debug(e);
            }
            index ++;
        }        
    }
    }
        else if(IL.Item_Pai__c != null && IL.NaoAcionar__c == false){
            pf = [SELECT Id, Produto_Pai__c, Produto_Filho__r.Id, Quantidade__c FROM Produto_Filho__c WHERE Produto_Pai__r.Id =: IL.Product2Id ORDER BY Produto_Filho__r.Id];
                
        for(Produto_Filho__c ProdFilho : pf){
            ids.add(ProdFilho.Produto_Filho__r.Id);         
            qtd.add(ProdFilho.Quantidade__c);         
        }
        system.debug(ids);

        id pbQ = IL.QuoteId;
        
        pbe = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN: ids and Pricebook2Id IN (SELECT Pricebook2Id FROM Quote WHERE ID =: pbQ) and CurrencyISOCode = 'BRL' ORDER BY Product2Id];
        
        system.debug(pbe);
            
        integer index = 0;
            if(pbe.size() > 0){
                for(PricebookEntry pb : pbe){
            
            QuoteLineItem ILC = new QuoteLineItem();
            ILC.QuoteId = IL.QuoteId;
            ILC.Item_Pai__c = IL.Item_Pai__c;
            ILC.Quantity =qtd[index];                      
            ILC.Product2Id = pb.Product2Id;
            ILC.PricebookEntryId = pb.Id;
            ILC.UnitPrice = pb.UnitPrice;
            try{
                insert ILC;
            }
            catch(dmlException e){
                system.debug(e);
            }
            index ++;
            }
   }
  }
 }
}