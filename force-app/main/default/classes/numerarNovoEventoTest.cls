@isTest
public class numerarNovoEventoTest {

    @isTest
    static void testTriggerComEventoDeTreinamento() {
        // Cria eventos já existentes
        List<Campaign> eventosExistentes = new List<Campaign>();
        for (Integer i = 0; i < 2; i++) {
            eventosExistentes.add(new Campaign(
                Name = 'Treinamento Existente ' + i,
                treinamento__c = true
            ));
        }
        insert eventosExistentes;

        // Cria um novo evento que deve acionar o trigger
        Campaign novoEvento = new Campaign(
            Name = 'Novo Evento Teste',
            treinamento__c = true
        );

        insert novoEvento;

        // Reconsulta para verificar se o campo foi preenchido
        Campaign eventoInserido = [SELECT Contagem_Eventos_de_Treinamento__c FROM Campaign WHERE Id = :novoEvento.Id];

        // Deve ser '0003' já que havia dois eventos antes
        System.assertEquals('0003', eventoInserido.Contagem_Eventos_de_Treinamento__c);
    }

    @isTest
    static void testTriggerIgnoraEventoNaoTreinamento() {
        Campaign eventoNormal = new Campaign(
            Name = 'Evento Normal',
            treinamento__c = false
        );

        insert eventoNormal;

        Campaign result = [SELECT Contagem_Eventos_de_Treinamento__c FROM Campaign WHERE Id = :eventoNormal.Id];
        System.assertEquals(null, result.Contagem_Eventos_de_Treinamento__c);
    }
}