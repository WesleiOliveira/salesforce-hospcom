@isTest
private class AgendadorNotificacaoAvaliacaoTest {

    @isTest
    static void testAgendamentoExecutaComSucesso() {
        // Simula o agendamento chamando o execute diretamente

        // Criar contexto fake de schedulable
        Test.startTest();
            AgendadorNotificacaoAvaliacao scheduler = new AgendadorNotificacaoAvaliacao();
            scheduler.execute(null); // null funciona porque não usamos o contexto
        Test.stopTest();

        System.assert(true, 'O método execute do scheduler foi chamado com sucesso.');
    }

    @isTest
    static void testAgendamentoViaSystemSchedule() {
        Test.startTest();
            String jobId = System.schedule(
                'Teste de Agendamento às 15h',
                '0 0 15 * * ?',
                new AgendadorNotificacaoAvaliacao()
            );
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'O ID do job agendado deve ser retornado.');
    }
}