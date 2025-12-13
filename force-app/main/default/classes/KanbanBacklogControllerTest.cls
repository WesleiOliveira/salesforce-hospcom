@IsTest
private class KanbanBacklogControllerTest {

    // Método auxiliar para criar registros de backlog
    private static Backlog__c criarBacklog(String status, String atividade) {
        Backlog__c b = new Backlog__c();
        b.Status__c = status;
        b.Atividade__c = atividade;
        return b;
    }

    @IsTest
    static void testGetBacklog() {
        // Cria registros de backlog
        List<Backlog__c> tickets = new List<Backlog__c>{
            criarBacklog('Novo', 'Ticket 1'),
            criarBacklog('Em Desenvolvimento', 'Ticket 2')
        };
        insert tickets;

        Test.startTest();
        List<Backlog__c> result = KanbanBacklogController.getBacklog();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deveria retornar registros de backlog');
        System.assertNotEquals(null, result[0].Id, 'O registro deveria ter Id preenchido');
    }

    @IsTest
    static void testUpdateStatus() {
        // Cria um registro de backlog
        Backlog__c ticket = criarBacklog('Novo', 'Ticket Teste');
        insert ticket;

        Test.startTest();
        KanbanBacklogController.updateStatus(ticket.Id, 'Finalizado');
        Test.stopTest();

        // Reconsulta para validar
        Backlog__c atualizado = [SELECT Id, Status__c FROM Backlog__c WHERE Id = :ticket.Id];
        System.assertEquals('Finalizado', atualizado.Status__c, 'O status deveria ter sido atualizado para Finalizado');
    }
}