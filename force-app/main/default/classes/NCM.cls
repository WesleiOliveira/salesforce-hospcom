public class NCM {
    @AuraEnabled
    public static void atualiza(string codigoNCM, string idSolicitacao){
        SolicitacaodeCadastro__c sc = [SELECT ID FROM SolicitacaodeCadastro__c WHERE ID = : idSolicitacao];
        sc.NCM__c = codigoNCM;
        try{
            update sc;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}