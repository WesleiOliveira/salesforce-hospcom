@IsTest
public class AuditoriaQualidadeControllerTest {

    @IsTest
    static void testBuscarAuditoria() {
        // Criar dados de teste
        WorkOrder wo = new WorkOrder(
            Subject = 'Teste Auditoria',
            Status = 'New'
        );
        insert wo;

        // Atualizar com campos customizados que o método usa
        wo.Situacao_Auditoria__c = 'Conforme';
        wo.Data_Auditoria__c = Date.today();
        wo.Observacoes_Auditoria__c = 'Tudo certo';
        wo.Auditado__c = true;
        update wo;

        Test.startTest();
        // Chamar o método a ser testado
        SObject result = AuditoriaQualidadeController.buscarAuditoria(wo.Id);
        Test.stopTest();

        // Verificar se retornou o registro correto
        System.assertNotEquals(null, result);
        System.assertEquals(wo.Id, result.get('Id'));
        System.assertEquals('Conforme', result.get('Situacao_Auditoria__c'));
    }

    @IsTest
    static void testSalvarAuditoria() {
        WorkOrder wo = new WorkOrder(
            Subject = 'Teste Salvar Auditoria',
            Status = 'New'
        );
        insert wo;

        Test.startTest();
        // Chamar método para salvar auditoria
        AuditoriaQualidadeController.salvarAuditoria(
            wo.Id,
            'Não Conforme',
            'Apontado problema',
            Date.today(),
            false
        );
        Test.stopTest();

        // Consultar do banco para validar atualização
        WorkOrder updated = [SELECT Situacao_Auditoria__c, Data_Auditoria__c, Observacoes_Auditoria__c, Auditado__c 
                             FROM WorkOrder WHERE Id = :wo.Id];

        System.assertEquals('Não Conforme', updated.Situacao_Auditoria__c);
        System.assertEquals('Apontado problema', updated.Observacoes_Auditoria__c);
        System.assertEquals(false, updated.Auditado__c);
    }
}