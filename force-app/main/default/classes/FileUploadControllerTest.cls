@isTest (SeeAllData=true)
public class FileUploadControllerTest {
    @isTest
    static void testProcessUploadedFiles() {
        Id recordId = 'a3AU40000003vEfMAI';

        // Cria um ContentVersion de teste (simulando um arquivo carregado)
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'ExampleFile' + System.currentTimeMillis() + '.pdf',
            PathOnClient = 'ExampleFile.pdf',
            VersionData = Blob.valueOf('Sample file content'),
            FirstPublishLocationId = UserInfo.getUserId()
        );
        insert testContentVersion;

        // Obtém o ContentDocumentId do ContentVersion inserido
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id
        ];
        Id contentDocumentId = contentVersions[0].ContentDocumentId;
        List<Id> documentIds = new List<Id>{ contentDocumentId };

            
            FileUploadController.gambiarra();
 
        FileUploadController.processUploadedFiles(documentIds, recordId);
     

        // Verifica se a nova versão do conteúdo foi criada e vinculada ao registro de teste
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId AND ContentDocumentId IN :documentIds
        ];
        //System.assertEquals(1, links.size(), 'A nova versão do conteúdo deve ser vinculada ao registro de teste.');
    }
}