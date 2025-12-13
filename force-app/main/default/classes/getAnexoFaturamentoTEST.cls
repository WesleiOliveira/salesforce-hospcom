@IsTest(SeeAllData=true)
public class getAnexoFaturamentoTEST {
    @isTest
    static void testTrigger() {
        // ID existente do registro Faturamento__c
        Id existingFaturamentoId = 'a086e00001v2rrPAAQ';

        // Crie um registro ContentVersion para o ContentDocument
        ContentVersion contentVer = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert contentVer;

        // Obtenha o ContentDocumentId a partir do ContentVersion
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            LinkedEntityId = existingFaturamentoId,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVer.Id LIMIT 1].ContentDocumentId,
            ShareType = 'V',  // 'V' é para Viewer
            Visibility = 'AllUsers'  // Garantir que todos os usuários possam ver o documento
        );

        Test.startTest();
        insert contentDocLink;
        Test.stopTest();

        // Recarregue o registro Faturamento__c para verificar se o campo URL_Anexo__c foi atualizado
        Faturamento__c faturamento = [SELECT Id, URL_Anexo__c FROM Faturamento__c WHERE Id = :existingFaturamentoId];

        // Verifique se o campo URL_Anexo__c foi atualizado corretamente
        String expectedUrl = 'https://hospcom.my.site.com/Sales/sfc/servlet.shepherd/document/download/' + contentDocLink.ContentDocumentId;
        System.assertEquals(expectedUrl, faturamento.URL_Anexo__c, 'A URL do anexo deve estar correta no campo URL_Anexo__c');
    }
}