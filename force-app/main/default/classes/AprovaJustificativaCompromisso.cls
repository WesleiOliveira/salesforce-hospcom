public class AprovaJustificativaCompromisso {
    
@AuraEnabled 
    public static void aprova(string idCompromisso){
        
        Event compromisso = [SELECT ID, checkInRealizado__c FROM Event WHERE ID =: idCompromisso];
        compromisso.checkInRealizado__c = true;
        update compromisso;
    }
}