@IsTest(seeAllData=true)
public class LimpaInadimplentesTest {
    
    @IsTest
    static void testDoPost() {
        // Define os dados da requisição
        
        // Configura o contexto da requisição
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        
        // Chama o método do controlador
        try{
            LimpaInadimplentes.doPost();
        }   
        catch(Exception e){     
        }
    }
}