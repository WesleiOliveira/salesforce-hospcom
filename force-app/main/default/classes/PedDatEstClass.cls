public class PedDatEstClass {
    
    public static Void FluxoInicial(OrderItem item_de_pedido){
		List<OrderItem> itens_de_pedido = new List<OrderItem>();
        itens_de_pedido = [
            SELECT	Data_de_Entrega_Fornecedor__c
            FROM 	OrderItem
            WHERE	OrderId = :item_de_pedido.OrderId
        ];
        Date maior_data = null;
        for(OrderItem item_de_pedido_temp : itens_de_pedido)
            if((maior_data == null) || (item_de_pedido_temp.Data_de_Entrega_Fornecedor__c > maior_data))
                maior_data = item_de_pedido_temp.Data_de_Entrega_Fornecedor__c;
        
		Order pedido = new Order();
        pedido = [
            SELECT	Id, Prazo_estimado__c
            FROM	Order
            WHERE 	Id = :item_de_pedido.OrderId
        ];
        pedido.Prazo_estimado__c = maior_data;
        update pedido;
    }
    
}