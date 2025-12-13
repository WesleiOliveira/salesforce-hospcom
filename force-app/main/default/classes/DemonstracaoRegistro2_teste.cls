@isTest(SeeAllData=true)
public class DemonstracaoRegistro2_teste {
    
    @isTest
    static void testContratoListagem() {
        
        Id order_id = '801U4000006JPiZIAW'; 
        
        Order	 contrato = [
            SELECT id
            FROM Order
            WHERE id =: order_id
        ];

         GestaoDocumentos.obterDocumentosVigentes();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contrato);
        DemonstracaoRegistro2 cl = new DemonstracaoRegistro2(sc);
    }
}