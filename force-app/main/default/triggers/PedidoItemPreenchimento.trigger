trigger PedidoItemPreenchimento on OrderItem (after update) {
    
    Set<Id> pedidos_id = new Set<Id>();
    for(OrderItem item_ped : Trigger.new){
        pedidos_id.add(item_ped.OrderId);
    }
    
    List<Order> pedidos = [
        SELECT  Id, Status, RecordType.Name, (
                    SELECT  Id, Status__c
                    FROM    Orderitems
                )
        FROM    Order
        WHERE   Id IN :pedidos_id
    ];
    List<String> status_inativo = new List<String>{'Rascunho','Aguardando Aprovação Comercial','Pendente', 'Aguardando Aprovação Financeira','Reprovado','Aprovado', 'Faturado', 'Cancelado'};
    
    for(Order pedido : pedidos){
        Integer qtd_novabe = 0,     qtd_entregue = 0,   qtd_atendido = 0,
        qtd_cancelado = 0,          qtd_total = 0,      qtd_faturado = 0;
        
        for(Orderitem item_ped : pedido.OrderItems){
            if(item_ped.Status__c == 'Novo') qtd_novabe++;
            else if(item_ped.Status__c == 'Aberto') qtd_novabe++;
            else if(item_ped.Status__c == 'Entregue Cliente') qtd_entregue++;
            else if(item_ped.Status__c == 'Atendido') qtd_atendido++;
            else if(item_ped.Status__c == 'Faturado') qtd_faturado++;
            else if(item_ped.Status__c == 'Cancelado') qtd_cancelado++;
            qtd_total++;
        }
        
        if(pedido.RecordType.Name=='Hospcom' || pedido.RecordType.Name=='Venda Balcão' || pedido.RecordType.Name == 'Venda Commerce' || pedido.RecordType.Name == 'OPME - Zimmer'){
            if(status_inativo.contains(pedido.Status)){
                if(qtd_cancelado == qtd_total) pedido.Status = 'Cancelado';
            }else{
                //if(qtd_total == qtd_novabe) pedido.Status = 'Ativo';
                if(qtd_cancelado == qtd_total) pedido.Status = 'Cancelado';
                else if(qtd_entregue>0 && qtd_entregue<(qtd_total-qtd_cancelado)) pedido.Status = 'Entregue Parcial';
                else if(qtd_entregue == (qtd_total-qtd_cancelado)) pedido.Status = 'Entregue Total';
                                
                else if(qtd_atendido>0 && qtd_atendido<(qtd_total-qtd_cancelado)) pedido.Status = 'Atendido Parcial';
                else if(qtd_atendido == (qtd_total-qtd_cancelado)) pedido.Status = 'Atendido Total';
                else pedido.Status = 'Em Andamento';
            }
        }
        else if(pedido.RecordType.Name=='Representação'){
            if(status_inativo.contains(pedido.Status)){
                if(qtd_cancelado == qtd_total) pedido.Status = 'Cancelado';
            }else{
                if(qtd_cancelado == qtd_total) pedido.Status = 'Cancelado';
                else if(qtd_entregue>0 && qtd_entregue<(qtd_total-qtd_cancelado)) pedido.Status = 'Entregue Parcial';
                else if(qtd_entregue == (qtd_total-qtd_cancelado)) pedido.Status = 'Entregue Total';
                
                else if(qtd_faturado == (qtd_total-qtd_cancelado)) pedido.Status = 'Entregue Total';
                
                else if(qtd_atendido>0 && qtd_atendido<(qtd_total-qtd_cancelado)) pedido.Status = 'Atendido Parcial';
                else if(qtd_atendido == (qtd_total-qtd_cancelado)) pedido.Status = 'Atendido Total';
                else pedido.Status = 'Em Andamento';
            }
        }
        
    }
    
    Util.AcaoInterna(true);
    update pedidos;
    Util.AcaoInterna(false);
}