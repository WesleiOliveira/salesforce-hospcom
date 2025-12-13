public class ProdutoCriacao {
	
    @AuraEnabled
    public static String Inicializacao(){
		ValoresInicializacao valores = new ValoresInicializacao();
		
		valores.marcas.add(new Map<String, String>{'value' => '', 'label' => '-- Nenhuma --'});
        for(Schema.PicklistEntry campo : Product2.Marca__c.getDescribe().getPicklistValues())
            valores.marcas.add(new Map<String, String>{'value' => campo.getLabel(), 'label' => campo.getLabel()});
		
		valores.familias.add(new Map<String, String>{'value' => '', 'label' => '-- Nenhuma --'});
        for(Schema.PicklistEntry campo : Product2.Family.getDescribe().getPicklistValues())
            valores.familias.add(new Map<String, String>{'value' => campo.getLabel(), 'label' => campo.getLabel()});
		
		valores.tipos.add(new Map<String, String>{'value' => '', 'label' => '-- Nenhum --'});
        for(Schema.PicklistEntry campo : Product2.Tipo_do_Produto__c.getDescribe().getPicklistValues())
            valores.tipos.add(new Map<String, String>{'value' => campo.getLabel(), 'label' => campo.getLabel()});
		
		return JSON.serialize(valores);
	}
	public class ValoresInicializacao{
		String mostrar;
		List<Map<String, String>> marcas;
		List<Map<String, String>> familias;
		List<Map<String, String>> tipos;
		
		public ValoresInicializacao(){
			marcas = new List<Map<String, String>>();
			familias = new List<Map<String, String>>();
			tipos = new List<Map<String, String>>();
		}
	}
	
    @AuraEnabled
    public static String Criar(
		String codigo, String nome,  String marca, String modelo, 
		String familia, String tipo, String descricao, Integer valor
	){
		RetornoCriar retorno = new RetornoCriar();
		Savepoint checkpoint = Database.setSavepoint();
		
		Product2 produto;
		List<PricebookEntry> valores = new List<PricebookEntry>();
		try {
			
			// produto
			produto = new Product2(
				ProductCode = codigo,
				Name = nome,
				Marca__c = marca,
				Modelo__c = modelo,
				Family = familia,
				Tipo_do_Produto__c = tipo,
				Description	= descricao,
				IsActive = true
			);
			insert produto;
			
			// entrada padrão
			valores.clear();
			for(Pricebook2 catalogo : [SELECT Id FROM Pricebook2 WHERE IsStandard = true])
				valores.add(new PricebookEntry(
					Product2Id = produto.Id,
					Pricebook2Id = catalogo.Id,
					CurrencyIsoCode = 'BRL',
					UnitPrice = valor,
					UseStandardPrice = false,
					IsActive = true
				));
			if(valores.size()>0)
				insert valores;
			
			// outras entradas
			valores.clear();
			for(Pricebook2 catalogo : [SELECT Id FROM Pricebook2 WHERE IsActive = true AND IsStandard = false])
				valores.add(new PricebookEntry(
					Product2Id = produto.Id,
					Pricebook2Id = catalogo.Id,
					CurrencyIsoCode = 'BRL',
					UnitPrice = valor,
					UseStandardPrice = true,
					IsActive = true
				));
			if(valores.size()>0)
				insert valores;
			
		}
		catch (System.DMLException e){
			for(Integer i=0; i<e.getNumDml(); i++)
				retorno.mensagem += e.getDmlMessage(i);
			Database.rollback(checkpoint);
			return JSON.serialize(retorno);
		}
		retorno.produto = produto;
		
		return JSON.serialize(retorno);
	}
	public class RetornoCriar{
		String mensagem;
		String url_base;
		Product2 produto;
		
		public RetornoCriar(){
			mensagem = '';
			url_base = Site.getBaseUrl();			
		}
	}

}