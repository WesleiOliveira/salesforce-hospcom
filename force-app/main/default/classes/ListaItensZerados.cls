public with sharing class ListaItensZerados {
	
	public 	list<WorkOrderLineItem> lista 		{get;set;}
    public 	String					url_base 	{get;set;}
	
	
	public ListaItensZerados(){ 
		this.url_base = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
	
		lista = new list<WorkOrderLineItem>();
		lista = [
			select  	id, LineItemNumber, PricebookEntry.Product2.Name,
						WorkOrder.WorkOrderNumber, WorkOrder.Tipo_de_Servi_o__c, WorkOrder.T_cnico_Respons_vel__c
			FROM		WorkOrderLineItem
			WHERE		(
							(UnitPrice = 0) 	OR 
							(UnitPrice = null)
						)
						AND
						(
							(WorkOrder.Categoria__c != 'GARANTIA DE FÁBRICA') AND
							(WorkOrder.Categoria__c != 'GARANTIA DE SERVIÇO') AND
							(WorkOrder.Categoria__c != 'CONTRATO DE SERVIÇO') AND
							(WorkOrder.Categoria__c != 'CONTRATO DE LOCAÇÃO')
						)
						AND 
						(
							NOT
							(
								WorkOrder.Tipo_de_Servi_o__c = 'INSTALAÇÃO'		AND
								(
									WorkOrder.Marca__c LIKE 'fanem'				OR
									WorkOrder.Marca__c LIKE 'intermed'			OR
									WorkOrder.Marca__c LIKE 'sercon'				
								)
							)
						)
						AND 	(NOT PricebookEntry.Product2.Name LIKE 'SERVIÇO DE INSTALAÇÃO')
						AND		WorkOrder.CreatedDate >= 2017-05-15T00:00:00.000+0000
			ORDER BY	WorkOrder.T_cnico_Respons_vel__c
		];  
	}
}