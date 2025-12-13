@IsTest
private class DashboardBacklogControllerTest {

    // Método auxiliar para criar registros de teste
    private static Backlog__c criarBacklog(String status, String origem, DateTime criadoEm, DateTime finalizadoEm, String atividade, Id contatoId) {
        Backlog__c b = new Backlog__c();
        b.Status__c = status;
        b.Origem__c = origem;
        b.Ticket_Criado_Em__c = criadoEm;
        b.Ticket_Finalizado_Em__c = finalizadoEm;
        b.Atividade__c = atividade;
        b.Atribuido__c = contatoId;
        return b;
    }

    @IsTest
    static void testGetDashboardData() {
        // Criar um contato para relacionar
        Contact c = new Contact(FirstName = 'User',LastName = 'Teste');
        insert c;

        // Criar registros de Backlog
        List<Backlog__c> registros = new List<Backlog__c>();

        registros.add(criarBacklog('Novo', 'Salesforce', DateTime.now().addDays(-1), null, 'Ticket Novo', c.Id));
        registros.add(criarBacklog('Em Desenvolvimento', 'Salesforce', DateTime.now().addDays(-2), null, 'Ticket Em Andamento', c.Id));
        registros.add(criarBacklog('Finalizado', 'Chatwoot', DateTime.now().addDays(-10), DateTime.now().addDays(-1), 'Ticket Finalizado 1', c.Id));
        registros.add(criarBacklog('Finalizado', 'Chatwoot', DateTime.now().addDays(-15), DateTime.now().addDays(-2), 'Ticket Finalizado 2', c.Id));
        registros.add(criarBacklog('Novo', 'Chatwoot', DateTime.now().addDays(-3), null, 'Ticket Chatwoot', c.Id));

        insert registros;

        Test.startTest();
        DashboardBacklogController.DashboardDTO dto = DashboardBacklogController.getDashboardData();
        Test.stopTest();

        // Validações
        System.assertNotEquals(null, dto, 'DTO não deveria ser nulo');
        System.assertEquals(2, dto.totalAbertos, 'Deveria ter 2 tickets em status "Novo"');
        System.assertEquals(1, dto.totalEmAndamento, 'Deveria ter 1 ticket em andamento');
        System.assertEquals(3, dto.ticketsRapidos, 'Deveria ter 3 tickets de origem Chatwoot');
        System.assertEquals(2, dto.totalFinalizados, 'Deveria ter 2 tickets finalizados');

        System.assert(dto.recentes.size() > 0, 'Deveria ter feedbacks recentes');
        System.assert(dto.finalizados.size() > 0, 'Deveria ter feedbacks finalizados');

        System.assert(dto.chartData.size() > 0, 'Deveria ter dados no gráfico de finalizados');
        System.assert(dto.chartDataStatus.size() > 0, 'Deveria ter dados no gráfico por status');
    }
}