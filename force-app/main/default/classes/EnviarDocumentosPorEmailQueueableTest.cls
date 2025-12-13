@isTest(seeAllData = true)
public class EnviarDocumentosPorEmailQueueableTest {

    @isTest
    public static void teste() {
        
        String comodatoId = 'a0KU4000004EiA9MAK'; 
        String demoId = 'a0KU4000004EiA9MAK';  
        String contratoId = 'a1Y6e00000EPC3pEAH';  
        //String emailDestino = 'witor.lomazzi@hospcom.net'; 


       List<Map<String, Object>>  documentos = DocumentosRegistros.documentosOts(comodatoId,0, 20);

       List<Map<String, Object>>  documentosOts_Demo = DocumentosRegistros.documentosOts_Demo(demoId,0, 20);
        
       
       List<Map<String, Object>>  documentosOts_contrato = DocumentosRegistros.documentosOts_contratos(demoId,0, 20);
    }
}