public class ContratoListagem {
    public List<Produto_da_Proposta_do_Contrato__c> produtosproposta {get; set;}
        public List<Ativos_do_Contrato__c> ativoscontratos {get; set;}
    public List<ContentDocumentLink> anexosContrato {get;set;}
    public List<ContentVersion> idDownl {get;set;}
    public List<Gest_o_de_Documentos__c> documentos { get; set; }
    
    
    public ContratoListagem(ApexPages.StandardController controlador){
        
        documentos = GestaoDocumentos.obterDocumentosVigentes();
        
        produtosproposta = [
            SELECT Id,Produto_Ofertado__r.Name,Produto_Ofertado__r.Modelo__c, Produto_Ofertado__r.Marca__c,Produto_Ofertado__r.ProductCode,Produto_Ofertado__r.Imagem_do_Produto__c, Name,Item_de_Proposta__c, C_digo_do_Produto__c, Contrato_de_Servi_o_Relacionado__c, Descri_o_Observa_o__c, Imagem_do_Produto__c, Marca__c, Modelo__c, Produto_Ofertado__c, Quantidade__c, Valor_Mensal__c, Valor_Mensal_da_Proposta__c
            FROM Produto_da_Proposta_do_Contrato__c
            WHERE Contrato_de_Servi_o_Relacionado__c = :((SObject)controlador.getRecord()).Id
            ORDER BY Item_de_Proposta__c ASC
        ];

        
        ativoscontratos = [
            SELECT Id,Ativo_Locado__r.Name, Ativo_Locado__r.Product2Id, Item_do_Contrato__c,Ativo_Locado__r.Imagem_do_Ativo__c, Aditivo_Contratual_Relacionado__c, Ativo_Locado__c, Contrato_de_Servico__c, Observa_o_Descri_o__c, Equipamento_no_Cliente__c, Imagem_do_Ativo__c, Marca__c, Modelo__c, N_de_S_rie__c, Quantidade__c, Valor_Total_Mensal__c, Valor_Unitario_Mensal__c  
            FROM Ativos_do_Contrato__c
            WHERE Contrato_de_Servico__c = :((SObject)controlador.getRecord()).Id
            ORDER BY Item_do_Contrato__c ASC
        ];
        
        anexosContrato = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :((SObject)controlador.getRecord()).Id AND ContentDocumentId IN (SELECT ID FROM ContentDocument WHERE Title LIKE '%ANEXAR%')
        ];
        
        Set<ID> s1 = new Set<ID>();
        
        for(ContentDocumentLink CDL : anexosContrato){
            s1.add(CDL.ContentDocumentId);
        }
        
        idDownl = [SELECT ID, ContentUrl FROM ContentVersion WHERE ContentDocumentId IN :s1 ];
             
    }
}