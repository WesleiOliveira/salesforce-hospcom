public class AssistenteEntregaProduto {

	public Id 						registro_pai_id {get;set;}
	public Order					pedido{get;set;}
	public List<OrderItem> 			itens_pedido{get;set;}
	public List<CEntregaDeItem>	    c_entregas_item{get;set;}
	
	public List<String> 			etapa {get;set;}
	public List<String>				etapas{get;set;}
	
	public Boolean 					tem_erros {get;set;}
	public List<String> 			erros {get;set;}
	
	public Boolean 					tem_produtos {get;set;}


	public AssistenteEntregaProduto(ApexPages.StandardController controller) {
		Inicializa(controller);
		ObtemDados();
	}
	
	public void Inicializa(ApexPages.StandardController controller){
		registro_pai_id = ((SObject)controller.getRecord()).Id;
		pedido = new Order();
		c_entregas_item = new List<CEntregaDeItem>();
		
		etapa = new List<String>();
		etapas = new List<String>();
		etapas.add('Entregar');
		SetaEtapa('entregar', 'Insira a quantidade entregue nos itens desejados');
		
		tem_erros = false;
	}
	
	public void SetaEtapa(String nome_etapa, String cabecalho){
		etapa.clear();
		etapa.add(nome_etapa);
		etapa.add(cabecalho);
	}
	
	public void ObtemDados(){
		tem_produtos = false;
		
		// pedido
		pedido = [
			SELECT	Id, OrderNumber
			FROM	Order
			WHERE	Id = :registro_pai_id
		];
		
		// itens do pedido ainda não entregues 100%
		itens_pedido = [
			SELECT	id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode, Marca__c, Modelo__c, PriceBookEntry.Product2.URL_da_Imagem__c, 
					Quantity, Quantidade_entregue__c, Quantidade_recebida__c 
			FROM	OrderItem
			WHERE	OrderId = :pedido.Id AND 
					Quantidade_falta_entregar__c > 0
			ORDER BY PriceBookEntry.Product2.Name
		];
		
		//** cria uma entrega p/ cada produto em aberto
		for(Orderitem item_pedido : itens_pedido){
			c_entregas_item.add(new CEntregaDeItem(
				item_pedido,
				new Entrega_de_item__c(
					Item_de_pedido_de_venda__c = item_pedido.Id,
					Data_de_entrega__c = null
				)
			));
		}
		
		tem_produtos = ((itens_pedido.size()>0)?true:false);
	}
	
	public pageReference Efetiva(){
		List<Entrega_de_item__c> entregas_item = new List<Entrega_de_item__c>();
		for(CEntregaDeItem c_entrega_item : c_entregas_item){
			if(c_entrega_item.entrega_item.Quantidade_entregue__c != null || c_entrega_item.entrega_item.Quantidade_entregue__c > 0){
				if(c_entrega_item.entrega_item.Data_de_entrega__c == null)
					c_entrega_item.entrega_item.Data_de_entrega__c = System.Today();
				entregas_item.add(c_entrega_item.entrega_item);
		   }
		}
		try {
			insert entregas_item;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		PreparaErros();
		if(tem_erros)
			return null;
		else
			return new PageReference('/' + String.valueOf(pedido.Id));    
	}
	
	public void PreparaErros(){
		tem_erros = ((ApexPages.getMessages().size()>0)?true:false);
        if(tem_erros){
            erros = new List<String>();
            for(Apexpages.Message mensagem: ApexPages.getMessages())
                erros.add(mensagem.getDetail());
        }
	}
	
	public class CEntregaDeItem {
		public Orderitem					item_pedido 	{get;set;}
		public Entrega_de_item__c			entrega_item	{get;set;}
		
		public CEntregaDeItem(Orderitem item_pedido_parm, Entrega_de_item__c entrega_item_parm) {
			item_pedido 	= item_pedido_parm;
			entrega_item 	= entrega_item_parm;
		}
	}
	
}