public with sharing class AssistenteCotacaoPDF{

	public Fornecedor__c 				fornecedor {get;set;}
	public List<Item_de_fornecedor__c> 	itens_fornecedor {get;set;}
	public List<Item_de_fornecedor__c> 	itens_fornecedor_cotar {get;set;}
			
	public Boolean 						tem_erros {get;set;}
	public List<String> 				erros {get;set;}
	
	public Boolean 						tem_produtos {get;set;}

	public AssistenteCotacaoPDF(ApexPages.StandardController controller) {
		Inicializa(controller);
	}
	
	public void Inicializa(ApexPages.StandardController controller){
		tem_erros = false;
		tem_produtos = true;

		fornecedor = (Fornecedor__c)controller.getRecord();
		fornecedor = [
			SELECT	Id, Name, Observacoes_Cotacao__c, 
					Pedido_de_compra__c, Pedido_de_compra__r.Name, Pedido_de_compra__r.Descricao__c, 
					Pedido_de_compra__r.Entrega_CEP__c, Pedido_de_compra__r.Entrega_Cidade__c, 
					Pedido_de_compra__r.Entrega_Estado__c, Pedido_de_compra__r.Entrega_Pais__c, 
					Pedido_de_compra__r.Entrega_Rua__c,
					Comprador__c, Comprador__r.Name, Comprador__r.CNPJ__c, Comprador__r.Raz_o_Social__c, 
					Fornecedor__c, Fornecedor__r.Name, Fornecedor__r.CNPJ__c, Fornecedor__r.Raz_o_Social__c
			FROM	Fornecedor__c
			WHERE	Id = :fornecedor.Id
		][0];
		fornecedor.Pedido_de_compra__r.Entrega_Estado__c = ConverteEstado(fornecedor.Pedido_de_compra__r.Entrega_Estado__c);
		
		itens_fornecedor = [
			SELECT 	Item_de_pedido_de_compra__r.Produto__r.ProductCode, Item_de_pedido_de_compra__r.Produto__r.Name,
					Item_de_pedido_de_compra__r.Produto__r.Modelo__c, Item_de_pedido_de_compra__r.Produto__r.Marca__c, 
					Item_de_pedido_de_compra__r.Produto__r.URL_da_Imagem__c,
					Item_de_pedido_de_compra__r.Descri_o_da_linha__c, Item_de_pedido_de_compra__r.Quantidade_requisitada__c,
					Cotar__c, Quantidade__c
			FROM	Item_de_fornecedor__c
			WHERE	Fornecedor__c = :fornecedor.Id
		];
		
		BuscaItensPDF();
	}
	
	public void BuscaItensPDF(){
		itens_fornecedor_cotar = [
			SELECT 	Item_de_pedido_de_compra__r.Produto__r.ProductCode, Item_de_pedido_de_compra__r.Produto__r.Name,
					Item_de_pedido_de_compra__r.Produto__r.Modelo__c, Item_de_pedido_de_compra__r.Produto__r.Marca__c,
					Item_de_pedido_de_compra__r.Descri_o_da_linha__c, Item_de_pedido_de_compra__r.Quantidade_requisitada__c,
					Cotar__c, Quantidade__c
			FROM	Item_de_fornecedor__c
			WHERE	Fornecedor__c = :fornecedor.Id AND
					Cotar__c = true
		];
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
		tem_produtos = true;
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

		BuscaItensPDF();		
		PreparaErros();
		if(tem_erros)
			return null;
		else{
			tem_produtos = ((itens_fornecedor_cotar.size()>0)?true:false);
			if(!tem_produtos)
				return null;
			else{
                PageReference pagina = new PageReference('/apex/AssistenteCotacaoPDF'+'?id='+fornecedor.id);
				pagina.setAnchor('/apex/AssistenteCotacaoPDF'+'?id='+fornecedor.id);                
                pagina.setRedirect(true);
				return pagina;
			}
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