public class RequisicaoController {  
       	public list <OrderItem> ProdPedVenda	{get;set;}
    
    	public Requisicao_de_item__c Req 		{get;set;}
    	public OrderItem ProdutoDoPedido 		{get;set;}
    	public Item_de_fornecedor__c ItemPC 	{get;set;}
    	
		public ID pvendaId 						{get;set;}
		public ID ide 							{get;set;} 
    
    	public Decimal quantidadedirec 			{get;set;}
    
        public Boolean show 					{get;set;}
    	public Boolean filtros 					{get;set;}
    	public Boolean fecharfiltros 			{get;set;}
    	public Boolean displayPopup 			{get;set;}
    	public Boolean displayinnerPopup 		{get;set;}
    
    	public String pedido 					{get;set;}
    	public String nome 						{get;set;}
    	public String modelo					{get;set;}
    	public String marca						{get;set;}
    	public String COD						{get;set;}
  
    public RequisicaoController (ApexPages.StandardController controller){
         ide = ApexPages.currentPage().getParameters().get('id');
		Req = [SELECT ID, Item_de_Pedido_de_compra__r.Produto__r.ProductCode, Item_de_Pedido_de_compra__r.Produto__r.name, Item_de_Pedido_de_compra__r.Id,  Quantidade_disponivel__c from Requisicao_de_item__c WHERE ID =: ide];
        
        ItemPC = [SELECT Fornecedor__r.Name, Fornecedor__r.Id FROM Item_de_fornecedor__c WHERE Item_de_pedido_de_compra__c =: Req.Item_de_Pedido_de_compra__r.Id ];
        
        ProdPedVenda = [ SELECT  Id, OrderItemNumber, Descricao_da_linha__c, Status__c, Order.Prazo_de_entrega__c, Quantity,
					 		     Order.OrderNumber, Quantidade_falta_requisitar__c, Order.Account.Name, Order.Account.Raz_o_Social__c, 
					 			 Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c,
					 			 PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode,
					 			 PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c 
                         FROM OrderItem 
                         WHERE Product2.ProductCode =: Req.Item_de_pedido_de_compra__r.Produto__r.ProductCode AND Quantidade_falta_requisitar__c > 0 AND (Order.Status NOT IN ('Entregue Total', 'Rascunho','Aguardando Aprovação Comercial','Aguardando Aprovação Financeira','Reprovado','Cancelado')) AND (Status__c = 'Aguardando Compra Fornecedor' OR Status__c='Aguardando Compra Fornecedor 2' OR Status__c='Aguardando Entrega Fornecedor')
                       	 ORDER BY Order.Prazo_de_entrega__c
                       ];
        show=false;
        fecharfiltros=false;
        filtros=true;
        
    }
    public void pegarpvendaid(){
        displayPopup = true;
  		displayinnerPopup =false;
        
        ProdutoDoPedido = [SELECT ID, Order.OrderNumber, Order.Account.Name, Quantidade_falta_requisitar__c FROM ORDERITEM WHERE ID =: pvendaId];

    }
    public pageReference novarequisicao(){

        if (Req.Quantidade_Disponivel__c < quantidadedirec){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Quantidade informada inferior à disponível.'));
        	return null;
        }
        else if(ProdutoDoPedido.Quantidade_falta_requisitar__c < quantidadedirec){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Quantidade informada superior ao que falta requisitar.'));
        	return null;
        }
        else{
        Requisicao_de_item__c direc = new Requisicao_de_item__c();
        direc.Quantidade_requisitada__c = quantidadedirec;
        direc.Requisicao_pai__c = Req.Id;
        direc.Item_de_pedido_de_compra__c = Req.Item_de_pedido_de_compra__c;
        direc.Item_de_pedido_de_venda__c = ProdutoDoPedido.Id;
        direc.Data_de_requisicao__c = System.today();
        direc.RecordTypeId = '0125A000001QVQA';
        direc.Nao_acionar_trigger__c='nao acionar';
        insert direc;
            
            Item_de_fornecedor__c IPC = [SELECT ID FROM Item_de_fornecedor__c WHERE Item_de_pedido_de_compra__c =: Req.Item_de_pedido_de_compra__c];
            update IPC;
            
            PageReference pr = new PageReference('/apex/Requisicao?id=' + ide);
   			pr.setRedirect(true);
   			return pr;
    }
    }
    
    public void filtros(){
        show = true;
        fecharfiltros=true;
        filtros=false;
    }
     public void filtroscl(){
        show = false;
        fecharfiltros=false;
        filtros=true;
    }
    public void search(){
        if(nome != null && modelo == '' && marca == '' && pedido =='' && COD == ''){
        	 ProdPedVenda = [SELECT  Id, OrderItemNumber, Descricao_da_linha__c, Status__c, Order.Prazo_de_entrega__c, Quantity,
					 		     Order.OrderNumber, Quantidade_falta_requisitar__c, Order.Account.Name, Order.Account.Raz_o_Social__c, 
					 			 Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c,
					 			 PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode,
					 			 PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c 
                         	FROM OrderItem 
                         	WHERE Product2.Name like : '%'+nome+'%' AND Quantidade_falta_requisitar__c > 0 AND (Order.Status NOT IN ('Entregue Total', 'Rascunho','Aguardando Aprovação Comercial','Aguardando Aprovação Financeira','Reprovado','Cancelado')) AND (Status__c = 'Aguardando Compra Fornecedor' OR Status__c='Aguardando Compra Fornecedor 2' OR Status__c='Aguardando Entrega Fornecedor') 
                       	 	ORDER BY Order.Prazo_de_entrega__c                       
                       		];
    }
        if(modelo != null && nome == '' && marca == '' && pedido =='' && COD == ''){
             ProdPedVenda = [SELECT  Id, OrderItemNumber, Descricao_da_linha__c, Status__c, Order.Prazo_de_entrega__c, Quantity,
					 		     Order.OrderNumber, Quantidade_falta_requisitar__c, Order.Account.Name, Order.Account.Raz_o_Social__c, 
					 			 Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c,
					 			 PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode,
					 			 PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c 
                         	FROM OrderItem 
                         	WHERE Product2.Modelo__c like : '%'+modelo+'%' AND Quantidade_falta_requisitar__c > 0 AND (Order.Status NOT IN ('Entregue Total', 'Rascunho','Aguardando Aprovação Comercial','Aguardando Aprovação Financeira','Reprovado','Cancelado')) AND (Status__c = 'Aguardando Compra Fornecedor' OR Status__c='Aguardando Compra Fornecedor 2' OR Status__c='Aguardando Entrega Fornecedor')
                       	 	ORDER BY Order.Prazo_de_entrega__c
                            ];   
        }
        if(marca != null && nome == '' && modelo == '' && pedido =='' && COD == ''){
             ProdPedVenda = [SELECT  Id, OrderItemNumber, Descricao_da_linha__c, Status__c, Order.Prazo_de_entrega__c, Quantity,
					 		     Order.OrderNumber, Quantidade_falta_requisitar__c, Order.Account.Name, Order.Account.Raz_o_Social__c, 
					 			 Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c,
					 			 PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode,
					 			 PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c 
                         	FROM OrderItem 
                         	WHERE Product2.Marca__c like : '%'+marca+'%' AND Quantidade_falta_requisitar__c > 0 AND (Order.Status NOT IN ('Entregue Total', 'Rascunho','Aguardando Aprovação Comercial','Aguardando Aprovação Financeira','Reprovado','Cancelado')) AND (Status__c = 'Aguardando Compra Fornecedor' OR Status__c='Aguardando Compra Fornecedor 2' OR Status__c='Aguardando Entrega Fornecedor') 
                       	 	ORDER BY Order.Prazo_de_entrega__c                            
                            ];
        }
            if (pedido != null && marca == '' && nome == '' && modelo == '' && COD == ''){
             ProdPedVenda = [SELECT  Id, OrderItemNumber, Descricao_da_linha__c, Status__c, Order.Prazo_de_entrega__c, Quantity,
					 		     Order.OrderNumber, Quantidade_falta_requisitar__c, Order.Account.Name, Order.Account.Raz_o_Social__c, 
					 			 Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c,
					 			 PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode,
					 			 PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c 
                         	FROM OrderItem 
                         	WHERE Order.OrderNumber like : '%'+pedido+'%' AND Quantidade_falta_requisitar__c > 0 AND (Order.Status NOT IN ('Entregue Total', 'Rascunho','Aguardando Aprovação Comercial','Aguardando Aprovação Financeira','Reprovado','Cancelado')) AND (Status__c = 'Aguardando Compra Fornecedor' OR Status__c='Aguardando Compra Fornecedor 2' OR Status__c='Aguardando Entrega Fornecedor') 
                       	 	ORDER BY Order.Prazo_de_entrega__c
                            ];
            }
        	if (COD != null && marca == '' && nome == '' && modelo == '' && pedido == ''){
             ProdPedVenda = [SELECT  Id, OrderItemNumber, Descricao_da_linha__c, Status__c, Order.Prazo_de_entrega__c, Quantity,
					 		     Order.OrderNumber, Quantidade_falta_requisitar__c, Order.Account.Name, Order.Account.Raz_o_Social__c, 
					 			 Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c,
					 			 PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode,
					 			 PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c 
                         	FROM OrderItem 
                         	WHERE Product2.ProductCode like : '%'+COD+'%' AND Quantidade_falta_requisitar__c > 0 AND (Order.Status NOT IN ('Entregue Total', 'Rascunho','Aguardando Aprovação Comercial','Aguardando Aprovação Financeira','Reprovado','Cancelado')) AND (Status__c = 'Aguardando Compra Fornecedor' OR Status__c='Aguardando Compra Fornecedor 2' OR Status__c='Aguardando Entrega Fornecedor') 
                       	 	ORDER BY Order.Prazo_de_entrega__c
                            ];
            }
        }
    public void closePopup(){
  	displayPopup = false;
    displayinnerPopup=true;
 	}
    }