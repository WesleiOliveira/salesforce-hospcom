public class Reserva {
    
    // Adicionando tratamento de erros mais específico
    public static void criaRecorrencia(Reserva_de_Sala__c rs){
    
            for(Integer i = 1; i <= rs.Frequencia__c; i++){
                Reserva_de_Sala__c novaRS = new Reserva_de_Sala__c();
                novaRS.In_cio__c = rs.In_cio__c.addDays((Integer.valueOf(rs.recorrencia__c) * i));
                novaRS.Termino__c = rs.Termino__c.addDays((Integer.valueOf(rs.recorrencia__c) * i));
                novaRS.Sala__c = rs.Sala__c;
                //novaRS.recorrente__c = true;
                novaRS.Status__c = rs.Status__c;
                novaRS.RecordTypeId = rs.RecordTypeId;
                novaRS.Reserva__c = rs.id;
                
            try {
                insert novaRS;
            } catch (Exception e) {
                
                System.debug('Erro ao criar recorrência: ' + e.getMessage());
                //throw new CustomException('Erro ao criar recorrência: ' + e.getMessage());
            }
                
            }
        
    }
    
}