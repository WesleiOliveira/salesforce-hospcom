public with sharing class AssistentePedidoCompra {

	public List<CAgrupamento>	c_agrupamentos_full;
	public List<CAgrupamento>	c_agrupamentos_gui {get;set;}

	public List<CRequisicao>	c_requisicoes_venda_full;
	public List<CRequisicao>	c_requisicoes_prod_full;
	public List<CRequisicao> 	c_requisicoes_final;
	public List<CRequisicao>	c_requisicoes_gui {get;set;}

	public List<CFornecedor>	c_fornecedores_full {get;set;}
	
	public Pedido_de_compra__c	pedido {get;set;}

	public List<String> 		etapa {get;set;}
	public List<String>			etapas{get;set;}
	
	public Boolean 				tem_erros {get;set;}
	public List<String> 		erros {get;set;}

	public String				filtro_pedido{get;set;}
	public String				filtro_marca{get;set;}
	public String				filtro_codigo{get;set;}
	public String				filtro_modelo{get;set;}
	public String				filtro_nome{get;set;}
	public String				filtro_generico{get;set;}
	public Integer				pagina{get;set;}
	public Integer				num_pagina{get;set;}
	public Integer				num_agrupamentos{get;set;}
	public Integer				num_requisicoes{get;set;}
	public Integer				num_agrupamentos_full{get;set;}
	public Integer				num_requisicoes_full{get;set;}
	public Integer				num_fornecedores_full{get;set;}
	public List<RecordType>		tipos_registro{get;set;}
	public Id					record_estoque_compra;
	public Id					record_venda_compra;
	public Id					record_venda_estoque;

	public AssistentePedidoCompra() {
		Inicializa();
		ObterItens();
	}

	public void Inicializa(){
		c_agrupamentos_full = new List<CAgrupamento>();
		c_agrupamentos_gui = new List<CAgrupamento>();
		
		c_requisicoes_venda_full = new List<CRequisicao>();
		c_requisicoes_prod_full = new List<CRequisicao>();
		c_requisicoes_final = new List<CRequisicao>();
		c_requisicoes_gui = new List<CRequisicao>();

		c_fornecedores_full = new List<CFornecedor>();
		pedido = new Pedido_de_compra__c();
		
		etapa = new List<String>();
		etapas = new List<String>();
		etapas.add('Cotação');
		etapas.add('Selecionar');
		etapas.add('Adicionar');
		etapas.add('Fornecedor');
		etapas.add('Confirmar');
		SetaEtapa('cotação', 'Insira alguns dados da cotação'); // selecionar

		tem_erros = false;
		
		filtro_pedido = '';
		filtro_marca = '';
		filtro_codigo = '';
		filtro_modelo = '';
		filtro_nome = '';
		filtro_generico = '';
		pagina=1;
		num_pagina=0;
		
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
			else if (tipo_registro.DeveloperName == 'Atender_venda_com_estoque')
				record_venda_estoque = tipo_registro.Id;
		}
	}

	public void SetaEtapa(String nome_etapa, String cabecalho){
		etapa.clear();
		etapa.add(nome_etapa);
		etapa.add(cabecalho);
	}

	public void PaginacaoAnterior(){
		pagina = pagina-1;
		PaginacaoDivide();
	}

	public void PaginacaoSeguinte(){
		pagina = pagina+1;
		PaginacaoDivide();
	}

	public void PaginacaoDivide(){
		Integer posicao_inicial = (pagina-1) * (25-1);
		Integer posicao_final = (pagina) * (25-1);
		Integer indice_maximo = c_agrupamentos_full.size()-1;

		c_requisicoes_gui.clear();
		c_agrupamentos_gui.clear();
		num_agrupamentos = 0;
		num_requisicoes = 0;
		if(indice_maximo>=0){
			for(Integer cont = posicao_inicial; cont <= posicao_final; cont++){
				if(cont > indice_maximo)
					break;
				c_agrupamentos_gui.add(c_agrupamentos_full[cont]);
				num_agrupamentos++;
				for(CRequisicao c_requisicao : c_requisicoes_venda_full){
					if(c_agrupamentos_full[cont].produto.Id == c_requisicao.item_venda.Product2Id){
						c_requisicoes_gui.add(c_requisicao);
						num_requisicoes++;
					}
				}
			}
		}
		if(c_requisicoes_venda_full.size()==0)
			pagina=0;
	}

	// **Cotação, **Selecionar, **Adicionar, **Fornecedor, **Confirmar
	public void PaginaAnterior(){
		if(etapa[0] == 'selecionar'){
			SetaEtapa('cotação', 'Insira alguns dados da cotação');
		}
		else if(etapa[0] == 'adicionar'){
			SetaEtapa('selecionar', 'Selecione produtos de pedidos de venda');
			ObterItens();
		}
		else if(etapa[0] == 'fornecedor'){
			SetaEtapa('adicionar', 'Selecione produtos adicionais');
			filtro_generico = '';
			PesquisaProdutos();
		}
		else if(etapa[0] == 'confirmar'){
			SetaEtapa('fornecedor', 'Selecione os fornecedores');
			filtro_generico = '';
			PesquisaFornecedor();
		}
	}

	public void PaginaSeguinte(){
		if(etapa[0] == 'cotação'){
			SetaEtapa('selecionar', 'Selecione produtos de pedidos de venda');
			ObterItens();
		}
		else if(etapa[0] == 'selecionar'){
			SetaEtapa('adicionar', 'Selecione produtos adicionais');
			PesquisaProdutos();
		}
		else if(etapa[0] == 'adicionar'){
			SetaEtapa('fornecedor', 'Selecione os fornecedores');
			filtro_generico = '';
			PesquisaFornecedor();
		}
		else if(etapa[0] == 'fornecedor'){
			SetaEtapa('confirmar', 'Confirme os dados para efetivar a criação');
			PreEfetivar();
		}
	}

	public void ObterItens(){

		// limpa lista, preservando os marcados
		Set<Id> requisicoes_flag_id = new Set<Id>();
		for(Integer cont=c_requisicoes_venda_full.size()-1; cont>=0; cont--){
			if(c_requisicoes_venda_full[cont].flag == true)
				requisicoes_flag_id.add(c_requisicoes_venda_full[cont].requisicao.Item_de_pedido_de_venda__c);
		}
		c_requisicoes_venda_full.clear();
		c_agrupamentos_full.clear();
		c_requisicoes_gui.clear();
		c_agrupamentos_gui.clear();

		// realiza busca
		String filtro_pedido2 = '%'+filtro_pedido+'%';
		String filtro_marca2 = '%'+filtro_marca+'%';
		String filtro_codigo2 = '%'+filtro_codigo+'%';
		String filtro_modelo2 = '%'+filtro_modelo+'%';
		String filtro_nome2 = '%'+filtro_nome+'%';
		pagina=1;
		List<OrderItem> itens_venda = new List<OrderItem>();
		itens_venda = [
			SELECT  Id, OrderItemNumber, Descricao_da_linha__c,
					Order.OrderNumber, Quantidade_falta_requisitar__c, Order.Account.Name, Order.Account.Raz_o_Social__c, 
					Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c, 
					PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode,
					PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c
			FROM    OrderItem
			WHERE   (Order.Status NOT IN ('Rascunho','Aguardando Aprovação Comercial','Aguardando Aprovação Financeira','Reprovado','Cancelado') AND
					Quantidade_falta_requisitar__c > 0 AND
					Order.OrderNumber LIKE :filtro_pedido2 AND
					Status__c = 'Aguardando Compra Fornecedor' AND
					PriceBookEntry.Product2.Marca__c LIKE :filtro_marca2 AND
					(PriceBookEntry.Product2.ProductCode LIKE :filtro_codigo2 OR PriceBookEntry.Product2.ProductCode = null) AND
					(PriceBookEntry.Product2.Modelo__c LIKE :filtro_modelo2 OR PriceBookEntry.Product2.Modelo__c = null) AND
					PriceBookEntry.Product2.Name LIKE :filtro_nome2) OR
					Id IN :requisicoes_flag_id
			ORDER BY PriceBookEntry.Product2.Name ASC, PriceBookEntry.Product2Id ASC
		];

		Id agrupamento_id = null;
		for(OrderItem item_venda : itens_venda){

			// popula requisições
			c_requisicoes_venda_full.add(new CRequisicao(
				new Requisicao_de_item__c(
					RecordTypeId = record_venda_compra,				// "Atender produto de pedido de venda, com produto de pedido de compra."
					Item_de_pedido_de_venda__c = item_venda.Id, 	// produto de pedido de venda
					Quantidade_requisitada__c = item_venda.Quantidade_falta_requisitar__c	// manual na requisição / automático no produto
				),
				//item_venda,
				new OrderItemLite (
					item_venda.PriceBookEntry.Product2Id,
					item_venda.Order.OrderNumber,
					item_venda.OrderItemNumber,
					
					item_venda.Order.Faturamento_Feito__r.Name,
					item_venda.Order.Account.Name,
					
					item_venda.Descricao_da_linha__c,
					item_venda.Quantidade_falta_requisitar__c,
					null, null, null, null, null
				),
				null,
				(requisicoes_flag_id.contains(item_venda.Id)?true:false)
			));

			// popula agrupamentos
			if(item_venda.PriceBookEntry.Product2Id == agrupamento_id){
				c_agrupamentos_full[c_agrupamentos_full.size()-1].quantidade += item_venda.Quantidade_falta_requisitar__c;
				if((c_agrupamentos_full[c_agrupamentos_full.size()-1].flag == true) && requisicoes_flag_id.contains(item_venda.Id)==false){
					c_agrupamentos_full[c_agrupamentos_full.size()-1].flag = false;
				}
			}else{
				c_agrupamentos_full.add(new CAgrupamento(
					new Product2(
						Id = item_venda.PriceBookEntry.Product2Id,
						ProductCode = item_venda.PriceBookEntry.Product2.ProductCode,
						URL_da_Imagem__c = item_venda.PriceBookEntry.Product2.URL_da_Imagem__c,
						Name = item_venda.PriceBookEntry.Product2.Name,
						Modelo__c = item_venda.PriceBookEntry.Product2.Modelo__c,
						Marca__c = item_venda.PriceBookEntry.Product2.Marca__c
					),
					item_venda.Quantidade_falta_requisitar__c,
					(requisicoes_flag_id.contains(item_venda.Id)?true:false)
				));
			}
			agrupamento_id = item_venda.PriceBookEntry.Product2Id;
		}
		num_agrupamentos_full = c_agrupamentos_full.size();
		num_requisicoes_full = c_requisicoes_venda_full.size();
		num_pagina = (Integer)((num_agrupamentos_full/25.0).round(System.RoundingMode.UP));
		PaginacaoDivide();
	}

	public void PesquisaProdutos(){
		// limpa lista, preservando os marcados
		Set<Id> requisicoes2_flag_id = new Set<Id>();
		for(Integer cont=c_requisicoes_prod_full.size()-1; cont>=0; cont--){
			if(c_requisicoes_prod_full[cont].flag == false)
				c_requisicoes_prod_full.remove(cont);
			else{
				requisicoes2_flag_id.add(c_requisicoes_prod_full[cont].produto.Id);
			}
		}

		c_requisicoes_gui.clear();

		// realiza busca
		String filtro_generico2 = '%'+filtro_generico+'%';
		pagina=1;
		List<Product2> produtos = new List<Product2>();
		produtos = [
			SELECT  Id, Name, ProductCode, URL_da_Imagem__c, Marca__c, Modelo__c
			FROM    Product2
			WHERE   IsActive = true AND
					(
						Marca__c 	 LIKE :filtro_generico2 OR
						ProductCode  LIKE :filtro_generico2 OR
						Modelo__c 	 LIKE :filtro_generico2 OR
						Name 		 LIKE :filtro_generico2
					) AND
					Id NOT IN :requisicoes2_flag_id
			ORDER BY Name ASC
			LIMIT 25
		];

		for(Product2 produto : produtos){

			// popula requisições
			c_requisicoes_prod_full.add(new CRequisicao(
				new Requisicao_de_item__c(
					RecordTypeId = record_estoque_compra,          // "Atender produto de estoque, com produto de pedido de compra."
					Quantidade_requisitada__c = null
				),
				null,
				produto,
				(requisicoes2_flag_id.contains(produto.Id)?true:false)
			));
		}
		c_requisicoes_gui.addAll(c_requisicoes_prod_full);

		num_requisicoes_full = c_requisicoes_prod_full.size();
	}

	public void PesquisaFornecedor(){
		// limpa lista, preservando os marcados
		Set<Id> fornecedores_flag_id = new Set<Id>();
		for(Integer cont=c_fornecedores_full.size()-1; cont>=0; cont--){
			if(c_fornecedores_full[cont].flag == false)
				c_fornecedores_full.remove(cont);
			else{
				fornecedores_flag_id.add(c_fornecedores_full[cont].conta.Id);
			}
		}

		// realiza busca
		String filtro_generico2 = '%'+filtro_generico+'%';
		pagina=1;
		List<Account> contas = new List<Account>();
		contas = [
			SELECT  Id, Name, Raz_o_Social__c, CNPJ__c, BillingCity, BillingState
			FROM    Account
			WHERE   (
						(Name 	 			LIKE :filtro_generico2) OR
						(Raz_o_Social__c 	LIKE :filtro_generico2) OR
						(CNPJ__c 	 		LIKE :filtro_generico2)
					) AND
					Id NOT IN :fornecedores_flag_id
			ORDER BY Name ASC
			LIMIT 25
		];

		for(Account conta : contas){
			// popula requisições
			c_fornecedores_full.add(new CFornecedor(
				conta,
				(fornecedores_flag_id.contains(conta.Id)?true:false)
			));
		}

		num_fornecedores_full = c_fornecedores_full.size();

	}

	public void PreEfetivar(){

		// ## otimizado ##
		Set<Id> requisicoes_flag_id = new Set<Id>();
		for(Integer cont=c_requisicoes_venda_full.size()-1; cont>=0; cont--){
			if(c_requisicoes_venda_full[cont].flag == true)
				requisicoes_flag_id.add(c_requisicoes_venda_full[cont].requisicao.Item_de_pedido_de_venda__c);
		}
		List<OrderItem> itens_venda = new List<OrderItem>();
		itens_venda = [
			SELECT  Id, OrderItemNumber, Descricao_da_linha__c, Order.Faturamento_Feito__r.Name, Order.Account.Name,
					Order.OrderNumber, Quantidade_falta_requisitar__c,
					PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.ProductCode,
					PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c
			FROM    OrderItem
			WHERE   Id IN :requisicoes_flag_id
			ORDER BY PriceBookEntry.Product2.Name ASC, PriceBookEntry.Product2Id ASC
		];
		c_requisicoes_venda_full.clear();
		for(OrderItem item_venda : itens_venda){
			c_requisicoes_venda_full.add(new CRequisicao(
				new Requisicao_de_item__c(
					RecordTypeId = record_venda_compra,				
					Item_de_pedido_de_venda__c = item_venda.Id, 	
					Quantidade_requisitada__c = item_venda.Quantidade_falta_requisitar__c
				),
				new OrderItemLite (
					item_venda.PriceBookEntry.Product2Id,
					item_venda.Order.OrderNumber,
					item_venda.OrderItemNumber,
					
					item_venda.Order.Faturamento_Feito__r.Name,
					item_venda.Order.Account.Name,
					
					item_venda.Descricao_da_linha__c,
					item_venda.Quantidade_falta_requisitar__c,
					item_venda.PriceBookEntry.Product2.ProductCode,
					item_venda.PriceBookEntry.Product2.URL_da_Imagem__c,
					item_venda.PriceBookEntry.Product2.Name,
					item_venda.PriceBookEntry.Product2.Modelo__c,
					item_venda.PriceBookEntry.Product2.Marca__c
				),
				null,
				(requisicoes_flag_id.contains(item_venda.Id)?true:false)
			));
		}
		
		for(Integer cont=c_requisicoes_prod_full.size()-1; cont>=0; cont--)
			if(c_requisicoes_prod_full[cont].flag == false)
				c_requisicoes_prod_full.remove(cont);
		for(Integer cont=c_fornecedores_full.size()-1; cont>=0; cont--)
			if(c_fornecedores_full[cont].flag == false)
				c_fornecedores_full.remove(cont);

		c_requisicoes_final = new List<CRequisicao>();
		c_requisicoes_final.addAll(c_requisicoes_venda_full);
		c_requisicoes_final.addAll(c_requisicoes_prod_full);

		// ordena em agrupamentos de produtos
		Set<Id> produtos_id = new Set<Id>();
		c_agrupamentos_gui.clear();
		for(CRequisicao requisicao : c_requisicoes_final){
			if(
				(requisicao.item_venda != null && !produtos_id.contains(requisicao.item_venda.Product2id)) ||
				(requisicao.produto != null && !produtos_id.contains(requisicao.produto.Id))
			){
				if(requisicao.item_venda != null){
					produtos_id.add(requisicao.item_venda.Product2id);
					c_agrupamentos_gui.add(new CAgrupamento(
						new Product2(
							Id = requisicao.item_venda.Product2Id,
							ProductCode = requisicao.item_venda.ProductCode,
							URL_da_Imagem__c = requisicao.item_venda.URL_da_Imagem,
							Name = requisicao.item_venda.Name,
							Modelo__c = requisicao.item_venda.Modelo,
							Marca__c = requisicao.item_venda.Marca
						),
						requisicao.item_venda.Quantidade_falta_requisitar,
						true
					));
				}
				else if(requisicao.produto != null){
					produtos_id.add(requisicao.produto.Id);
					c_agrupamentos_gui.add(new CAgrupamento(
						new Product2(
							Id = requisicao.produto.Id,
							ProductCode = requisicao.produto.ProductCode,
							URL_da_Imagem__c = requisicao.produto.URL_da_Imagem__c,
							Name = requisicao.produto.Name,
							Modelo__c = requisicao.produto.Modelo__c,
							Marca__c = requisicao.produto.Marca__c
						),
						(Decimal) requisicao.requisicao.Quantidade_requisitada__c,
						true
					));
				}
			}else{
				for(CAgrupamento c_agrupamento : c_agrupamentos_gui){
					if(requisicao.item_venda != null && c_agrupamento.produto.id == requisicao.item_venda.Product2id){
						c_agrupamento.quantidade += requisicao.item_venda.Quantidade_falta_requisitar;
					}
					else if(requisicao.produto != null && c_agrupamento.produto.id == requisicao.produto.Id){
						c_agrupamento.quantidade += (Decimal) requisicao.requisicao.Quantidade_requisitada__c;
					}
				}
			}
		}
		num_fornecedores_full = c_fornecedores_full.size();
		num_agrupamentos_full = c_agrupamentos_gui.size();
	}

	public pageReference Efetiva(){
		
		// insere "cotação"
		if(pedido.Data_de_inicio__c == null)
			pedido.Data_de_inicio__c = System.Today();
		try {
			Insert pedido;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}

		// insere "itens de cotação"
		List<Item_de_pedido_de_compra__c> itens_compra = new List<Item_de_pedido_de_compra__c>();
		for(CAgrupamento c_agrupamento : c_agrupamentos_gui){
			itens_compra.add(new Item_de_pedido_de_compra__c(
				Pedido_de_compra__c = pedido.Id,
				Produto__c = c_agrupamento.produto.Id
			));
		}
		try {
			insert itens_compra;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		
		// insere "requisições de itens"
		List<Requisicao_de_item__c> requisicoes = new List<Requisicao_de_item__c>();
		for(CRequisicao c_requisicao : c_requisicoes_final){
			for(Item_de_pedido_de_compra__c item_compra : itens_compra){
				if((c_requisicao.item_venda != null && item_compra.Produto__c == c_requisicao.item_venda.Product2Id) ||
				   (c_requisicao.produto != null && item_compra.Produto__c == c_requisicao.produto.Id)){
					c_requisicao.requisicao.Item_de_pedido_de_compra__c = item_compra.Id;
					break;
				}
			}
			c_requisicao.requisicao.Data_de_requisicao__c = System.Today();
			requisicoes.add(c_requisicao.requisicao);
		}
		try {
			insert requisicoes;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		
		// insere "fornecedores"
		List<Fornecedor__c> fornecedores = new List<Fornecedor__c>();
		for(CFornecedor c_fornecedor : c_fornecedores_full){
			fornecedores.add(new Fornecedor__c(
				Fornecedor__c = c_fornecedor.conta.Id,
				Pedido_de_compra__c = pedido.Id,
				Comprador__c = pedido.Comprador__c
			));
		}
		try {
			insert fornecedores;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		
		// insere "itens de fornecedor"
		List<Item_de_fornecedor__c> itens_de_fornecedor = new List<Item_de_fornecedor__c>();
		for(Item_de_pedido_de_compra__c item_compra : itens_compra){
			Decimal quantidade=0;
			for(Requisicao_de_item__c requisicao : requisicoes)
				if(requisicao.Item_de_pedido_de_compra__c == item_compra.id)
					quantidade += requisicao.Quantidade_requisitada__c;
			for(Fornecedor__c fornecedor : fornecedores){
				itens_de_fornecedor.add(new Item_de_fornecedor__c(
					Fornecedor__c = fornecedor.id,
					Item_de_pedido_de_compra__c = item_compra.id,
					Quantidade__c = quantidade
				));
			}			
		}
		try {
			insert itens_de_fornecedor;
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
	
	public void BuscaEndereco(){
		List<Account> contas = new List<Account>();
		
		contas = [
			SELECT	BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode,
					ShippingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
			FROM 	Account
			WHERE	Id = :pedido.Comprador__c
		];

		if(contas.size() == 1){
			
			if (contas[0].ShippingStreet!=null && contas[0].ShippingState!=null && contas[0].ShippingCity!=null){
				pedido.Entrega_CEP__c = contas[0].ShippingPostalCode;
				pedido.Entrega_Cidade__c = contas[0].ShippingCity;
				pedido.Entrega_Estado__c = contas[0].ShippingState;
				pedido.Entrega_Pais__c = contas[0].ShippingCountry;
				pedido.Entrega_Rua__c = contas[0].ShippingStreet;								
			}
			else if(contas[0].BillingStreet!=null && contas[0].BillingState!=null && contas[0].BillingCity!=null){
				pedido.Entrega_CEP__c = contas[0].BillingPostalCode;
				pedido.Entrega_Cidade__c = contas[0].BillingCity;
				pedido.Entrega_Estado__c = contas[0].BillingState;
				pedido.Entrega_Pais__c = contas[0].BillingCountry;
				pedido.Entrega_Rua__c = contas[0].BillingStreet;				
			}
			
		}
	}
	
	
	public class cRequisicao {
		public Requisicao_de_item__c	requisicao	{get;set;}
		public OrderItemLite            item_venda	{get;set;}
		public Product2					produto		{get;set;}
		public Boolean 					flag		{get;set;}

		public cRequisicao(Requisicao_de_item__c requisicao_parm, OrderItemLite item_venda_parm, Product2 produto_parm, Boolean flag_parm) {
			requisicao 	= requisicao_parm;
			item_venda 	= item_venda_parm;
			produto 	= produto_parm;
			flag 		= flag_parm;
		}
	}

	public class CAgrupamento {
		public Product2					produto		{get;set;}
		public Decimal 					quantidade	{get;set;}
		public Boolean 					flag		{get;set;}

		public CAgrupamento(Product2 produto_parm, Decimal quantidade_parm, Boolean flag_parm) {
			produto 	= produto_parm;
			quantidade 	= quantidade_parm;
			flag   		= flag_parm;
		}
	}

	public class CFornecedor {
		public Account					conta		{get;set;}
		public Boolean 					flag		{get;set;}

		public CFornecedor(Account conta_parm, Boolean flag_parm) {
			conta 		= conta_parm;
			flag   		= flag_parm;
		}
	}
	
	public class OrderItemLite {
		public Id			Product2Id						{get;set;}
		public String 		OrderNumber						{get;set;}
		public String 		OrderItemNumber					{get;set;}
		public String 		OrderItemFaturamento			{get;set;}
		public String 		OrderItemConta					{get;set;}
		public String 		Descricao_da_linha				{get;set;}
		public Decimal		Quantidade_falta_requisitar 	{get;set;}
		
		public String		ProductCode						{get;set;}
		public String 		URL_da_Imagem					{get;set;}
		public String 		Name							{get;set;}
		public String 		Modelo							{get;set;}
		public String 		Marca							{get;set;}
		
		public OrderItemLite(Id Product2Id_parm, String OrderNumber_parm, String OrderItemNumber_parm, 
							String OrderItemFaturamento_parm, String OrderItemConta_parm, 
						    String Descricao_da_linha_parm, Decimal Quantidade_falta_requisitar_parm,
						    String ProductCode_parm, String URL_da_Imagem_parm, String Name_parm, 
						    String Modelo_parm, String Marca_parm){
			Product2Id					= Product2Id_parm;
			OrderNumber					= OrderNumber_parm;
			OrderItemNumber				= OrderItemNumber_parm;
			OrderItemFaturamento		= OrderItemFaturamento_parm;
			OrderItemConta				= OrderItemConta_parm;
			Descricao_da_linha			= Descricao_da_linha_parm;
			Quantidade_falta_requisitar = Quantidade_falta_requisitar_parm;
			ProductCode					= ProductCode_parm;
			URL_da_Imagem				= URL_da_Imagem_parm;
			Name						= Name_parm;
			Modelo						= Modelo_parm;
			Marca						= Marca_parm;
		}
	}
	
}