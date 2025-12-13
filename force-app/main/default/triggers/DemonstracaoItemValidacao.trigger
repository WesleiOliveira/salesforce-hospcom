trigger DemonstracaoItemValidacao on Produto_da_demonstracao__c (before insert, before update, before delete) {
    
    
    
    for(Produto_da_demonstracao__c item_demo :  Trigger.new){
        string doNothing = 'nada';
        
        
    }
}