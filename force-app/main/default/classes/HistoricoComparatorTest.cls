@isTest
public class HistoricoComparatorTest {
    @isTest
    public static void testHistoricoComparator() {
        // Criar registros de exemplo
        HISTORICO_DE_REVISAO__c record1 = new HISTORICO_DE_REVISAO__c();
        record1.Item__c = 'Item 1';
        record1.Natureza_da_Alteracao__c = 'Alteração 1';
        record1.Data__c = Date.valueOf('2023-10-01');
        
        HISTORICO_DE_REVISAO__c record2 = new HISTORICO_DE_REVISAO__c();
        record2.Item__c = 'Item 2';
        record2.Natureza_da_Alteracao__c = 'Alteração 2';
        record2.Data__c = Date.valueOf('2023-10-03');

        // Crie uma lista de registros
        List<HistoricoComparator> records = new List<HistoricoComparator>();
        records.add(new HistoricoComparator(record1));
        records.add(new HistoricoComparator(record2));

        // Ordene os registros
        records.sort();

        // Verifique se os registros estão na ordem correta
        System.assertEquals('Item 1', records[0].historicalRecord.Item__c);
        System.assertEquals('Alteração 1', records[0].historicalRecord.Natureza_da_Alteracao__c);
        System.assertEquals(Date.valueOf('2023-10-01'), records[0].historicalRecord.Data__c);

        System.assertEquals('Item 2', records[1].historicalRecord.Item__c);
        System.assertEquals('Alteração 2', records[1].historicalRecord.Natureza_da_Alteracao__c);
        System.assertEquals(Date.valueOf('2023-10-03'), records[1].historicalRecord.Data__c);
    }
}