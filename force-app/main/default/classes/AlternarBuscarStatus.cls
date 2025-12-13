global class AlternarBuscarStatus implements Schedulable {
    global void execute(SchedulableContext ctx) {
        // Buscar todos os registros com o campo Buscar__c = true
        List<Processo_Judicial__c> processosAtivos = [SELECT Id, Atualizacao_Buscar__c FROM Processo_Judicial__c WHERE Buscar__c = true LIMIT 1];
        
        // Cancelar job existente se necessário
        deleteExistingScheduledJobs('Alterna Buscar');
        
        // Desmarcar o registro atual, se houver
        if (!processosAtivos.isEmpty()) {
            Processo_Judicial__c registroAtual = processosAtivos[0];
            registroAtual.Buscar__c = false;
            update registroAtual;
        }
        
        // Buscar o próximo registro a ser ativado com base na última atualização
        Processo_Judicial__c proximoRegistro = [SELECT Id FROM Processo_Judicial__c ORDER BY Atualizacao_Buscar__c ASC LIMIT 1];
        
        // Definir o próximo registro como ativo
        if (proximoRegistro != null) {
            proximoRegistro.Buscar__c = true;
            proximoRegistro.Atualizacao_Buscar__c = System.now(); // Atualiza o campo de data/hora
            update proximoRegistro;
        }
        
        // Reagendar para rodar daqui a 10 minutos
        Datetime agora = System.now();
        Datetime daqui10Minutos = agora.addMinutes(10);
        String cronExp = '0 ' + daqui10Minutos.minute() + ' ' + daqui10Minutos.hour() + ' ' + daqui10Minutos.day() + ' ' + daqui10Minutos.month() + ' ? ' + daqui10Minutos.year();
        
        // Reagendar o job
        System.schedule('Alterna Buscar', cronExp, new AlternarBuscarStatus());
    }
    
    private static void deleteExistingScheduledJobs(String jobName) {
        List<CronTrigger> triggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        for (CronTrigger cronTrigger : triggers) {
            System.abortJob(cronTrigger.Id);
        }
    }
}