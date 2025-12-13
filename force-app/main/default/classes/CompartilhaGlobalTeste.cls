@isTest(SeeAllData=true)
private class CompartilhaGlobalTeste { 
    static testMethod void teste_geral(){ 
        test.startTest();    
        
        ContentDocumentLink link = new ContentDocumentLink(
            linkedentityid = Id.valueOf('0WO5A000000XcLc'),
            contentdocumentid = Id.valueOf('0695A000003jg4M'),
            sharetype = 'V',
            visibility = 'AllUsers'
        );
        insert link;

		test.stopTest();
    }
}