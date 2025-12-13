trigger UpdateStandardPrices on Product2 (after insert) {
    Set<ID> prodIdSet = Trigger.newMap.keySet();
    
    
    Pricebook2 pb = [select ID from Pricebook2 where IsStandard = TRUE and IsActive = TRUE];
    
    List<PricebookEntry> pbeList = new List<PricebookEntry>();
    List<PricebookEntry> PriceB = new List<PricebookEntry>();
    List<PricebookEntry> PriceC = new List<PricebookEntry>();
                    
    
    if(trigger.isinsert) {        
        for (Product2 p : Trigger.new) {
            if(p.Valor_de_Venda__c != null){
            if(!p.isClone()){
            pbeList.add( new PricebookEntry( Pricebook2Id = pb.ID, Product2Id=p.ID, UnitPrice=p.Valor_de_Venda__c, IsActive = p.IsActive, UseStandardPrice = false));
            insert pbeList;
            
            if(p.Tipo_do_Produto__c =='Peça'){
                PriceB.add( new PricebookEntry( Pricebook2Id = '01s31000003wrkA', Product2Id=p.ID, UnitPrice=p.Valor_de_Venda__c, IsActive = p.IsActive, UseStandardPrice = true));    
                PriceC.add( new PricebookEntry( Pricebook2Id = '01s31000003qb7b', Product2Id=p.ID, UnitPrice=p.Valor_de_Venda__c, IsActive = p.IsActive, UseStandardPrice = true));    

                insert PriceB;
                insert PriceC;
            }
            else{
                PriceB.add( new PricebookEntry( Pricebook2Id = '01s5A000004fbcR', Product2Id=p.ID, UnitPrice=p.Valor_de_Venda__c, IsActive = p.IsActive, UseStandardPrice = true));
            insert PriceB;
            }
        }
            else{
                PricebookEntry px = [select UnitPrice from PricebookEntry where Product2Id =: p.getCloneSourceId() limit 1];
                px.UnitPrice=p.Valor_de_Venda__c;
                    update px;                    
            }
        }
    }
    }
}