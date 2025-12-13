public class PedInsFeed {
    
    public static void FluxoInicial(OrderItem item_de_pedido){
		OrderItem item_completo = new OrderItem();
		item_completo = [
			SELECT	Order.Status, Product2.ProductCode, Product2.Name, Product2.Marca__c, Product2.Modelo__c
			FROM	OrderItem
			WHERE	Id = :item_de_pedido.Id
		];
        
		if(item_completo.Order.Status != 'Rascunho'){
		
			user usuario = new User();
			usuario = [SELECT CommunityNickName FROM User WHERE Id = :System.UserInfo.getUserId()];
			
			String mensagem = 'O item <b>'+item_completo.Product2.Name+'</b>, ';
			if(item_completo.Product2.ProductCode != null)
				mensagem += 'PN <b>'+item_completo.Product2.ProductCode+'</b>, ';
			if(item_completo.Product2.Marca__c != null)
				mensagem += 'marca '+item_completo.Product2.Marca__c+', ';
			if(item_completo.Product2.Modelo__c != null)
				mensagem += 'modelo '+item_completo.Product2.Modelo__c+', ';
			mensagem += 'R$ '+item_de_pedido.UnitPrice+', ';
			mensagem += 'Qtd. '+item_de_pedido.Quantity+', ';
			mensagem += 'foi deletado por <b>'+usuario.CommunityNickName+'</b>';		
			
			FeedItem publicacao = new FeedItem(
				ParentId = item_de_pedido.OrderId,
				Type = 'TextPost',
				IsRichText = true,
				Body =  mensagem,
				NetworkScope = 'AllNetworks',
				Visibility = 'AllUsers',
				Status = 'Published'
			);
			
			insert publicacao;
		}
    }
    
}