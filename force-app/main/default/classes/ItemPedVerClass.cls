public class ItemPedVerClass {
    
    public static String VerificaStatus(OrderItem item_de_pedido){
        String retorno = null;
        Order pedido = new Order();
        pedido = [
            SELECT	Status
            FROM	Order
            WHERE	Id = :item_de_pedido.OrderId
        ];
        if((pedido.Status == 'Rascunho') ||
           (pedido.Status == 'Aguardando Aprovação Comercial') ||
           (pedido.Status == 'Aguardando Aprovação Financeira') ||
           (pedido.Status == 'Cancelado/Reprovado')){ 
            if(item_de_pedido.Status__c != 'Novo')
      			retorno = 'Não é possível alterar Status do item. Pedido não aprovado (' + pedido.Status + ')';
		}
        return retorno;
    }

    public static String VerificaDataFornecedor(OrderItem item_de_pedido){
        String retorno = null;
        Order pedido = new Order();
        pedido = [
            SELECT	Status
            FROM	Order
            WHERE	Id = :item_de_pedido.OrderId
        ];
        if((pedido.Status == 'Rascunho') ||
           (pedido.Status == 'Aguardando Aprovação Comercial') ||
           (pedido.Status == 'Aguardando Aprovação Financeira') ||
           (pedido.Status == 'Cancelado/Reprovado')){ 
            if(item_de_pedido.Data_de_Entrega_Fornecedor__c != null)
      			retorno = 'Não é possível alterar Data do item. Pedido ainda não aprovado (' + pedido.Status + ')';
		}
        return retorno;
    }
           
}