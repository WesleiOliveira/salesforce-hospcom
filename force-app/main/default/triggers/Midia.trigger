trigger Midia on MktMidia__c (before insert, before update, before delete){
	
	List<Id> miniaturas_id = new List<Id>();
	List<Id> anexos_id = new List<Id>();
	List<MktMidia__c> midias = new List<MktMidia__c>();

	if(Trigger.isInsert || Trigger.isUpdate){
		for(MktMidia__c midia : Trigger.new){
			
			// validações ---------------------------------------------------------------------------
			
				
			// (alterar) não salva se [tipo == extensão/video] && [qtd anexo > 0]
			if(Trigger.isUpdate && (midia.Tipo__c=='Extensão' || midia.Tipo__c=='Vídeo') && midia.Quantidade_de_anexos__c>0)
				midia.Tipo__c.addError('O tipo selecionado não permite anexos)'); 
				
			// (inserir/alterar) não salva se [tipo == extensão/video] && [arq/prop/ico == null]
			if(midia.Tipo__c=='Extensão' || midia.Tipo__c=='Vídeo'){
				if(midia.URL_do_Arquivo__c==null)
					midia.URL_do_Arquivo__c.addError('O tipo selecionado requer o link para o arquivo');
				if(midia.Tamanho__c==null)
					midia.Tamanho__c.addError('O tipo selecionado requer o tamanho do arquivo'); 
				if(midia.Formato__c==null)
					midia.Formato__c.addError('O tipo selecionado requer o formato do arquivo'); 
				if(midia.Extensao__c==null)
					midia.Extensao__c.addError('O tipo selecionado requer a extensao do arquivo'); 
				if(midia.Icone_url__c==null)
					midia.Icone_url__c.addError('O tipo selecionado requer o ícone do arquivo (documento público)'); 
			}
			
			// (inserir/alterar) não salva se [tipo != extensão/video] && [arq/prop/ico inseriu/alterou manualmente]
			if((midia.Tipo__c!='Extensão' && midia.Tipo__c!='Vídeo') && midia.Interno__c==false){
				if(midia.URL_do_Arquivo__c != null)
					midia.URL_do_Arquivo__c.addError('O tipo selecionado não permite link para o arquivo');
				if(Trigger.isUpdate){
					if(Trigger.oldMap.get(midia.Id).Tamanho__c != midia.Tamanho__c)
						midia.Tamanho__c.addError('O tipo selecionado não permite alteração manual do tamanho do arquivo'); 
					if(Trigger.oldMap.get(midia.Id).Formato__c != midia.Formato__c)
						midia.Formato__c.addError('O tipo selecionado não permite alteração manual do formato do arquivo'); 
					if(Trigger.oldMap.get(midia.Id).Extensao__c != midia.Extensao__c)
						midia.Extensao__c.addError('O tipo selecionado não permite alterção manual da extensao do arquivo'); 
					if(Trigger.oldMap.get(midia.Id).Icone_url__c != midia.Icone_url__c)
						midia.Icone_url__c.addError('O tipo selecionado não permite alteração manual do ícone do arquivo'); 					
				}else if(Trigger.isInsert){
					if(midia.Tamanho__c!=null)
						midia.Tamanho__c.addError('O tipo selecionado não permite inserção manual do tamanho do arquivo'); 
					if(midia.Formato__c!=null)
						midia.Formato__c.addError('O tipo selecionado não permite inserção manual do formato do arquivo'); 
					if(midia.Extensao__c!=null)
						midia.Extensao__c.addError('O tipo selecionado não permite inserção manual da extensao do arquivo'); 
					if(midia.Icone_url__c!=null)
						midia.Icone_url__c.addError('O tipo selecionado não permite inserção manual do ícone do arquivo'); 					
				}
			}
			
			// ações --------------------------------------------------------------------------------
			
			// (alterar) se [ico alterou] && [ico.old != null]: deleta ico.old (document)
			if(Trigger.isUpdate && Trigger.oldMap.get(midia.Id).Icone_url__c!=null && Trigger.oldMap.get(midia.Id).Icone_url__c!=midia.Icone_url__c){
				Integer indice_id = Trigger.oldMap.get(midia.Id).Icone_url__c.indexOf('id=');
				if (indice_id > -1)
					miniaturas_id.add(Trigger.oldMap.get(midia.Id).Icone_url__c.subString(indice_id+3, indice_id+18));
			}
			
		} // loop new
	} // if ins/upd
	
	else if(Trigger.isDelete){
		for(MktMidia__c midia : Trigger.old){
			
			// ações --------------------------------------------------------------------------------
			
			// (deletar) se [ico != null]: deleta ico (document)
			if(midia.Icone_url__c!=null){
				Integer indice_id = midia.Icone_url__c.indexOf('id=');
				if (indice_id > -1)
					miniaturas_id.add(midia.Icone_url__c.subString(indice_id+3, indice_id+18));
			}
			
			// (deletar) se [qtd anexo > 0]: deleta anexo (content)
			if(midia.Quantidade_de_anexos__c>0){
				if(midia.DownloadId__c!=null)
					anexos_id.add(midia.DownloadId__c);
			}
			
		} // loop new
	} // if ins/upd
	
	// ações finais -------------------------------------------------------------------------
	
	if(miniaturas_id.size()>0){
		List<Document> miniaturas = new List<Document>();
		miniaturas = [SELECT Id FROM Document WHERE Id IN :miniaturas_id];
		if(miniaturas.size()>0)
			delete miniaturas;
	}
	
	if(anexos_id.size()>0){
		List<ContentVersion> versoes = new List<ContentVersion>();
		List<Id> documentos_id = new List<Id>();
		List<ContentDocument> documentos = new List<ContentDocument>();
		
		versoes = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :anexos_id];
		
		if(versoes.size()>0){
			for(ContentVersion versao : versoes)
				documentos_id.add(versao.ContentDocumentId);
			documentos = [SELECT Id FROM ContentDocument WHERE Id IN :documentos_id];
			if(documentos.size()>0)
				delete documentos;
		}
	}
	
}