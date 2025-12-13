@IsTest
private class EvitaDuplicatasTriggerTest {

    @TestSetup
    static void setup() {
        // Cria uma despesa existente para simular duplicata
        Despesa__c despesaExistente = new Despesa__c(
            Valor__c = 1.00,
            Descricao__c = 'Almoço de negócios', 
            Motivo__c = 'teste1',
            Evento__c = '7015A000002Bv3pQAC', // Evite fixos em produção!
            Linha_da_Despesa__c = 'PMLS'
        );
        insert despesaExistente;
    }

    @IsTest
    static void deveBloquearDuplicata() {
        // Cria nova despesa igual à existente
        Despesa__c despesaDuplicada = new Despesa__c(
            Valor__c = 1.00,
            Descricao__c = 'Almoço de negócios',
            Motivo__c = 'teste1',
            Evento__c = '7015A000002Bv3pQAC', // Mesmo cuidado aqui
            Linha_da_Despesa__c = 'PMLS'
        );

        Test.startTest();
        try {
            insert despesaDuplicada;
            System.assert(false, 'A trigger deveria ter bloqueado a duplicata.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Já existe uma entrada de estoque com essa chave de integração.'),
                'Mensagem de erro inesperada: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void devePermitirDespesaDiferente() {
        // Cria uma despesa diferente (valor diferente)
        Despesa__c despesaNova = new Despesa__c(
            Valor__c = 2.00,
            Descricao__c = 'Jantar de negócios',
            Motivo__c = 'teste21',
            Evento__c = '7015A000002Bv3pQAC',
            Linha_da_Despesa__c = 'PMLS'
        );

        Test.startTest();
        insert despesaNova;
        Test.stopTest();

        System.assertEquals(
            2,
            [SELECT COUNT() FROM Despesa__c],
            'Deveria existir 2 despesas no total (1 existente + 1 nova válida).'
        );
    }
}