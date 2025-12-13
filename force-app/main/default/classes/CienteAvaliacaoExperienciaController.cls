public with sharing class CienteAvaliacaoExperienciaController {
    
    @AuraEnabled
    public static String saveAvaliacao(id recordId){
        Avaliacao_de_Experiencia__c avaliacao = [SELECT Id, 
                                                        Ciente__c, 
                                                        Data_de_Ciencia__c,
                                                        Avaliacao_Finalizada__c,
                                                        Aprovado__c
                                                 FROM Avaliacao_de_Experiencia__c
                                                 WHERE Id =: recordId];

       avaliacao.Ciente__c = true;
       avaliacao.Data_de_Ciencia__c = Date.today();

        try {
            update avaliacao;
            return 'Success';
        } catch (exception e) {
            return e.getMessage();
        }
        
                                                    
    }


    @AuraEnabled
    public static Avaliacao_de_Experiencia__c getAvaliacao(Id recordId){

        return [SELECT  Id, 
                        Periodo_da_Avaliacao__c, 
                        NotificacaoNomeColaborador__c,
                        Ciente__c,
                        Data_de_Ciencia__c, 
                        Aprovado__c
                FROM Avaliacao_de_Experiencia__c
                WHERE Id =: recordId];
    }
}