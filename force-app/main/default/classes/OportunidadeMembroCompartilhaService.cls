public without sharing class OportunidadeMembroCompartilhaService {

    public static void executar(Boolean isInsert, Boolean isUpdate, Boolean isDelete, List<OpportunityTeamMember> membros) {
        if (membros == null || membros.isEmpty()) return;

        // opp -> { userId -> level ('Read'/'Edit') }
        Map<Id, Map<Id, String>> oppToUserLevel = new Map<Id, Map<Id, String>>();
        // opp -> users afetados (para DELETE)
        Map<Id, Set<Id>> oppToUsersAll = new Map<Id, Set<Id>>();

        // Coleta dos membros
        for (OpportunityTeamMember m : membros) {
            if (m.OpportunityId == null || m.UserId == null) continue;

            if (!oppToUsersAll.containsKey(m.OpportunityId)) {
                oppToUsersAll.put(m.OpportunityId, new Set<Id>());
            }
            oppToUsersAll.get(m.OpportunityId).add(m.UserId);

            if ((isInsert || isUpdate) && (m.OpportunityAccessLevel == 'Read' || m.OpportunityAccessLevel == 'Edit')) {
                if (!oppToUserLevel.containsKey(m.OpportunityId)) {
                    oppToUserLevel.put(m.OpportunityId, new Map<Id, String>());
                }
                oppToUserLevel.get(m.OpportunityId).put(m.UserId, m.OpportunityAccessLevel);
            }
        }
        if (oppToUsersAll.isEmpty()) return;

        Set<Id> oppIds = new Set<Id>(oppToUsersAll.keySet());
        Set<Id> allUsers = new Set<Id>();
        for (Set<Id> s : oppToUsersAll.values()) allUsers.addAll(s);

        // =========================
        // 1) SOQL (apenas 3 consultas)
        // =========================
        List<Demonstracao__c> demos = [
            SELECT Id, Oportunidade__c, OwnerId,
                   (SELECT Id, UserOrGroupId, RowCause, AccessLevel
                    FROM Shares
                    WHERE RowCause = 'Manual' AND UserOrGroupId IN :allUsers)
            FROM Demonstracao__c
            WHERE Oportunidade__c IN :oppIds
        ];

        List<Order> pedidos = [
            SELECT Id, OpportunityId, Demonstracao__r.Oportunidade__c, OwnerId,
                   (SELECT Id, UserOrGroupId, RowCause, OrderAccessLevel
                    FROM Shares
                    WHERE RowCause = 'Manual' AND UserOrGroupId IN :allUsers)
            FROM Order
            WHERE OpportunityId IN :oppIds
               OR Demonstracao__r.Oportunidade__c IN :oppIds
        ];

        List<Faturamento__c> faturamentos = [
            SELECT Id, OwnerId,
                   Pedido__r.OpportunityId,
                   Pedido__r.Demonstracao__r.Oportunidade__c,
                   (SELECT Id, UserOrGroupId, RowCause, AccessLevel
                    FROM Shares
                    WHERE RowCause = 'Manual' AND UserOrGroupId IN :allUsers)
            FROM Faturamento__c
            WHERE Pedido__r.OpportunityId IN :oppIds
               OR Pedido__r.Demonstracao__r.Oportunidade__c IN :oppIds
        ];

        // =========================
        // 2) DML collections
        // =========================
        List<Demonstracao__Share> demoInserts = new List<Demonstracao__Share>();
        List<Demonstracao__Share> demoUpdates = new List<Demonstracao__Share>();
        List<Demonstracao__Share> demoDeletes = new List<Demonstracao__Share>();

        List<OrderShare> orderInserts = new List<OrderShare>();
        List<OrderShare> orderUpdates = new List<OrderShare>();
        List<OrderShare> orderDeletes = new List<OrderShare>();

        List<Faturamento__Share> fatInserts = new List<Faturamento__Share>();
        List<Faturamento__Share> fatUpdates = new List<Faturamento__Share>();
        List<Faturamento__Share> fatDeletes = new List<Faturamento__Share>();

        // =========================
        // 3) Montagem - DEMONSTRACAO__c
        // =========================
        for (Demonstracao__c d : demos) {
            Set<Id> usersAll = oppToUsersAll.get(d.Oportunidade__c);
            Map<Id, String> usersLevels = oppToUserLevel.get(d.Oportunidade__c);

            Map<Id, Demonstracao__Share> existing = new Map<Id, Demonstracao__Share>();
            for (SObject sob : d.Shares) {
                Demonstracao__Share sh = (Demonstracao__Share)sob;
                existing.put(sh.UserOrGroupId, sh);
            }

            if (isDelete && usersAll != null && !usersAll.isEmpty()) {
                for (Id uid : usersAll) {
                    Demonstracao__Share ex = existing.get(uid);
                    if (ex != null) demoDeletes.add(new Demonstracao__Share(Id = ex.Id));
                }
            }

            if ((isInsert || isUpdate) && usersLevels != null && !usersLevels.isEmpty()) {
                for (Id uid : usersLevels.keySet()) {
                    if (uid == d.OwnerId) continue;
                    String desired = usersLevels.get(uid); // 'Read' ou 'Edit'
                    Demonstracao__Share ex = existing.get(uid);
                    if (ex == null) {
                        Demonstracao__Share sh = new Demonstracao__Share();
                        sh.ParentId      = d.Id;
                        sh.UserOrGroupId = uid;
                        sh.AccessLevel   = desired;
                        sh.RowCause      = 'Manual';
                        demoInserts.add(sh);
                    } else if (ex.AccessLevel != desired) {
                        ex.AccessLevel = desired;
                        demoUpdates.add(ex);
                    }
                }
            }
        }

        // =========================
        // 4) Montagem - ORDER
        // =========================
        for (Order o : pedidos) {
            Id refOpp = null;
            if (o.OpportunityId != null) {
                refOpp = o.OpportunityId;
            } else if (o.Demonstracao__r != null) {
                refOpp = o.Demonstracao__r.Oportunidade__c;
            }
            if (refOpp == null) continue;

            Set<Id> usersAll = oppToUsersAll.get(refOpp);
            Map<Id, String> usersLevels = oppToUserLevel.get(refOpp);

            Map<Id, OrderShare> existing = new Map<Id, OrderShare>();
            for (SObject sob : o.Shares) {
                OrderShare sh = (OrderShare)sob;
                existing.put(sh.UserOrGroupId, sh);
            }

            if (isDelete && usersAll != null && !usersAll.isEmpty()) {
                for (Id uid : usersAll) {
                    OrderShare ex = existing.get(uid);
                    if (ex != null) orderDeletes.add(new OrderShare(Id = ex.Id));
                }
            }

            if ((isInsert || isUpdate) && usersLevels != null && !usersLevels.isEmpty()) {
                for (Id uid : usersLevels.keySet()) {
                    if (uid == o.OwnerId) continue;
                    String desired = usersLevels.get(uid); // 'Read' ou 'Edit'
                    OrderShare ex = existing.get(uid);
                    if (ex == null) {
                        OrderShare sh = new OrderShare();
                        sh.OrderId          = o.Id;
                        sh.UserOrGroupId    = uid;
                        sh.OrderAccessLevel = desired; // campo correto p/ OrderShare
                        sh.RowCause         = 'Manual';
                        orderInserts.add(sh);
                    } else if (ex.OrderAccessLevel != desired) {
                        ex.OrderAccessLevel = desired;
                        orderUpdates.add(ex);
                    }
                }
            }
        }

        // =========================
        // 5) Montagem - FATURAMENTO__c
        // =========================
        for (Faturamento__c f : faturamentos) {
            Id refOpp = null;
            if (f.Pedido__r != null) {
                if (f.Pedido__r.OpportunityId != null) {
                    refOpp = f.Pedido__r.OpportunityId;
                } else if (f.Pedido__r.Demonstracao__r != null) {
                    refOpp = f.Pedido__r.Demonstracao__r.Oportunidade__c;
                }
            }
            if (refOpp == null) continue;

            Set<Id> usersAll = oppToUsersAll.get(refOpp);
            Map<Id, String> usersLevels = oppToUserLevel.get(refOpp);

            Map<Id, Faturamento__Share> existing = new Map<Id, Faturamento__Share>();
            for (SObject sob : f.Shares) {
                Faturamento__Share sh = (Faturamento__Share)sob;
                existing.put(sh.UserOrGroupId, sh);
            }

            if (isDelete && usersAll != null && !usersAll.isEmpty()) {
                for (Id uid : usersAll) {
                    Faturamento__Share ex = existing.get(uid);
                    if (ex != null) fatDeletes.add(new Faturamento__Share(Id = ex.Id));
                }
            }

            if ((isInsert || isUpdate) && usersLevels != null && !usersLevels.isEmpty()) {
                for (Id uid : usersLevels.keySet()) {
                    if (uid == f.OwnerId) continue;
                    String desired = usersLevels.get(uid); // 'Read' ou 'Edit'
                    Faturamento__Share ex = existing.get(uid);
                    if (ex == null) {
                        Faturamento__Share sh = new Faturamento__Share();
                        sh.ParentId      = f.Id;
                        sh.UserOrGroupId = uid;
                        sh.AccessLevel   = desired; // custom share usa AccessLevel
                        sh.RowCause      = 'Manual';
                        fatInserts.add(sh);
                    } else if (ex.AccessLevel != desired) {
                        ex.AccessLevel = desired;
                        fatUpdates.add(ex);
                    }
                }
            }
        }

        // =========================
        // 6) DML em lote (com proteção de recursão)
        // =========================
        Util.AcaoInterna(true);
        try {
            if (!demoInserts.isEmpty())  Database.insert(demoInserts, false);
            if (!orderInserts.isEmpty()) Database.insert(orderInserts, false);
            if (!fatInserts.isEmpty())   Database.insert(fatInserts, false);

            if (!demoUpdates.isEmpty())  Database.update(demoUpdates, false);
            if (!orderUpdates.isEmpty()) Database.update(orderUpdates, false);
            if (!fatUpdates.isEmpty())   Database.update(fatUpdates, false);

            if (!demoDeletes.isEmpty())  Database.delete(demoDeletes, false);
            if (!orderDeletes.isEmpty()) Database.delete(orderDeletes, false);
            if (!fatDeletes.isEmpty())   Database.delete(fatDeletes, false);
        } finally {
            Util.AcaoInterna(false);
        }
    }
}