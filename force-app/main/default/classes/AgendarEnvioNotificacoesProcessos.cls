global class AgendarEnvioNotificacoesProcessos implements Schedulable {
    global void execute(SchedulableContext sc) {
        NotificacaoProcessos.enviarNotificacoes();
    }
}