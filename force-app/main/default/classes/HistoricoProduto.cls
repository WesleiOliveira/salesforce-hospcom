public class HistoricoProduto {
    @AuraEnabled
    public static Id criarHistorico(String objetoJSON) {
        Historico_do_produto__c novoRegistro = (Historico_do_produto__c) JSON.deserialize(objetoJSON, Historico_do_produto__c.class);
        
        try {
            novoRegistro.Status__c = 'APROVADO';
            insert novoRegistro;
            System.debug('Registro criado com sucesso. ID do Registro: ' + novoRegistro.Id);
            
            return novoRegistro.Id;
        } catch (Exception e) {
            String error = 'Erro ao criar registro: ' + e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Id criarHistoricoComAprovacao(String objetoJSON) {
        Historico_do_produto__c novoRegistro = (Historico_do_produto__c) JSON.deserialize(objetoJSON, Historico_do_produto__c.class);
        
        try {
            novoRegistro.Status__c = 'EM APROVAÇÃO';
            novoRegistro.Aprovacao__c = true;
            insert novoRegistro;
            System.debug('Registro criado com sucesso. ID do Registro: ' + novoRegistro.Id);
            
            return novoRegistro.Id;
        } catch (Exception e) {
            String error = 'Erro ao criar registro: ' + e.getMessage();
            System.debug(error);            
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
}