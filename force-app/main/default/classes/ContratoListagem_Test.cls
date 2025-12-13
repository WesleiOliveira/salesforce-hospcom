@isTest(SeeAllData=true)
public class ContratoListagem_Test {
    
    @isTest
    static void testContratoListagem() {
        
        Id contratoId = 'a1Y6e00000EPC3pEAH'; 
        
        Contrato_de_Servi_o__c	 contrato = [
            SELECT id
            FROM Contrato_de_Servi_o__c
            WHERE id =: contratoId
        ];

         GestaoDocumentos.obterDocumentosVigentes();
        ApexPages.StandardController sc = new ApexPages.StandardController(contrato);
        ContratoListagem cl = new ContratoListagem(sc);
    }
}