trigger Link on ContentDocumentLink (after insert, after delete){
	
	List<Id> midias_id = new List<Id>();
	List<Id> documentos_id = new List<Id>();
	List<MktMidia__c> midias = new List<mktMidia__c>();
	List<ContentDocument> documentos = new List<ContentDocument>();
	List<Id> miniaturas_id = new List<Id>();
	
	for(ContentDocumentLink link : (Trigger.isInsert ? Trigger.new : Trigger.old)){
		if(String.ValueOf(link.LinkedEntityId).left(3) == 'a1T'){ // a1T = MktMidia__c
			midias_id.add(link.LinkedEntityId);
			documentos_id.add(link.ContentDocumentId);
		}
	}
	
	if(midias_id.size()>0){
		midias = [
			SELECT	Id, Interno__c, Quantidade_de_anexos__c, Tipo__c, Tamanho__c, Formato__c, Extensao__c, DownloadId__c, Icone_url__c
			FROM	MktMidia__c
			WHERE	Id IN :midias_id
		];
		documentos = [
			SELECT	LatestPublishedVersionId, LatestPublishedVersion.Title, LatestPublishedVersion.FileExtension,
					LatestPublishedVersion.FileType, LatestPublishedVersion.ContentSize
			FROM	ContentDocument
			WHERE	Id IN :documentos_id
		];
		
		if(Trigger.isInsert){
			for(ContentDocumentLink link : Trigger.new){
				for(MktMidia__c midia : midias){
					if(link.LinkedEntityId == midia.Id) {
						
						// validações ---------------------------------------------------------------------------
						
						// (inserir) não anexa se [tipo == extensão/video]
						if (midia.Tipo__c=='Extensão' || midia.Tipo__c=='Vídeo')
							link.addError('O tipo selecionado não permite anexar arquivo');
						
						// (inserir) não anexa se [qtd anexo > 0]
						if (midia.Quantidade_de_anexos__c > 0)
							link.addError('Não é permitido anexar mais de um arquivo em uma mídia');
						
						// ações --------------------------------------------------------------------------------
						
						// (inserir) insere [propriedades/qtd anexo] na midia (+ botão: gera miniatura e insere [ico] na midia)
						for(ContentDocument documento : documentos){
							if(link.ContentDocumentId == documento.id){
								
								midia.Interno__c = true;
								midia.Quantidade_de_anexos__c = 1;
								midia.DownloadId__c = documento.LatestPublishedVersionId;
								midia.Extensao__c = documento.LatestPublishedVersion.FileExtension;
								midia.Formato__c = documento.LatestPublishedVersion.FileType;
								
								Decimal tamanho;
								if (documento.LatestPublishedVersion.ContentSize < 1024)
									midia.Tamanho__c = String.valueOf(documento.LatestPublishedVersion.ContentSize) + ' B';
								else if (documento.LatestPublishedVersion.ContentSize >= 1024 && documento.LatestPublishedVersion.ContentSize < (1024*1024)){
									tamanho = Decimal.valueOf(documento.LatestPublishedVersion.ContentSize);
									tamanho = tamanho.divide(1024,2);
									midia.Tamanho__c = String.valueOf(tamanho) + ' KB';
								}else if (documento.LatestPublishedVersion.ContentSize >= (1024*1024) && documento.LatestPublishedVersion.ContentSize < (1024*1024*1024)) {
									tamanho = Decimal.valueOf(documento.LatestPublishedVersion.ContentSize);
									tamanho = tamanho.divide((1024*1024),2);
									midia.Tamanho__c = String.valueOf(tamanho) + ' MB';
								}else {
									tamanho = Decimal.valueOf(documento.LatestPublishedVersion.ContentSize);
									tamanho = tamanho.divide((1024*1024*1024),2);
									midia.Tamanho__c = String.valueOf(tamanho) + ' GB';
								}
								
							}
						}

					}
				}
			}
		}
		else if(Trigger.isDelete){
			
			// ações --------------------------------------------------------------------------------
			
			// (deletar) deleta miniatura/documento, remover [propriedades/qtd anexo/ico] da midia
			for(MktMidia__c midia : midias){
				if(midia.Icone_url__c!=null){
					Integer indice_id = midia.Icone_url__c.indexOf('id=');
					if (indice_id > -1)
						miniaturas_id.add(midia.Icone_url__c.subString(indice_id+3, indice_id+18));											
				}
				midia.Interno__c = true;
				midia.Quantidade_de_anexos__c = 0;
				midia.DownloadId__c = null;
				midia.Extensao__c = null;
				midia.Formato__c = null;
				midia.Tamanho__c = null;
				midia.Icone_url__c = null;
			}				
			delete documentos;
		}
		
		// ações finais -------------------------------------------------------------------------
		
		if(miniaturas_id.size()>0){
			List<Document> miniaturas = new List<Document>();
			miniaturas = [SELECT Id FROM Document WHERE Id IN :miniaturas_id];
			if(miniaturas.size()>0)
				delete miniaturas;
		}

		update midias;
		for(MktMidia__c midia : midias)
			midia.Interno__c = false;
		update midias;
	}
	
}