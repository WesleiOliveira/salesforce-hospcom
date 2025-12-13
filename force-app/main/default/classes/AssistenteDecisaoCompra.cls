public class AssistenteDecisaoCompra {

	public Id 									registro_pai_id {get;set;}
	public Pedido_de_compra__c					pedido{get;set;}
	public List<Item_de_pedido_de_compra__c>	itens_compra{get;set;}
	public List<Requisicao_de_item__c		>	destinacoes{get;set;}
	public List<CFornecedor>					c_fornecedores{get;set;}
	public List<Item_de_fornecedor__c>			itens_fornecedor{get;set;}
	
	public List<String> 						etapa {get;set;}
	public List<String>							etapas{get;set;}
	
	public Boolean 								tem_erros {get;set;}
	public List<String> 						erros {get;set;}

	public AssistenteDecisaoCompra(ApexPages.StandardController controller) {
		Inicializa(controller);
		ObtemRegistros();
	}
	
	public void Inicializa(ApexPages.StandardController controller){
		registro_pai_id = ((SObject)controller.getRecord()).Id;
		pedido = new Pedido_de_compra__c();
		itens_compra = new List<item_de_pedido_de_compra__c>();
		c_fornecedores = new List<CFornecedor>();
		itens_fornecedor = new List<Item_de_fornecedor__c>();
		
		etapa = new List<String>();
		etapas = new List<String>();
		etapas.add('Decisão');
		SetaEtapa('decisão', 'Avalie e selecione os produtos mais adequados de acordo com seus fornecedores');
		
		tem_erros = false;
	}
	
	public void SetaEtapa(String nome_etapa, String cabecalho){
		etapa.clear();
		etapa.add(nome_etapa);
		etapa.add(cabecalho);
	}
		
	public void ObtemRegistros(){
		pedido = [
			SELECT	Id, Name, Descricao__c, Data_de_inicio__c, Tipo__c
			FROM	Pedido_de_compra__c
			WHERE	Id = :registro_pai_id
		][0];
		
		itens_compra = [
			SELECT	id, Produto__r.Name, Codigo_do_produto__c, Marca__c, Modelo__c, Produto__r.URL_da_Imagem__c, Pedido_de_compra__r.Tipo__c,
					Quantidade_requisitada__c, Quantidade_comprada__c, Quantidade_total__c, Descri_o_da_linha__c, Unidade_de_medida__c, Valor_da_ultima_compra__c
			FROM	Item_de_pedido_de_compra__c
			WHERE	Pedido_de_compra__c = :pedido.Id
			ORDER BY Produto__r.Name
		];
		
		List<Fornecedor__c> fornecedores = [
			SELECT 	Id, Forma_de_pagamento__c, Descricao_do_pagamento__c, Prazo_de_recebimento__c, Tipo_de_Frete__c, 
					Valor_total_cotado__c, Fornecedor__c, Fornecedor__r.Name, Fornecedor__r.Raz_o_Social__c, 
					Transportadora__c, Transportadora__r.Name, Transportadora__r.Raz_o_Social__c,
					Comprador__c, Comprador__r.Name, Comprador__r.Raz_o_Social__c
			FROM 	Fornecedor__c
			WHERE	Pedido_de_compra__c = :pedido.Id
			ORDER BY Fornecedor__r.Name
		];
		
		List<Id> fornecedores_id = new List<Id>();
		for(Fornecedor__c fornecedor : fornecedores){
			fornecedores_id.add(fornecedor.Id);
			c_fornecedores.add(new CFornecedor(fornecedor));
		}
		
		itens_fornecedor = [
			SELECT	Id, Item_de_pedido_de_compra__c, Fornecedor__c, Cotar__c, Comprar__c, Quantidade__c, Valor_unit_da_ultima_compra__c, 
					Valor_unitario__c, Valor_total__c, Prazo_de_recebimento__c, (SELECT	Id, Item_do_pedido_de_compra2__c, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber, Item_de_pedido_de_venda__r.UnitPrice, Item_de_pedido_de_venda__r.Quantity, Item_de_pedido_de_venda__r.TotalPrice
			FROM	Destinacoes__r)
			FROM	Item_de_fornecedor__c
			WHERE	Fornecedor__c IN :fornecedores_id 
			ORDER BY Produto__c
		];
	}
	
	public pageReference Efetiva(){
		try {
			update itens_fornecedor;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
			tem_erros = ((ApexPages.getMessages().size()>0)?true:false);
		}
		
		// arquiva e desarquiva requisições de itens
		if(!tem_erros){
			itens_compra.clear();
			itens_compra = [
				SELECT	id, Produto__r.Name, Codigo_do_produto__c, Marca__c, Modelo__c, Produto__r.URL_da_Imagem__c, Pedido_de_compra__r.Tipo__c,
					Quantidade_requisitada__c, Quantidade_comprada__c, Quantidade_total__c, Descri_o_da_linha__c, Unidade_de_medida__c, Valor_da_ultima_compra__c
				FROM	Item_de_pedido_de_compra__c
				WHERE	Pedido_de_compra__c = :pedido.Id
				ORDER BY Produto__r.Name
			];
			List<Id> itens_compra_arquivar_id = new List<Id>();
			List<Id> itens_compra_desarquivar_id = new List<Id>();
			for(Item_de_pedido_de_compra__c item_compra : itens_compra){
                if(item_compra.Quantidade_comprada__c == 0 || item_compra.Quantidade_comprada__c == null){
					itens_compra_arquivar_id.add(item_compra.Id);
                }
                else{
					itens_compra_desarquivar_id.add(item_compra.Id);
                }
			}
			List<Requisicao_de_item__c> requisicoes_item = [
				SELECT	Id, Arquivar__c, Item_de_pedido_de_compra__c
				FROM	Requisicao_de_item__c
				WHERE	Item_de_pedido_de_compra__c IN :itens_compra_arquivar_id OR
						Item_de_pedido_de_compra__c IN :itens_compra_desarquivar_id
			];
            
            List<Item_de_fornecedor__c> itens_pedidos = [
				SELECT	Id, Status__c
				FROM	Item_de_fornecedor__c
				WHERE	Item_de_pedido_de_compra__r.Pedido_de_compra__c = : registro_pai_id AND Comprar__c = false
			];
            for(Item_de_fornecedor__c ipc : itens_pedidos){
                ipc.Status__c = 'Cancelado';
            }
            try {
				update itens_pedidos;
			}
			catch (System.DMLException e){
				ApexPages.addMessages(e);
			}
            
			for(Requisicao_de_item__c requisicao_item : requisicoes_item){
				if(itens_compra_arquivar_id.contains(requisicao_item.Item_de_pedido_de_compra__c))
					requisicao_item.Arquivar__c = true;
				else 
					requisicao_item.Arquivar__c = false;
			}
			try {
				update requisicoes_item;
			}
			catch (System.DMLException e){
				ApexPages.addMessages(e);
			}
		}
        List <ProcessInstance> aprovacoesPend = [SELECT Id, status, TargetObjectId, TargetObject.Type, ProcessDefinitionId, CreatedById, CreatedDate, 
            (SELECT Id, ActorId, ProcessInstanceId FROM Workitems) 
            FROM ProcessInstance 
            WHERE Status = 'Pending' AND TargetObjectId =: registro_pai_id];
        
        List<ID> IDS = new List<ID>();
        
        for(ProcessInstance PI : aprovacoesPend){
            IDS.add(PI.ID);
        }
        
        List<ProcessInstanceWorkitem> workItems = [
   	 				SELECT Id, ProcessInstanceId 
    				FROM ProcessInstanceWorkitem 
            		WHERE ProcessInstanceId IN: IDS
  		];
        
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
		for(ProcessInstanceWorkitem workItem : workItems){
  		Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
  		req.setWorkitemId(workItem.Id);
  		req.setAction('Approve');
  		requests.add(req);
		}
        try{
            Approval.ProcessResult[] processResults = Approval.process(requests);
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

	public class CFornecedor {
		public Fornecedor__c	fornecedor	{get;set;}
		public Integer 			prazo		{get;set;}

		public CFornecedor(Fornecedor__c fornecedor_parm) {
			fornecedor 			= fornecedor_parm;
			
			if(fornecedor.Prazo_de_recebimento__c!=null){
				DateTime prazo_time = fornecedor.Prazo_de_recebimento__c;
				String   prazo_str  = prazo_time.format('yyyyMMdd');
				prazo   			= integer.valueof(prazo_str);				
			}else
				prazo = null;
		}
	}

	
}