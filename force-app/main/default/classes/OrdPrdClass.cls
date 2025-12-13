public with sharing class OrdPrdClass{
    
    Public String 						obj_nome			{get;set;}
    Public String				        url_base            {get;set;}
    Public String				        url_prefixo         {get;set;}
    Public String				        mensagem            {get;set;}
	
    Public Opportunity                  oportunidade        {get;set;}
    Public List<OpportunityLineItem>	itens_de_opp   	    {get;set;}
	
    Public Order                  		pedido        		{get;set;}
    Public List<OrderItem>				itens_de_ped   	    {get;set;}
	
    Public String					    itens_de_opp_str	{get;set;}
    Public String					    itens_de_ped_str	{get;set;}
    
    public OrdPrdClass(ApexPages.StandardController controller) {
        Inicializa(controller);
        ObtemObjetoPai(controller);
        if(obj_nome == 'Opportunity')
            ObtemItensOpp();
        else if(obj_nome == 'Order')
            ObtemItensPed();
	}

    public void Inicializa(ApexPages.StandardController controller){
        obj_nome 			= controller.getRecord().Id.getSObjectType().getDescribe().getName();
        url_base            = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
        url_prefixo         = Site.getPathPrefix();
        mensagem            = '';
        itens_de_opp_str    = '';
    }
    
    public void ObtemObjetoPai(ApexPages.StandardController controller){
		if(obj_nome == 'Opportunity'){
			oportunidade = [
				SELECT	Id, RecordType.Name
				FROM	Opportunity
				WHERE 	Id = :((Opportunity)controller.getRecord()).Id
			];
		}
		else if(obj_nome == 'Order'){
			pedido = [
				SELECT	Id, Tipo__c
				FROM	Order
				WHERE 	Id = :((Order)controller.getRecord()).Id
			];
		}
	}
    
    public void ObtemItensPed(){	
		List<OrderItem> itens_de_ped_temp = new List<OrderItem>();
		itens_de_ped = new List<OrderItem>();
		
        itens_de_ped_temp = [
            SELECT   Id, Product2.ProductCode, Product2.Name, Modelo__c, Marca__c, 
					 Quantity, Product2.URL_da_Imagem__c, Item__c, Item_Pai__c
            FROM     OrderItem
            WHERE    OrderId = :pedido.Id
			ORDER BY Item__c ASC
        ];
		
		for(integer cont_1=0; cont_1<itens_de_ped_temp.size(); cont_1++){
			if(itens_de_ped_temp[cont_1].Item_Pai__c == null){
				itens_de_ped.add(itens_de_ped_temp[cont_1]);
				if(itens_de_ped_temp[cont_1].Item__c != null){
					for(integer cont_2=0; cont_2<itens_de_ped_temp.size(); cont_2++){
						if(itens_de_ped_temp[cont_2].Item_Pai__c == itens_de_ped_temp[cont_1].Item__c){
							itens_de_ped.add(itens_de_ped_temp[cont_2]);
						}
					}					
				}
			}
		}
		
	}
	
	public void ObtemItensOpp(){	
		List<OpportunityLineItem> itens_de_opp_temp = new List<OpportunityLineItem>();
		itens_de_opp = new List<OpportunityLineItem>();
		
        itens_de_opp_temp = [
            SELECT   Id, ProductCode, Product2.Name, Modelo_do_Produto__c, Nome_do_Fabricante__c, 
					 Quantity, Product2.URL_da_Imagem__c, Item__c, Item_Pai__c
            FROM     OpportunityLineItem
            WHERE    OpportunityId = :oportunidade.Id
			ORDER BY Item__c ASC
        ];
		
		for(integer cont_1=0; cont_1<itens_de_opp_temp.size(); cont_1++){
			if(itens_de_opp_temp[cont_1].Item_Pai__c == null){
				itens_de_opp.add(itens_de_opp_temp[cont_1]);
				if(itens_de_opp_temp[cont_1].Item__c != null){
					for(integer cont_2=0; cont_2<itens_de_opp_temp.size(); cont_2++){
						if(itens_de_opp_temp[cont_2].Item_Pai__c == itens_de_opp_temp[cont_1].Item__c){
							itens_de_opp.add(itens_de_opp_temp[cont_2]);
						}
					}					
				}
			}
		}
		
	}
	
    public void SalvaItensPed(){
		List<String> itens_de_ped_nova 	= new List<String>();
		Integer 	 cont_item_pai 		= 1;
        Integer		 cont_item_filho    = null;
        Integer 	 ultimo_pai_item 	= null;
		Id 			 ultimo_pai_id 		= null;
		Boolean		 eh_filho			= false;
				
        itens_de_ped_nova = itens_de_ped_str.split('\\,');
		if((pedido.Tipo__c != null && pedido.Tipo__c.indexOf('Governo') == -1) || pedido.Tipo__c == null){
			cont_item_filho = 1;
			for(integer cont_1=0; cont_1<itens_de_ped_nova.size(); cont_1++)
				if(itens_de_ped_nova[cont_1].substring(0,1) != '_')
					cont_item_filho++;
		}
		else{
			cont_item_filho = 0;
			for(integer cont_1=0; cont_1<itens_de_ped.size(); cont_1++)
				if(itens_de_ped[cont_1].Item_Pai__c == null)
					if(itens_de_ped[cont_1].Item__c > cont_item_filho)
						cont_item_filho = (Integer) itens_de_ped[cont_1].Item__c;
			cont_item_filho++;
		}
		
		for(integer cont_1=0; cont_1<itens_de_ped_nova.size(); cont_1++){
			if(itens_de_ped_nova[cont_1].substring(0,1) != '_'){
				ultimo_pai_item = cont_item_pai++;
				ultimo_pai_id   = itens_de_ped_nova[cont_1];
			}
			else if(itens_de_ped_nova[cont_1].substring(0,1) == '_'){
				itens_de_ped_nova[cont_1] = itens_de_ped_nova[cont_1].substring(1);
				eh_filho = true;
			}
			for(integer cont_2=0; cont_2<itens_de_ped.size(); cont_2++){
				if(itens_de_ped_nova[cont_1] == itens_de_ped[cont_2].Id){
					if(eh_filho){
                        itens_de_ped[cont_2].Item__c = cont_item_filho++;
						if((pedido.Tipo__c != null && pedido.Tipo__c.indexOf('Governo') == -1) || pedido.Tipo__c == null){
							itens_de_ped[cont_2].Item_Pai__c = ultimo_pai_item;
							for(integer cont_3=0; cont_3<itens_de_ped.size(); cont_3++)
								if(itens_de_ped[cont_3].Id == ultimo_pai_id)
									itens_de_ped[cont_2].Produto_Principal__c = itens_de_ped[cont_3].Id;
						}else{
							for(integer cont_3=0; cont_3<itens_de_ped.size(); cont_3++){
								if(itens_de_ped[cont_3].Id == ultimo_pai_id){
									itens_de_ped[cont_2].Item_Pai__c = itens_de_ped[cont_3].Item__c;
									itens_de_ped[cont_2].Produto_Principal__c = itens_de_ped[cont_3].Id;
								}
							}
						}
						eh_filho = false;
					}else{
						if((pedido.Tipo__c != null && pedido.Tipo__c.indexOf('Governo') == -1) || pedido.Tipo__c == null)
							itens_de_ped[cont_2].Item__c = ultimo_pai_item;
						itens_de_ped[cont_2].Item_Pai__c = null;
						itens_de_ped[cont_2].Produto_Principal__c = null;
					}
				}
			}
		}
		
		update itens_de_ped;
		ObtemItensPed();
		
        mensagem = 'sucesso';
    }
	
	public void SalvaItensOpp(){
		List<String> itens_de_opp_nova 	= new List<String>();
		Integer 	 cont_item_pai 		= 1;
        Integer		 cont_item_filho    = null;
        Integer 	 ultimo_pai_item 	= null;
		Id 			 ultimo_pai_id 		= null;
		Boolean		 eh_filho			= false;
		
        itens_de_opp_nova = itens_de_opp_str.split('\\,');
		if(oportunidade.RecordType.Name.indexOf('Governo') == -1){
			cont_item_filho = 1;
			for(integer cont_1=0; cont_1<itens_de_opp_nova.size(); cont_1++)
				if(itens_de_opp_nova[cont_1].substring(0,1) != '_')
					cont_item_filho++;
		}else{
			cont_item_filho = 0;
			for(integer cont_1=0; cont_1<itens_de_opp.size(); cont_1++)
				if(itens_de_opp[cont_1].Item_Pai__c == null)
					if(itens_de_opp[cont_1].Item__c > cont_item_filho)
						cont_item_filho = (Integer) itens_de_opp[cont_1].Item__c;
			cont_item_filho++;
		}
		
		for(integer cont_1=0; cont_1<itens_de_opp_nova.size(); cont_1++){
			if(itens_de_opp_nova[cont_1].substring(0,1) != '_'){
				ultimo_pai_item = cont_item_pai++;
				ultimo_pai_id   = itens_de_opp_nova[cont_1];
			}
			else if(itens_de_opp_nova[cont_1].substring(0,1) == '_'){
				itens_de_opp_nova[cont_1] = itens_de_opp_nova[cont_1].substring(1);
				eh_filho = true;
			}
			for(integer cont_2=0; cont_2<itens_de_opp.size(); cont_2++){
				if(itens_de_opp_nova[cont_1] == itens_de_opp[cont_2].Id){
					if(eh_filho){
                        itens_de_opp[cont_2].Item__c = cont_item_filho++;
						if(oportunidade.RecordType.Name.indexOf('Governo') == -1){
							itens_de_opp[cont_2].Item_Pai__c = ultimo_pai_item;
						}else{
							for(integer cont_3=0; cont_3<itens_de_opp.size(); cont_3++)
								if(itens_de_opp[cont_3].Id == ultimo_pai_id)
									itens_de_opp[cont_2].Item_Pai__c = itens_de_opp[cont_3].Item__c;
						}
						eh_filho = false;
					}else{
						if(oportunidade.RecordType.Name.indexOf('Governo') == -1)
							itens_de_opp[cont_2].Item__c = ultimo_pai_item;
						itens_de_opp[cont_2].Item_Pai__c = null;
					}
				}
			}
		}
		
		update itens_de_opp;
		ObtemItensOpp();
		
        mensagem = 'sucesso';
    }
    
}