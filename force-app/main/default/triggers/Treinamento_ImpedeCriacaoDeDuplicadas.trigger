trigger Treinamento_ImpedeCriacaoDeDuplicadas on Membro_Interno_do_Evento__c (before insert) {

    if(trigger.isBefore == true && trigger.isInsert == true){
        for(Membro_Interno_do_Evento__c membroAtual: trigger.new){
            
            List<Membro_Interno_do_Evento__c> membrosDuplicados = [
                												   	SELECT Id, name, Evento__c,Contato__c, Usuario__c 
                                                                   	FROM Membro_Interno_do_Evento__c 
                                                                   	WHERE  Empresa__c != '0016e00003FCikh' AND Contato__c != null AND Contato__c =: membroAtual.Contato__c AND  Evento__c =: membroAtual.Evento__c
                                                                  ];
                
 				System.debug('Tamanho da lista encontrada: ' + membrosDuplicados.size());   
            
                if(membrosDuplicados.size() == 0){
                    //membroAtual.addError('Membro já cadastrado');
                    System.debug('Tamanho da lista encontrada: ' + membrosDuplicados.size());
                }else{
                    
                    System.debug('Tamanho da lista encontrada: ' + membrosDuplicados.size());
                    membroAtual.addError('Membro já cadastrado');
                }
         }
    }
}