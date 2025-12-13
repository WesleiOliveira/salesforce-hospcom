@IsTest(seeAllData=true)
public class apiConfirmacaoServiceTest {
    
    @IsTest
    static void testDoPost() {
        // Define os dados da requisição
        String requestBody = 'a1gU4000001nwOsIAI';
        
        // Chama o método do controlador
        try{
            ApiConfirmacaoService.processRequest(requestBody);
        }   
        catch(Exception e){     
        }
    }
    @IsTest
    static void testDoPost2() {
        // Define os dados da requisição
        String requestBody = 'a1gU4000001nwQU';
        
        // Chama o método do controlador
        try{
            ApiConfirmacaoService.processRequest(requestBody);
        }   
        catch(Exception e){     
        }
    }
}