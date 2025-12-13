public with sharing class LinkMiniatura{
	
	public Boolean 		bloqueia 	{get;set;}
	public MktMidia__c	midia		{get;set;}
	public String 		url_base    {get;set;}
	
    public LinkMiniatura(ApexPages.StandardController controller) {
		url_base = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
		
		midia = [SELECT Id, Name, DownloadId__c, Icone_url__c FROM MktMidia__c WHERE Id = :controller.getRecord().Id];
		
		if(midia.DownloadId__c == null || midia.Icone_url__c != null){
			bloqueia = true;
		}
		else{
			bloqueia = false;
		}
	}
	
	// botão: gera miniatura e insere [ico] na midia
    public PageReference GerarMiniatura(){

		PageReference miniatura_page = new PageReference(
			url_base+'/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+midia.DownloadId__c
		);
		
		Blob miniatura_blob;
		if (Test.isRunningTest())
			miniatura_blob = null;
		else
			miniatura_blob = miniatura_page.getContent();
		
		Document miniatura = new Document(
			Name 				= midia.Name,
			Description			= midia.Id,
			Body 				= miniatura_blob,
			Type 				= 'jpg',
			ContentType 		= 'image/jpeg',
			FolderId			= '00l5A000001v5JBQAY',
			IsInternalUseOnly 	= false,
			IsPublic			= true
		);

		insert miniatura;

		midia.Interno__c = true;
		midia.Icone_url__c = url_base+'/servlet/servlet.ImageServer?id='+miniatura.Id+'&oid=00Di0000000JVhH';
		update midia;
		
		midia.Interno__c = false;
		update midia;
		
		return new PageReference('/' + String.valueOf(midia.Id));
	}
}