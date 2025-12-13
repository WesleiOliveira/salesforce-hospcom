public class HospcoinTransferencia {

	
    @AuraEnabled    
    public static void transderenciaRH(Id idCarteiraDestinataria, Id idCarteiraRemetente, Decimal saldo, String programa){
        	
       Transfer_ncia_Hospcoin__c transferencia = new Transfer_ncia_Hospcoin__c();
        
        
        
        
        transferencia.Carteira_Destinataria__c = idCarteiraDestinataria;
        transferencia.Carteira_Remetente__c = idCarteiraRemetente;
        transferencia.Quantidade_de_Hospcoins__c = saldo;
        transferencia.Programa__c = programa;
        
        try{
        	insert transferencia ;
        }catch(Exception e){
            throw new AuraHandledException('ERROR: ' + e.getMessage());
        }
    }
}