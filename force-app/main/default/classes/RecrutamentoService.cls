public with sharing class RecrutamentoService {
    
    public static void inserirAvaliacaoExperiencia(List<Recrutamento__c> newRecrutamentoList) {
        
        List<Recrutamento__c> recrutamentoEfetivado   = new List<Recrutamento__c>();

        for (Recrutamento__c recrutamento : newRecrutamentoList) {
            if (recrutamento.Status__c == 'Aprovado'     && 
                recrutamento.Data_de_Admissao__c != null &&
                recrutamento.Contato_do_Colaborador__c != null) {
                recrutamentoEfetivado.add(recrutamento);
            }
        }
       
        List<Avaliacao_de_Experiencia__c> avaliacaoList = new List<Avaliacao_de_Experiencia__c>();

        for (Recrutamento__c recrutamento : recrutamentoEfetivado) {
            Avaliacao_de_Experiencia__c avaliacao1Periodo = new Avaliacao_de_Experiencia__c();
            avaliacao1Periodo.Periodo_da_Avaliacao__c = '1º Período (45 Dias)';
            avaliacao1Periodo.Nome_do_Colaborador__c = recrutamento.Contato_do_Colaborador__c;
            avaliacao1Periodo.Data_Fim__c = recrutamento.Data_de_Admissao__c.addDays(45);
            avaliacaoList.add(avaliacao1Periodo);

            Avaliacao_de_Experiencia__c avaliacao2Periodo = new Avaliacao_de_Experiencia__c();
            avaliacao2Periodo.Periodo_da_Avaliacao__c = '2º Período (90 Dias)';
            avaliacao2Periodo.Nome_do_Colaborador__c = recrutamento.Contato_do_Colaborador__c;
            avaliacao2Periodo.Data_Fim__c = recrutamento.Data_de_Admissao__c.addDays(90);
            avaliacaoList.add(avaliacao2Periodo);
        }

        if(avaliacaoList.size() > 0) {
            insert avaliacaoList;
        }
    }
}