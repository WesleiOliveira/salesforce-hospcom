public class DemonstracaoChecklist2 {
	
	public Documento documento {get;set;}
	public Order demonstracao {get;set;}
	public List<Produto> produtos {get;set;}
	public String tipo_check {get;set;}
    public List<OrderItem> Ativos {get;set;}
    //public Asset ativo {get;set;}
    
	public DemonstracaoChecklist2(ApexPages.StandardController controlador){
		tipo_check = System.currentPageReference().getParameters().get('tipo');
		Ativos = [SELECT ID, Product2Id, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, Product2.Marca__c, Product2.URL_da_Imagem__c, Description
 FROM ORDERITEM WHERE ORDERID = :((SObject)controlador.getRecord()).Id ];
		// demonstração
		demonstracao = [
			SELECT	Name, Account.RecordType.Name, Account.Raz_o_Social__c, Account.Name, Account.CNPJ__c, Account.CPF__pc, OrderNumber,
					Faturamento_feito__r.CNPJ__c, CurrencyISOCode
			FROM	Order
			WHERE	Id = :((SObject)controlador.getRecord()).Id
		];
		
		// itens
		List<OrderItem> itens = [
			SELECT	Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, Product2.Name, Product2.Modelo__c, Id, 
					Product2.Marca__c, Description, TotalPrice, Item__c, Item_Pai__c, Descricao_da_linha__c, Product2Id
                    
			FROM	OrderItem
			WHERE	OrderId = :((SObject)controlador.getRecord()).Id
			ORDER BY Ordem__c ASC NULLS LAST
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
			
			if((atual=='equipamento'&& proximo=='acessorio') || ((anterior==null||anterior=='acessorio') && (atual=='equipamento' && (proximo=='equipamento'||proximo==null))))
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