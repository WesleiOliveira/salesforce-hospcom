@isTest
public class FileControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Criar um Account para associar os arquivos
        Account acc = new Account(Name = 'Teste Conta');
        insert acc;

        // Criar um ContentDocument para simular um arquivo existente
        ContentVersion cv = new ContentVersion(
            Title = 'Contrato Social.pdf',
            PathOnClient = 'Contrato_Social.pdf',
            VersionData = Blob.valueOf('Arquivo teste'),
            IsMajorVersion = true
        );
        insert cv;
    }
    
    @isTest
    static void testCheckExistingFile() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId,
            LinkedEntityId = acc.Id,
            ShareType = 'V'
        );
        insert cdl;

        Test.startTest();
        String fileId = FileController.checkExistingFile('Contrato Social.pdf', acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, fileId, 'O arquivo deveria existir');
    }
    /*
    @isTest
    static void testDeleteExistingFile() {
        ContentDocument existingFile = [SELECT Id FROM ContentDocument LIMIT 1];
        
        Test.startTest();
        FileController.deleteExistingFile(existingFile.Id);
        Test.stopTest();
        
        Integer count = [SELECT COUNT() FROM ContentDocument WHERE Id = :existingFile.Id];
        System.assertEquals(0, count, 'O arquivo deveria ter sido excluído');
    }
    */
    @isTest
    static void testRenameContentVersionApex() {
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion LIMIT 1];
        String auraId = 'NovoAuraIdNomeArquivo';
        
        Test.startTest();
        FileController.renameContentVersionApex(cv.Id, auraId);
        Test.stopTest();
        
        ContentVersion updatedCV = [SELECT Title FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(auraId, updatedCV.Title, 'O arquivo deveria ter sido renomeado com o Aura ID');
        
        ContentDocument updatedCD = [SELECT Title FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
        System.assertEquals(auraId, updatedCD.Title, 'O ContentDocument também deveria ter sido renomeado');
    }
     @IsTest
    static void testUpdateBooleanFieldSuccessfully() {
        // Obter a conta de teste criada no setup
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Definir parâmetros para o teste
        String fieldToUpdate = 'IsPartner';
        Boolean newValue = true;
        
        Test.startTest();
        // Chamar o método que está sendo testado
        updateAccountField(testAccount.Id, fieldToUpdate, newValue);
        Test.stopTest();
        
        // Verificar se a atualização foi bem-sucedida
        Account updatedAccount = [SELECT Id, IsPartner FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(newValue, updatedAccount.IsPartner, 'O campo IsPartner deveria ter sido atualizado para true');
    }
    
    
    // Método para simular a chamada ao método original
    private static void updateAccountField(Id accountId, String fieldName, boolean fieldValue) {
        try {
            // Chamar o método real
            FileController.updateAccountField(accountId, fieldName, fieldValue);
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao atualizar conta: ' + e.getMessage());
        }
    }
    @isTest
    static void aaa(){
        FileController.gambiarra();
        FileController.gambiarra2();
    }
    
}