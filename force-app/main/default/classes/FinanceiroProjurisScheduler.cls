global class FinanceiroProjurisScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Chame seu método de processamento de notas fiscais
        FinanceiroProjuris.pesquisa();
        
        // Cancelar job existente se necessário
        deleteExistingScheduledJobs('Financeiro Projuris');
        
        // Reagendar para rodar daqui a 10 minutos
        Datetime agora = System.now();
        Datetime daqui10Minutos = agora.addMinutes(10);
        String cronExp = '0 ' + daqui10Minutos.minute() + ' ' + daqui10Minutos.hour() + ' ' + daqui10Minutos.day() + ' ' + daqui10Minutos.month() + ' ? ' + daqui10Minutos.year();
        
        // Reagendar o job
        System.schedule('Financeiro Projuris', cronExp, new FinanceiroProjurisScheduler());
    }
    
    private static void deleteExistingScheduledJobs(String jobName) {
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        for (CronTrigger cronTrigger : cronTriggers) {
            System.abortJob(cronTrigger.Id);
        }
    }
}