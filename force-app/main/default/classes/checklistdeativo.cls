public class checklistdeativo {

    public Ativos_do_Contrato__c AtivodoContrato {get;set;}
    public List<Asset> Ativo {get;set;}
    
    public checklistdeativo(ApexPages.StandardController controller) {
        
        AtivodoContrato = [
            SELECT Id, Ativo_Locado__c, Contrato_de_Servico__c
            FROM Ativos_do_Contrato__c
            WHERE Id = :((SObject)controller.getRecord()).Id         
        ]; 
        
        Ativo = [
            SELECT Id, Name, (
                SELECT Nome_do_Item__c, Conforme__c, N_o_Conforme__c, Quantidade__c, N_de_Rastreio__c, Ativo_Relacionado__c
                FROM Itens_de_Checklist_do_Ativo__r            
                )
            FROM Asset
            WHERE Id = :AtivodoContrato.Ativo_Locado__c
        ];  
    }
}