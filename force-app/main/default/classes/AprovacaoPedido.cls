public without sharing class AprovacaoPedido {
    
    @AuraEnabled
    public static void aprovaPedido(String workItemId, String comentario) {
        // Consulta todos os aprovadores relacionados ao item de trabalho de aprovação
        List<ProcessInstanceWorkitem> aprovadores = [SELECT ActorId FROM ProcessInstanceWorkitem WHERE Id = :workItemId];
        
        // Verifica se o usuário atual é um dos aprovadores ou se é um Administrador do Sistema
        Boolean autorizado = isUsuarioAutorizado(aprovadores);
        
        if (!autorizado) {
            throw new AuraHandledException('Usuário não autorizado a aprovar este pedido.');
        }
        
        // Processa a aprovação
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setWorkitemId(workItemId);
        req.setAction('Approve');
        req.setComments(comentario);
        requests.add(req);
        
        try {
            Approval.ProcessResult[] processResults = Approval.process(requests);
            // Verifica o resultado da aprovação
            for (Approval.ProcessResult result : processResults) {
                if (result.isSuccess()) {
                    // Lógica para sucesso (opcional)
                } else {
                    throw new AuraHandledException('Erro ao aprovar o pedido: ' + result.getErrors().get(0).getMessage());
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao processar a aprovação: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void rejeitaPedido(String workItemId, String comentario, String motivo, String idPedido) {
        // Consulta todos os aprovadores relacionados ao item de trabalho de aprovação
        List<ProcessInstanceWorkitem> aprovadores = [SELECT ActorId FROM ProcessInstanceWorkitem WHERE Id = :workItemId];
        
        // Verifica se o usuário atual é um dos aprovadores ou se é um Administrador do Sistema
        Boolean autorizado = isUsuarioAutorizado(aprovadores);
        
        if (!autorizado) {
            throw new AuraHandledException('Usuário não autorizado a reprovar este pedido.');
        }
        
        // Atualiza o campo Motivo do pedido
        Order pedido = [SELECT ID, Motivo__c FROM Order WHERE ID = :idPedido];
        pedido.Motivo__c = motivo;
        
        try {
            update pedido;
            
            // Processa a rejeição
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItemId);
            req.setAction('Reject');
            req.setComments(comentario);
            requests.add(req);
            
            Approval.ProcessResult[] processResults = Approval.process(requests);
            // Verifica o resultado da rejeição
            for (Approval.ProcessResult result : processResults) {
                if (result.isSuccess()) {
                    // Lógica para sucesso (opcional)
                } else {
                    throw new AuraHandledException('Erro ao reprovar o pedido: ' + result.getErrors().get(0).getMessage());
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao processar a rejeição: ' + e.getMessage());
        }
    }

    // Método que verifica se o usuário é um dos aprovadores ou se é um Administrador do Sistema
    public static Boolean isUsuarioAutorizado(List<ProcessInstanceWorkitem> aprovadores) {
        Boolean autorizado = false;

        // Verifica se o usuário logado é um dos aprovadores
        Set<Id> aprovadoresIds = new Set<Id>();
        for (ProcessInstanceWorkitem aprovador : aprovadores) {
            aprovadoresIds.add(aprovador.ActorId);
        }

        // Verifica se o usuário atual está entre os aprovadores
        if (aprovadoresIds.contains(UserInfo.getUserId())) {
            autorizado = true;
        }

        // Verifica se o usuário logado possui o perfil de "Administrador do sistema"
        if (!autorizado) {
            List<Profile> perfis = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' LIMIT 1];
            if (!perfis.isEmpty() && UserInfo.getProfileId() == perfis[0].Id) {
                autorizado = true;
            }
        }

        return autorizado;
    }
}