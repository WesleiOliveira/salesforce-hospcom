public with sharing class AssistentePedidoCompraPDF{

	public Fornecedor__c 				fornecedor {get;set;}
	public List<Item_de_fornecedor__c> 	itens_fornecedor {get;set;}
	public String						nome{get;set;}
	public Date							hoje{get;set;}
	public DateTime						agora{get;set;}
		
	public Boolean 						tem_erros {get;set;}
	public List<String> 				erros {get;set;}

	public Boolean 						tem_produtos {get;set;}
	public Boolean 						esta_aprovado {get;set;}
	
	public AssistentePedidoCompraPDF(ApexPages.StandardController controller) {
		Inicializa(controller);
	}
	
	public void Inicializa(ApexPages.StandardController controller){
		tem_erros = false;
		tem_produtos = true;
		esta_aprovado = false;
		
		fornecedor = (Fornecedor__c)controller.getRecord();
		fornecedor = [
			SELECT	Pedido_de_compra__c, Pedido_de_compra__r.Name, Pedido_de_compra__r.Descricao__c, Pedido_de_compra__r.Data_de_inicio__c,
					Pedido_de_compra__r.Entrega_Pais__c, Pedido_de_compra__r.Entrega_Rua__c, Pedido_de_compra__r.Entrega_Cidade__c, 
					Pedido_de_compra__r.Entrega_Estado__c, Pedido_de_compra__r.Entrega_CEP__c, Pedido_de_compra__r.Status__c,
					
					Id, Name, Itens_total__c, Prazo_de_recebimento__c, Tipo_de_Frete__c, Valor_total_comprado__c, 
					Forma_de_pagamento__c, Descricao_do_pagamento__c, Observacoes_compra__c,
					
					Comprador__r.Id, Comprador__r.Name, Comprador__r.CNPJ__c, Comprador__r.Raz_o_Social__c,
					
					Fornecedor__r.Id, Fornecedor__r.Name, Fornecedor__r.CNPJ__c, Fornecedor__r.Raz_o_Social__c, 
					Fornecedor__r.BillingCountry, Fornecedor__r.BillingStreet, Fornecedor__r.BillingCity, 
					Fornecedor__r.BillingState, Fornecedor__r.BillingPostalCode,

					Transportadora__r.Id, Transportadora__r.Name, Transportadora__r.CNPJ__c, Transportadora__r.Raz_o_Social__c
			FROM	Fornecedor__c
			WHERE	Id = :fornecedor.Id
		][0];
		fornecedor.Pedido_de_compra__r.Entrega_Estado__c = ConverteEstado(fornecedor.Pedido_de_compra__r.Entrega_Estado__c);
		fornecedor.Fornecedor__r.BillingState = ConverteEstado(fornecedor.Fornecedor__r.BillingState);
		
		itens_fornecedor = [
			SELECT 	Codigo_do_produto__c, Produto__c, Modelo__c, Marca__c, Item_de_pedido_de_compra__r.Descri_o_da_linha__c,
					Quantidade__c, Valor_unitario__c, Valor_total__c, Item_de_pedido_de_compra__r.Produto__r.URL_da_Imagem__c, Unidade_de_medida__c
			FROM	Item_de_fornecedor__c
			WHERE	Fornecedor__c = :fornecedor.Id AND
					Comprar__c = true
		];
		
		tem_produtos  = ((itens_fornecedor.size()>0)?true:false);
		esta_aprovado = ((fornecedor.Pedido_de_compra__r.Status__c !='1 - Rascunho' && fornecedor.Pedido_de_compra__r.Status__c !='2 - Em Andamento' && 
		                  fornecedor.Pedido_de_compra__r.Status__c !='3 - Em Aprovação' && fornecedor.Pedido_de_compra__r.Status__c !='3 - Em aprovação financeira' && fornecedor.Pedido_de_compra__r.Status__c !='6 - Reprovado' && 
						  fornecedor.Pedido_de_compra__r.Status__c !='7 - Cancelado')?true:false);
		
		nome = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
		hoje = System.Today();
		agora = System.now();
	}
	
	public String ConverteEstado(String estado){
		
		if     (estado == 'Acre')                estado = 'AC';
		else if(estado == 'Alagoas')             estado = 'AL';
		else if(estado == 'Amapá')               estado = 'AP';
		else if(estado == 'Amazonas')            estado = 'AM';
		else if(estado == 'Bahia')               estado = 'BA';
		else if(estado == 'Ceará')               estado = 'CE';
		else if(estado == 'Distrito Federal')    estado = 'DF';
		else if(estado == 'Espírito Santo')      estado = 'ES';
		else if(estado == 'Goiás')               estado = 'GO';
		else if(estado == 'Maranhão')            estado = 'MA';
		else if(estado == 'Mato Grosso')         estado = 'MT';
		else if(estado == 'Mato Grosso do Sul')  estado = 'MS';
		else if(estado == 'Minas Gerais')        estado = 'MG';
		else if(estado == 'Pará')                estado = 'PA';
		else if(estado == 'Paraíba')             estado = 'PB';
		else if(estado == 'Paraná')              estado = 'PR';
		else if(estado == 'Pernambuco')          estado = 'PE';
		else if(estado == 'Piauí')               estado = 'PI';
		else if(estado == 'Rio de Janeiro')      estado = 'RJ';
		else if(estado == 'Rio Grande do Norte') estado = 'RN';
		else if(estado == 'Rio Grande do Sul')   estado = 'RS';
		else if(estado == 'Rondônia')            estado = 'RO';
		else if(estado == 'Roraima')             estado = 'RR';
		else if(estado == 'Santa Catarina')      estado = 'SC';
		else if(estado == 'São Paulo')           estado = 'SP';
		else if(estado == 'Sergipe')             estado = 'SE';
		else if(estado == 'Tocantins')           estado = 'TO';
		
		return estado;
	}

	public pageReference GeraPDF(){
		if(tem_produtos && fornecedor.Pedido_de_compra__r.Status__c  == '5 - Concluído'){
			try {
				update fornecedor;
			}
			catch (System.DMLException e){
				ApexPages.addMessages(e);
			}
			
			PreparaErros();
			if(tem_erros){
				return null;
			}
			else{
                PageReference pagina = new PageReference('/apex/AssistentePedidoCompraPDF'+'?id='+fornecedor.id);
				pagina.setAnchor('/apex/AssistentePedidoCompraPDF'+'?id='+fornecedor.id);                
                pagina.setRedirect(true);
				return pagina;
			}
		}
		else{
			return null;
		}	
	}	
	
	public void PreparaErros(){
		tem_erros = ((ApexPages.getMessages().size()>0)?true:false);
        if(tem_erros){
            erros = new List<String>();
            for(Apexpages.Message mensagem: ApexPages.getMessages())
                erros.add(mensagem.getDetail());
        }
	}
	
}