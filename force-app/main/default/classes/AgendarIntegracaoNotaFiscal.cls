global class AgendarIntegracaoNotaFiscal implements Schedulable {
    global static void execute(SchedulableContext sc) {
        // Chame seu método de processamento de notas fiscais
        IntegracaoNotaFiscal.processarNotasFiscais();
        
        // Cancelar job existente se necessário
        deleteExistingScheduledJobs('ProcessarNotasFiscaisJob');
        
        // Reagendar para rodar daqui a 60 minutos
        Datetime agora = System.now();
        Datetime daqui10Minutos = agora.addMinutes(60);
        String cronExp = '0 ' + daqui10Minutos.minute() + ' ' + daqui10Minutos.hour() + ' ' + daqui10Minutos.day() + ' ' + daqui10Minutos.month() + ' ? ' + daqui10Minutos.year();
        
        // Reagendar o job
        System.schedule('ProcessarNotasFiscaisJob', cronExp, new AgendarIntegracaoNotaFiscal());
    }
    
    private static void deleteExistingScheduledJobs(String jobName) {
        List<CronTrigger> triggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        for (CronTrigger triggser : triggers) {
            System.abortJob(triggser.Id);
        }
    }
}