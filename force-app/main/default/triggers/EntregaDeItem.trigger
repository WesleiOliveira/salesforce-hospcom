trigger EntregaDeItem on Entrega_de_item__c (after insert, after update, after delete){
    
    String acao     = Trigger.isInsert?'insert':Trigger.isUpdate?'update':'delete';
    String momento  = Trigger.isBefore?'before':'after';
    public static Set<Id>                           itens_venda_id = new Set<Id>();
    public static List<OrderItem>                   itens_venda_bak;
    public static List<OrderItem>                   itens_venda;
    public static List<Entrega_de_item__c>       	entregas_item;
    
    // identifica alterações em entregas
    if(momento == 'after'){
        if(acao == 'insert'){
            for(Entrega_de_item__c entrega_item : Trigger.new){
                itens_venda_id.add(entrega_item.Item_de_pedido_de_venda__c);
            }
        }
        else if(acao == 'update'){
            Integer cont_item=0;
            for(Entrega_de_item__c entrega_item : Trigger.new){
                if((Trigger.old[cont_item].Quantidade_entregue__c != entrega_item.Quantidade_entregue__c)||
                   (Trigger.old[cont_item].Data_de_entrega__c != entrega_item.Data_de_entrega__c)){
                    itens_venda_id.add(entrega_item.Item_de_pedido_de_venda__c);
                }
                cont_item++;
            }
        }
        else if(acao == 'delete'){
            for(Entrega_de_item__c entrega_item : Trigger.old){
                itens_venda_id.add(entrega_item.Item_de_pedido_de_venda__c);
            }
        }
    }
    
    // se detectou alterações, busca todos as requisições irmãs
    if(itens_venda_id.size() > 0){
        entregas_item = [
            SELECT   Id, Quantidade_entregue__c, Data_de_entrega__c, Item_de_pedido_de_venda__c
            FROM     Entrega_de_item__c
            WHERE    Item_de_pedido_de_venda__c IN :itens_venda_id
            ORDER BY Id DESC
        ];
    }
    
    // replica em itens de venda
    if(itens_venda_id.size() > 0){
        itens_venda = [
            SELECT   Id, Quantidade_entregue__c, Data_de_entrega__c
            FROM     OrderItem
            WHERE    Id IN :itens_venda_id
            ORDER BY Id DESC
        ];
        itens_venda_bak = itens_venda.deepClone(true, true, true);
        
        for(OrderItem item_venda : itens_venda){
            item_venda.Quantidade_entregue__c = 0;
            item_venda.Data_de_entrega__c = null;
            for(Entrega_de_item__c entrega_item : entregas_item){
                if(entrega_item.Item_de_pedido_de_venda__c == item_venda.Id){
                    // Quantidade_entregue__c
					item_venda.Quantidade_entregue__c += entrega_item.Quantidade_entregue__c;                           
                    // Data_de_entrega__c
                    if(item_venda.Data_de_entrega__c == null || item_venda.Data_de_entrega__c < entrega_item.Data_de_entrega__c){
                        item_venda.Data_de_entrega__c = entrega_item.Data_de_entrega__c;                           
                    }
                }
            }
        }
        for(Integer cont_bak = itens_venda_bak.size()-1; cont_bak>=0; --cont_bak){
            for(Integer cont = itens_venda.size()-1; cont>=0; --cont){
                if(itens_venda_bak[cont_bak].Id == itens_venda[cont].Id){
                    if(itens_venda_bak[cont_bak] == itens_venda[cont])
                        itens_venda.remove(cont);
                    break;              
                }
            }
        }
        if(itens_venda.size()>0){
            update itens_venda;
        }
    }
 	 
}