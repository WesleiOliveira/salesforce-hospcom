@isTest
public class DocumentosRegistrosBatchTest {
    @isTest
    public static void teste() {
        
        String comodatoId = 'a0K6e00001ngJ4uEAE';  
        String emailDestino = 'witor.lomazzi@hospcom.net'; 
       
        DocumentosRegistros.documentosOts(comodatoId);
        DocumentosRegistrosBatch.startBatch( comodatoId,  emailDestino);
        
        
         DocumentosRegistros.gambiarra();
        //EnviarDocumentosEmail.gambiarra();
    }
}