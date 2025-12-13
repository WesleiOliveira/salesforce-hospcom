public class ItensPCompraController {
    
    public id ide                                                               {get;set;}
    
    public List <Item_de_fornecedor__c> itens     {get;set;}
    
    public ItensPCompraController (ApexPages.StandardController controller){
        
              ide = ApexPages.currentPage().getParameters().get('id');
        
                  itens = [SELECT ID, Name, Produto__c, Cotar__c, Comprar__c, Codigo_do_produto__c, Modelo__c, Marca__c, Valor_unitario__c, Quantidade__c, Quantidade_recebida__c, Quantidade_recebida2__c, Valor_total__c, Status__c, Prazo_de_recebimento__c, Prazo_de_recebimento2__c, Tipo__c, Data_de_recebimento__c, Data_da_compra__c FROM Item_de_fornecedor__c WHERE Fornecedor__c =: ide];

        }
    public void salvar(){
        try{
            update itens;
        }
        catch(DmlException e){
            
        }
    }
    public void todosAg(){
        for(Item_de_fornecedor__c item : itens){
            if(item.Status__c == 'Novo' || item.Status__c == null){
            item.Status__c = 'Aguardando Entrega Fornecedor';
            update item;
                }
        }
    }
}