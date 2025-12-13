@isTest
public class PSQ_Test {
    @isTest
    static void testTriggerPSQ() {
        // Busca dois usuários ativos
        List<User> usuarios = [
            SELECT Id 
            FROM User 
            WHERE IsActive = true 
            LIMIT 2
        ];

        // Garante que tem pelo menos 2 usuários no org de teste
        System.assert(usuarios.size() >= 2, 'Precisa de pelo menos 2 usuários ativos no org de teste');

        User u1 = usuarios[0];
        User u2 = usuarios[1];

        // Registro inicial
        PSQ__c procedimento = new PSQ__c(
            Name = 'Procedimento Teste',
            Status__c = 'Revisão',
            Elaborador__c = u1.Id,
            Revisor__c = u2.Id
        );
        insert procedimento;

        //  Testa de Revisão → Elaboração
        procedimento.Status__c = 'Elaboração';
        update procedimento;

        // Volta para Aprovação para preparar próximo cenário
        procedimento.Status__c = 'Aprovação';
        update procedimento;

        //  Testa de Aprovação → Revisão
        procedimento.Status__c = 'Revisão';
        update procedimento;

        //  Testa de Revisão → Aprovação (aprovação do registro)
        procedimento.Status__c = 'Aprovação';
        update procedimento;
    }
}