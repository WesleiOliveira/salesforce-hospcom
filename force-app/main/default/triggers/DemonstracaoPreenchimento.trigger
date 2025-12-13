trigger DemonstracaoPreenchimento on Demonstracao__c (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.IsInsert){
        
        for(Demonstracao__c demonstracao : Trigger.new){
            demonstracao.Status__c = 'Rascunho';
            
            demonstracao.Rua__c = demonstracao.Conta__r.BillingStreet;
            demonstracao.Cidade__c = demonstracao.Conta__r.BillingCity;
            demonstracao.Estado__c = demonstracao.Conta__r.BillingState;
            demonstracao.CEP__c = demonstracao.Conta__r.BillingPostalCode;
        }
    }
}