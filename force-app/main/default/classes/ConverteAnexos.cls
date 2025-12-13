public with sharing class ConverteAnexos {

    public static void Converte(Id reg_id){
        
        if(ConverteAnexosControle.ExecutarUmaVez()){  
            List<ContentDocumentLink> 	link_lista 		    = 	new List<ContentDocumentLink>();
            List<Id>					documento_lista_id 	= 	new List<Id>();
            List<ContentDocument> 	    documento_lista 	= 	new List<ContentDocument>();   
            List<Id>					versao_lista_id 	= 	new List<Id>();
            List<ContentVersion>		versao_lista		= 	new List<ContentVersion>();
            List<Attachment>			anexo_lista			= 	new	List<Attachment>();
            
            // lista links
            link_lista = [
                SELECT  ContentDocumentId
                FROM    ContentDocumentLink
                WHERE   LinkedEntityId = :reg_id
            ];
            
            // continua somente se houver documentos relacionados
            if(link_lista.size()>0){
                // lista id's documentos
                for(ContentDocumentLink link : link_lista){
                     documento_lista_id.add(link.ContentDocumentId);
                }
                
                // lista documentos
                documento_lista = [
                    SELECT 	LatestPublishedVersionId
                    FROM	ContentDocument
                    WHERE	Id IN :documento_lista_id AND
                            FileType != 'SNOTE'
                ];
                // lista id's versões
                for(ContentDocument documento : documento_lista){
                    versao_lista_id.add(documento.LatestPublishedVersionId);
                }
                
                // lista versões 
                versao_lista = [
                    SELECT  Id, Title, VersionData, FileType
                    FROM    ContentVersion
                    WHERE   Id IN :versao_lista_id
                ];
            
                // salva anexos
                for(ContentVersion versao : versao_lista){
					String extensao = versao.FileType.toLowerCase();
                    if(extensao == 'text')
                        extensao = 'txt';
					
                    Attachment anexo = new Attachment(
                        ParentId 	= id.valueOf(reg_id),
                        Body 		= versao.VersionData,
                        Name 		= versao.Title + '.' + extensao
                    );
                    anexo_lista.Add(anexo);
                }
                insert anexo_lista;
                
                // deleta arquivos 
                delete documento_lista;
            }    	       
        }        
    }
}