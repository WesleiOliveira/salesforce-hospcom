@isTest
public class getAnexoNfCompraTEST {
    @isTest
    static void testTrigger() {
        // ID fictício para o campo obrigatório Pedido_de_Compra__c
        Id pedidoDeCompraId = 'a1bU4000001lWIPIA2';

        // Crie um registro Nota_fiscal_de_pedido_de_compra__c para teste
        Nota_fiscal_de_pedido_de_compra__c nfCompra = new Nota_fiscal_de_pedido_de_compra__c(
            Pedido_de_Compra__c = pedidoDeCompraId
        );
        insert nfCompra;

        // Crie um registro ContentVersion para o ContentDocument
        ContentVersion contentVer = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert contentVer;

        // Obtenha o ContentDocumentId a partir do ContentVersion
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            LinkedEntityId = nfCompra.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVer.Id LIMIT 1].ContentDocumentId,
            ShareType = 'V'  // 'V' é para Viewer
        );

        Test.startTest();
        insert contentDocLink;
        Test.stopTest();

        // Recarregue o registro Nota_fiscal_de_pedido_de_compra__c para verificar se o campo URL_Anexo__c foi atualizado
        nfCompra = [SELECT Id, URL_Anexo__c FROM Nota_fiscal_de_pedido_de_compra__c WHERE Id = :nfCompra.Id];

        // Verifique se o campo URL_Anexo__c foi atualizado corretamente
        String expectedUrl = 'https://hospcom.my.site.com/Sales/sfc/servlet.shepherd/document/download/' + contentDocLink.ContentDocumentId;
        System.assertEquals(expectedUrl, nfCompra.URL_Anexo__c, 'A URL do anexo deve estar correta no campo URL_Anexo__c');
    }
}