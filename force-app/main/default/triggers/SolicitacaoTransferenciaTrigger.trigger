trigger SolicitacaoTransferenciaTrigger on Solicitacao_de_Tranferencia_Hospcoins__c (after update) {
    for (Solicitacao_de_Tranferencia_Hospcoins__c solicitacao : Trigger.new) {
        Solicitacao_de_Tranferencia_Hospcoins__c oldSolicitacao = Trigger.oldMap.get(solicitacao.Id);

        // Só processa quando o status muda para 'Aprovado'
        if (solicitacao.Status__c == 'Aprovado' && oldSolicitacao.Status__c != 'Aprovado') {
            System.debug('Solicitação aprovada: ' + solicitacao.Id);

            try {
                String idContato = solicitacao.Destinatario__c;
                String justificativa = solicitacao.Justificativa__c;
                String nome = solicitacao.Enviado_por__c;
                Id userId = solicitacao.Remetente__c;

                System.debug('Chamando método envia com:');
                System.debug('Destinatário: ' + idContato);
                System.debug('Justificativa: ' + justificativa);
                System.debug('Nome externo: ' + nome);

                programaValeu.envia(idContato, justificativa, nome, userId);

            } catch (Exception e) {
                System.debug('Erro ao chamar programaValeu.envia: ' + e.getMessage());
            }
        }
    }
}