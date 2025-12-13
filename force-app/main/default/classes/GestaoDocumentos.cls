public class GestaoDocumentos {

    public static List<Gest_o_de_Documentos__c> obterDocumentosVigentes() {
        List<Gest_o_de_Documentos__c> documentos = [SELECT Id, Name, Data_de_criacao__c, Revisao__c, Documento__c, Empresa__c, N_mero_de_Revis_o__c, SISTEMA__c, Status__c, RecordTypeId, Empresa_pesquisa__c
                                                    FROM Gest_o_de_Documentos__c
                                                    WHERE Status__c = 'VIGENTE'];
        return documentos;
    }
}