public class DownloadDocumento {
    
    public PageReference AbreLink(){
        
        Id id_doc = Id.valueOf(System.currentPageReference().getParameters().get('id'));
    	List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        String CaminhoPagina;
        
        links = [
            SELECT      Id, ContentDocumentId
            FROM        ContentDocumentLink
            WHERE       linkedEntityId = :id_doc
            ORDER BY    SystemModstamp DESC
            LIMIT       1        
        ];
        
        if(links.size() == 0){
			CaminhoPagina = '/' + String.valueOf(id_doc);
        }
        
        else if(links.size() == 1){
            ContentDocument documento = new ContentDocument();
            documento = [
                SELECT		Id, LatestPublishedVersionId
                FROM		ContentDocument
                WHERE		Id = :links[0].ContentDocumentId
            ];
            CaminhoPagina = '/sfc/servlet.shepherd/version/download/' + String.ValueOf(documento.LatestPublishedVersionId);
        }
        
        return new PageReference(CaminhoPagina);
        
    }
}