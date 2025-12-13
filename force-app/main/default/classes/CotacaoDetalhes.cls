public class CotacaoDetalhes {
	
	public Documento documento {get;set;}
	public Quote cotacao {get;set;}
	public List<Produto> produtos {get;set;}
	
	public CotacaoDetalhes(ApexPages.StandardController controlador){
		
		// cotação
		cotacao = [
			SELECT		Opportunity.Name, Opportunity.Numero_OP__c, Account.Raz_o_Social__c, Account.CNPJ__c, 
					Opportunity.Description, Opportunity.Declara_es__c,
						Opportunity.Modalidade__c, Opportunity.Local__c, Opportunity.Processo__c, Opportunity.Exclusivo_ME_EPP__c, 
					Opportunity.Verba__c, Opportunity.Numero_Verba__c, Opportunity.Data_da_Abertura__c, Opportunity.CloseDate,
					Opportunity.ATA_SRP__c, Opportunity.Data_do_Inicio_da_ATA__c, Opportunity.Data_do_Fim_da_ATA__c, 
						Opportunity.Necess_rio_Impugnar__c, Opportunity.Prazo_Impugna_o__c, Opportunity.Protocolo_Impugnacao__c,
					Opportunity.Motivo_da_Impugna_o__c, Opportunity.Itens_a_Impugnar__c, Opportunity.Necess_rio_Recurso__c,
					Opportunity.Prazo_Recurso__c, Opportunity.Protocolo_Recurso__c, Opportunity.Motivo_Recurso__c, 
					Opportunity.Itens_para_recurso__c, 
						Opportunity.Documentacao_de_credenciamento__c, Opportunity.Documentacao_de_habilitacao__c, 
					Opportunity.Documentacao_de_proposta__c, 
						Forma_de_pagamento__c, Condicao_de_pagamento__c, Prazo_de_garantia__c, Frete__c, Prazo_de_entrega__c, 
					Opportunity.Prazo_de_entrega_Edital__c, 
						Opportunity.Faturamento_Feito2__r.CNPJ__c, Opportunity.Faturamento_Feito2__r.Raz_o_Social__c, Opportunity.Owner.Name, 
					Opportunity.RecordType.Name, Opportunity.Departamento__c,
						Name, QuoteNumber, Description, Data_de_emissao__c, ExpirationDate, 
						Subtotal, Discount, GrandTotal, CurrencyISOCode, 
						ShippingName, ShippingStreet, ShippingCity, ShippingStateCode, ShippingPostalCode, ShippingCountry,
						BillingName, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountry,
						Contact.Name, Email, Phone,
						Owner.Name
			FROM	Quote
			WHERE	Id = :((SObject)controlador.getRecord()).Id
		];
		
		// produtos
		List<QuoteLineItem> itens = [
			SELECT	Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, 
					Product2.Marca__c, UnitPrice, Valor_minimo__c, Quantity, Subtotal, Discount, TotalPrice, Item__c, Item_Pai__c,
					Lote__c, Descricao_da_linha__c
			FROM	QuoteLineItem
			WHERE	QuoteId = :((SObject)controlador.getRecord()).Id
			ORDER BY Item__c ASC NULLS LAST
		];
		
		List<QuoteLineItem> itens_ordem = new List<QuoteLineItem>();
		for(QuoteLineItem item_equip : itens)
			if(item_equip.Item__c!=null && item_equip.Item_Pai__c==null){
				itens_ordem.add(item_equip);
				for(QuoteLineItem item_acess : itens)
					if(item_acess.Item_Pai__c==item_equip.Item__c)
						itens_ordem.add(item_acess);
			}
		
		produtos = new List<Produto>();
		Decimal subtotal = 0;
		for(Integer cont=0; cont<itens_ordem.size(); cont++){
			Produto produto = new Produto(itens_ordem[cont]);
			subtotal += itens_ordem[cont].TotalPrice;
			
			String anterior = (cont==0?null:(itens_ordem[cont-1].Item_Pai__c==null?'equipamento':'acessorio'));
			String atual = (itens_ordem[cont].Item_Pai__c==null?'equipamento':'acessorio');
			String proximo = (cont==itens_ordem.size()-1?null:(itens_ordem[cont+1].Item_Pai__c==null?'equipamento':'acessorio'));
			
			if((atual=='equipamento'&& proximo=='acessorio') || ((anterior==null||anterior=='acessorio') && (atual=='equipamento' && (proximo=='equipamento'||proximo==null))))
				produto.cabecalho = true;
			if((anterior=='equipamento'||anterior=='acessorio') && atual=='acessorio' && (proximo=='equipamento'||proximo==null)){
				produto.subtotal = cotacao.CurrencyISOCode+' '+String.valueOf(subtotal.format());
				if(!produto.subtotal.contains(',')) produto.subtotal += ',00';
				else if(produto.subtotal.substringAfter(',').length()==1) produto.subtotal += '0';
				subtotal = 0;
			}
			produtos.add(produto);
		}
		
		// documento
		documento = new Documento();
		if(cotacao.Opportunity.Faturamento_Feito2__r.CNPJ__c == '27.476.124/0001-02'){
			documento.timbrado = PageReference.forResource('TimbradoHealth').getUrl();
			documento.empresa_nome = 'HEALTH SOLUTION COMERCIO E SERIVÇOS - EIRELE - ME';
			documento.empresa_dados = 'inscrita no CNPJ sob N° 27.476.124/0001-02, sediada na Rua 89, N° 717, Qd. F45A, Lt. 81/83, Setor Sul, Goiânia - GO, CEP 74093-140';
		}
		else if(cotacao.Opportunity.Faturamento_Feito2__r.CNPJ__c == '23.813.386/0001-56'){
			documento.timbrado = PageReference.forResource('TimbradoGDB').getUrl();
			documento.empresa_nome = 'GDB COMÉRCIO E SERVIÇOS - EIRELI - EPP';
			documento.empresa_dados = 'inscrita no CNPJ sob N° 23.813.386/0001-56, sediada na Rua Antônio Viera, N° 76, Jardim Bela Vista, Campo Grande - MS, CEP 79003-071';
		}
		else if(cotacao.Opportunity.Faturamento_Feito2__r.CNPJ__c == '05.743.288/0001-08'){
			documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();
			documento.empresa_nome = 'HOSPCOM EQUIPAMENTOS HOSPITALARES - EIRELI';
			documento.empresa_dados = 'inscrita no CNPJ sob N° 05.743.288/0001-08, sediada na Rua 104, N° 74, Setor Sul, Goiânia - GO, CEP 74083-300';
		}else{
			documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();
			documento.empresa_nome = 'HOSPCOM EQUIPAMENTOS HOSPITALARES - EIRELI';
			documento.empresa_dados = 'inscrita no CNPJ sob N° 05.743.288/0001-08, sediada na Rua 104, N° 74, Setor Sul, Goiânia - GO, CEP 74083-300';
		}
		
		documento.titulo = 'D  e  t  a  l  h  e  s     d  a     O  p  o  r  t  u  n  i  d  a  d  e';
		
		List<OpportunityContactRole> signatario = [
			SELECT	Contact.Name, Contact.RG__c, Contact.CPF__c
			FROM	OpportunityContactRole
			WHERE	Role = 'Signatário da proposta (Hospcom)' AND
					OpportunityId = :cotacao.OpportunityId
		];
		if(signatario.size()==1){
			documento.ass_nome = signatario[0].Contact.Name;
			documento.ass_rg = signatario[0].Contact.RG__c;
			documento.ass_cpf = signatario[0].Contact.CPF__c;
		}
		
		List<OpportunityTeamMember> vendedor = [
			SELECT	User.Name
			FROM	OpportunityTeamMember
			WHERE	TeamMemberRole = 'Vendedor principal' AND
					OpportunityId = :cotacao.OpportunityId
		];
		if(vendedor.size()==1){
			documento.vendedor = vendedor[0].User.Name;
		}
		
		if(cotacao.Opportunity.Documentacao_de_credenciamento__c!=null)
			documento.docs_cred.addAll(cotacao.Opportunity.Documentacao_de_credenciamento__c.split('\\;'));
		if(cotacao.Opportunity.Documentacao_de_habilitacao__c!=null)
			documento.docs_habi.addAll(cotacao.Opportunity.Documentacao_de_habilitacao__c.split('\\;'));
		if(cotacao.Opportunity.Documentacao_de_proposta__c!=null)
			documento.docs_prop.addAll(cotacao.Opportunity.Documentacao_de_proposta__c.split('\\;'));
		
	}
	
	public class Produto{
		public Boolean cabecalho{get;set;}
		public QuoteLineItem item{get;set;}
		public String subtotal{get;set;}
		
		public Produto(QuoteLineItem item){
			this.cabecalho = false;
			this.item = item;
			this.subtotal = null;
		}
	}
    
	public class Documento{
		public String timbrado{get;set;}
		public String titulo{get;set;}
		public String empresa_nome {get;set;}
		public String empresa_dados {get;set;}
		public String ass_nome {get;set;}
		public String ass_rg {get;set;}
		public String ass_cpf {get;set;}
		public String vendedor {get;set;}
		public List<String> docs_cred {get;set;}
		public List<String> docs_habi {get;set;}
		public List<String> docs_prop {get;set;}
		
		public Documento(){
			docs_cred = new List<String>();
			docs_habi = new List<String>();
			docs_prop = new List<String>();
		}
	}
    
}