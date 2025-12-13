public class ContratoChecklist{
    

    public List<Asset> Ativos {get;set;}
    public List<Gest_o_de_Documentos__c> documentos { get; set; }
    
    public ContratoChecklist(ApexPages.StandardController controlador){
        
        
		documentos = GestaoDocumentos.obterDocumentosVigentes();
        
        // Ativos do Contrato
        List<Ativos_do_Contrato__c> Ativosdocontrato = [
            SELECT  Ativo_Locado__c
            FROM    Ativos_do_Contrato__c
            WHERE   Contrato_de_Servico__c = :((SObject)controlador.getRecord()).Id
        ];
        
        List<Id> ListaAtivosdeContratoId = new List<Id>();
        
        for(Ativos_do_Contrato__c ativocontrato : Ativosdocontrato ){
        ListaAtivosdeContratoId.add(ativocontrato.Ativo_Locado__c);
        
        }
        
         Ativos = [
        SELECT Id, Name, (
            SELECT Nome_do_Item__c, Conforme__c, N_o_Conforme__c, Quantidade__c, N_de_Rastreio__c, Ativo_Relacionado__c
            FROM Itens_de_Checklist_do_Ativo__r
            
            )
        FROM Asset
        WHERE Id IN :ListaAtivosdeContratoId 
        ];
        
        
        
        
    }
  
    
}