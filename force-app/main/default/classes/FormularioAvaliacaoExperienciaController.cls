public with sharing class FormularioAvaliacaoExperienciaController {
    
    @AuraEnabled
    public static String saveRespostas(Id recordId,String respostasJSON, String justificativasJSON, String aprovado, String observacoes){


        Map<String, Object> respostas = (Map<String, Object> ) JSON.deserializeUntyped(respostasJSON);

        Map<String, Object> justificativas = (Map<String, Object>) JSON.deserializeUntyped(justificativasJSON);

        System.debug('recordId: ' + recordId);
        System.debug('respostas: ' + respostas);
        System.debug('justificativasJSON: ' + justificativasJSON);


        Avaliacao_de_Experiencia__c avaliacao = [SELECT Id, 
                                                        Pergunta_1__c, 
                                                        Pergunta_2__c, 
                                                        Pergunta_3__c, 
                                                        Pergunta_4__c, 
                                                        Pergunta_5__c, 
                                                        Pergunta_6__c, 
                                                        Pergunta_7__c, 
                                                        Pergunta_8__c,
                                                        Justificativa_1__c,
                                                        Justificativa_2__c,
                                                        Justificativa_3__c,
                                                        Justificativa_4__c,
                                                        Justificativa_5__c,
                                                        Justificativa_6__c,
                                                        Justificativa_7__c,
                                                        Justificativa_8__c,
                                                        Observacoes__c,
                                                        Avaliacao_Finalizada__c
                                                 FROM Avaliacao_de_Experiencia__c
                                                 WHERE Id =: recordId];

        avaliacao.Pergunta_1__c = (String)respostas.get('Pergunta_1__c');
        avaliacao.Pergunta_2__c = (String)respostas.get('Pergunta_2__c');
        avaliacao.Pergunta_3__c = (String)respostas.get('Pergunta_3__c');
        avaliacao.Pergunta_4__c = (String)respostas.get('Pergunta_4__c');
        avaliacao.Pergunta_5__c = (String)respostas.get('Pergunta_5__c');
        avaliacao.Pergunta_6__c = (String)respostas.get('Pergunta_6__c');
        avaliacao.Pergunta_7__c = (String)respostas.get('Pergunta_7__c');
        avaliacao.Pergunta_8__c = (String)respostas.get('Pergunta_8__c');
        avaliacao.Justificativa_1__c = (String)justificativas.get('Justificativa_1__c');
        avaliacao.Justificativa_2__c = (String)justificativas.get('Justificativa_2__c');
        avaliacao.Justificativa_3__c = (String)justificativas.get('Justificativa_3__c');
        avaliacao.Justificativa_4__c = (String)justificativas.get('Justificativa_4__c');
        avaliacao.Justificativa_5__c = (String)justificativas.get('Justificativa_5__c');
        avaliacao.Justificativa_6__c = (String)justificativas.get('Justificativa_6__c');
        avaliacao.Justificativa_7__c = (String)justificativas.get('Justificativa_7__c');
        avaliacao.Justificativa_8__c = (String)justificativas.get('Justificativa_8__c');
        avaliacao.Observacoes__c = observacoes;
        avaliacao.Avaliacao_Finalizada__c = true;
        avaliacao.Aprovado__c = aprovado;

        System.debug(avaliacao);

        update avaliacao;

        return 'success';
    }

    @AuraEnabled
    public static Avaliacao_de_Experiencia__c getRespostas(Id recordId){

        return [SELECT  Id, 
                        Pergunta_1__c, 
                        Pergunta_2__c, 
                        Pergunta_3__c, 
                        Pergunta_4__c, 
                        Pergunta_5__c, 
                        Pergunta_6__c, 
                        Pergunta_7__c, 
                        Pergunta_8__c ,
                        Justificativa_1__c, 
                        Justificativa_2__c, 
                        Justificativa_3__c,
                        Justificativa_4__c,
                        Justificativa_5__c,
                        Justificativa_6__c,
                        Justificativa_7__c,
                        Justificativa_8__c,
                        Avaliacao_Finalizada__c,
                        Periodo_da_Avaliacao__c,
                        Observacoes__c,
                        Aprovado__c
                FROM Avaliacao_de_Experiencia__c
                WHERE Id =: recordId];
    }
}