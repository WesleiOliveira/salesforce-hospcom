global class DistribuicoesProjurisScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Chame seu método de processamento de notas fiscais
        DistribuicoesProjuris.pesquisa();
        
        // Cancelar job existente se necessário
        deleteExistingScheduledJobs('Distribuições Projuris');
        
        // Reagendar para rodar daqui a 90 minutos
        Datetime agora = System.now();
        Datetime daqui90Minutos = agora.addMinutes(90);
        String cronExp = '0 ' + daqui90Minutos.minute() + ' ' + daqui90Minutos.hour() + ' ' + daqui90Minutos.day() + ' ' + daqui90Minutos.month() + ' ? ' + daqui90Minutos.year();
        
        // Reagendar o job
        System.schedule('Distribuições Projuris', cronExp, new DistribuicoesProjurisScheduler());
    }
    
    private static void deleteExistingScheduledJobs(String jobName) {
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        for (CronTrigger cronTrigger : cronTriggers) {
            System.abortJob(cronTrigger.Id);
        }
    }
}