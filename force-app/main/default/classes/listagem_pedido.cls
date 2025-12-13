public with sharing class listagem_pedido{
        
        public Order                    pedido {get;set;}
        public List<OrderItem>    itens_ok_ped {get;set;}
    public List<Integer>    qtd_lista {get;set;}
    
    public listagem_pedido(ApexPages.StandardController controller) {
        Id objeto_pai = ((SObject)controller.getRecord()).Id;
        
        if(objeto_pai.getSObjectType().getDescribe().getName() == 'Order')
            listagem_pedido((Order)controller.getRecord());
        }
    
    public void listagem_pedido(Order pedido){
                pedido = [
                        SELECT  Id, OrderNumber, Order.Account.Name, ShippingCity, ShippingState, EffectiveDate, 
                                        Prazo_de_entrega__c
                        FROM    Order
                        WHERE   Id = :pedido.Id
                ][0];
                
        List<OrderItem> itens_ped_ord = new List<OrderItem>();    
        itens_ped_ord = [
            SELECT       Id, PricebookEntryId, Quantity, TotalPrice, UnitPrice, Item__c, ordem__c, Item_Pai__c, Descricao_da_linha__c,
                         OrderItem.Product2.Name, OrderItem.Product2.URL_da_Imagem__c, OrderItem.Product2.ProductCode,
                         OrderItem.Product2.Modelo__c, OrderItem.Product2.Marca__c, OrderItem.Product2.Description, 
                                         OrderItem.Product2.Family, OrderItem.Product2.Tipo_do_Produto__c, Description, Status__c
            FROM         OrderItem
            WHERE    OrderId = :pedido.Id
                        ORDER BY ordem__c ASC
        ];
        
        Decimal qtd_cont=0;
                itens_ok_ped = new List<OrderItem>(); 
                for(integer cont_1=0; cont_1<itens_ped_ord.size(); cont_1++){
            if(itens_ped_ord[cont_1].Quantity > qtd_cont)
                qtd_cont = itens_ped_ord[cont_1].Quantity;
                        if(itens_ped_ord[cont_1].Item_Pai__c == null){
                                List<OrderItem> itens_temp = new List<OrderItem>();
                                OrderItem item_total = new OrderItem(Item__c=0, Quantity=1, UnitPrice=itens_ped_ord[cont_1].TotalPrice);
                                if(itens_ped_ord[cont_1].Item__c != null){
                                        for(integer cont_2=0; cont_2<itens_ped_ord.size(); cont_2++){
                                                if(itens_ped_ord[cont_2].Item_Pai__c == itens_ped_ord[cont_1].Item__c){
                                                        itens_temp.add(itens_ped_ord[cont_2]);
                                                        item_total.UnitPrice += itens_ped_ord[cont_2].TotalPrice;
                                                }
                                        }
                                }
                                
                                if(itens_temp.size() > 0){
                                        if(itens_ok_ped.size() > 0)
                                                itens_ok_ped[itens_ok_ped.size()-1].Description = 'esp';
                                        itens_ped_ord[cont_1].Description = 'cab';
                                        itens_ok_ped.add(itens_ped_ord[cont_1]);
                                        itens_ok_ped.addAll(itens_temp);
                                        itens_ok_ped.add(item_total);   
                                }
                                else{
                                        itens_ok_ped.add(itens_ped_ord[cont_1]);
                                }
                        }
                }
        
                qtd_lista = new List<Integer>();
        for(Integer cont=0; cont < qtd_cont; cont++)
            qtd_lista.add(cont);
        
    }
    
}