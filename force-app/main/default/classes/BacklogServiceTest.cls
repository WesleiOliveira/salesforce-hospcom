@isTest
public class BacklogServiceTest {

    @testSetup
    static void createData() {
        // Cria alguns registros de Backlog__c para os testes
        List<Backlog__c> backlogs = new List<Backlog__c>();
        for (Integer i = 0; i < 3; i++) {
            backlogs.add(new Backlog__c(
                Status__c = 'Novo',
                Data_Estimada_de_T_rmino__c = Date.today().addDays(1)
            ));
        }
        insert backlogs;
    }

    @isTest
    static void testAtualizaDataAbertura() {
        // Recupera registros criados no @testSetup
        List<Backlog__c> tickets = [SELECT Id, Ticket_Criado_Em__c FROM Backlog__c];

        // Executa o método
        Test.startTest();
        BacklogService.atualizaDataAbertura(tickets);
        Test.stopTest();

        // Verifica se os valores foram preenchidos
        for (Backlog__c b : tickets) {
            System.assertNotEquals(null, b.Ticket_Criado_Em__c, 'Data de abertura deveria ter sido preenchida');
        }
    }

    @isTest
    static void testAtualizaDataFinalizacao() {
          // Recupera registros criados no @testSetup
        List<Backlog__c> tickets = [SELECT Id, Status__c, Ticket_Finalizado_Em__c FROM Backlog__c];

        // Cria cópia representando os "velhosTickets" (estado anterior)
        Map<Id, Backlog__c> velhosTickets = new Map<Id, Backlog__c>();
        for (Backlog__c b : tickets) {
            Backlog__c oldB = new Backlog__c(
                Id = b.Id,
                Status__c = b.Status__c
            );
            velhosTickets.put(b.Id, oldB);
        }

        // Atualiza um para "Finalizado"
        tickets[0].Status__c = 'Finalizado';

        Test.startTest();
        BacklogService.atualizaDataFinalizacao(tickets, velhosTickets);
        Test.stopTest();

        // Verifica se apenas o finalizado teve a data setada
        System.assertNotEquals(null, tickets[0].Ticket_Finalizado_Em__c, 'Deveria ter preenchido data de finalização');
        for (Integer i = 1; i < tickets.size(); i++) {
            System.assertEquals(null, tickets[i].Ticket_Finalizado_Em__c, 'Somente o primeiro deveria ser atualizado');
        }
    }

    @IsTest
    static void testAtualizadaHorasEstimadas() {
        // Busca registros criados no setup
        List<Backlog__c> tickets = [SELECT Id, Ticket_Criado_Em__c, Data_Estimada_de_T_rmino__c, Tempo_de_Execucao__c 
                                    FROM Backlog__c];
        
        Test.startTest();
        BacklogService.atualizadaHorasEstimadas(tickets);
        Test.stopTest();
    }
  
}