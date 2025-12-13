@isTest
public class AuditoriaEstrSemTest {

    static testMethod void testInsertComNCsemDescricao() {
        Auditoria_Estrutural_Semanal__c audit = new Auditoria_Estrutural_Semanal__c();
        audit.pergunta1__c = 'NC'; // descrição d1__c obrigatória

        Test.startTest();
        try {
            insert audit;
            System.assert(false, 'Deveria ter lançado erro de validação');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('A descrição é obrigatória'));
        }
        Test.stopTest();
    }

    static testMethod void testInsertComNCcomDescricao() {
        Auditoria_Estrutural_Semanal__c audit = new Auditoria_Estrutural_Semanal__c();
        audit.pergunta1__c = 'NC';
        audit.d1__c = 'Descrição correta';

        Test.startTest();
        insert audit;
        Test.stopTest();

        System.assertNotEquals(null, audit.Id, 'Registro deveria ter sido inserido');
    }

    static testMethod void testUpdateComNCsemAnexo() {
        Auditoria_Estrutural_Semanal__c audit = new Auditoria_Estrutural_Semanal__c();
        audit.pergunta1__c = 'C';
        insert audit;

        // Atualiza para NC, mas sem anexos
        audit.pergunta1__c = 'NC';
        audit.d1__c = 'Descrição';

        Test.startTest();
        try {
            update audit;
            System.assert(false, 'Deveria ter lançado erro de anexo obrigatório');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('É obrigatório anexar uma imagem'));
        }
        Test.stopTest();
    }

    static testMethod void testUpdateComNCcomAnexo() {
        Auditoria_Estrutural_Semanal__c audit = new Auditoria_Estrutural_Semanal__c();
        audit.pergunta1__c = 'C';
        insert audit;

        // Simula anexo
        ContentVersion cv = new ContentVersion(
            Title = 'Imagem',
            PathOnClient = 'imagem.jpg',
            VersionData = Blob.valueOf('arquivo'),
            IsMajorVersion = true
        );
        insert cv;

        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = audit.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Atualiza para NC com descrição
        audit.pergunta1__c = 'NC';
        audit.d1__c = 'Tem anexo agora';

        Test.startTest();
        update audit;
        Test.stopTest();

        System.assert(true, 'Atualização com anexo passou corretamente');
    }
}