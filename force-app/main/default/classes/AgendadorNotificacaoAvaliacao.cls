global class AgendadorNotificacaoAvaliacao implements Schedulable {
    global void execute(SchedulableContext sc) {
        AvaliacaoExperienciaService.enviarNotificacoesGestor();
    }
}