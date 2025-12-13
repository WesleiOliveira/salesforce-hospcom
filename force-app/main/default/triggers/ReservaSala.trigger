trigger ReservaSala on Reserva_de_Sala__c (before insert, after insert,  before update) { 
    
                                	
    
    List<String> errors = new List<String>();
    
    if(trigger.isInsert && trigger.isBefore){   
        
        
        
        for(Reserva_de_Sala__c rs : Trigger.new) {
            if(true){
                
                List<Reserva_de_Sala__c> salasReservadas = [
                    SELECT id, name, Sala__c, In_cio__c, Status__c, Termino__c,Frequencia__c,recorrencia__c,Reserva_recorrente__c, RecordType.name
                    FROM Reserva_de_Sala__c 
                    WHERE Status__c != 'Finalizado' AND Status__c != 'Reprovado' AND Sala__c =: rs.Sala__c AND RecordTypeid =: rs.RecordTypeId
                ];    
                
                
                
                
                
                DateTime inicio;
                DateTime termino1;  
                DateTime agora = DateTime.now();
                
                if (rs.In_cio__c <= agora) {
                    rs.addError('Não é possível reservar uma sala para uma data passada.');
                }
                
                /*
                *if (rs.Termino__c > rs.In_cio__c.addDays(1)) {
                *   errors.add('A reserva não pode ultrapassar um dia.');
                *}
                */
                
                System.debug('Array: ' + salasReservadas);
                
                
                
                for(Integer i = 0; i < salasReservadas.size(); i++) {
                    
                    DateTime inicioReservaNova = rs.In_cio__c.addHours(-3);
                    DateTime terminoReservaNova = rs.Termino__c.addHours(-3);
                    
                    for (Reserva_de_Sala__c salaExistente : salasReservadas) {
                        DateTime inicioSalaExistente = salaExistente.In_cio__c.addHours(-3);
                        DateTime terminoSalaExistente = salaExistente.Termino__c.addHours(-3);
                        
                        if ((inicioReservaNova >= inicioSalaExistente && inicioReservaNova < terminoSalaExistente) ||
                            (terminoReservaNova > inicioSalaExistente && terminoReservaNova <= terminoSalaExistente) ||
                            (inicioReservaNova <= inicioSalaExistente && terminoReservaNova >= terminoSalaExistente)) {
                                rs.addError('Já existe uma reunião neste horário na sala "' + salasReservadas[i].Sala__c + '" que vai de: ' + inicioSalaExistente + ' a ' + terminoSalaExistente + '.');
                                
                                System.debug('error' + salasReservadas[i].id + salasReservadas[i].name + salasReservadas[i].Sala__c + salasReservadas[i]);
                                
                                
                            } else {
                                
                            }
                    }
                }
            }
        } 
    }
        
        if(trigger.isInsert && trigger.isAfter){  
              System.debug('RS:');
            for(Reserva_de_Sala__c rs : Trigger.new) {
               
                 System.debug('recorrencia: ' + rs.recorrencia__c);
                if(rs.recorrencia__c > 0 ){
                    
                    try {
                        System.debug('RS: ' + rs);
                        
                        Reserva.criaRecorrencia(rs); // Chamada para criar recorrência
                    } catch (Exception e) {
                        System.debug('Erro ao criar recorrência: ' + e.getMessage());
                        rs.addError('Erro ao criar recorrência: ' + e.getMessage());
                    }
                }
            }
        }
   
}