public with sharing class FotoDePerfilController {
     
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {
 
        if (!Schema.sObjectType.Recrutamento__c.isAccessible()) {
            throw new System.NoAccessException();
            
        }
  
        return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
            ORDER BY LastModifiedDate DESC LIMIT 1];
    }
     
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 
 
        if (!Schema.sObjectType.Recrutamento__c.isUpdateable()) {
            throw new System.NoAccessException();
            	
        }
 
        Attachment attachment = new Attachment();
        
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
        attachment.contentType = contentType;
        insert attachment;
        return attachment.id;
    }
 
}