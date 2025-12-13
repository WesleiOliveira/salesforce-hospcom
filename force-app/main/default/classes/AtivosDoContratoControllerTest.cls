@IsTest(seeAllData=true)
public class AtivosDoContratoControllerTest {
    @IsTest
    static void testGetAtivosByContratoId() {
        Id contratoId = 'a1Y6e00000C3V6I';
        
        // Executa o método getAtivosByContratoId
        List<Ativos_do_Contrato__c> ativos = AtivosDoContratoController.getAtivosByContratoId(contratoId);
        
        // Verifica se a lista de ativos não está vazia
        System.assertNotEquals(0, ativos.size(), 'A lista de ativos deve conter registros.');
    }
    
    @IsTest
    static void testUpdateEquipamentoStatus() {
        List<Id> ativoIds = new List<Id>{'a1h6e00000GnzVB', 'a1hU4000000BZnF'};
        Boolean status = true;
        Date dataEntregaOuRetorno = Date.today();
        
        // Executa o método updateEquipamentoStatus para marcar os ativos como entregues
        AtivosDoContratoController.updateEquipamentoStatus(ativoIds, status, dataEntregaOuRetorno);
        
        // Verifica se os ativos foram atualizados corretamente
        List<Ativos_do_Contrato__c> ativosAtualizados = [SELECT Id, Equipamento_no_Cliente__c, Data_de_entrega__c, Data_de_retorno__c
                                                         FROM Ativos_do_Contrato__c
                                                         WHERE Id IN :ativoIds];
        
        for (Ativos_do_Contrato__c ativo : ativosAtualizados) {
            System.assertEquals(status, ativo.Equipamento_no_Cliente__c, 'O status do equipamento no cliente deve ser true.');
            //System.assertEquals(dataEntregaOuRetorno, ativo.Data_de_entrega__c, 'A data de entrega deve ser hoje.');
            //System.assertEquals(null, ativo.Data_de_retorno__c, 'A data de retorno deve ser null.');
        }

        // Executa o método updateEquipamentoStatus para marcar os ativos como removidos
        status = false;
        AtivosDoContratoController.updateEquipamentoStatus(ativoIds, status, dataEntregaOuRetorno);

        // Verifica se os ativos foram atualizados corretamente
        ativosAtualizados = [SELECT Id, Equipamento_no_Cliente__c, Data_de_entrega__c, Data_de_retorno__c
                             FROM Ativos_do_Contrato__c
                             WHERE Id IN :ativoIds];

        for (Ativos_do_Contrato__c ativo : ativosAtualizados) {
            System.assertEquals(status, ativo.Equipamento_no_Cliente__c, 'O status do equipamento no cliente deve ser false.');
            //System.assertEquals(null, ativo.Data_de_entrega__c, 'A data de entrega deve ser null.');
            System.assertEquals(dataEntregaOuRetorno, ativo.Data_de_retorno__c, 'A data de retorno deve ser hoje.');
        }
    }
    @isTest
    public static void testSubstituirAtivo() {
        // Prepara os dados de teste
        Id ativoId = 'a1h6e00000GnzVB';
        String novoNumeroDeSerie = 'KJ6T35019055';
        Date dataSubstituicao = Date.today();

        Test.startTest();
        AtivosDoContratoController.substituirAtivo(ativoId, novoNumeroDeSerie, dataSubstituicao);
        Test.stopTest();

    }
}