@isTest(SeeAllData=true)
public class DownloadDocumentoTeste {

    
    static testMethod void DownloadDocTeste(){ 
      	test.startTest();    
        
		Documentos_Licita_ao__c documento = new Documentos_Licita_ao__c();
        documento = [
            SELECT	id
            FROM	Documentos_Licita_ao__c
            LIMIT 	1
        ];

        
        PageReference PaginaDownload = Page.DownloadDocumento;        
        Test.setCurrentPage(PaginaDownload);
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(documento.Id));
		
        DownloadDocumento controlador = new DownloadDocumento() ;
		controlador.AbreLink();
            
        test.stopTest();
    }
}