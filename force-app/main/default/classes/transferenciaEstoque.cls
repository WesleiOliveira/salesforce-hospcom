public class transferenciaEstoque {
    @AuraEnabled
    public static string cria(string solicitacao, string produto, integer quantidade, string estoqueOrigem, string estoqueDestino){
        Item_da_Transfer_ncia_de_Estoque__c ite = new Item_da_Transfer_ncia_de_Estoque__c();
        ite.Solicita_o_de_Transfer_ncia_de_Estoque__c = solicitacao;
        ite.Produto__c = produto;
        ite.Quantidade__c = quantidade;
        ite.Estoque_de_origem__c = estoqueOrigem;
        ite.Estoque_de_destino__c = estoqueDestino;
        
        try{
            insert ite;
            return ite.Id;
            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}