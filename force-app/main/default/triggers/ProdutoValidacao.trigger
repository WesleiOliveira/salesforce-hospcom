trigger ProdutoValidacao on Product2 (before insert) {

	// ignora erros
    if(!Util.IgnorarErros() && Trigger.isBefore && Trigger.isInsert){
		
		// seta dados iniciais
		List<String> codigos = new List<String>();
		List<Id> 	 ids 	 = new List<Id>();
		
		for(Product2 produto : Trigger.new){
			
			// código do fabricante repetido pt1
			if(produto.ProductCode != null){
				codigos.add(produto.ProductCode);
				if(Trigger.isUpdate)
					ids.add(produto.Id);				
			}
			
			// código hospcom alterado
			if(Trigger.isUpdate && Trigger.oldMap.get(produto.Id).StockKeepingUnit != null && 
			   produto.StockKeepingUnit != Trigger.oldMap.get(produto.Id).StockKeepingUnit){
				produto.StockKeepingUnit.addError('Código Hospcom não é editável', false);
			}
			
		}
		
		// código do fabricante repetido pt2
		if(codigos.size()>0){
			List<Product2> produtos_base = [
				SELECT	Id, Name, ProductCode
				FROM	Product2
				WHERE	ProductCode IN :codigos AND
						Id NOT IN :ids
			];
			if(produtos_base.size()>0){
				for(Product2 produto : Trigger.new){
					if(produto.ProductCode != null)
						for(Product2 produto_base : produtos_base){
							if(produto.ProductCode == produto_base.ProductCode)
								produto.ProductCode.addError('Código fornecedor duplicado com <a href=\'/'
								+ produto_base.id + '\'>' + produto_base.Name + '</a>', false);
						}
				}
			}
		}
		
	}
	
}