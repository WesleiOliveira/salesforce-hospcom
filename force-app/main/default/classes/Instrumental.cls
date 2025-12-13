public class Instrumental {
    
    public List<ContentDocumentLink> anexosContrato {get;set;}
    public List<ContentVersion> idDownl 			{get;set;}
    
    public Instrumental(ApexPages.StandardController controlador){
        Set<ID> s = new Set<ID>();
        s.add(((SObject)controlador.getRecord()).Id);

        anexosContrato = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN : s 
        ];
        
        Set<ID> s1 = new Set<ID>();
        
        for(ContentDocumentLink CDL : anexosContrato){
            s1.add(CDL.ContentDocumentId);
        }
        
        idDownl = [SELECT ID, ContentUrl, ContentDocument.Title FROM ContentVersion WHERE ContentDocumentId IN :s1 ];
    }
}