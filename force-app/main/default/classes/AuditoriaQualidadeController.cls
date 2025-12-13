public with sharing class AuditoriaQualidadeController {
      @AuraEnabled(cacheable=true)
    public static SObject buscarAuditoria(Id recordId) {
        
        String objectName = recordId.getSObjectType().getDescribe().getName();

        String query = 'SELECT Id, Situacao_Auditoria__c, Data_Auditoria__c, Observacoes_Auditoria__c,  Auditado__c ' +
                       'FROM ' + objectName + ' WHERE Id = :recordId';
        
        SObject registro =  Database.query(query);

        return registro;
    }

    @AuraEnabled
    public static void salvarAuditoria(Id recordId, String situacao, String observacao, Date dataAuditoria, Boolean auditado) {
        String objectName = recordId.getSObjectType().getDescribe().getName();
        
        SObject registro = Database.query(
            'SELECT Id FROM ' + objectName + ' WHERE Id = :recordId'
        );
        
        registro.put('Situacao_Auditoria__c', situacao);
        registro.put('Data_Auditoria__c', dataAuditoria);
        registro.put('Observacoes_Auditoria__c', observacao);
        registro.put('Auditado__c', auditado);
        
        update registro;
    }
}