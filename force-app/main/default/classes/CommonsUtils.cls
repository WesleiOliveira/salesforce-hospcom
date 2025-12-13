public with sharing class CommonsUtils {

    @AuraEnabled
    Public Static Void ActivatePurchaseOrder(String id){
        Fornecedor__c f = new Fornecedor__c();
        f.Status_do_PC__c = 'Ativo';
        f.Id = id;
        Update f;
    }
    
}