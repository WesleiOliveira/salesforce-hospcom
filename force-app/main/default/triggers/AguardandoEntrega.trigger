trigger AguardandoEntrega on Fornecedor__c (after update) {
    
    for(Fornecedor__c pc: Trigger.new){
        if(pc.Status_do_PC__c == 'Em andamento' && (pc.Status_do_PC__c != Trigger.oldMap.get(pc.Id).Status_do_PC__c)){
            AssistenteCompras.aguardandoEntrega(pc.Id, 'CMP - AG. ENTREGA FORNECEDOR');
        }
    }
    
}