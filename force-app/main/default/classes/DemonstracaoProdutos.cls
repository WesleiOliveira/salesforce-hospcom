public class DemonstracaoProdutos {
	// Demonstracao |  AtivoPesquisa

	public Tela tela {get;set;}
	public Demonstracao__c demonstracao {get;set;}
	public AtivoPesquisa ativo_pesquisa {get;set;}

	public DemonstracaoProdutos(ApexPages.StandardController controlador) {
		tela = new Tela();

		demonstracao = ((Demonstracao__c)controlador.getRecord());
		DemonstracaoBuscar();

		ativo_pesquisa = new AtivoPesquisa();
		ativo_pesquisa.ftr_tipo_vals.add(new SelectOption('TODOS', 'TODOS'));
		List<String> tipos_ignorar = new List<String>{'SERVIÇO','SOFTWARE','KIT SERVIÇO'};
        for(Schema.PicklistEntry tipo : Product2.Tipo_do_Produto__c.getDescribe().getPicklistValues())
			if(!tipos_ignorar.contains(tipo.getLabel()))
				ativo_pesquisa.ftr_tipo_vals.add(new SelectOption(tipo.getLabel(),tipo.getLabel()));
		AtivoPesquisar();
	}


	public void DemonstracaoBuscar(){
		demonstracao = Database.query(
			'SELECT		Id, CurrencyIsoCode,( ' +
			'				SELECT		Id, Item__c, Item_Pai__c, Descricao__c, Valor__c, ' +
			' 							Ativo__c, Ativo__r.SerialNumber, Ativo__r.Description,  Ativo__r.Observa_es__c, ' +
			'							Ativo__r.Product2Id, Ativo__r.Product2.URL_da_Imagem__c, Ativo__r.Product2.Name, ' +
			'							Ativo__r.Product2.Modelo__c, Ativo__r.Product2.Marca__c, Ativo__r.Product2.StockKeepingUnit, ' +
			'							Ativo__r.Product2.ProductCode ' +
			'				FROM		Produtos_da_Demonstracao__r ' +
			'				ORDER BY	Item__c ' +
			'			) ' +
			'FROM		Demonstracao__c ' +
			'WHERE		Id = \'' + demonstracao.Id + '\' '
		);
	}

	public void AtivoPesquisar(){

		// filtros ...
		List<String> condicoes = new List<String>();
		String condicao = '';
		String condicao_filho = '';
		
		// ...fixos
		condicoes.add('SerialNumber != null');
		condicoes.add('Status NOT IN (\'INOPERANTE\', \'DESATIVADO\')');
		condicoes.add('Disponivel_p_contratos__c INCLUDES(\'Demonstração\')');
		condicoes.add(
			' (Id NOT IN ( ' +
			' 		SELECT  Ativo__c ' +
			' 		FROM 	Produto_da_demonstracao__c ' +
			' 		WHERE 	Ativo__c != null AND ' +
			' 				Demonstracao__c =  \'' + demonstracao.Id + '\'' +
			' ))'
		);
		condicoes.add('Product2Id != null');
		condicoes.add('Product2.IsActive = true');
		condicoes.add(
			' (Product2Id IN ( ' +
			' 		SELECT  Product2Id ' +
			' 		FROM 	PriceBookEntry ' +
			' 		WHERE 	Pricebook2Id = \''+tela.cat_padrao+'\' AND ' +
			' 				CurrencyIsoCode = \''+demonstracao.CurrencyIsoCode+'\' AND ' +
			' 				IsActive = true' +
			' ))'
		);
		
		// concatena filho
        if(condicoes.size()>0){
			condicao_filho = String.join(condicoes, ' AND ');
			condicao_filho = 'WHERE ' + condicao_filho + ' ';
		}
		
		// ...usuário
		if(ativo_pesquisa.termo_busca.trim() != null && ativo_pesquisa.termo_busca.trim() != ''){
            condicoes.add(
                '( ' +
					'Name LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
					'Nome_do_Ativo__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
					'Marca__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
					'Modelo__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
					'SerialNumber LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'ID_Tag__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Patrimonio__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Estoque__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Product2.StockKeepingUnit LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Product2.ProductCode LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Product2.Name LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Product2.Marca__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Product2.Modelo__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Product2.Family LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Product2.Tipo_do_Produto__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Account.Name LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Account.Raz_o_Social__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' OR '+
                    'Account.Identificacao_fiscal__c LIKE \'%'+ativo_pesquisa.termo_busca.trim()+'%\' '+
                ' )'
            );
		}
		if(ativo_pesquisa.ftr_tipo != 'TODOS'){
			condicoes.add('Product2.Tipo_do_Produto__c = \'' + ativo_pesquisa.ftr_tipo + '\'');
		}

		// concatena
        if(condicoes.size()>0){
			condicao = String.join(condicoes, ' AND ');
			condicao = 'WHERE ' + condicao + ' ';
		}

		// pesquisa
		List<Asset> ativos = Database.query(
			'SELECT		SerialNumber, Estoque__c, Patrimonio__c, ID_Tag__c, Description, Observa_es__c, Status, ' +
			'			Product2.URL_da_Imagem__c, Product2.Name, Product2.Modelo__c, Product2.Marca__c, Product2.ProductCode, ' +
			'			Product2.StockKeepingUnit, Product2Id, Account.Name, ( ' +
			'				SELECT	SerialNumber, Estoque__c, Patrimonio__c, ID_Tag__c, Description, Observa_es__c, Status, Price, ' +
			'						Product2.URL_da_Imagem__c, Product2.Name, Product2.Modelo__c, Product2.Marca__c, Product2.ProductCode, ' +
			'						Product2.StockKeepingUnit, Product2Id, Account.Name ' +
			'				FROM	ChildAssets ' +
			'				' + condicao_filho +
			'			), ( ' +
			'				SELECT	Demonstracao__r.Name, Demonstracao__r.Data_prevista__c, Demonstracao__r.Data_de_termino__c, ' +
			'						Demonstracao__r.Status__c ' +
			'				FROM	Produtos_da_demonstracao__r ' +
			'				WHERE	Demonstracao__r.Status__c NOT IN (\'Finalizado\', \'Cancelado\') ' +
			'			), ( ' +
			'				SELECT	Contrato_de_Servico__r.N_mero_da_Proposta_Contrato__c, Contrato_de_Servico__r.Data_de_In_cio_do_Contrato__c, ' +
			'						Contrato_de_Servico__r.Data_de_T_rmino_do_Contrato__c, Contrato_de_Servico__r.Status_do_Contrato__c' +
			'				FROM	Ativos_do_Contrato__r ' +
			'				WHERE	Contrato_de_Servico__r.Status_do_Contrato__c NOT IN (\'CONCLUÍDO (COM PENDENCIAS)\', \'CONCLUÍDO\', \'CANCELADO\') ' +
			'			), ( ' +
			'				SELECT	Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.N_mero_da_Proposta_Contrato__c, ' + 
			'						Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.Data_de_In_cio_do_Contrato__c, ' +
			'						Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.Data_de_T_rmino_do_Contrato__c, ' + 
			'						Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.Status_do_Contrato__c' +
			'				FROM	Ativos_do_Aditivo_Contratual__r ' +
			'				WHERE	Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.Status_do_Contrato__c NOT IN '+ 
			'						(\'CONCLUÍDO (COM PENDENCIAS)\', \'CONCLUÍDO\', \'CANCELADO\') ' +
			'			) ' +
			'FROM		Asset ' +
			 condicao +
			'ORDER BY 	Product2.Name ASC ' +
			'LIMIT		'+ ativo_pesquisa.reg_pag + ' ' +
			'OFFSET		'+ (ativo_pesquisa.pag_atual-1)*ativo_pesquisa.reg_pag + ' '
		);

		// preços
		Set<Id> produtos_id = new Set<Id>();
		for(Asset ativo : ativos){
			produtos_id.add(ativo.Product2Id);
			for(Asset ativo_filho : ativo.ChildAssets)
				produtos_id.add(ativo_filho.Product2Id);
		}
		List<PricebookEntry> entradas = [
			SELECT 		UnitPrice, Product2Id
			FROM 		PricebookEntry
			WHERE		Product2Id IN :produtos_id AND
						PriceBook2Id = :tela.cat_padrao AND
						CurrencyIsoCode = :demonstracao.CurrencyIsoCode
		];

		// popula...
		ativo_pesquisa.ativos.clear();
		tela.legenda = '';
		Set<String> legendas = new Set<String>();
		for(Asset ativo : ativos){
			Ativo ativo2 = new Ativo();
			
			// ... campos
			if(ativo.SerialNumber==null)
				ativo.SerialNumber = '-';
			if(ativo.patrimonio__c==null)
				ativo.patrimonio__c = '-';
			if(ativo.ID_Tag__c==null)
				ativo.ID_Tag__c = '-';
			if(ativo.Product2.URL_da_Imagem__c==null && !Test.isRunningTest())
				ativo.Product2.URL_da_Imagem__c = 'https://hospcom--c.na49.content.force.com/servlet/servlet.ImageServer?id=0155A000009y8x5&oid=00Di0000000JVhH&lastMod=1540211149000';
			if(ativo.Product2.Modelo__c==null)
				ativo.Product2.Modelo__c = '-';
			if(ativo.Product2.ProductCode==null)
				ativo.Product2.ProductCode = '-';
			ativo2.campos = ativo;
			
			// ... acessórios
			for(Asset ativo_filho : ativo.ChildAssets)
				ativo2.acessorios += (ativo2.acessorios!='' ? '<br/>' : '') + '&nbsp;&#8627;&nbsp;'+ativo_filho.Product2.Name + ', SN:' + ativo_filho.SerialNumber;

			// ... valor
			for(PricebookEntry entrada : entradas){
				if(ativo.Product2Id == entrada.Product2Id){
					ativo2.valor = String.ValueOf(entrada.UnitPrice);
				}
				for(Asset ativo_filho : ativo.ChildAssets){
					if(ativo_filho.Product2Id == entrada.Product2Id){
						ativo_filho.Price = entrada.UnitPrice;
					}
				}
			}

			// ... status
			List<String> statuses = new List<String>();
			List<String> lista = new List<String>();
			if(ativo.Produtos_da_demonstracao__r.size()>0){
				statuses.add('EM DEMONSTRAÇÃO');
				legendas.add('EM DEMONSTRAÇÃO');
				for(Produto_da_demonstracao__c prod_demo : ativo.Produtos_da_demonstracao__r)
					lista.add(
						'#' + prod_demo.Demonstracao__r.Name +
						', de ' + ((DateTime)prod_demo.Demonstracao__r.Data_prevista__c).formatGMT('dd/MM/yyyy') +
						' à ' +((DateTime)prod_demo.Demonstracao__r.Data_de_termino__c).formatGMT('dd/MM/yyyy') +
						' (' +prod_demo.Demonstracao__r.Status__c + ')'
					);
				ativo2.demonstracoes = String.join(lista, ' <br/> ');
				lista.clear();
			}
			if(ativo.Ativos_do_Contrato__r.size()>0 || ativo.Ativos_do_Aditivo_Contratual__r.size()>0){
				statuses.add('EM CONTRATO');
				legendas.add('EM CONTRATO');
				for(Ativos_do_Contrato__c ativ_cont : ativo.Ativos_do_Contrato__r)
					lista.add(
						'#' + ativ_cont.Contrato_de_Servico__r.N_mero_da_Proposta_Contrato__c +
						', de ' + ((DateTime)ativ_cont.Contrato_de_Servico__r.Data_de_In_cio_do_Contrato__c).formatGMT('dd/MM/yyyy') +
						' à ' +((DateTime)ativ_cont.Contrato_de_Servico__r.Data_de_T_rmino_do_Contrato__c).formatGMT('dd/MM/yyyy') +
						' (' +ativ_cont.Contrato_de_Servico__r.Status_do_Contrato__c + ')'
					);
				for(Ativo_do_Aditivo_Contratual__c ativ_add_cont : ativo.Ativos_do_Aditivo_Contratual__r)
					lista.add(
						'#' + ativ_add_cont.Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.N_mero_da_Proposta_Contrato__c + '+' +
						', de ' + ((DateTime)ativ_add_cont.Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.Data_de_In_cio_do_Contrato__c).formatGMT('dd/MM/yyyy') +
						' à ' +((DateTime)ativ_add_cont.Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.Data_de_T_rmino_do_Contrato__c).formatGMT('dd/MM/yyyy') +
						' (' +ativ_add_cont.Aditivo_Contratual_Relacionado__r.Contrato_de_Servi_o_Relacionado__r.Status_do_Contrato__c + ')'
					);
				ativo2.contratos = String.join(lista, ' <br/> ');
				lista.clear();
			}
			if(ativo.Status == 'EM MANUTENÇÃO'){
				statuses.add('EM MANUTENÇÃO');
				legendas.add('EM MANUTENÇÃO');
			}
			if(ativo.Status == 'OPERACIONAL (OBS)'){
				statuses.add('COM OBSERVAÇÕES');
				legendas.add('COM OBSERVAÇÕES');
			}
			if(statuses.size()>0)
				ativo2.status = '['+String.join(statuses, ' | ') +']';

			// adiciona
			ativo_pesquisa.ativos.add(ativo2);
		}
		tela.legenda = String.join((Iterable<String>)legendas, ', ');
		System.Debug(LoggingLevel.INFO,'tela.legenda: '+tela.legenda);

		// paginação
		ativo_pesquisa.reg_total = Database.countQuery('SELECT count() FROM Asset ' + condicao);
		ativo_pesquisa.pag_total = (Integer)((ativo_pesquisa.reg_total/(Decimal)ativo_pesquisa.reg_pag).round(System.RoundingMode.UP));

	}

	public void DemonstracaoSalvarProdutos(){

		List<List<Serial2Apex>> itens_new_pe = (List<List<Serial2Apex>>)JSON.deserialize(tela.itens_demo, List<List<Serial2Apex>>.class);

		// esta na "old" e não está na "new": remove da "old"
		Boolean remove;
		List<Produto_da_Demonstracao__c> itens_old_del = new List<Produto_da_Demonstracao__c>();
		for(Produto_da_Demonstracao__c item_old : demonstracao.Produtos_da_Demonstracao__r){
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
		List<Produto_da_Demonstracao__c> itens_old_upd = new List<Produto_da_Demonstracao__c>();
		List<Produto_da_Demonstracao__c> itens_old_ins = new List<Produto_da_Demonstracao__c>();
		for(List<Serial2Apex> itens_new_pi : itens_new_pe){
			for(Serial2Apex iten_new_p : itens_new_pi){ // loop pai
				insere = true;
				if(iten_new_p.itm_id != ''){
					for(Produto_da_Demonstracao__c item_old : demonstracao.Produtos_da_Demonstracao__r){
						if(iten_new_p.itm_id == item_old.id){
							insere = false;
							item_old.Ativo__c = iten_new_p.atv_id;
							item_old.Item__c = Decimal.valueOf(iten_new_p.itm_item);
							item_old.Item_pai__c = (iten_new_p.itm_item_pai!='' ? Decimal.valueOf(iten_new_p.itm_item_pai) : null );
							item_old.Valor__c = Decimal.valueOf(iten_new_p.itm_valor);
							item_old.Descricao__c = iten_new_p.itm_descricao;
							itens_old_upd.add(item_old);
							break;
						}
					}
				}
				if(insere){
					itens_old_ins.add(new Produto_da_Demonstracao__c(
						Demonstracao__c = demonstracao.Id,
						Ativo__c = iten_new_p.atv_id,
						Item__c = Decimal.valueOf(iten_new_p.itm_item),
						Item_pai__c = (iten_new_p.itm_item_pai!='' ? Decimal.valueOf(iten_new_p.itm_item_pai) : null ),
						Valor__c = Decimal.valueOf(iten_new_p.itm_valor),
						Descricao__c = iten_new_p.itm_descricao
					));
				}
				for(List<Children> itens_new_fi : iten_new_p.Children){
					for(Children iten_new_f : itens_new_fi){ // loop filho
						insere = true;
						if(iten_new_f.itm_id != ''){
							for(Produto_da_Demonstracao__c item_old : demonstracao.Produtos_da_Demonstracao__r){
								if(iten_new_f.itm_id == item_old.id){
									insere = false;
									item_old.Ativo__c = iten_new_f.atv_id;
									item_old.Item__c = Decimal.valueOf(iten_new_f.itm_item);
									item_old.Item_pai__c = (iten_new_f.itm_item_pai!='' ? Decimal.valueOf(iten_new_f.itm_item_pai) : null );
									item_old.Valor__c = Decimal.valueOf(iten_new_f.itm_valor);
									item_old.Descricao__c = iten_new_f.itm_descricao;
									itens_old_upd.add(item_old);
									break;
								}
							}
						}
						if(insere){
							itens_old_ins.add(new Produto_da_Demonstracao__c(
								Demonstracao__c = demonstracao.Id,
								Ativo__c = iten_new_f.atv_id,
								Item__c = Decimal.valueOf(iten_new_f.itm_item),
								Item_pai__c = (iten_new_f.itm_item_pai!='' ? Decimal.valueOf(iten_new_f.itm_item_pai) : null ),
								Valor__c = Decimal.valueOf(iten_new_f.itm_valor),
								Descricao__c = iten_new_f.itm_descricao
							));
						}
					}
				}
			}
		}
		
		if(itens_old_upd.size()>0)
			try{update itens_old_upd;}
			catch(System.DMLException e){ApexPages.addMessages(e);}

		if(itens_old_ins.size()>0)
			try{insert itens_old_ins;}
			catch(System.DMLException e){ApexPages.addMessages(e);}

		DemonstracaoBuscar();
		VerificarErros();
	}

    public void VerificarErros(){
		tela.mensagem = null;
        for(Apexpages.Message mensagem : ApexPages.getMessages())
			tela.mensagem = (tela.mensagem==null ? '' :  tela.mensagem + '\n') + mensagem.getDetail() ;
		ApexPages.getMessages().clear();
    }


	public class Tela{
		public String mensagem {get;set;}
		public String legenda {get;set;}
		public String url_base {get;set;}
		public String itens_demo {get;set;}
		public Id cat_padrao {get;set;}

		public Tela(){
			mensagem = null;
			legenda = '';
			url_base = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
			itens_demo = '';
			cat_padrao = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1][0].Id;
		}
	}

	public class AtivoPesquisa{
		public List<Ativo> ativos {get;set;}

		public String termo_busca {get;set;}
		public String ftr_tipo {get;set;}
		public List<SelectOption> ftr_tipo_vals {get;set;}

		public Integer reg_pag {get;set;}
		public Integer pag_atual {get;set;}
		public Integer pag_total {get;set;}
		public Integer reg_total {get;set;}

		public AtivoPesquisa(){
			ativos = new List<Ativo>();
			reg_pag = 20;
			termo_busca = '';
			ftr_tipo = 'TODOS';
			ftr_tipo_vals = new List<SelectOption>();
			pag_atual = 1;
			pag_total = 0;
			reg_total = 0;
		}
	}

	public class Ativo{
		public Asset campos {get;set;}
		public String acessorios {get;set;}
		public String status {get;set;}
		public String valor {get;set;}
		public String demonstracoes {get;set;}
		public String contratos {get;set;}

		public Ativo(){
			campos = new Asset();
			acessorios = '';
			status = '';
			valor = '';
			demonstracoes = '';
			contratos = '';
		}
	}

	public class Serial2Apex {

		public String itm_id;
		public String prd_id;
		public String atv_id;
		public String itm_item;
		public String itm_item_pai;
		public String itm_valor;
		public String itm_descricao;
		public List<List<Children>> children;

		public List<List<Serial2Apex>> parse(String json) {
			return (List<List<Serial2Apex>>) System.JSON.deserialize(json, List<List<Serial2Apex>>.class);
		}
	}

	public class Children {
		public String itm_id;
		public String prd_id;
		public String atv_id;
		public String itm_item;
		public String itm_item_pai;
		public String itm_valor;
		public String itm_descricao;
	}

}