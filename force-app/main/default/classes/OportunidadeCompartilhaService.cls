public without sharing class OportunidadeCompartilhaService {

    public static void replicaShares(List<Opportunity> novasOpps) {
        Set<Id> oportunidadesId = new Map<Id, Opportunity>(novasOpps).keySet();

        // --- Consultas ---
        List<OpportunityTeamMember> membrosOpp = [
            SELECT OpportunityId, UserId, OpportunityAccessLevel
            FROM OpportunityTeamMember
            WHERE OpportunityId IN :oportunidadesId
            AND User.IsActive = true
            AND OpportunityAccessLevel IN ('Read','Edit')
        ];

        List<Demonstracao__c> demos = [
            SELECT Id, Oportunidade__c, OwnerId, Departamento__c,
                   (SELECT Id FROM Shares WHERE RowCause = 'Manual')
            FROM Demonstracao__c
            WHERE Oportunidade__c IN :oportunidadesId
        ];

        List<Order> pedidos = [
            SELECT Id, OpportunityId, Demonstracao__r.Oportunidade__c, OwnerId, Departamento3__c,
                   (SELECT Id FROM Shares WHERE RowCause = 'Manual')
            FROM Order
            WHERE (OpportunityId IN :oportunidadesId OR Demonstracao__r.Oportunidade__c IN :oportunidadesId)
            AND Status NOT IN ('Entregue Total')
        ];

        List<Faturamento__c> fats = [
            SELECT Id, Pedido__r.OpportunityId, Pedido__r.Demonstracao__r.Oportunidade__c, OwnerId, Departamento3__c,
                   (SELECT Id FROM Shares WHERE RowCause = 'Manual')
            FROM Faturamento__c
            WHERE Pedido__r.OpportunityId IN :oportunidadesId
               OR Pedido__r.Demonstracao__r.Oportunidade__c IN :oportunidadesId
        ];

        // --- Agrupar registros por Opp ---
        Map<Id, List<Demonstracao__c>> mapDemos = new Map<Id, List<Demonstracao__c>>();
        for (Demonstracao__c d : demos) {
            if(!mapDemos.containsKey(d.Oportunidade__c)){
                mapDemos.put(d.Oportunidade__c, new List<Demonstracao__c>());
            }
            mapDemos.get(d.Oportunidade__c).add(d);
        }

        Map<Id, List<Order>> mapPedidos = new Map<Id, List<Order>>();
        for (Order o : pedidos) {
            Id chave = o.OpportunityId != null ? o.OpportunityId : o.Demonstracao__r.Oportunidade__c;
            if(chave != null){
                if(!mapPedidos.containsKey(chave)){
                    mapPedidos.put(chave, new List<Order>());
                }
                mapPedidos.get(chave).add(o);
            }
        }

        Map<Id, List<Faturamento__c>> mapFats = new Map<Id, List<Faturamento__c>>();
        for (Faturamento__c f : fats) {
            Id chave = f.Pedido__r.OpportunityId != null ? f.Pedido__r.OpportunityId : f.Pedido__r.Demonstracao__r.Oportunidade__c;
            if(chave != null){
                if(!mapFats.containsKey(chave)){
                    mapFats.put(chave, new List<Faturamento__c>());
                }
                mapFats.get(chave).add(f);
            }
        }

        // --- Acumular DML ---
        List<Demonstracao__Share> demoDelete = new List<Demonstracao__Share>();
        List<OrderShare> pedDelete = new List<OrderShare>();
        List<Faturamento__Share> fatDelete = new List<Faturamento__Share>();

        List<Demonstracao__Share> demoInsert = new List<Demonstracao__Share>();
        List<OrderShare> pedInsert = new List<OrderShare>();
        List<Faturamento__Share> fatInsert = new List<Faturamento__Share>();

        // Coletar shares existentes
        for(Demonstracao__c d : demos) demoDelete.addAll(d.Shares);
        for(Order p : pedidos) pedDelete.addAll(p.Shares);
        for(Faturamento__c f : fats) fatDelete.addAll(f.Shares);

        // Montar novos shares com acesso direto via Map
        for(Opportunity opp : novasOpps){
            for(OpportunityTeamMember m : membrosOpp){
                if(m.OpportunityId == opp.Id && opp.OwnerId != m.UserId){

                    // Demonstracoes
                    if(mapDemos.containsKey(opp.Id)){
                        for(Demonstracao__c d : mapDemos.get(opp.Id)){
                            d.OwnerId = opp.OwnerId;
                            d.Departamento__c = opp.Departamento__c;
                            demoInsert.add(new Demonstracao__Share(
                                ParentId = d.Id,
                                UserOrGroupId = m.UserId,
                                AccessLevel = m.OpportunityAccessLevel
                            ));
                        }
                    }

                    // Pedidos
                    if(mapPedidos.containsKey(opp.Id)){
                        for(Order p : mapPedidos.get(opp.Id)){
                            p.OwnerId = opp.OwnerId;
                            p.Departamento3__c = opp.Departamento__c;
                            pedInsert.add(new OrderShare(
                                OrderId = p.Id,
                                UserOrGroupId = m.UserId,
                                OrderAccessLevel = m.OpportunityAccessLevel
                            ));
                        }
                    }

                    // Faturamentos
                    if(mapFats.containsKey(opp.Id)){
                        for(Faturamento__c f : mapFats.get(opp.Id)){
                            f.OwnerId = opp.OwnerId;
                            f.Departamento3__c = opp.Departamento__c;
                            fatInsert.add(new Faturamento__Share(
                                ParentId = f.Id,
                                UserOrGroupId = m.UserId,
                                AccessLevel = m.OpportunityAccessLevel
                            ));
                        }
                    }
                }
            }
        }

        // --- Executar DML em bloco ---
        Util.AcaoInterna(true);
        if(!demoDelete.isEmpty()) delete demoDelete;
        if(!pedDelete.isEmpty()) delete pedDelete;
        if(!fatDelete.isEmpty()) delete fatDelete;

        if(!demos.isEmpty()) update demos;
        if(!pedidos.isEmpty()) update pedidos;
        if(!fats.isEmpty()) update fats;

        if(!demoInsert.isEmpty()) insert demoInsert;
        if(!pedInsert.isEmpty()) insert pedInsert;
        if(!fatInsert.isEmpty()) insert fatInsert;
        Util.AcaoInterna(false);
    }

    public static void validaExclusao(List<Opportunity> oldOpps) {
        Set<Id> ids = new Map<Id, Opportunity>(oldOpps).keySet();
        List<Opportunity> opps = [
            SELECT Id,
                   (SELECT Id FROM Orders),
                   (SELECT Id FROM Demonstracoes__r)
            FROM Opportunity
            WHERE Id IN :ids
        ];

        Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>(opps);

        for(Opportunity trg : oldOpps){
            Opportunity full = mapOpps.get(trg.Id);
            if(full != null){
                if(full.Orders.size() > 0){
                    trg.addError('Não é possível excluir uma oportunidade com pedidos vinculados.');
                }
                if(full.Demonstracoes__r.size() > 0){
                    trg.addError('Não é possível excluir uma oportunidade com demonstrações vinculadas.');
                }
            }
        }
    }
}