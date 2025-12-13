trigger DemonstracaoCompartilha on Demonstracao__c (before insert, after insert, before update, after update, before delete) {
    if(!Util.AcaoInterna()){
        
        Set<Id> demonstracoes_id = new Set<Id>();
        Set<Id> oportunidades_id = new Set<Id>();
        for(Demonstracao__c demonstracao : (Trigger.isDelete ? Trigger.old : Trigger.new)){
            demonstracoes_id.add(demonstracao.Id);
            if(demonstracao.Oportunidade__c!=null)
                oportunidades_id.add(demonstracao.Oportunidade__c);
        }
        
        if(Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate)){
            if(oportunidades_id.size()>0){
                List<Opportunity> oportunidades = [
                    SELECT  Id, OwnerId, Departamento__c
                    FROM    Opportunity
                    WHERE   Id IN :oportunidades_id
                ];
                for(Demonstracao__c demonstracao : Trigger.new){
                    for(Opportunity oportunidade : oportunidades){
                        if(demonstracao.Oportunidade__c == oportunidade.Id){
                            demonstracao.OwnerId = oportunidade.OwnerId;
                            demonstracao.Departamento__c = oportunidade.Departamento__c;
                        }
                    }
                }
            }
            if(Trigger.isUpdate){
                List<Order> pedidos = [
                    SELECT  Id, Demonstracao__c, OwnerId, Departamento3__c
                    FROM    Order
                    WHERE   Demonstracao__c IN :demonstracoes_id
                ];
                for(Demonstracao__c demonstracao : Trigger.new){
                    for(Order pedido : pedidos){
                        if(demonstracao.Id == pedido.Demonstracao__c){
                            pedido.OwnerId = demonstracao.OwnerId;
                            pedido.Departamento3__c = demonstracao.Departamento__c;
                        }
                    }
                }
                List<Faturamento__c> faturamentos = [
                    SELECT  Id, Pedido__r.Demonstracao__c, OwnerId, Departamento3__c
                    FROM    Faturamento__c
                    WHERE   Pedido__r.Demonstracao__c IN :demonstracoes_id
                ];
                for(Demonstracao__c demonstracao : Trigger.new){
                    for(Faturamento__c faturamento : faturamentos){
                        if(demonstracao.Id == faturamento.Pedido__r.Demonstracao__c){
                            faturamento.OwnerId = demonstracao.OwnerId;
                            faturamento.Departamento3__c = demonstracao.Departamento__c;
                        }
                    }
                }
                
                if(pedidos.size()>0){
                    Util.AcaoInterna(true);
                    update pedidos;
                    Util.AcaoInterna(false);                    
                }
                if(faturamentos.size()>0){
                    Util.AcaoInterna(true);
                    update faturamentos;
                    Util.AcaoInterna(false);
                }
            }
        }
        
        else if(Trigger.isAfter && (Trigger.IsInsert || Trigger.isUpdate)){
            List<Demonstracao__Share> membros_demo = new List<Demonstracao__Share>();
            List<Membro_da_Equipe_da_Demonstracao__c> membros_demo2 = new List<Membro_da_Equipe_da_Demonstracao__c>();
            List<OrderShare> membros_ped = new List<OrderShare>();
            List<Faturamento__Share> membros_fat = new List<Faturamento__Share>();
            List<Order> pedidos = new List<Order>();
            List<Faturamento__c> faturamentos = new List<Faturamento__c>();
            
            if(Trigger.isUpdate){
                List<Demonstracao__c> demonstracoes = [
                    SELECT  Id, Oportunidade__c, (
                                SELECT  Id
                                FROM    Shares
                                WHERE   RowCause = 'Manual'
                            ), (
                                SELECT  Id
                                FROM    Membros_da_Equipe_da_demonstracao__r
                            )
                    FROM    Demonstracao__c 
                    WHERE   Id IN :demonstracoes_id
                ];
                pedidos = [
                    SELECT  Id, OwnerId, Demonstracao__r.Oportunidade__c, (
                                SELECT  Id
                                FROM    Shares
                                WHERE   RowCause = 'Manual'
                            )
                    FROM    Order 
                    WHERE   Demonstracao__c IN :demonstracoes_id
                ];
                faturamentos = [
                    SELECT  Id, OwnerId, Pedido__r.Demonstracao__r.Oportunidade__c, Pedido__r.Demonstracao__c, (
                                SELECT  Id
                                FROM    Shares
                                WHERE   RowCause = 'Manual'
                            )
                    FROM    Faturamento__c 
                    WHERE   Pedido__r.Demonstracao__c IN :demonstracoes_id
                ];
                for(Demonstracao__c demonstracao : demonstracoes){
                    for(Demonstracao__Share membro_demo : demonstracao.Shares){
                        membros_demo.add(membro_demo);
                    }
                    if(demonstracao.Oportunidade__c!=null){
                        for(Membro_da_Equipe_da_Demonstracao__c membro_demo2 : demonstracao.Membros_da_Equipe_da_demonstracao__r){
                            membros_demo2.add(membro_demo2);
                        }
                    }
                }
                for(Order pedido : pedidos){
                    for(OrderShare membro_ped : pedido.Shares){
                        membros_ped.add(membro_ped);
                    }
                }
                for(Faturamento__c faturamento : faturamentos){
                    for(Faturamento__Share membro_fat : faturamento.Shares){
                        membros_fat.add(membro_fat);
                    }
                }
                if(membros_demo.size()>0){
                    Util.AcaoInterna(true);
                    delete membros_demo;
                    Util.AcaoInterna(false);
                    membros_demo.clear();
                }
                if(membros_demo2.size()>0){
                    Util.AcaoInterna(true);
                    delete membros_demo2;
                    Util.AcaoInterna(false);
                    membros_demo2.clear();
                }
                if(membros_ped.size()>0){
                    Util.AcaoInterna(true);
                    delete membros_ped;
                    Util.AcaoInterna(false);
                    membros_ped.clear();
                }
                if(membros_fat.size()>0){ 
                    Util.AcaoInterna(true);
                    delete membros_fat;
                    Util.AcaoInterna(false);
                    membros_fat.clear();
                }
            }
            
            if(oportunidades_id.size()>0){
                List<OpportunityTeamMember> membros_opp = [
                    SELECT  OpportunityId, UserId, OpportunityAccessLevel
                    FROM    OpportunityTeamMember
                    WHERE   OpportunityId IN :oportunidades_id AND User.IsActive = true AND
                            (OpportunityAccessLevel = 'Read' OR OpportunityAccessLevel = 'Edit')
                ];
                
                for(Demonstracao__c demonstracao : Trigger.new){
                    for(OpportunityTeamMember membro_opp : membros_opp){
                        if((demonstracao.Oportunidade__c == membro_opp.OpportunityId) && membro_opp.UserId != demonstracao.OwnerId){
                            membros_demo.add(new Demonstracao__Share(
                                ParentId = demonstracao.Id,
                                UserOrGroupId = membro_opp.UserId,
                                AccessLevel = membro_opp.OpportunityAccessLevel
                            ));
                        }
                    }
                }
                if(membros_demo.size()>0) {
                    Util.AcaoInterna(true);
                    insert membros_demo;
                    Util.AcaoInterna(false);
                }
                
                if(Trigger.isUpdate){
                    
                    for(Order pedido : pedidos){
                        for(OpportunityTeamMember membro_opp : membros_opp){
                            if((pedido.Demonstracao__r.Oportunidade__c == membro_opp.OpportunityId) && membro_opp.UserId != pedido.OwnerId){
                                membros_ped.add(new OrderShare(
                                    OrderId = pedido.Id,
                                    UserOrGroupId = membro_opp.UserId,
                                    OrderAccessLevel = membro_opp.OpportunityAccessLevel
                                ));
                            }
                        }
                    }
                    
                    for(Faturamento__c faturamento : faturamentos){
                        for(OpportunityTeamMember membro_opp : membros_opp){
                            if((faturamento.Pedido__r.Demonstracao__r.oportunidade__c == membro_opp.OpportunityId) && membro_opp.UserId != faturamento.OwnerId){
                                membros_fat.add(new Faturamento__Share(
                                    ParentId = faturamento.Id,
                                    UserOrGroupId = membro_opp.UserId,
                                    AccessLevel = membro_opp.OpportunityAccessLevel
                                ));
                            }
                        }
                    }
                    if(membros_ped.size()>0) {
                        Util.AcaoInterna(true);
                        insert membros_ped; 
                        Util.AcaoInterna(false);
                    }
                    if(membros_fat.size()>0) {
                        Util.AcaoInterna(true);
                        insert membros_fat; 
                        Util.AcaoInterna(false);
                    }
                }
            }
        }
        
        else if(Trigger.isBefore && Trigger.isDelete){
            List<Demonstracao__c> demonstracoes = [
                SELECT  Id, (
                            SELECT  Id
                            FROM    Pedidos__r
                        )
                FROM    Demonstracao__c 
                WHERE   Id IN :demonstracoes_id
            ];
            for(Demonstracao__c demonstracao_trg : Trigger.old){
                for(Demonstracao__c demonstracao_sql : demonstracoes){
                    if((demonstracao_trg.Id == demonstracao_sql.Id) && (demonstracao_sql.Pedidos__r.size() > 0)){
                        demonstracao_trg.addError('Não é possível excluir uma demonstracao com pedidos vinculados.');
                    }
                }
            }
        }
    }
}