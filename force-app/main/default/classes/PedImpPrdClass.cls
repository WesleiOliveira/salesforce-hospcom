public class PedImpPrdClass {
    
    public static String FluxoInicial(Order pedido){
        String retorno = null;
        if (pedido.OpportunityId != null){
            retorno = ImpPrdOpp(pedido.OpportunityId, pedido);
        }else if(pedido.Ordem_de_trabalho__c != null){
            retorno = ImpPrdOt(pedido.Ordem_de_trabalho__c, pedido);
        }
        return retorno;
    }
    
    public static String ImpPrdOpp(Id oportunidade_id, Order pedido){
        
        String retorno = null;
        
        // obtém produtos da opp pai
        LIST<OpportunityLineItem> itens_opp = new LIST<OpportunityLineItem>();
        itens_opp = [
            SELECT	Item__c, Item_Pai__c, Product2Id, PriceBookEntryId, Descricao_a_linha__c, UnitPrice, Discount, Quantity, Product2.Tipo_do_Produto__c
            FROM    OpportunityLineItem
            WHERE	OpportunityId = :oportunidade_id
        ];
        
        // converte "produtos de opp" em "produtos de pedido" (!= serviço)
        List<OrderItem> itens_pedido = new LIST<OrderItem>();
        for(OpportunityLineItem item_opp : itens_opp){
            OrderItem item_pedido = new OrderItem(
                OrderId 				= pedido.Id,
                Item__c					= item_opp.Item__c,
                Item_Pai__c				= item_opp.Item_Pai__c,
                PriceBookEntryId		= item_opp.PriceBookEntryId,
                Descricao_da_linha__c 	= item_opp.Descricao_a_linha__c,
                UnitPrice 				= (item_opp.UnitPrice-((item_opp.UnitPrice/100)*(item_opp.Discount!=null?item_opp.Discount:0))),
                Quantity				= item_opp.Quantity,
                Status__c				= (pedido.Tipo__c=='Serviço')?'Aberto':'Novo'
            );
            itens_pedido.add(item_pedido);
        }
        
        // se NÃO tem produto != serviço
        if(itens_pedido.size() == 0){
            retorno = 'Essa Oportunidade não possui itens para pedido!!!';
        }
        
        // se TEM produto != serviço
        else{
            
            // insere "produtos de pedido"
            insert itens_pedido;
            
            // atualiza "produto pai" de "itens de pedido"
            for(Integer cont_1=0; cont_1<itens_pedido.size(); cont_1++){
                if(itens_pedido[cont_1].Item_Pai__c != null && itens_pedido[cont_1].Item_Pai__c != 0)
                for(Integer cont_2=0; cont_2<itens_pedido.size(); cont_2++)
                    if(itens_pedido[cont_1].Item_Pai__c == itens_pedido[cont_2].Item__c)
                        itens_pedido[cont_1].Produto_Principal__c = itens_pedido[cont_2].Id;
            } 
            update itens_pedido;
        }
        
        return retorno;
    }
    
    public static String ImpPrdOt(Id ordem_de_trabalho_id, Order pedido){
        String retorno = null;
        
        // obtém produtos da ot pai
        LIST<WorkOrderLineItem> itens_ot = new LIST<WorkOrderLineItem>();
        itens_ot = [
            SELECT	Product2Id, PriceBookEntryId, UnitPrice, Discount, Quantity, Product2.Tipo_do_Produto__c
            FROM    WorkOrderLineItem
            WHERE	WorkOrderId = :ordem_de_trabalho_id
        ];
        
        // converte "produtos de ot" em "produtos de pedido" (!= serviço)
        List<OrderItem> itens_pedido = new LIST<OrderItem>();
        for(WorkOrderLineItem item_ot : itens_ot){
            OrderItem item_pedido = new OrderItem(
                OrderId 				= pedido.Id,
                PriceBookEntryId		= item_ot.PriceBookEntryId,
                UnitPrice 				= (item_ot.UnitPrice-((item_ot.UnitPrice/100)*(item_ot.Discount!=null?item_ot.Discount:0))),
                Quantity				= item_ot.Quantity,
                Status__c				= (pedido.Tipo__c=='Serviço')?'Aberto':'Novo'
            );
            itens_pedido.add(item_pedido);
        }
        
        // se NÃO tem produto != serviço
        if(itens_pedido.size() == 0){
            retorno = 'Essa Ordem de Trabalho não possui itens para pedido!!!';
        }
        
        // se TEM produto != serviço
        else{
            
            // insere "produtos de pedido"
            insert itens_pedido;
        }
        
        return retorno;
    }
    
}