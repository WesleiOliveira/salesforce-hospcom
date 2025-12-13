public class OportunidadeBotoes {
	
    @AuraEnabled
    public static String PrepararCloneOportunidade(String opp_id){
		ValoresCloneOportunidade valores = new ValoresCloneOportunidade();
		Opportunity oportunidade = [
			SELECT	Name, OwnerId, Owner.Name, Amount, CurrencyIsoCode, (
						SELECT	Id
						FROM	OpportunityLineItems
					)
			FROM	Opportunity
			WHERE 	Id = :opp_id
		];
		
		valores.nome = 'Clone de ' + oportunidade.Name;
		
		valores.proprietarios.add(new Map<String, String>{'value' => oportunidade.OwnerId, 'label' => 'Manter proprietario ('+oportunidade.Owner.Name+')'});
		valores.proprietarios.add(new Map<String, String>{'value' => UserInfo.getUserId(), 'label' => 'Criar para mim ('+UserInfo.getName()+')'});
		valores.proprietario = UserInfo.getUserId();
		
		valores.produtos.add(new Map<String, String>{'value' => 'com', 'label' => 'Manter os produtos ('+oportunidade.OpportunityLineItems.size()+ ' / '+oportunidade.CurrencyIsoCode+' '+oportunidade.Amount+')'});
		valores.produtos.add(new Map<String, String>{'value' => 'sem', 'label' => 'Sem produtos'});
		valores.produto = 'com';
		
		return JSON.serialize(valores);
	}public class ValoresCloneOportunidade{
		String nome;
		List<Map<String, String>> proprietarios;
		List<Map<String, String>> produtos;
		String proprietario;
		String produto;
		
		public ValoresCloneOportunidade(){
			proprietarios = new List<Map<String, String>>();
			produtos = new List<Map<String, String>>();
		}
	}
	
	@AuraEnabled
	public static String ClonarOportunidade(String opp_id, String opp_nome, String opp_prop, String opp_prods){
		String 	campos_opp   = Util.ObterCamposObjeto('Opportunity'), 
				campos_prods = Util.ObterCamposObjeto('OpportunityLineItem');
		RetornoClonarOportunidade retorno = new RetornoClonarOportunidade();
				
		Opportunity oportunidade = Database.query(
			'SELECT	' + campos_opp + ', ( ' +
			'			SELECT	' + campos_prods +
			'		 	FROM	OpportunityLineItems ' +
			'		) ' +
			'FROM	Opportunity ' +
			'WHERE	Id = \'' + opp_id + '\' ' 
		);
		
		Opportunity oportunidade_clone = oportunidade.Clone(false, true, false, false);
		oportunidade_clone.SyncedQuoteId = null;
		oportunidade_clone.Name = opp_nome;
		oportunidade_clone.OwnerId = opp_prop;
		
		Util.AcaoInterna(true);
		Savepoint checkpoint = Database.setSavepoint();
		try {
			insert oportunidade_clone;
		}
		catch (System.DMLException e){
			for(Integer i=0; i<e.getNumDml(); i++)
				retorno.mensagem += e.getDmlMessage(i);
			Database.rollback(checkpoint);
			return JSON.serialize(retorno);
		}
		retorno.oportunidade = [SELECT Id, Numero_OP__c FROM Opportunity WHERE Id = :oportunidade_clone.Id];
		
		if(opp_prods == 'com'){
			List<OpportunityLineItem> itens_clone = oportunidade.OpportunityLineItems.deepClone(false, false, false);
			for(OpportunityLineItem item_clone : itens_clone){
				item_clone.OpportunityId = oportunidade_clone.Id;
				item_clone.TotalPrice = null;
			}
			try {
				insert itens_clone;
			}
			catch (System.DMLException e){
				for(Integer i=0; i<e.getNumDml(); i++)
					retorno.mensagem += e.getDmlMessage(i);
				Database.rollback(checkpoint);
				return JSON.serialize(retorno);
			}
		}
		Util.AcaoInterna(false);
		
		return JSON.serialize(retorno);
	}public class RetornoClonarOportunidade{
		String mensagem;
		String url_base;
		Opportunity oportunidade;
		
		public RetornoClonarOportunidade(){
			mensagem = '';
			url_base = Site.getBaseUrl();			
		}
	}
    
	
    @AuraEnabled
    public static String PrepararAlteraCatalogo(String opp_id){
		ValoresAlteraCatalogo valores = new ValoresAlteraCatalogo();
		
		Opportunity oportunidade = [
			SELECT	Pricebook2Id, Pricebook2.Name, SyncedQuoteId, (
						SELECT	Id, Product2Id, Product2.StockKeepingUnit
						FROM	OpportunityLineItems
					), (
						SELECT	Id
						FROM 	Quotes
					)
			FROM	Opportunity
			WHERE 	Id = :opp_id
		];
		valores.catalogo_atual = oportunidade.Pricebook2.Name;
		
		Set<Id> prods_opp_id = new Set<Id>();
		for(OpportunityLineItem item_opp : oportunidade.OpportunityLineItems)
			prods_opp_id.add(item_opp.Product2Id);
		
		List<Pricebook2> catalogos = [
			SELECT	Id, Name, (
						SELECT	Id, Product2Id
						FROM	PricebookEntries
						WHERE	IsActive = true AND Product2Id IN :prods_opp_id
					)
			FROM	Pricebook2
			WHERE	IsActive = true AND Id != :oportunidade.Pricebook2Id
		];
		
		for(Pricebook2 catalogo : catalogos){
			valores.catalogos.add(new Map<String, String>{'value' => catalogo.Id, 'label' => catalogo.Name});
			Set<Id> prods_cat_id = new Set<Id>();
			for(PricebookEntry entrada : catalogo.PricebookEntries)
				prods_cat_id.add(entrada.Product2Id);
			Set<String> prods_opp_sem_cat = new Set<String>();
			for(OpportunityLineItem item_opp : oportunidade.OpportunityLineItems){
				if(!prods_cat_id.contains(item_opp.Product2Id))
					prods_opp_sem_cat.add(item_opp.Product2.StockKeepingUnit);
			}
			valores.pendencias.add(new Map<String, String>{'value' => catalogo.Id, 'label' => String.join((Iterable<String>)prods_opp_sem_cat, ', ')});
		}
		
		if(catalogos.size()>0)
			valores.catalogo = catalogos[0].Id;
		
		if(oportunidade.Quotes.size()>0 && oportunidade.SyncedQuoteId==null)
			valores.catalogo_alerta = 'Antes de alterar, sincronize uma das cotações existentes com a oportunidade. OBS: Ao sincronizar, os itens da cotação substituirão os da oportunidade.';
		
		return JSON.serialize(valores);
	}public class ValoresAlteraCatalogo{
		List<Map<String, String>> catalogos;
		List<Map<String, String>> pendencias;
		String catalogo;
		String catalogo_atual;
		String catalogo_alerta;
		
		public ValoresAlteraCatalogo(){
			catalogos = new List<Map<String, String>>();
			pendencias = new List<Map<String, String>>();
			catalogo_alerta='';
		}
	}
	
	@AuraEnabled
	public static String AlterarCatalogo(String opp_id, String cat_id){
		String campos_prods = Util.ObterCamposObjeto('OpportunityLineItem');
		RetornoAlterarCatalogo retorno = new RetornoAlterarCatalogo();
		
		Opportunity oportunidade = Database.query(
			'SELECT	Id, Pricebook2Id, ( ' +
			'			SELECT	' + campos_prods +
			'		 	FROM	OpportunityLineItems ' +
			'		) ' +
			'FROM	Opportunity ' +
			'WHERE	Id = \'' + opp_id + '\' ' 
		);
		
		Util.AcaoInterna(true);
		Savepoint checkpoint = Database.setSavepoint();
		List<OpportunityLineItem> itens_novos = oportunidade.OpportunityLineItems.deepClone(false, false, false);
		try {
			delete oportunidade.OpportunityLineItems;
		}
		catch (System.DMLException e){
			for(Integer i=0; i<e.getNumDml(); i++)
				retorno.mensagem += e.getDmlMessage(i);
			Database.rollback(checkpoint);
			return JSON.serialize(retorno);
		}
		
		oportunidade.Pricebook2Id = cat_id;
		try {
			System.Debug(LoggingLevel.INFO,'oportunidade: '+ oportunidade);
			update oportunidade;
		}
		catch (System.DMLException e){
			for(Integer i=0; i<e.getNumDml(); i++)
				retorno.mensagem += e.getDmlMessage(i);
			Database.rollback(checkpoint);
			return JSON.serialize(retorno);
		}
		
		Set<Id> prods_opp_id = new Set<Id>();
		for(OpportunityLineItem item_opp : itens_novos)
			prods_opp_id.add(item_opp.Product2Id);
		List<PricebookEntry> entradas = [
			SELECT	Id, Product2Id
			FROM	PricebookEntry
			WHERE	Pricebook2Id = :cat_id AND Product2Id IN :prods_opp_id
		];
		for(Integer i=itens_novos.size()-1; i>=0; i--){
			itens_novos[i].PricebookEntryId = null;
			itens_novos[i].TotalPrice = null;
			for(PricebookEntry entrada : entradas){
				if(itens_novos[i].Product2Id == entrada.Product2Id)
					itens_novos[i].PricebookEntryId = entrada.Id;
			}
			if(itens_novos[i].PricebookEntryId == null)
				itens_novos.remove(i);
		}
		try {
			System.Debug(LoggingLevel.INFO,'itens_novos: '+itens_novos);
			insert itens_novos;
		}
		catch (System.DMLException e){
			for(Integer i=0; i<e.getNumDml(); i++)
				retorno.mensagem += e.getDmlMessage(i);
			Database.rollback(checkpoint);
			return JSON.serialize(retorno);
		}
		retorno.catalogo_novo = [SELECT Name FROM Pricebook2 WHERE Id = :cat_id].Name;
		Util.AcaoInterna(false);
		
		return JSON.serialize(retorno);
	}public class RetornoAlterarCatalogo{
		String mensagem;
		String catalogo_novo;
		
		public RetornoAlterarCatalogo(){
			mensagem = '';
		}
	}	

	
    @AuraEnabled
    public static String PrepararAlteraProprietario(String opp_id){
		ValoresAlteraProprietario valores = new ValoresAlteraProprietario();
		Opportunity oportunidade = [
			SELECT	Name, OwnerId, Owner.Name
			FROM	Opportunity
			WHERE 	Id = :opp_id
		];
		valores.proprietario_atual =  oportunidade.Owner.Name;

		List<User> usuarios = [
			SELECT	Id, Name, UserType
			FROM	User
			WHERE	IsActive=true AND 
					Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen=false) AND
					Id != :oportunidade.OwnerId
			ORDER BY Name ASC
		];
		
		for(User usuario : usuarios)
			valores.proprietarios2.add(new Map<String, String>{'value' => usuario.Id, 'label' => usuario.Name+' ('+usuario.UserType+')'});
		
		if(usuarios.size()>0)
			valores.proprietario2 = usuarios[0].Id;
		
		return JSON.serialize(valores);
	}public class ValoresAlteraProprietario{
		List<Map<String, String>> proprietarios2;
		String proprietario2;
		String proprietario_atual;
		
		public ValoresAlteraProprietario(){
			proprietarios2 = new List<Map<String, String>>();
		}
	}
	
	@AuraEnabled
	public static String AlterarProprietario(String opp_id, String prop_id){
		RetornoAlterarProprietario retorno = new RetornoAlterarProprietario();
		
		Opportunity oportunidade = Database.query(
			'SELECT	Id, OwnerId ' +
			'FROM	Opportunity ' +
			'WHERE	Id = \'' + opp_id + '\' ' 
		);
		
		Savepoint checkpoint = Database.setSavepoint();
		oportunidade.OwnerId = prop_id;
		try {
			update oportunidade;
		}
		catch (System.DMLException e){
			for(Integer i=0; i<e.getNumDml(); i++)
				retorno.mensagem += e.getDmlMessage(i);
			Database.rollback(checkpoint);
			return JSON.serialize(retorno);
		}
		
		retorno.proprietario_novo = [SELECT Name FROM User WHERE Id = :prop_id].Name;
		
		return JSON.serialize(retorno);
	}public class RetornoAlterarProprietario{
		String mensagem;
		String proprietario_novo;
		
		public RetornoAlterarProprietario(){
			mensagem = '';
		}
	}


}