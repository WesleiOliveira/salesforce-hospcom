public class TarefasControlador {
    
    // Método que recebe um mês de referência e atualiza registros
    @AuraEnabled
    public static void atualizarTarefasPorMes(String mesReferencia) {
        // Verifica se o mês de referência é nulo
        if (mesReferencia == null) {
            throw new IllegalArgumentException('O mês de referência não pode ser nulo.');
        }
        
        // Consulta os registros do objeto Task com os critérios especificados
        List<Task> tarefasParaAtualizar = [
            SELECT Id, Per_odo_fechado__c
            FROM Task
            WHERE mes_referencia__c = :mesReferencia
              AND meta__c = TRUE
              AND Per_odo_fechado__c = FALSE
        ];
        
        // Atualiza o campo Per_odo_fechado__c para TRUE
        for (Task tarefa : tarefasParaAtualizar) {
            tarefa.Per_odo_fechado__c = TRUE;
        }
        
        // Realiza a atualização no banco de dados
        if (!tarefasParaAtualizar.isEmpty()) {
            update tarefasParaAtualizar;
        }
    }
}