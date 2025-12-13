public with sharing class Listagem_InstrucaoDeServico {
    
    
    public List<Item_da_Instrucao_de_servico__c> topico_instrucao {get; set;}
    
    public Listagem_InstrucaoDeServico(ApexPages.StandardController controller){
        Id objeto_pai = ((SObject)controller.getRecord()).Id;
        
        if(objeto_pai.getSObjectType().getDescribe().getName() == 'Instrucao_de_Servico__c')
            Listagem_InstrucaoDeServico((Instrucao_de_Servico__c)controller.getRecord());
    }
        
    public void Listagem_InstrucaoDeServico(Instrucao_de_Servico__c instucao_Servico){
        
        topico_instrucao = [
            SELECT   id, Name, Conteudo__c, Numero_do_Topico__c
            FROM Item_da_Instrucao_de_servico__c
            WHERE Instrucao_de_Servico__c =:   instucao_Servico.id
            ORDER BY Numero_do_Topico__c ASC  
        ];
    }
}