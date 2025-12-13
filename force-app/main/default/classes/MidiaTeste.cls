@isTest(seeAllData=true)
private class MidiaTeste {
	
    @isTest 
	static void TesteMidia(){
		System.Debug(LoggingLevel.INFO,'TesteMidia inicio');
		
		MktMidia__c midia = new MktMidia__c(
			Categoria__c = 'a1RU4000000q05ZMAQ',
			Tipo__c = 'Catálogo',
			Name = 'teste1'
		);
		
		// insert : excessão arquivo com link + propriedades manual
		try {
			midia.Tamanho__c='10 MB';
			midia.Formato__c='PDF';
			midia.Extensao__c='pdf';
			midia.Icone_url__c='https://www.google.com';
			insert midia;
		} catch(Exception error) {
			System.assert(error.getMessage().contains('O tipo selecionado'));
		}
		
		// midia : insert normal
		midia.Tamanho__c=null;
		midia.Formato__c=null;
		midia.Extensao__c=null;
		midia.Icone_url__c=null;
		insert midia;
		
		// midia : update normal
		midia.name = 'teste2';
		update midia;
		

		// update : excessão video com anexo
		try {
			midia.Tipo__c='Vídeo';
			midia.Quantidade_de_anexos__c=1;
			update midia;
		} catch(Exception error) {
			System.assert(error.getMessage().contains('O tipo selecionado '));
		}
		midia.Tipo__c='Catálogo';
		midia.Quantidade_de_anexos__c=0;
		
		// update : excessão video sem link e propriedades
		try {
			midia.Tipo__c='Vídeo';
			update midia;
		} catch(Exception error) {
			System.assert(error.getMessage().contains('O tipo selecionado'));
		}
		midia.Tipo__c='Catálogo';
		
		// update : excessão arquivo com link + propriedades manual
		try {
			midia.URL_do_Arquivo__c='https://www.google.com';
			midia.Tamanho__c='10 MB';
			midia.Formato__c='PDF';
			midia.Extensao__c='pdf';
			midia.Icone_url__c='https://www.google.com';
			update midia;
		} catch(Exception error) {
			System.assert(error.getMessage().contains('O tipo selecionado '));
		}
		midia.URL_do_Arquivo__c=null;
		midia.Tamanho__c=null;
		midia.Formato__c=null;
		midia.Extensao__c=null;
		midia.Icone_url__c=null;
		
		// update : operações com imagens
		midia.Interno__c=true;
		midia.Icone_url__c='https://hospcom--douglas--c.cs41.content.force.com/servlet/servlet.ImageServer?id=0155A000009yGk2&oid=00D550000000Qcs&lastMod=1545321940000';
		update midia;
		
		// link : delete
		delete midia;
		
		System.Debug(LoggingLevel.INFO,'TesteMidia fim');
	}
	
    @isTest 
	static void TesteLink(){
		System.Debug(LoggingLevel.INFO,'TesteLink inicio');
		
		// midia : insert
		MktMidia__c midia = new MktMidia__c(
			Categoria__c = 'a1RU4000000q05ZMAQ',
			Tipo__c = 'Catálogo',
			Name = 'test3'
		);
		insert midia;
		
		// link : insert 
		ContentDocumentLink link = new ContentDocumentLink(
			LinkedEntityId = midia.Id, 
			ContentDocumentId = '0695A000004xPsj',
			Visibility = 'AllUsers',
			ShareType = 'V'
		);
		insert link;
		
		// teste botão
		ApexPages.StandardController controlador = new ApexPages.StandardController(midia);
		LinkMiniatura botao = new LinkMiniatura(controlador);
		botao.GerarMiniatura();
		
		
		// link : delete
		delete link;
		
		System.Debug(LoggingLevel.INFO,'TesteLink fim');
	}	
	
}