public class AssistenteEdicaoMassa {

	public Id 								registro_pai_id {get;set;}
	public Order							pedido{get;set;}
	public List<CItemVenda>					c_itens_venda{get;set;}
	
	public List<SelectOption>				status_todos {get;set;}
	public String							status {get;set;}
	
	public Boolean 							tem_erros {get;set;}
	public List<String> 					erros {get;set;}
	
	public AssistenteEdicaoMassa(ApexPages.StandardController controller) {
		Inicializa(controller);
		ObtemItensVenda();
	}
	
	public void Inicializa(ApexPages.StandardController controller){
		registro_pai_id = ((SObject)controller.getRecord()).Id;
		pedido = new Order();
		c_itens_venda = new List<CItemVenda>();
				
		status_todos = new List<SelectOption>();
		status_todos.add(new SelectOption('','Selecione o status...'));
		for(Schema.PicklistEntry valor_temp : OrderItem.Status__c.getDescribe().getPicklistValues())
			status_todos.add(new SelectOption(valor_temp.getLabel(),valor_temp.getLabel()));
		
		tem_erros = false;
	}
	
	public void ObtemItensVenda(){
        System.debug(registro_pai_id);
		pedido = [
			SELECT 	Id, OrderNumber
			FROM 	Order
			WHERE	Id = :registro_pai_id
		];
		
		List<OrderItem> itens_venda = new List<OrderItem>();
		itens_venda = [
			SELECT	Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode, Marca__c, Modelo__c, PriceBookEntry.Product2.URL_da_Imagem__c,
					Status__c, Descricao_da_linha__c, Quantity, UnitPrice, OrderId
			FROM	OrderItem
			WHERE	OrderId = :registro_pai_id
			ORDER BY PriceBookEntry.Product2.Name ASC, PriceBookEntry.Product2.Id ASC
		];
		
		// trabalha bordas de itens divididos e adiciona a lista GUI
		for(Integer cont=0; cont<itens_venda.size(); cont++){
			String antes = null, depois = null, borda = null;
			
			if(cont>0){
				if(itens_venda[cont-1].PriceBookEntry.Product2.Id == itens_venda[cont].PriceBookEntry.Product2.Id)
					antes = 'igual';
				else
					antes = 'diferente';
			}else
				antes = 'diferente';
			if((cont+1)<itens_venda.size()){
				if(itens_venda[cont+1].PriceBookEntry.Product2.Id == itens_venda[cont].PriceBookEntry.Product2.Id)
					depois = 'igual';
				else
					depois = 'diferente';
			}else
				depois = 'diferente';
			
			if(antes == 'igual' && depois == 'igual')
				borda = 'lateral';
			else if(antes == 'igual' && depois == 'diferente')
				borda = 'baixo';
			else if(antes == 'diferente' && depois == 'igual')
				borda = 'cima';
			else if(antes == 'diferente' && depois == 'diferente')
				borda = null;
			
			c_itens_venda.add(new CItemVenda(itens_venda[cont], false, itens_venda[cont].Quantity, itens_venda[cont].Status__c, borda));
		}
		
	}
	
	public pageReference Efetiva(){
		
		// variáveis auxiliares
		Savepoint restorepoint = Database.setSavepoint();
		List<String> status_novo = new list<String> {'Novo','Aberto'};
		List<String> status_divide = new list<String> {'Reservado','Aguardando Faturamento Cliente','Aguardando Faturamento','Aguardando Entrega Cliente','Entregue Cliente','Atendido'};
		List<OrderItem> itens_venda_upd = new List<OrderItem>();
		List<OrderItem> itens_venda_add = new List<OrderItem>();
		List<Requisicao_de_item__c> requisicoes_item = new List<Requisicao_de_item__c>();
		List<Entrega_de_item__c> entregas_item = new List<Entrega_de_item__c>();
		List<RecordType> tipos_registro = new List<RecordType>();
		Id record_estoque_compra, record_venda_compra, record_venda_estoque;
		
		// obtém tipos de registro
		tipos_registro = [
			SELECT	Id, DeveloperName
			FROM 	RecordType
			WHERE	SObjectType = 'Requisicao_de_item__c'
		];
		for(RecordType tipo_registro : tipos_registro){
			if(tipo_registro.DeveloperName == 'Suprir_estoque_com_compra')
				record_estoque_compra = tipo_registro.Id;
			else if (tipo_registro.DeveloperName == 'Atender_venda_com_compra')
				record_venda_compra = tipo_registro.Id;
            //Comentado para não inserir mais deste tipo deregistro
			else if (tipo_registro.DeveloperName == 'Atender_venda_com_estoque')
				record_venda_estoque = tipo_registro.Id;
		}
		
		// atualiza/divide itens, cria requisições
		for(CItemVenda c_item_venda : c_itens_venda){
			if( c_item_venda.status_old != c_item_venda.item_venda.Status__c && status_novo.contains(c_item_venda.status_old) && status_divide.contains(c_item_venda.item_venda.Status__c) && c_item_venda.qtd_atendida < c_item_venda.item_venda.Quantity){
				itens_venda_add.add(new OrderItem( OrderId = c_item_venda.item_venda.OrderId, PricebookEntryId = c_item_venda.item_venda.PricebookEntryId, Status__c = 'OPR - ANALISE DE COMPRA', Quantity = c_item_venda.item_venda.Quantity - c_item_venda.qtd_atendida, UnitPrice = c_item_venda.item_venda.UnitPrice, Descricao_da_linha__c = c_item_venda.item_venda.Descricao_da_linha__c));
				c_item_venda.item_venda.Quantity = c_item_venda.qtd_atendida;
			}
			
			if( c_item_venda.status_old != c_item_venda.item_venda.Status__c && status_novo.contains(c_item_venda.status_old) && !status_novo.contains(c_item_venda.item_venda.Status__c) && c_item_venda.item_venda.Status__c != 'OPR - ANALISE DE COMPRA' && c_item_venda.item_venda.Status__c != 'CMP - AG. ENTREGA FORNECEDOR' && c_item_venda.item_venda.Status__c != 'Cancelado'){
				requisicoes_item.add(new Requisicao_de_item__c(	RecordTypeId = record_venda_estoque, Quantidade_requisitada__c = c_item_venda.qtd_atendida,	Item_de_pedido_de_venda__c = c_item_venda.item_venda.Id, Data_de_requisicao__c = System.Today())); 
			}
			
			if(c_item_venda.status_old != c_item_venda.item_venda.Status__c && (c_item_venda.status_old != 'Entregue' && c_item_venda.status_old != 'Atendido') && (c_item_venda.item_venda.Status__c == 'Entregue' ||  c_item_venda.item_venda.Status__c == 'Atendido')){
				entregas_item.add(new Entrega_de_item__c( Quantidade_entregue__c = c_item_venda.qtd_atendida, Item_de_pedido_de_venda__c = c_item_venda.item_venda.Id, Data_de_entrega__c = System.Today()));
			}
			
			itens_venda_upd.add(c_item_venda.item_venda);
		}
		
		// salva na base de dados
		try{
			update itens_venda_upd;
		} catch(System.DMLException e){ ApexPages.addMessages(e); }
		
		//if(ApexPages.getMessages().size()==0 && requisicoes_item.size()>0){
		//	try{ insert requisicoes_item; }
        //    catch (System.DMLException e){ ApexPages.addMessages(e); }
		//}
		
		if(ApexPages.getMessages().size()==0 && entregas_item.size()>0){
			try{ insert entregas_item; }
			catch (System.DMLException e){ ApexPages.addMessages(e); }
		}
		
		if(ApexPages.getMessages().size()==0 && itens_venda_add.size()>0){
			try { insert itens_venda_add; }
			catch(System.DMLException e){ ApexPages.addMessages(e); }
		}
		
		// tratamento de erros
		
		PreparaErros();
		if(tem_erros){
			Database.rollback(restorepoint);
			return null;
		}
		else{
			PageReference tempPage = ApexPages.currentPage();            
			tempPage.setRedirect(true);
			return tempPage;
		}
	}
	
	public pageReference RetornarRegistro(){
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
	
	public class CItemVenda {
		public OrderItem	item_venda		{get;set;}
		public Boolean 		flag			{get;set;}
		public Decimal		qtd_atendida	{get;set;}
		public String		status_old		{get;set;}
		public String		borda			{get;set;}

		public CItemVenda(OrderItem item_venda_parm, Boolean flag_parm, Decimal qtd_atendida_parm, String status_old_parm, String borda_parm){
			item_venda 		= item_venda_parm;
			flag   			= flag_parm;
			qtd_atendida   	= qtd_atendida_parm;
			status_old   	= status_old_parm;
			borda			= borda_parm;
		}
	}

}