@isTest
public class TarefaStatusMapTest {

    @isTest
    static void testTransicoesDeStatus() {
        // Criar tarefa inicial com status 'Não iniciado'
        Task t = new Task(
            Subject = 'Teste de Tarefa',
            Status = 'Não iniciado',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(1)
        );
        insert t;

        // -------- Transição 1: Não iniciado → Em andamento --------
        t.Status = 'Em andamento';
        update t;

        Task t1 = [SELECT Ultimo_Status__c FROM Task WHERE Id = :t.Id];
        System.assertEquals('Não iniciado', t1.Ultimo_Status__c, 'Deveria ter salvo o status anterior: Não iniciado');

        // -------- Transição 2: Em andamento → Aguardando outra pessoa --------
        t.Status = 'Aguardando outra pessoa';
        update t;

        Task t2 = [SELECT Ultimo_Status__c FROM Task WHERE Id = :t.Id];
        System.assertEquals('Em andamento', t2.Ultimo_Status__c, 'Deveria ter salvo o status anterior: Em andamento');

        // -------- Transição 3: Aguardando outra pessoa → Em andamento --------
        t.Status = 'Em andamento';
        update t;

        Task t3 = [SELECT Ultimo_Status__c FROM Task WHERE Id = :t.Id];
        System.assertEquals('Aguardando outra pessoa', t3.Ultimo_Status__c, 'Deveria ter salvo o status anterior: Aguardando outra pessoa');

        // -------- Transição 4: Em andamento → Concluído --------
        t.Status = 'Concluído';
        t.Data_da_Conclusao__c = Date.today();
        update t;

        Task t4 = [
            SELECT Status,
                   Inicio_andamento__c,
                   Tempo_de_execu_o__c,
                   Tempo_parado__c,
                   //Tempo_de_Conclus_o__c,
                   Ultimo_Status__c,
                   Data_e_Hora_de_In_cio__c
            FROM Task
            WHERE Id = :t.Id
        ];

        // -------- Validações finais -------- //
        System.assertEquals('Em andamento', t4.Ultimo_Status__c, 'Deveria ter salvo o status anterior à conclusão');
        System.assertNotEquals(null, t4.Data_e_Hora_de_In_cio__c, 'Data de início deve ser preenchida');
        //System.assertNotEquals(null, t4.Tempo_de_Conclus_o__c, 'Tempo de conclusão deve ser calculado');
        System.assert(t4.Tempo_de_execu_o__c != null && t4.Tempo_de_execu_o__c >= 0,
                      'Tempo de execução deve estar presente e ser não-negativo');
        System.assert(t4.Tempo_parado__c != null && t4.Tempo_parado__c >= 0,
                      'Tempo parado deve estar presente e ser não-negativo');
    }
}