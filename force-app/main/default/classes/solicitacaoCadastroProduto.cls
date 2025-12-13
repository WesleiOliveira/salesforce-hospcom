public class solicitacaoCadastroProduto {
    
    @AuraEnabled
    public static void createSolicitacaoDeCadastro(String categoriaCompra, String nome, String descricao, String modelo, String marca, String c_d_Fabricante, String unidadeDeMedida) {
        // Create a new instance of SolicitacaodeCadastro__c
        SolicitacaodeCadastro__c solicitacao = new SolicitacaodeCadastro__c();
        
        // Set the fields with the provided value
        solicitacao.Nome__c = nome;
        solicitacao.Descricao__c = descricao;
        solicitacao.Modelo__c = modelo;
        solicitacao.Marca__c = marca;
        solicitacao.C_d_Fabricante__c = c_d_Fabricante;
        solicitacao.Unidade_de_medida__c = unidadeDeMedida;
        solicitacao.Categoria_de_compra__c = categoriaCompra;
        solicitacao.Fam_lia__c = 'OUTROS';
        solicitacao.Tipo__c = 'OUTROS';
        solicitacao.Valor_de_Venda__c = 0.0;
        solicitacao.Linha__c = 'OUTROS';
        
        try{
            insert solicitacao;
            System.debug('SolicitacaodeCadastro__c record created successfully.');
            
        }
        catch(DMLException e){
            throw new AuraHandledException(e.getMessage());
        }
    
    }
    
}