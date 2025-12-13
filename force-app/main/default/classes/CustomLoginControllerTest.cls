@isTest
public class CustomLoginControllerTest {
    
    static testMethod void teste_geral(){ 
        test.startTest();    
        
		CustomLoginController controlador = new CustomLoginController();
        controlador.forwardToCustomAuthPage();
        controlador.login();
		
        test.stopTest();
    }
}