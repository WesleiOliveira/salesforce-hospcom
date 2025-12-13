public class FileStorage {
	
	public List<Proposta__c> proposta {get;set;}
    public Proposta__c proposta_del {get;set;}
	
	public FileStorage(){
		proposta = new List<Proposta__c>();
	}
	
	public void Pesquisar(){
		proposta = [
			select  Id, Name, Oportunidade__c, Ordem_de_trabalho__c
			FROM   	Proposta__c
			WHERE  	Oportunidade__c != null OR Ordem_de_trabalho__c != null
			ORDER BY CreatedDate ASC
			LIMIT  	1
		];

		if(proposta.size()==1){	
			proposta_del = + proposta[0];
			
			List<Attachment> anexo = [
				select  Name, Body
				FROM	Attachment
				WHERE   ParentId = :proposta[0].Id
			];
			if(anexo.size()==1){
				ContentVersion versao = new ContentVersion(
					PathOnClient = anexo[0].Name,
					Title = anexo[0].Name,
					VersionData = anexo[0].Body
				);
				insert versao;
				versao = [
					SELECT 	ContentDocumentId
					FROM	ContentVersion
					WHERE	Id = :versao.Id
				];
				ContentDocumentLink link = new ContentDocumentLink(
					ContentDocumentId = versao.ContentDocumentId,
					LinkedEntityId = (proposta[0].Oportunidade__c!=null ? proposta[0].Oportunidade__c : proposta[0].Ordem_de_trabalho__c),
					ShareType = 'I',
					Visibility = 'AllUsers'
				);
				insert link;
				delete anexo;
			}
			delete proposta;
		}
	}
	
}