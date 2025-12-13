trigger RequisicaoDeItem on Requisicao_de_item__c (after insert, after update, after delete){
    
    String acao     = Trigger.isInsert?'insert':Trigger.isUpdate?'update':'delete';
    String momento  = Trigger.isBefore?'before':'after';
    public static Set<Id>                           itens_venda_id = new Set<Id>();
    public static List<OrderItem>                   itens_venda_bak;
    public static List<OrderItem>                   itens_venda;
    public static Set<Id>                           itens_compra_id = new Set<Id>();
    public static List<Item_de_pedido_de_compra__c> itens_compra_bak;
    public static List<Item_de_pedido_de_compra__c> itens_compra;
    public static List<Requisicao_de_item__c>       requisicoes_item;
    public static List<Recebimento_de_item__c>      recebimentos_estoque = new List<Recebimento_de_item__c>();
    
    // identifica alterações em requisições
    if(momento == 'after'){
        if(acao == 'insert'){
            recebimentos_estoque.clear();
            for(Requisicao_de_item__c requisicao_item : Trigger.new){
                if(requisicao_item.Item_de_pedido_de_venda__c != null){ // suprir VENDA com compra + suprir VENDA com estoque
                    itens_venda_id.add(requisicao_item.Item_de_pedido_de_venda__c);
                    if(requisicao_item.Item_de_pedido_de_compra__c == null){ // específico de estoque
                        recebimentos_estoque.add(new Recebimento_de_item__c(
                            Requisicao_de_produto__c = requisicao_item.Id,
                            Data_de_recebimento__c = requisicao_item.Data_de_requisicao__c,
                            Quantidade_recebida__c = requisicao_item.Quantidade_requisitada__c
                        ));
                    }
                }
                if(requisicao_item.Item_de_pedido_de_compra__c != null)// suprir venda com COMPRA + suprir estoque com COMPRA
                    itens_compra_id.add(requisicao_item.Item_de_pedido_de_compra__c);
            }
        }
        else if(acao == 'update'){
            Integer cont_item=0;
            for(Requisicao_de_item__c requisicao_item : Trigger.new){
                if((Trigger.old[cont_item].Quantidade_requisitada__c != requisicao_item.Quantidade_requisitada__c)||
                   (Trigger.old[cont_item].Arquivar__c != requisicao_item.Arquivar__c)||
                   (Trigger.old[cont_item].Comprar__c != requisicao_item.Comprar__c)||
                   (Trigger.old[cont_item].Quantidade_recebida__c != requisicao_item.Quantidade_recebida__c)||
                   (Trigger.old[cont_item].Data_de_requisicao__c != requisicao_item.Data_de_requisicao__c)||
                   (Trigger.old[cont_item].Data_de_recebimento__c != requisicao_item.Data_de_recebimento__c)||
                   (Trigger.old[cont_item].Prazo_de_recebimento__c != requisicao_item.Prazo_de_recebimento__c)){
                    if(requisicao_item.Item_de_pedido_de_venda__c != null) // suprir VENDA com compra + suprir VENDA com estoque
                        itens_venda_id.add(requisicao_item.Item_de_pedido_de_venda__c);
                    if(requisicao_item.Item_de_pedido_de_compra__c != null)// suprir venda com COMPRA + suprir estoque com COMPRA
                        itens_compra_id.add(requisicao_item.Item_de_pedido_de_compra__c);
                }
                cont_item++;
            }
        }
        else if(acao == 'delete'){
            for(Requisicao_de_item__c requisicao_item : Trigger.old){
                if(requisicao_item.Item_de_pedido_de_venda__c != null) // suprir VENDA com compra + suprir VENDA com estoque
                    itens_venda_id.add(requisicao_item.Item_de_pedido_de_venda__c);
                if(requisicao_item.Item_de_pedido_de_compra__c != null)// suprir venda com COMPRA + suprir estoque com COMPRA
                    itens_compra_id.add(requisicao_item.Item_de_pedido_de_compra__c);
            }
        }
    }
    
    // se detectou alterações, busca todos as requisições irmãs
    if((itens_venda_id.size() > 0)||(itens_compra_id.size() > 0)){
        requisicoes_item = [
            SELECT   Id, Quantidade_requisitada__c, Quantidade_recebida__c, Data_de_requisicao__c, Data_de_recebimento__c, Prazo_de_recebimento__c,
                     Item_de_pedido_de_venda__c, Item_de_pedido_de_compra__c, Arquivar__c, Comprar__c 
            FROM     Requisicao_de_item__c
            WHERE    Item_de_pedido_de_venda__c IN :itens_venda_id OR
                     Item_de_pedido_de_compra__c IN :itens_compra_id
            ORDER BY Id DESC
        ];
    }
    
    // replica em itens de venda
    if(itens_venda_id.size() > 0){
        itens_venda = [
            SELECT   Id, Quantidade_requisitada__c, Quantidade_recebida__c, Data_de_requisicao__c, Data_de_recebimento__c, Prazo_de_recebimento__c,
                     Resumo__c
            FROM     OrderItem
            WHERE    Id IN :itens_venda_id
            ORDER BY Id DESC
        ];
        itens_venda_bak = itens_venda.deepClone(true, true, true);
        
        for(OrderItem item_venda : itens_venda){
            item_venda.Quantidade_requisitada__c = 0;
            item_venda.Quantidade_recebida__c = 0;
            item_venda.Data_de_requisicao__c = null;
            item_venda.Data_de_recebimento__c = null;
            item_venda.Prazo_de_recebimento__c = null;
            Integer qtd_requisicoes=0, qtd_compras=0;
            
            for(Requisicao_de_item__c requisicao_item : requisicoes_item){
                if(requisicao_item.Item_de_pedido_de_venda__c != null){
                    if(requisicao_item.Item_de_pedido_de_venda__c == item_venda.Id){
                        // Quantidade_requisitada__c
                        if(!requisicao_item.Arquivar__c)
                            item_venda.Quantidade_requisitada__c += requisicao_item.Quantidade_requisitada__c;                           
                        // Quantidade_recebida__c
                        item_venda.Quantidade_recebida__c += requisicao_item.Quantidade_recebida__c;                         
                        // Data_de_requisicao__c
                        if(item_venda.Data_de_requisicao__c == null || item_venda.Data_de_requisicao__c < requisicao_item.Data_de_requisicao__c){
                            item_venda.Data_de_requisicao__c = requisicao_item.Data_de_requisicao__c;                 
                        }
                        // Data_de_recebimento__c
                        if(item_venda.Data_de_recebimento__c == null || item_venda.Data_de_recebimento__c < requisicao_item.Data_de_recebimento__c){
                            item_venda.Data_de_recebimento__c = requisicao_item.Data_de_recebimento__c;                         
                        }
                        // Prazo_de_recebimento__c
                        if(item_venda.Prazo_de_recebimento__c == null || item_venda.Prazo_de_recebimento__c < requisicao_item.Prazo_de_recebimento__c){
                            item_venda.Prazo_de_recebimento__c = requisicao_item.Prazo_de_recebimento__c;                           
                        }
                        // Compra efetivada pt1
                        if(!requisicao_item.Arquivar__c){
                            qtd_requisicoes += 1;
                            if(requisicao_item.Comprar__c == true)
                                qtd_compras += 1;                           
                        }
                    }
                }
            }
            // Compra efetivada pt2
            List<String> resumo;
            if(item_venda.Resumo__c!=null)
                resumo = item_venda.Resumo__c.split(';');
            else
                resumo = new List<String>();
            for(Integer cont=resumo.size()-1; cont>=0 ;cont--)
                if(resumo[cont].containsIgnoreCase('compra'))
                    resumo.remove(cont);
            if(qtd_compras == 0)
                resumo.add('Não Comprado');
            else if(qtd_compras > 0 && qtd_compras < qtd_requisicoes)
                resumo.add('Comprado Parcial');
            else if(qtd_compras == qtd_requisicoes)
                resumo.add('Comprado Total');
            item_venda.Resumo__c = String.join(resumo, ';');
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
    
    // replica em itens de compra
    if(itens_compra_id.size() > 0){
        itens_compra = [
            SELECT   Id, Quantidade_requisitada__c, Quantidade_recebida__c, Data_de_requisicao__c, Data_de_recebimento__c
            FROM     Item_de_pedido_de_compra__c
            WHERE    Id IN :itens_compra_id
            ORDER BY Id DESC
        ];
        itens_compra_bak = itens_compra.deepClone(true, true, true);
        
        for(Item_de_pedido_de_compra__c item_compra : itens_compra){
            item_compra.Quantidade_requisitada__c = 0;
            item_compra.Quantidade_recebida__c = 0;
            item_compra.Data_de_requisicao__c = null;
            item_compra.Data_de_recebimento__c = null;
            for(Requisicao_de_item__c requisicao_item : requisicoes_item){
                if(requisicao_item.Item_de_pedido_de_compra__c != null){
                    if(requisicao_item.Item_de_pedido_de_compra__c == item_compra.Id){
                        // Quantidade_requisitada__c
                        if(!requisicao_item.Arquivar__c)
                            item_compra.Quantidade_requisitada__c += requisicao_item.Quantidade_requisitada__c;                          
                        // Quantidade_recebida__c
                        item_compra.Quantidade_recebida__c += requisicao_item.Quantidade_recebida__c;                            
                        // Data_de_requisicao__c
                        if(item_compra.Data_de_requisicao__c == null || item_compra.Data_de_requisicao__c < requisicao_item.Data_de_requisicao__c){
                            item_compra.Data_de_requisicao__c = requisicao_item.Data_de_requisicao__c;                          
                        }
                        // Data_de_recebimento__c
                        if(item_compra.Data_de_recebimento__c == null || item_compra.Data_de_recebimento__c < requisicao_item.Data_de_recebimento__c){
                            item_compra.Data_de_recebimento__c = requisicao_item.Data_de_recebimento__c;                            
                        }
                    }
                }
            }
        }
        
        for(Integer cont_bak = itens_compra_bak.size()-1; cont_bak>=0; --cont_bak){
            for(Integer cont = itens_compra.size()-1; cont>=0; --cont){
                if(itens_compra_bak[cont_bak].Id == itens_compra[cont].Id){
                    if(itens_compra_bak[cont_bak] == itens_compra[cont])
                        itens_compra.remove(cont);
                    break;                      
                }
            }
        }
        if(itens_compra.size()>0){
            update itens_compra;
        }
    }
    
    // se for requisição: suprir venda com estoque:
    if(recebimentos_estoque.size()>0)
        insert recebimentos_estoque;
    
}