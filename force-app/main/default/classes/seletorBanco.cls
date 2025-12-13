public class seletorBanco {
    
    @auraEnabled
    public static void atualizarOuCriarRegistro(String nome, String metaData) {
        try {
            Option__c registroExistente = [SELECT Id FROM Option__c WHERE Name = :nome LIMIT 1];
            
            if (registroExistente != null) {
                registroExistente.meta_data__c = metaData;
                update registroExistente;
            }
            
        } catch (DmlException e) {
            System.debug('Erro ao atualizar/criar registro: ' + e.getMessage());
        } catch (QueryException e) {
            System.debug('Erro na consulta: ' + e.getMessage());
        }
    }
}