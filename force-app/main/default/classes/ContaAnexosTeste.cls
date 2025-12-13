@isTest(SeeAllData=true)
public class ContaAnexosTeste {

    static testMethod void ContaAnexos1Teste(){ 
        test.startTest();
        
        // teste 1 ----------------------------------------------------------
        ContentDocumentLink link = new ContentDocumentLink(
        	LinkedEntityId =	Id.valueOf('a035A00000WRSOF'),
            ContentDocumentId =	Id.valueOf('0695A000003j6ip'), 
            ShareType = 		'V', 
            Visibility = 		'AllUsers'
        );
        insert link;
        
        // teste 2 ----------------------------------------------------------
        ContentDocument doc_empresa = new ContentDocument();
        doc_empresa = [
            SELECT 	Id
            FROM	ContentDocument
            WHERE	Id = '0695A000003j6ip'	
        ];
        delete doc_empresa;
        
        // teste 3 ----------------------------------------------------------
	    Documentos_Licita_ao__c doc_empr = new Documentos_Licita_ao__c();
        doc_empr = [
            SELECT 	Id
            FROM	Documentos_Licita_ao__c
            WHERE	Id = 'a035A00000WRSOF'
        ];
        update doc_empr;
        
        // fIM testes -------------------------------------------------------
		
        test.stopTest();
    }
        
}