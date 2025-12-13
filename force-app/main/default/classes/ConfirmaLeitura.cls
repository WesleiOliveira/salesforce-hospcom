public class ConfirmaLeitura {
    @AuraEnabled
    public static void confirma(string comunicado){
        Confirmacao_de_Leitura__c cl = new Confirmacao_de_Leitura__c();
        cl.Comunicado__c = comunicado;
        insert cl;
    }
}