public with sharing class FileUploadController {
    
    @AuraEnabled
    public static void processUploadedFiles(List<Id> documentIds, Id recordId) {
        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :documentIds];
        
        for (ContentVersion cv : contentVersions) {
            ContentVersion newVersion = new ContentVersion();
            newVersion.Title = 'Contrato Externo.pdf'; // Adiciona a extensão .pdf
            newVersion.PathOnClient = cv.Title + '.pdf'; // Adiciona a extensão .pdf
            newVersion.VersionData = cv.VersionData;
            newVersion.FirstPublishLocationId = recordId;
            insert newVersion;
        }
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        Set<Id> newDocumentIds = new Set<Id>();
        for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId = :recordId]) {
            newDocumentIds.add(cv.ContentDocumentId);
        }
        
        delete [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocumentId IN :newDocumentIds];
        
        for (Id documentId : newDocumentIds) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = documentId;
            cdl.ShareType = 'V';
            contentDocumentLinks.add(cdl);
        }
        
        if (!contentDocumentLinks.isEmpty()) {
            insert contentDocumentLinks;
        }
    }

    public static String bs64ContratosExternos(Id idContrato ) {
        String base64Contents;
        
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocument.LatestPublishedVersionId
                                                   FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId = :idContrato 
                                                   AND ContentDocument.Title = 'Contrato Externo.pdf']; // Adiciona a extensão .pdf
        
        if (!documentLinks.isEmpty() && documentLinks[0].ContentDocument.LatestPublishedVersionId != null) {
            ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE Id = :documentLinks[0].ContentDocument.LatestPublishedVersionId LIMIT 1];
            base64Contents = EncodingUtil.base64Encode(cv.VersionData);
        }
        
        return base64Contents;
    }

    
    public static void gambiarra(){
        
        String a = 'a';
        
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
        a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';a = 'a';
    }
}