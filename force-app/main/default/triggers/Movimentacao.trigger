trigger Movimentacao on Movimentacao_de_Pessoas__c (before update) {
    
    

    if (Trigger.isUpdate && Trigger.isBefore) {
        
        
         Map<Id, Movimentacao_de_Pessoas__c> mapaMovimentacoesAntigas = Trigger.oldMap;

    for (Movimentacao_de_Pessoas__c Mov : Trigger.new) {
        Movimentacao_de_Pessoas__c antigaMov = mapaMovimentacoesAntigas.get(Mov.Id);

            if (mov.Status__c == 'Registrado' && antigaMov.Status__c != 'Registrado' && mov.RecordTypeId == '0126e000001pMJLAA2' ) {
                List<Checklist_Ativo__c> listaDeAtivos = [
                    SELECT ID, Name, Ativo__c, Movimenta_o_de_Pessoas__c, Movimenta_o_de_Pessoas__r.Name, Ativo_conforme__c 
                    FROM Checklist_ativo__c 
                    WHERE Movimenta_o_de_Pessoas__c = :mov.Id
                ];
                
                List<String> ativosInconformesNomes = new List<String>();
                
                for (Checklist_Ativo__c ativoAtual : listaDeAtivos) {
                    //System.debug('Ativo Atual: ' + ativoAtual);
                    if (!ativoAtual.Ativo_conforme__c) {
                        ativosInconformesNomes.add(ativoAtual.Name);
                    }
                }
                
                if (!ativosInconformesNomes.isEmpty()) {
                    String errorMessage = 'ATIVO(OS) INCONFORME: [newline]';
                    
                    errorMessage += String.join(ativosInconformesNomes, ', [newline]') ;
                        errorMessage = errorMessage.replace('[newline]', '\n');
                    mov.addError(errorMessage);
                }
                
                 
 String a11 = ''; 
 String a12 = ''; 
 String a13 = ''; 
 String a14 = ''; 
 String a15 = ''; 
 String a16 = ''; 
 String a17 = ''; 
 String a18 = ''; 
 String a19 = ''; 
 String a110 = '';

  
 String a21 = ''; 
 String a22 = ''; 
 String a23 = ''; 
 String a24 = ''; 
 String a25 = ''; 
 String a26 = ''; 
 String a27 = ''; 
 String a28 = ''; 
 String a29 = ''; 
 String a210 = '';

  
 String a31 = ''; 
 String a32 = ''; 
 String a33 = ''; 
 String a34 = ''; 
 String a35 = ''; 
 String a36 = ''; 
 String a37 = ''; 
 String a38 = ''; 
 String a39 = ''; 
 String a310 = '';
            }
        }
        
    }
}