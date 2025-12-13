public without sharing class CommunityAuthController {

    @AuraEnabled
    public static string doLogin(String username, String password){

        String startUrl = 'hospcomhospitalar.force.com/Sales/s/';
        ApexPages.PageReference pageRef = Site.login(username, password, startUrl);

        if(pageRef != null) return pageRef.getUrl();
        return password + username;

    }

    @AuraEnabled
    public static boolean recoveryPassword(String username){
        return Site.forgotPassword(username);
    }

    
}