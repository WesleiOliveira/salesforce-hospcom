@isTest(SeeAllData=true)
public class ContratoChecklist_Test {
    
    @isTest
    static void testContratoChecklist() {
        
        Id contratoId = '5006e00001rPD1kAAG'; 
        
        Case contrato = [
            SELECT id
            FROM Case
            WHERE id =: contratoId
        ];

         GestaoDocumentos.obterDocumentosVigentes();
        ApexPages.StandardController sc = new ApexPages.StandardController(contrato);
        ContratoChecklist cl = new ContratoChecklist(sc);
    }
}