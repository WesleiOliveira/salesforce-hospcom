@RestResource(urlMapping='/linkPublico')
global without sharing class publicLink{
    
    @HttpPost
    global static void doPost() {
        
        // Obtém os dados da requisição
        String requestBody = RestContext.request.requestBody.toString();
        valores request = (valores)JSON.deserialize(requestBody, valores.class);
        Map<String, String> responseMap = new Map<String, String>();
        
        system.debug(requestBody);
                
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :request.idDoc LIMIT 1];
        
        ContentDistribution cd = new ContentDistribution();
        
        cd.Name = 'Test';
        
        cd.ContentVersionId = cv.id;
        
        cd.PreferencesAllowViewInBrowser = true;
        
        cd.PreferencesLinkLatestVersion = true;
        
        cd.PreferencesNotifyOnVisit = false;
        
        cd.PreferencesPasswordRequired = false;
        
        cd.PreferencesAllowOriginalDownload = true;
        
        
        try {
            insert cd;
            responseMap.put('Link: ', cd.ContentDownloadUrl);
            String responseBody = JSON.serialize(responseMap);
            RestContext.response.responseBody = Blob.valueOf(responseBody);
            
        } catch (DmlException error) {
            System.debug(error);
            responseMap.put('erro', error.getMessage());
            String responseBody = JSON.serialize(responseMap);
            RestContext.response.responseBody = Blob.valueOf(responseBody);
            
        }
    }
    public class valores{
        public String idDoc;
        
    }
}