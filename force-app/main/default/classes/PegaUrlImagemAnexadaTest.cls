@isTest
public class PegaUrlImagemAnexadaTest {
    @isTest
    static void testGetFileURLs() {
        // Criar um registro de teste
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Criar uma versão do conteúdo (isso cria automaticamente um ContentDocument)
        ContentVersion contentVer = new ContentVersion();
        contentVer.VersionData = Blob.valueOf('Test Data'); // Simula um arquivo
        contentVer.PathOnClient = 'test.png';
        contentVer.Title = 'Test File';
        contentVer.IsMajorVersion = true;
        insert contentVer;

        // Obter o ContentDocumentId gerado automaticamente
        ContentVersion insertedContentVer = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVer.Id LIMIT 1
        ];

        // Criar um ContentDocumentLink para associar ao registro
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = insertedContentVer.ContentDocumentId;
        link.LinkedEntityId = testAccount.Id;
        link.ShareType = 'V';
        insert link;

        // **Iniciar teste para simular execução do controlador**
        Test.startTest();
        
        // Simular passagem de parâmetros no Visualforce
        ApexPages.currentPage().getParameters().put('id', testAccount.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        PegaUrlImagemAnexada controller = new PegaUrlImagemAnexada(sc);
        List<String> urls = controller.getFileURLs();
        
        Test.stopTest();

        // **Verificações**
        System.assert(urls.size() > 0, 'A URL do arquivo não foi gerada corretamente.');
        System.assert(urls[0].startsWith('/sfc/servlet.shepherd/version/download/'), 'A URL gerada não é válida.');
    }
}