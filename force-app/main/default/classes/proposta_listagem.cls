public with sharing class proposta_listagem{
    
    public List<OpportunityLineItem>    itens_ok_opp        {get;set;}
    public List<WorkOrderLineItem>      itens_ok_ot         {get;set;}
    
    public proposta_listagem(ApexPages.StandardController controller) {
        Id objeto_pai = ((SObject)controller.getRecord()).Id;
        
        if(objeto_pai.getSObjectType().getDescribe().getName() == 'Opportunity')
            listagem_oportunidade((Opportunity)controller.getRecord());
        else if(objeto_pai.getSObjectType().getDescribe().getName() == 'WorkOrder')
            listagem_ordem_de_trabalho((WorkOrder)controller.getRecord());
    }
    
    public void listagem_oportunidade(Opportunity oportunidade){
        List<OpportunityLineItem> itens_opp_ord = new List<OpportunityLineItem>();    
        itens_opp_ord = [
            SELECT   Id, PricebookEntryId, Quantity, Discount, TotalPrice, UnitPrice, Item__c, Item_Pai__c, Descricao_a_linha__c ,
                     OpportunityLineItem.Product2.Name, OpportunityLineItem.Product2.URL_da_Imagem__c,
                     OpportunityLineItem.Product2.ProductCode, OpportunityLineItem.Product2.StockKeepingUnit, 
                                         OpportunityLineItem.Product2.Modelo__c,
                     OpportunityLineItem.Product2.Marca__c, OpportunityLineItem.Product2.Description, Description 
            FROM     OpportunityLineItem
            WHERE    OpportunityId = :oportunidade.ID
            ORDER BY Item__c ASC
        ];
       
       
       
        itens_ok_opp = new List<OpportunityLineItem>(); 
        for(integer cont_1=0; cont_1<itens_opp_ord.size(); cont_1++){
            if(itens_opp_ord[cont_1].Item_Pai__c == null){
                //itens_ok_opp.add(itens_opp_ord[cont_1]);
                List<OpportunityLineItem> itens_temp = new List<OpportunityLineItem>();
                OpportunityLineItem item_total = new OpportunityLineItem(Item__c=0, TotalPrice=itens_opp_ord[cont_1].TotalPrice);
                if(itens_opp_ord[cont_1].Item__c != null){
                    for(integer cont_2=0; cont_2<itens_opp_ord.size(); cont_2++){
                        if(itens_opp_ord[cont_2].Item_Pai__c == itens_opp_ord[cont_1].Item__c){
                            //itens_ok_opp.add(itens_opp_ord[cont_2]);
                            itens_temp.add(itens_opp_ord[cont_2]);
                            item_total.TotalPrice += itens_opp_ord[cont_2].TotalPrice;
                        }
                    }                   
                }
                
                if(itens_temp.size() > 0){
                    if(itens_ok_opp.size() > 0)
                        itens_ok_opp[itens_ok_opp.size()-1].Description = 'esp';
                    itens_opp_ord[cont_1].Description = 'cab';
                    itens_ok_opp.add(itens_opp_ord[cont_1]);
                    itens_ok_opp.addAll(itens_temp);
                    itens_ok_opp.add(item_total);   
                }
                else{
                    itens_ok_opp.add(itens_opp_ord[cont_1]);
                }
            }
        }
        
    }
    
    public void listagem_ordem_de_trabalho(WorkOrder ordem_de_trabalho){
        List<WorkOrderLineItem> itens_ot_ord = new List<WorkOrderLineItem>();    
        itens_ot_ord = [
            SELECT   Id, PricebookEntryId, Quantity, Discount, TotalPrice, UnitPrice, Item__c, Item_Pai__c,
                     WorkOrderLineItem.Product2.Name, WorkOrderLineItem.Product2.URL_da_Imagem__c,
                     WorkOrderLineItem.Product2.ProductCode, WorkOrderLineItem.Product2.StockKeepingUnit, 
                                         WorkOrderLineItem.Product2.Modelo__c,
                     WorkOrderLineItem.Product2.Marca__c, WorkOrderLineItem.Product2.Description, Description
            FROM     WorkOrderLineItem
            WHERE    WorkOrderId = :ordem_de_trabalho.ID
            ORDER BY Item__c ASC
        ];
        
        itens_ok_ot = new List<WorkOrderLineItem>(); 
        for(integer cont_1=0; cont_1<itens_ot_ord.size(); cont_1++){
            if(itens_ot_ord[cont_1].Item_Pai__c == null){
                // itens_ok_ot.add(itens_ot_ord[cont_1]);
                List<WorkOrderLineItem> itens_temp = new List<WorkOrderLineItem>();
                WorkOrderLineItem item_total = new WorkOrderLineItem(Item__c=0, Quantity=1, UnitPrice=itens_ot_ord[cont_1].TotalPrice);
                if(itens_ot_ord[cont_1].Item__c != null){
                    for(integer cont_2=0; cont_2<itens_ot_ord.size(); cont_2++){
                        if(itens_ot_ord[cont_2].Item_Pai__c == itens_ot_ord[cont_1].Item__c){
                            // itens_ok_ot.add(itens_ot_ord[cont_2]);
                            itens_temp.add(itens_ot_ord[cont_2]);
                            item_total.UnitPrice += itens_ot_ord[cont_2].TotalPrice;
                        }
                    }                   
                }
                
                
                if(itens_temp.size() > 0){
                    if(itens_ok_ot.size() > 0)
                        itens_ok_ot[itens_ok_ot.size()-1].Description = 'esp';
                    itens_ot_ord[cont_1].Description = 'cab';
                    itens_ok_ot.add(itens_ot_ord[cont_1]);
                    itens_ok_ot.addAll(itens_temp);
                    itens_ok_ot.add(item_total);    
                }
                else{
                    itens_ok_ot.add(itens_ot_ord[cont_1]);
                }
            }
        }
    }
}