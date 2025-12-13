public with sharing class meta {
    
    @AuraEnabled(cacheable=true)
    public static List<Goal__c> getGoals(Id vendedorId) {
        if (String.isEmpty(vendedorId)) {
            return new List<Goal__c>();
        }

        return [
            SELECT Id, Name, Vendedor__c, Linha__c, Inicio__c, Final__c, Meta__c
            FROM Goal__c
            WHERE Vendedor__c = :vendedorId
        ];
    }

    @AuraEnabled
    public static void saveGoals(List<Goal__c> goals) {
        if (goals == null || goals.isEmpty()) {
            throw new AuraHandledException('Nenhuma meta para salvar.');
        }

        try {
            upsert goals;
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao salvar metas: ' + e.getMessage());
        }
    }
}