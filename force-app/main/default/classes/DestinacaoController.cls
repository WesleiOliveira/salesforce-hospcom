public class DestinacaoController {
    
    public list <Item_de_pedido_de_compra__c> Records	{get;set;}
    
    public list <Item_de_fornecedor__c> item 			{get;set;}
    public Fornecedor__c PedidoDeCompra 				{get;set;}
     
    public Boolean show 								{get;set;}
    
	public string reqId 								{get;set;}
    
    public ID ide 										{get;set;} 

      
    public DestinacaoController(ApexPages.StandardController controller){
        show=false;
                 ide = ApexPages.currentPage().getParameters().get('id');
        		 PedidoDeCompra = [SELECT Id, Name FROM Fornecedor__c WHERE Id =: ide];

        item = [Select Item_de_pedido_de_compra__c, Fornecedor__r.Name from Item_de_fornecedor__c where Fornecedor__r.Id =: PedidoDeCompra.id];
        show=true;
       		 Records = [SELECT Id, Name, Quantidade_requisitada__c, Data_de_requisicao__c, Produto__r.ProductCode, Produto__r.Modelo__c,
                			   Pedido_de_compra__r.Data_de_inicio__c, Produto__c, Produto__r.Marca__c,
                			   Pedido_de_compra__r.Name, (SELECT Id, Name, Quantidade_requisitada__c, Quantidade_disponivel__c, RecordTypeId, Item_de_pedido_de_venda__c, Item_de_pedido_de_venda__r.Order.OrderNumber FROM Requisicoes_de_Itens__r ORDER by RecordTypeId, Quantidade_requisitada__c )               			    
                        FROM Item_de_pedido_de_compra__c 
                        WHERE Id IN (Select Item_de_pedido_de_compra__c from Item_de_fornecedor__c where Fornecedor__r.Id =: PedidoDeCompra.id)  ORDER BY Name
                       ];
    }
    public pageReference upd(){
         for(Item_de_pedido_de_compra__c pd : Records){
				update pd.Requisicoes_de_itens__r;     
                
            }
        	PageReference pr = new PageReference('/apex/Destinacao2?id=' + ide);
   				pr.setRedirect(true);
   				return pr;
    }
    public PageReference deleteRecord(){
        Requisicao_de_item__c req = [select id from Requisicao_de_item__c where id =: reqId limit 1];        
        if(req != null)
        {
            try{
                delete req;	
            }
            catch(DmlException ex){
                ApexPages.addMessages(ex);
            }
        }
       return null;
   }
}