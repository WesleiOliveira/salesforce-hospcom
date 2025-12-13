public with sharing class LMDDetailController {
    public L_M_D__c lmDetail { get; set; }

    public List<Historico_de_Revisao__c> getOrderedHistRicos() {
        List<Historico_de_Revisao__c> histRicos = [SELECT Id, Item__c, Natureza_da_Alteracao__c, Data__c
                                                   FROM Historico_de_Revisao__c
                                                   WHERE L_M_D__c = :lmDetail.Id
                                                   ORDER BY Data__c ASC];
        return histRicos;
    }

    public LMDDetailController() {
        // Construtor padrão vazio
    }

    public LMDDetailController(ApexPages.StandardController controller) {
        lmDetail = [SELECT Id, T_tulo_do_Documento__c, C_digo_do_Documento__c FROM L_M_D__c WHERE Id = :controller.getId()];
    }
}