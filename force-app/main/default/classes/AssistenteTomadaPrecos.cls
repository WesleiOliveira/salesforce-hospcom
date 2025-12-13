public class AssistenteTomadaPrecos {

	public Id 								registro_pai_id {get;set;}
	public Fornecedor__c					fornecedor{get;set;}
	public List<Item_de_fornecedor__c>		itens_fornecedor{get;set;}
	
	public List<String> 					etapa {get;set;}
	public List<String>						etapas{get;set;}
	
	public Boolean 							tem_erros {get;set;}
	public List<String> 					erros {get;set;}
	
	public Boolean 							tem_produtos {get;set;}
	
	public AssistenteTomadaPrecos(ApexPages.StandardController controller) {
		Inicializa(controller);
		ObtemFornecedorItens();
	}
	
	public void Inicializa(ApexPages.StandardController controller){
		registro_pai_id = ((SObject)controller.getRecord()).Id;
		fornecedor = new Fornecedor__c();
		itens_fornecedor = new List<Item_de_fornecedor__c>();
		
		etapa = new List<String>();
		etapas = new List<String>();
		etapas.add('Preço');
		SetaEtapa('preço', 'Insira valores, prazo, e demais informações da cotação');
		
		tem_erros = false;
	}
	
	public void SetaEtapa(String nome_etapa, String cabecalho){
		etapa.clear();
		etapa.add(nome_etapa);
		etapa.add(cabecalho);
	}
	
	public void ObtemFornecedorItens(){
		fornecedor = [
			SELECT 	Id, Fornecedor__r.Name, Pedido_de_compra__r.Name, Pedido_de_compra__r.Descricao__c, Forma_de_pagamento__c, Descricao_do_pagamento__c, Pedido_de_compra__c,
					Prazo_de_recebimento__c, Tipo_de_Frete__c, Transportadora__c, Name, Fornecedor__r.Raz_o_Social__c, Valor_do_frete__c
			FROM 	Fornecedor__c
			WHERE	Id = :registro_pai_id
		];
		
		itens_fornecedor = [
			SELECT	Id, Name, Produto__c, Codigo_do_produto__c, Marca__c, Modelo__c, Quantidade__c, Valor_unitario__c, Valor_unit_da_ultima_compra__c,Valor_unit_inicial_de_negociacao__c,
					Item_de_pedido_de_compra__r.Produto__r.URL_da_Imagem__c,
            		Fornecedor__r.Tipo__c
			FROM	Item_de_fornecedor__c
			WHERE	Fornecedor__c = :registro_pai_id
			ORDER BY Produto__c
		];
		
		tem_produtos = ((itens_fornecedor.size()>0)?true:false);
	}
	
	
	public pageReference Efetiva(){
		try {
			update fornecedor;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}
		
		try {
			update itens_fornecedor;
		}
		catch (System.DMLException e){
			ApexPages.addMessages(e);
		}

		PreparaErros();
		if(tem_erros)
			return null;
		else
			return new PageReference('https://hospcom.my.site.com/Sales/s/pedido-de-compra/'+ String.valueOf(fornecedor.Pedido_de_compra__c) + '/' + fornecedor.Pedido_de_compra__r.Name + '?tabset-39928=2');
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