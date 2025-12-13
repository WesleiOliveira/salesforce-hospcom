public class SolicitacaoDevolucaoController {
    
    // Propriedade para receber o ID da Solicitação de Devolução da página Visualforce
    public Id solicitacaoDevolucaoId { get; set; }
    
    // Lista que armazenará os itens retornados
    public List<Item_da_Solicita_o_de_devolu_o__c> listaItens { get; set; }
    
    // Construtor padrão
    public SolicitacaoDevolucaoController() {
        listaItens = new List<Item_da_Solicita_o_de_devolu_o__c>();
    }
    
    // Construtor com StandardController (para uso com Visualforce)
    public SolicitacaoDevolucaoController(ApexPages.StandardController stdController) {
        // Obtém o ID do registro atual da página
        solicitacaoDevolucaoId = stdController.getId();
        
        // Carrega os itens automaticamente se houver um ID
        if (solicitacaoDevolucaoId != null) {
            carregarItens();
        }
    }
    
    // Método para buscar os itens da solicitação de devolução
    public void carregarItens() {
        try {
            if (solicitacaoDevolucaoId != null) {
                listaItens = [
                    SELECT Id, 
                           OwnerId, 
                           IsDeleted, 
                           Name, 
                           CurrencyIsoCode, 
                           CreatedDate, 
                           CreatedById, 
                           LastModifiedDate, 
                           LastModifiedById, 
                           Imagem__c,
                           SystemModstamp, 
                           LastActivityDate, 
                           ConnectionReceivedId, 
                           ConnectionSentId, 
                           Solicita_o_de_devolu_o__c, 
                           Produto_do_pedido__c, 
                           Status__c, 
                           Valor_do_Produto_do_Pedido__c, 
                           id_pedido__c, 
                           Pedido__c, 
                           id_do_pedido__c, 
                           nomeProduto__c, 
                           codigoFabricante__c, 
                           C_digo_do_produto_do_pedido__c, 
                           Quantidade__c, 
                           numeroSerie__c
                    FROM Item_da_Solicita_o_de_devolu_o__c
                    WHERE Solicita_o_de_devolu_o__c = :solicitacaoDevolucaoId
                    ORDER BY CreatedDate DESC
                ];
            } else {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING, 
                    'ID da Solicitação de Devolução não informado.'
                ));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 
                'Erro ao carregar itens: ' + e.getMessage()
            ));
        }
    }
    
    // Método para retornar a quantidade de itens
    public Integer getTotalItens() {
        return listaItens != null ? listaItens.size() : 0;
    }
    
    // Método para verificar se existem itens
    public Boolean getTemItens() {
        return getTotalItens() > 0;
    }
}