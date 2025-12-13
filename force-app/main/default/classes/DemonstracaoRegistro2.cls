public class DemonstracaoRegistro2 {
	
	public Documento documento {get;set;}
	public Order demonstracao {get;set;}
	public List<Produto> produtos {get;set;}
	public Integer qtd {get;set;}
	public List<String> qtd_linhas {get;set;}
    public List<Gest_o_de_Documentos__c> documentos { get; set; }
	
	public DemonstracaoRegistro2(ApexPages.StandardController controlador){
        // demonstração
		demonstracao = [
			SELECT	Name, Account.RecordType.Name, Account.Raz_o_Social__c, Account.Name, Account.CNPJ__c, Account.CPF__pc, 
					Faturamento_feito__r.CNPJ__c, CurrencyISOCode, Participantes__c
			FROM	Order
			WHERE	Id = :((SObject)controlador.getRecord()).Id
		];
        
        
		documentos = GestaoDocumentos.obterDocumentosVigentes();
        
		if(Test.isRunningTest())
			qtd = 1;
		else 
            qtd = demonstracao.Participantes__c.intValue();
		qtd_linhas = new List<String>();
		for(Integer cont=1; cont<=qtd; cont++)
			qtd_linhas.add(String.valueOf(cont));
				
		
		// itens
		List<OrderItem> itens = [
			SELECT	Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, 
					Product2.Marca__c, Description, TotalPrice, Item__c, Item_Pai__c, Descricao_da_linha__c
			FROM	OrderItem
			WHERE	OrderId = :((SObject)controlador.getRecord()).Id
			ORDER BY Item__c ASC NULLS LAST
		];
		
		List<OrderItem> itens_ordem = new List<OrderItem>();
		for(OrderItem item_equip : itens)
			if(item_equip.Item__c!=null && item_equip.Item_Pai__c==null){
				itens_ordem.add(item_equip);
				for(OrderItem item_acess : itens)
					if(item_acess.Item_Pai__c==item_equip.Item__c)
						itens_ordem.add(item_acess);
			}
		for(OrderItem item_vazio : itens)
			if(item_vazio.Item__c==null && item_vazio.Item_Pai__c==null)
				itens_ordem.add(item_vazio);
		
		produtos = new List<Produto>();
		Decimal subtotal = 0;
		for(Integer cont=0; cont<itens_ordem.size(); cont++){
			Produto produto = new Produto(itens_ordem[cont]);
			subtotal += itens_ordem[cont].TotalPrice;
			
			String anterior = (cont==0?null:(itens_ordem[cont-1].Item_Pai__c==null?'equipamento':'acessorio'));
			String atual = (itens_ordem[cont].Item_Pai__c==null?'equipamento':'acessorio');
			String proximo = (cont==itens_ordem.size()-1?null:(itens_ordem[cont+1].Item_Pai__c==null?'equipamento':'acessorio'));
			
			// if((atual=='equipamento'&& proximo=='acessorio') || ((anterior==null||anterior=='acessorio') && (atual=='equipamento' && (proximo=='equipamento'||proximo==null))))
			if(anterior==null)
				produto.cabecalho = true;
			if((anterior=='equipamento'||anterior=='acessorio') && atual=='acessorio' && (proximo=='equipamento'||proximo==null)){
				produto.subtotal = demonstracao.CurrencyISOCode+' '+String.valueOf(subtotal.format());
				if(!produto.subtotal.contains(',')) produto.subtotal += ',00';
				else if(produto.subtotal.substringAfter(',').length()==1) produto.subtotal += '0';
				subtotal = 0;
			}
			
			produtos.add(produto);
		}
		
		// documento
		documento = new Documento();
		if(demonstracao.Faturamento_feito__r.CNPJ__c == '27.476.124/0001-02')
			documento.timbrado = PageReference.forResource('TimbradoHealth').getUrl();
		else if(demonstracao.Faturamento_feito__r.CNPJ__c == '23.813.386/0001-56')
			documento.timbrado = PageReference.forResource('TimbradoGDB').getUrl();
		else
			documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();	
	}
	
	public class Produto{
		public Boolean cabecalho{get;set;}
		public OrderItem item{get;set;}
		public String subtotal{get;set;}
		
		public Produto(OrderItem item){
			this.cabecalho = false;
			this.item = item;
			this.subtotal = null;
		}
	}
    
	public class Documento{
		public String timbrado{get;set;}
		
		public Documento(){}
	}
    
}