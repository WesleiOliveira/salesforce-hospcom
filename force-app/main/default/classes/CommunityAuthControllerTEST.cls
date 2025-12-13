@isTest
public class CommunityAuthControllerTEST {

    @isTest
    public static void teste(){
        CommunityAuthController.doLogin('desenvolvimento@hospcom.net','dev@3241');
        CommunityAuthController.recoveryPassword('desenvolvimento@hospcom.net');        
    }
    
}