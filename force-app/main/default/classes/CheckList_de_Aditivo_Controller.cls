public class CheckList_de_Aditivo_Controller {    

    public List<Asset> Ativos {get;set;}
    
    public CheckList_de_Aditivo_Controller(ApexPages.StandardController controlador){
        
        
        // Ativos do Contrato
        List<Aditivo_Relacionado__c> AtivosAditivo = [
            SELECT  Tipo_de_Aditivo__c, Ativo_do_Contrato_Relacionado__r.Ativo_Locado__c
            FROM    Aditivo_Relacionado__c
            WHERE   Aditivo_Contratual_Relacionado__c = :((SObject)controlador.getRecord()).Id
        ];
        
        List<Id> ListaAtivosdeAditivo = new List<Id>();
        
        for(Aditivo_Relacionado__c ativoaditivo : AtivosAditivo ){
        ListaAtivosdeAditivo.add(ativoaditivo.Ativo_do_Contrato_Relacionado__r.Ativo_Locado__c);
        
        }
        
         Ativos = [
        SELECT Id, Name, (
            SELECT Nome_do_Item__c, Conforme__c, N_o_Conforme__c, Quantidade__c, N_de_Rastreio__c, Ativo_Relacionado__c
            FROM Itens_de_Checklist_do_Ativo__r
            
            )
        FROM Asset
        WHERE Id IN :ListaAtivosdeAditivo 
        ];
        
        
        
        
    }
  
    
}