public class PedidoProdutos {
	
	public Tela tela {get;set;}
	
	public Order pedido {get;set;}
	public Pesquisa pesquisa {get;set;}
	public Navegacao navegacao {get;set;}
	
	public PedidoProdutos(ApexPages.StandardController controlador) {
		tela = new Tela();
		
		pedido = ((Order)controlador.getRecord());
		pedidoBuscar();
		
		if(pedido.Pricebook2Id == null){
			for(Pricebook2 catalogo : [SELECT Id, Name FROM Pricebook2 WHERE IsActive = true])
				tela.dado_cats.add(new SelectOption(catalogo.Id, catalogo.Name));
		}else{
			pesquisa = new Pesquisa();
			Pesquisar();
			
			navegacao = new Navegacao();
			Navegar();			
		}
	}
	
	
	public void pedidoBuscar(){
		pedido = Database.query(
			'SELECT		Id, PriceBook2Id, CurrencyIsoCode, QuoteId, OpportunityId, Ordem_de_trabalho__c,( ' +
			'				SELECT		Id, Product2.ProductCode, Product2.StockKeepingUnit, Product2.Name, Product2.Marca__c, Product2.Modelo__c, ' +
			'							Product2.Description, Product2.URL_da_Imagem__c, PricebookEntryId, ' +
			'							Item__c, Item_Pai__c, Lote__c, Descricao_da_linha__c, ' +
			'							UnitPrice, Quantity, TotalPrice' +
			'				FROM		OrderItems ' +
			'				ORDER BY	Item__c ' +
			'			) ' +
			'FROM		Order ' +
			'WHERE		Id = \'' + pedido.Id + '\' ' 
		);
		
		for(OrderItem item : pedido.OrderItems){
			if(item.Product2.URL_da_Imagem__c==null)
				item.Product2.URL_da_Imagem__c = 'https://hospcom--c.na49.content.force.com/servlet/servlet.ImageServer?id=0155A000009y8x5&oid=00Di0000000JVhH&lastMod=1540211149000';
		}
	}
    
	public void PedidoSalvarProdutos(){
		List<List<Serial2Apex>> itens_new_pe = (List<List<Serial2Apex>>)JSON.deserialize(tela.itens_ped, List<List<Serial2Apex>>.class);
		
		// esta na "old" e não está na "new": 	remove da "old"
		Boolean remove;
		List<OrderItem> itens_old_del = new List<OrderItem>();
		for(OrderItem item_old : pedido.OrderItems){
			remove = true;
			for(List<Serial2Apex> itens_new_pi : itens_new_pe){
				for(Serial2Apex iten_new_p : itens_new_pi){ // loop pai
					if(iten_new_p.itm_id!='' && item_old.id == iten_new_p.itm_id){
						remove = false;
						break;
					}
					for(List<Children> itens_new_fi : iten_new_p.children){
						for(Children iten_new_f : itens_new_fi){ // loop filho
							if(iten_new_f.itm_id!='' && item_old.id == iten_new_f.itm_id){
								remove = false;
								break;
							}
						}
					}
					
				}
			}
			if(remove)
				itens_old_del.add(item_old);
		}
		
		if(itens_old_del.size()>0)
			try{delete itens_old_del;}
			catch(System.DMLException e){ApexPages.addMessages(e);}
		
		// está na "old" e na "new": 			atualiza "old" com "new"
		// não está na "old" e está na "new" 	edicinoa na "old"
		Boolean insere;
		List<OrderItem> itens_old_upd = new List<OrderItem>();
		List<OrderItem> itens_old_ins = new List<OrderItem>();		
		for(List<Serial2Apex> itens_new_pi : itens_new_pe){
			for(Serial2Apex iten_new_p : itens_new_pi){ // loop pai
				insere = true;
				if(iten_new_p.itm_id != ''){
					for(OrderItem item_old : pedido.OrderItems){
						if(iten_new_p.itm_id == item_old.id){
							insere = false;
							item_old.Item__c = Decimal.valueOf(iten_new_p.itm_item);
							item_old.Item_pai__c = (iten_new_p.itm_item_pai!='' ? Decimal.valueOf(iten_new_p.itm_item_pai) : null );
							item_old.Lote__c = iten_new_p.itm_lote;
							item_old.UnitPrice = Decimal.valueOf(iten_new_p.itm_valor);
							item_old.Quantity = Decimal.valueOf(iten_new_p.itm_quantidade);
							item_old.Descricao_da_linha__c = iten_new_p.itm_descr_linha;
							itens_old_upd.add(item_old);
							break;
						}					
					}
				}
				if(insere){
					itens_old_ins.add(new OrderItem(
						OrderId = pedido.Id,
						Status__c = (pedido.Ordem_de_trabalho__c!=null?'Aberto':'Novo'),
						PricebookEntryId = iten_new_p.ent_id,
						Item__c = Decimal.valueOf(iten_new_p.itm_item),
						Item_pai__c = (iten_new_p.itm_item_pai!='' ? Decimal.valueOf(iten_new_p.itm_item_pai) : null ),
						Lote__c = iten_new_p.itm_lote,
						UnitPrice = Decimal.valueOf(iten_new_p.itm_valor),
						Quantity = Decimal.valueOf(iten_new_p.itm_quantidade),
						Descricao_da_linha__c = iten_new_p.itm_descr_linha
					));
				}
				for(List<Children> itens_new_fi : iten_new_p.Children){
					for(Children iten_new_f : itens_new_fi){ // loop filho
						insere = true;
						if(iten_new_f.itm_id != ''){
							for(OrderItem item_old : pedido.OrderItems){
								if(iten_new_f.itm_id == item_old.id){
									insere = false;
									item_old.Item__c = Decimal.valueOf(iten_new_f.itm_item);
									item_old.Item_pai__c = (iten_new_f.itm_item_pai!='' ? Decimal.valueOf(iten_new_f.itm_item_pai) : null );
									item_old.Lote__c = iten_new_f.itm_lote;
									item_old.UnitPrice = Decimal.valueOf(iten_new_f.itm_valor);
									item_old.Quantity = Decimal.valueOf(iten_new_f.itm_quantidade);
									item_old.Descricao_da_linha__c = iten_new_f.itm_descr_linha;
									itens_old_upd.add(item_old);
									break;
								}			
							}
						}
						if(insere){
							itens_old_ins.add(new OrderItem(
								OrderId = pedido.Id,
								Status__c = (pedido.Ordem_de_trabalho__c!=null?'Aberto':'Novo'),
								PricebookEntryId = iten_new_f.ent_id,
								Item__c = Decimal.valueOf(iten_new_f.itm_item),
								Item_pai__c = (iten_new_f.itm_item_pai!='' ? Decimal.valueOf(iten_new_f.itm_item_pai) : null ),
								Lote__c = iten_new_f.itm_lote,
								UnitPrice = Decimal.valueOf(iten_new_f.itm_valor),
								Quantity = Decimal.valueOf(iten_new_f.itm_quantidade),
								Descricao_da_linha__c = iten_new_f.itm_descr_linha
							));
						}
					}
				}
			}
		}
		if(itens_old_upd.size()>0)
			try{update itens_old_upd;}
			catch(System.DMLException e){ApexPages.addMessages(e);}
		
		if(itens_old_ins.size()>0){
			try{insert itens_old_ins;}
			catch(System.DMLException e){ApexPages.addMessages(e);}
			
			for(List<Serial2Apex> itens_new_pi : itens_new_pe){
				for(Serial2Apex iten_new_p : itens_new_pi){ // loop pai
					if(iten_new_p.itm_id==''){
						for(OrderItem item_old_ins : itens_old_ins){
							if(Decimal.valueOf(iten_new_p.itm_item) == item_old_ins.Item__c){
								iten_new_p.itm_id = item_old_ins.Id;
								break;
							}
						}
					}
					for(List<Children> itens_new_fi : iten_new_p.children){
						for(Children iten_new_f : itens_new_fi){ // loop filho
							if(iten_new_f.itm_id==''){
								for(OrderItem item_old_ins : itens_old_ins){
									if(Decimal.valueOf(iten_new_f.itm_item) == item_old_ins.Item__c){
										iten_new_f.itm_id = item_old_ins.Id;
										break;
									}
								}
							}
						}
					}
				}
			}
			tela.itens_ped = JSON.serialize(itens_new_pe);
		}
		
		pedidoBuscar();
		VerificarErros();
	}
	
	public void PedidoSalvarCatalogo(){
		pedido.Pricebook2Id = tela.dado_cat;
		update pedido;
		
		pesquisa = new Pesquisa();
		Pesquisar();
		
		navegacao = new Navegacao();
		Navegar();			
	}
	
	public void Pesquisar(){
		
		// filtros
		List<String> condicoes = new List<String>();
		String condicao = '';
		if(pesquisa.termo_busca.trim() != null && pesquisa.termo_busca.trim() != '')
            condicoes.add(
                '( ' +
                    'Name LIKE \'%'+pesquisa.termo_busca.trim()+'%\' OR '+
                    'ProductCode LIKE \'%'+pesquisa.termo_busca.trim()+'%\' OR '+
                    'StockKeepingUnit LIKE \'%'+pesquisa.termo_busca.trim()+'%\' OR '+
                    'Family LIKE \'%'+pesquisa.termo_busca.trim()+'%\' OR '+
                    'Marca__c LIKE \'%'+pesquisa.termo_busca.trim()+'%\' OR '+
                    'Modelo__c LIKE \'%'+pesquisa.termo_busca.trim()+'%\' '+
                ' )'
            );
		if(pesquisa.ftr_tipo == 'Equipamentos'){
			condicoes.add('Tipo_do_Produto__c = \'EQUIPAMENTO\'');
		}else if(pesquisa.ftr_tipo == 'Não equipamentos'){
			condicoes.add('Tipo_do_Produto__c != \'EQUIPAMENTO\'');
		}
		if(pesquisa.ftr_add_restricao == false){ // padrão 
			condicoes.add(
				'IsActive = true AND Id IN (' +
					'SELECT Product2Id ' +
					'FROM 	PricebookEntry ' +
					'WHERE 	IsActive = true AND' +
					'	 	Pricebook2Id = \''+ pedido.Pricebook2Id +'\' AND' +
					'	 	CurrencyIsoCode = \''+ pedido.CurrencyIsoCode +'\' ' +
				') '
			);
		}
		if(pesquisa.ftr_add_servico == false){ // padrão
			condicoes.add('Tipo_do_Produto__c != \'SERVIÇO\'');
		}
        if(condicoes.size()>0){
			condicao = String.join(condicoes, ' AND ');
			condicao = 'WHERE ' + condicao + ' ';
		}
		
		// produtos
		List<Product2> produtos = Database.query(
			'SELECT		Id, ProductCode, StockKeepingUnit, Name, Marca__c, Modelo__c,Description, Tipo_do_Produto__c, URL_da_Imagem__c, IsActive ' +
			'FROM		Product2 ' +
			 condicao +
			'ORDER BY 	LastModifiedDate  DESC ' +
			'LIMIT		'+ pesquisa.reg_pag + ' ' +
			'OFFSET		'+ (pesquisa.pag_atual-1)*pesquisa.reg_pag + ' '
		);
		List<Id> produtos_id = new List<Id>();
		for(Product2 produto : produtos)
			produtos_id.add(produto.id);
		
		// entradas de catalogos (status)
		List<PricebookEntry> entradas = [
			SELECT 		Id, UnitPrice, IsActive, Product2Id
			FROM 		PricebookEntry
			WHERE		Product2Id IN :produtos_id AND
						PriceBook2Id = :pedido.PriceBook2Id AND 
						CurrencyIsoCode = :pedido.CurrencyIsoCode
		];
		
		// itens de oportunidade (estatísticas)
		List<AggregateResult> vendas = [
			SELECT  	SUM(Quantity) Quantity, AVG(UnitPrice) UnitPrice, MAX(Product2Id) Product2Id
			FROM    	OpportunityLineItem
			WHERE		Product2Id IN :produtos_id AND
						Opportunity.StageName = 'WIN' AND
						Opportunity.CurrencyIsoCode = :pedido.CurrencyIsoCode
		];
		
		// pesquisa
		pesquisa.produtos.clear();
		for(Product2 produto : produtos){
			Produto produto2 = new Produto();
			
			// produto
			if(produto.URL_da_Imagem__c==null)
				produto.URL_da_Imagem__c = 'https://hospcom--c.na49.content.force.com/servlet/servlet.ImageServer?id=0155A000009y8x5&oid=00Di0000000JVhH&lastMod=1540211149000';
			if(produto.Modelo__c==null)
				produto.Modelo__c = '-';
			if(produto.Tipo_do_Produto__c==null)
				produto.Tipo_do_Produto__c = '-';
			produto2.campos = produto;
			
			// status
			if(!produto.isActive){
				produto2.status = 'Produto desativado';
			}else{
				for(PricebookEntry entrada : entradas){
					if(produto.id == entrada.Product2Id){
						if(!entrada.isActive){
							produto2.status = 'Entrada no catálogo desativada';
						}else{
							produto2.status = 'Ativo';
							produto2.entrada_id = entrada.Id;
							produto2.entrada_valor = String.ValueOf(entrada.UnitPrice);
							break;
						}
					}
				}
				if(produto2.status == null){
					produto2.status = 'Produto sem entrada no catálogo';
				}
			}
			
			// estatísticas
			for(AggregateResult venda : vendas){
				if(produto.Id == venda.get('Product2Id')){
					produto2.total_vendido = String.valueOf(((Decimal)venda.get('Quantity')).setScale(0));
					produto2.media_valor = String.valueOf(((Decimal) venda.get('UnitPrice')).setScale(2));
				}
			}
			
			pesquisa.produtos.add(produto2);
		}
		
		// paginação
		pesquisa.reg_total = Database.countQuery('SELECT count() FROM Product2 ' + condicao);
		pesquisa.pag_total = (Integer)((pesquisa.reg_total/(Decimal)pesquisa.reg_pag).round(System.RoundingMode.UP));
		
	}
    
	public void Navegar(){
		navegacao.categorias = new List<MktCategoria__c>();
		navegacao.produtos = new List<Produto>();
		navegacao.categoria = new MktCategoria__c();
		navegacao.ftr_tipo_vals = new List<SelectOption>();
		
		if(navegacao.ftr_id==''){
			navegacao.categorias = Database.query(
				'SELECT     Name, Icone_url__c ' +
				'FROM       MktCategoria__c ' +
				'WHERE      Categoria_pai__c = null AND ' +
				'			Ativo__c = true ' +
				'ORDER BY   Name ASC '
			);
		}
		else{
			navegacao.categoria = Database.query(
				'SELECT     Name, Icone_url__c,  Categoria_pai__c ' +
				'FROM       MktCategoria__c ' +
				'WHERE      Id = \''+ navegacao.ftr_id +'\' '
			);
			navegacao.categorias = Database.query(
				'SELECT 	Name, Icone_url__c ' +
				'FROM 		MktCategoria__c ' +
				'WHERE 		Categoria_pai__c = \''+ navegacao.ftr_id +'\' ' +
				'ORDER BY   Ordem__c ASC'
			);
			
			List<AggregateResult> tipos = [
				SELECT 		count(Id) qtd, parte__r.tipo_do_produto__c tipo
				FROM 		MktParte__c
				WHERE 		Categoria__c = :navegacao.ftr_id
				GROUP BY 	Parte__r.Tipo_do_produto__c
				ORDER BY    parte__r.tipo_do_produto__c ASC
			];
			
			if(tipos.size()>0){
				if(navegacao.ftr_id!=navegacao.ftr_id_old)
					navegacao.ftr_tipo = String.valueOf(tipos[0].get('tipo'));
				for(AggregateResult tipo : tipos){
					navegacao.ftr_tipo_vals.add(new SelectOption(
						String.valueOf(tipo.get('tipo')),
						String.valueOf(tipo.get('tipo')) +' ('+String.valueOf(tipo.get('qtd'))+')'
					));
					if(navegacao.ftr_id!=navegacao.ftr_id_old && String.valueOf(tipo.get('tipo'))=='EQUIPAMENTO')
						navegacao.ftr_tipo = 'EQUIPAMENTO';
				}
				
				// obtem produtos
				List<MktParte__c> partes = Database.query(
					'SELECT		Parte__r.Id, Parte__r.ProductCode, Parte__r.StockKeepingUnit, Parte__r.Name, Parte__r.Marca__c, Parte__r.Modelo__c, ' +
					'			Parte__r.Description, Parte__r.Tipo_do_Produto__c, Parte__r.URL_da_Imagem__c, Parte__r.IsActive ' +
					'FROM 		MktParte__c ' +
					'WHERE 		Categoria__c = \''+ navegacao.ftr_id +'\' AND ' +
					'			Parte__r.Tipo_do_produto__c = \''+ navegacao.ftr_tipo +'\' ' +
					'ORDER BY   Ordem__c ASC'
				);
				List<Id> produtos_id = new List<Id>();
				for(MktParte__c parte : partes)
					produtos_id.add(parte.Parte__r.Id);
				
				// entradas de catalogos (status)
				List<PricebookEntry> entradas = [
					SELECT 		Id, UnitPrice, IsActive, Product2Id
					FROM 		PricebookEntry
					WHERE		Product2Id IN :produtos_id AND
								PriceBook2Id = :pedido.PriceBook2Id AND 
								CurrencyIsoCode = :pedido.CurrencyIsoCode
				];
				
				// itens de oportunidade (estatísticas)
				List<AggregateResult> vendas = [
					SELECT  	SUM(Quantity) Quantity, AVG(UnitPrice) UnitPrice, MAX(Product2Id) Product2Id
					FROM    	OpportunityLineItem
					WHERE		Product2Id IN :produtos_id AND
								Opportunity.StageName = 'WIN' AND
								Opportunity.CurrencyIsoCode = :pedido.CurrencyIsoCode
				];
				
				// pesquisa
				pesquisa.produtos.clear();
				for(MktParte__c parte : partes){
					Produto produto2 = new Produto();
					
					// produto
					if(parte.Parte__r.URL_da_Imagem__c==null)
						parte.Parte__r.URL_da_Imagem__c = 'https://hospcom--c.na49.content.force.com/servlet/servlet.ImageServer?id=0155A000009y8x5&oid=00Di0000000JVhH&lastMod=1540211149000';
					if(parte.Parte__r.Modelo__c==null)
						parte.Parte__r.Modelo__c = '-';
					if(parte.Parte__r.Tipo_do_Produto__c==null)
						parte.Parte__r.Tipo_do_Produto__c = '-';
					produto2.campos = parte.Parte__r;
					
					// status
					if(!parte.Parte__r.isActive){
						produto2.status = 'Produto desativado';
					}else{
						for(PricebookEntry entrada : entradas){
							if(parte.Parte__r.id == entrada.Product2Id){
								if(!entrada.isActive){
									produto2.status = 'Entrada no catálogo desativada';
								}else{
									produto2.status = 'Ativo';
									produto2.entrada_id = entrada.Id;
									produto2.entrada_valor = String.ValueOf(entrada.UnitPrice);
									break;
								}
							}
						}
						if(produto2.status == null){
							produto2.status = 'Produto sem entrada no catálogo';
						}
					}
					
					// estatísticas
					for(AggregateResult venda : vendas){
						if(parte.Parte__r.Id == venda.get('Product2Id')){
							produto2.total_vendido = String.valueOf(((Decimal)venda.get('Quantity')).setScale(0));
							produto2.media_valor = String.valueOf(((Decimal) venda.get('UnitPrice')).setScale(2));
						}
					}
					
					navegacao.produtos.add(produto2);
				}
				
			}
		}
		navegacao.ftr_id_old = navegacao.ftr_id;
	}
	
    public void VerificarErros(){
		tela.mensagem = null;
        for(Apexpages.Message mensagem : ApexPages.getMessages())
			tela.mensagem = (tela.mensagem==null ? '' :  tela.mensagem + '\n') + mensagem.getDetail() ;
		ApexPages.getMessages().clear();
    }
	
	public class Tela{
		public String mensagem {get;set;}
		public String url_base {get;set;}
		public String itens_ped {get;set;}
		public String dado_cat {get;set;}
		public List<SelectOption> dado_cats {get;set;}
		
		public Tela(){
			mensagem = null;
			url_base = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
			itens_ped = '';
			dado_cat = null;
			dado_cats = new List<SelectOption>();
		}
	}
	
	
	public class Pesquisa{
		public List<Produto> produtos {get;set;}
		
		public String termo_busca {get;set;}
		public String ftr_tipo {get;set;}
		public List<SelectOption> ftr_tipo_vals {get;set;}
		public Boolean ftr_add_restricao {get;set;}
		public Boolean ftr_add_servico {get;set;}
		
		public Integer reg_pag {get;set;}
		public Integer pag_atual {get;set;}
		public Integer pag_total {get;set;}
		public Integer reg_total {get;set;}
		
		public Pesquisa(){
			produtos = new List<Produto>();
			reg_pag = 26;
			termo_busca = '';
			ftr_tipo = null;
			ftr_tipo_vals = new List<SelectOption>();
			ftr_tipo_vals.add(new SelectOption('Todos', 'Todos'));
			ftr_tipo_vals.add(new SelectOption('Equipamentos', 'Equipamentos'));
			ftr_tipo_vals.add(new SelectOption('Não equipamentos', 'Não equipamentos'));
			ftr_add_restricao = false;
			ftr_add_servico = true;
			pag_atual = 1;
			pag_total = 0;
			reg_total = 0;
		}
	}
	
	public class Navegacao{
		public List<MktCategoria__c> categorias {get;set;}
		public List<Produto> produtos {get;set;}
		public MktCategoria__c categoria {get;set;}
		
		public String ftr_id {get;set;}
		public String ftr_id_old {get;set;}
		public String ftr_tipo {get;set;}
		public List<SelectOption> ftr_tipo_vals {get;set;}

		
		public Navegacao(){
			categorias = new List<MktCategoria__c>();
			produtos = new List<Produto>();
			categoria = new MktCategoria__c();
			ftr_id = '';
			ftr_id_old = '';
			ftr_tipo = null;
			ftr_tipo_vals = new List<SelectOption>();
		}
	}
	
	public class Produto{
		public Product2 campos {get;set;}
		public String status {get;set;}
		public Id     entrada_id {get;set;}
		public String entrada_valor {get;set;}
		public String total_vendido {get;set;}
		public String media_valor {get;set;}
		
		public Produto(){
			campos = new Product2();
			status = null;
		}
	}
	
	public class Serial2Apex {

		public String itm_id;
		public String ent_id;
		public String itm_item;
		public String itm_item_pai;
		public String itm_lote;
		public String itm_valor;
		public String itm_quantidade;
		public String itm_desconto;
		public String itm_descr_linha;
		public List<List<Children>> children;

		public List<List<Serial2Apex>> parse(String json) {
			return (List<List<Serial2Apex>>) System.JSON.deserialize(json, List<List<Serial2Apex>>.class);
		}
	}	
	
	public class Children {
		public String itm_id;
		public String ent_id;
		public String itm_item;
		public String itm_item_pai;
		public String itm_lote;
		public String itm_valor;
		public String itm_quantidade;
		public String itm_desconto;
		public String itm_descr_linha;
	}
	
}