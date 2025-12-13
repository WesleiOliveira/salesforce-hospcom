public class DemonstracaoChecklist {
	
	public Documento documento {get;set;}
	public Demonstracao__c demonstracao {get;set;}
	public List<Produto> produtos {get;set;}
	public String tipo_check {get;set;}
    public List<Asset> Ativos {get;set;}
    public Asset ativo {get;set;}
    
	public DemonstracaoChecklist(ApexPages.StandardController controlador){
		tipo_check = System.currentPageReference().getParameters().get('tipo');
        Ativos = [SELECT ID, NAME, SerialNumber, Product2.Modelo__c, Product2.Marca__c, Description, Product2.URL_da_Imagem__c, Product2.StockKeepingUnit, (SELECT Name, Nome_do_Item__c, Quantidade__c, Conforme__c, N_o_Conforme__c From Itens_de_Checklist_do_Ativo__r) FROM ASSET WHERE ID IN (SELECT Ativo__c FROM Produto_da_demonstracao__c WHERE Demonstracao__c =:((SObject)controlador.getRecord()).Id) ORDER BY Name DESC ];
		
		// demonstração
		demonstracao = [
			SELECT	Name, Conta__r.RecordType.Name, Conta__r.Raz_o_Social__c, Conta__r.Name, Conta__r.CNPJ__c, Conta__r.CPF__pc, 
					Fornecedor__r.CNPJ__c, CurrencyISOCode
			FROM	Demonstracao__c
			WHERE	Id = :((SObject)controlador.getRecord()).Id
		];
		
		// itens
		List<Produto_da_demonstracao__c> itens = [
			SELECT	Ativo__r.Product2.URL_da_Imagem__c, Ativo__r.Product2.StockKeepingUnit, Ativo__r.Product2.Name, Ativo__r.Product2.Modelo__c, Ativo__r.Id, 
					Ativo__r.Product2.Marca__c, Ativo__r.SerialNumber, Valor__c, Item__c, Item_Pai__c, Descricao__c        
                    
			FROM	Produto_da_Demonstracao__c
			WHERE	Demonstracao__c = :((SObject)controlador.getRecord()).Id
			ORDER BY Item__c ASC NULLS LAST
		];
        
		List<Produto_da_demonstracao__c> itens_ordem = new List<Produto_da_Demonstracao__c>();
		for(Produto_da_Demonstracao__c item_equip : itens)
			if(item_equip.Item__c!=null && item_equip.Item_Pai__c==null){
				itens_ordem.add(item_equip);
                
				for(Produto_da_Demonstracao__c item_acess : itens)
					if(item_acess.Item_Pai__c==item_equip.Item__c)
						itens_ordem.add(item_acess);
			}

		for(Produto_da_Demonstracao__c item_vazio : itens)
			if(item_vazio.Item__c==null && item_vazio.Item_Pai__c==null)
				itens_ordem.add(item_vazio);
		
		produtos = new List<Produto>();
		Decimal subtotal = 0;
		for(Integer cont=0; cont<itens_ordem.size(); cont++){
			Produto produto = new Produto(itens_ordem[cont]);
			subtotal += itens_ordem[cont].Valor__c;
			
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
		if(demonstracao.Fornecedor__r.CNPJ__c == '27.476.124/0001-02')
			documento.timbrado = PageReference.forResource('TimbradoHealth').getUrl();
		else if(demonstracao.Fornecedor__r.CNPJ__c == '23.813.386/0001-56')
			documento.timbrado = PageReference.forResource('TimbradoGDB').getUrl();
		else
			documento.timbrado = PageReference.forResource('TimbradoHospcom').getUrl();	
	}
	
	public class Produto{
		public Boolean cabecalho{get;set;}
		public Produto_da_demonstracao__c item{get;set;}
		public String subtotal{get;set;}
		
		public Produto(Produto_da_demonstracao__c item){
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