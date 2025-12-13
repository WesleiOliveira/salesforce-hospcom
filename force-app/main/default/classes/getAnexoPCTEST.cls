@IsTest(SeeAllData=true)
public class getAnexoPCTEST {
    @isTest
    static void testTrigger() {
        // ID fictício para o campo Fornecedor__c
        Id fornecedorId = 'a1bU4000001lWIPIA2';
        
        //a1bHZ000000hQiPYAU sand
        ////a1bU4000001lWIPIA2 prod

        // Crie um registro Fornecedor__c para teste
        Fornecedor__c fornecedor = new Fornecedor__c(
            Id = fornecedorId
        );

        // Crie um registro ContentVersion para o ContentDocument
        ContentVersion contentVer = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert contentVer;

        // Obtenha o ContentDocumentId a partir do ContentVersion
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            LinkedEntityId = fornecedor.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVer.Id LIMIT 1].ContentDocumentId,
            ShareType = 'V'  // 'V' é para Viewer
        );

        Test.startTest();
        insert contentDocLink;
        Test.stopTest();

        // Recarregue o registro Fornecedor__c para verificar se o campo URL_Anexo__c foi atualizado
        fornecedor = [SELECT Id, URL_Anexo__c FROM Fornecedor__c WHERE Id = :fornecedor.Id];

        // Verifique se o campo URL_Anexo__c foi atualizado corretamente
        String expectedUrl = 'https://hospcom.my.site.com/Sales/sfc/servlet.shepherd/document/download/' + contentDocLink.ContentDocumentId;
        System.assertEquals(expectedUrl, fornecedor.URL_Anexo__c, 'A URL do anexo deve estar correta no campo URL_Anexo__c');
    }
}