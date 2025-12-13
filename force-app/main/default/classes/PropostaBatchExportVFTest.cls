@isTest(seeAllData=true)
public class PropostaBatchExportVFTest {

   @isTest
    static void testBatch() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        PropostaBatchExportVF.isTestMode = true; // ativa simulação
        Database.executeBatch(new PropostaBatchExportVF(q.Id), 1);
        Test.stopTest();
        
        List<ContentVersion> cvs = [SELECT Id FROM ContentVersion WHERE Title LIKE :('Proposta_' + q.Id)];
        System.assert(!cvs.isEmpty(), 'Deveria ter criado um ContentVersion com o PDF da proposta');
        
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :q.Id];
        System.assert(!links.isEmpty(), 'Deveria ter vinculado o arquivo à Quote');
    }
}