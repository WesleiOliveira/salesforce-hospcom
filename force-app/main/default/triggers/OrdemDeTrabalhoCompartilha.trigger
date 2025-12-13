trigger OrdemDeTrabalhoCompartilha on WorkOrder (after update, before delete) {
    if(!Util.AcaoInterna()){
        
        Set<Id> ordens_de_trabalho_id = new Set<Id>();
        for(WorkOrder ordem_de_trabalho : (Trigger.isDelete ? Trigger.old : Trigger.new)){
            ordens_de_trabalho_id.add(ordem_de_trabalho.Id);
        }
        
        if(Trigger.isAfter && Trigger.isUpdate){
            List<Order> pedidos = [
                SELECT  Id, Ordem_de_trabalho__c, OwnerId, Departamento3__c, (
                            SELECT  Id
                            FROM    Shares
                            WHERE   RowCause = 'Manual'
                        )
                FROM    Order 
                WHERE   Ordem_de_trabalho__c IN :ordens_de_trabalho_id
            ];
            List<Faturamento__c> faturamentos = [
                SELECT  Id, Pedido__c, OwnerId, Departamento3__c, (
                            SELECT  Id
                            FROM    Shares
                            WHERE   RowCause = 'Manual'
                        )
                FROM    Faturamento__c 
                WHERE   Pedido__c IN (
                            SELECT  Id 
                            FROM    Order 
                            WHERE   Ordem_de_trabalho__c IN :ordens_de_trabalho_id
                        )
            ];
            
            List<OrderShare> membros_ped = new List<OrderShare>();
            List<Faturamento__Share> membros_fat = new List<Faturamento__Share>();
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
            if(membros_ped.size()>0) {
                Util.AcaoInterna(true);
                delete membros_ped;
                Util.AcaoInterna(false);
                membros_ped.clear();
            }
            if(membros_fat.size()>0) {
                Util.AcaoInterna(true);
                delete membros_fat;
                Util.AcaoInterna(false);
                membros_fat.clear();
            }
            
            for(WorkOrder ordem_de_trabalho : Trigger.new){
                for(Order pedido : pedidos){
                    if(ordem_de_trabalho.Id == pedido.Ordem_de_trabalho__c){
                        pedido.OwnerId = ordem_de_trabalho.OwnerId;
                        pedido.Departamento3__c = ordem_de_trabalho.Departamento__c;
                        for(Faturamento__c faturamento : faturamentos){
                            if(pedido.Id == faturamento.Pedido__c){
                                faturamento.OwnerId = ordem_de_trabalho.OwnerId;
                                faturamento.Departamento3__c = ordem_de_trabalho.Departamento__c;
                            }
                        }
                    }
                }
            }
            if(pedidos.size()>0) {
                Util.AcaoInterna(true);
                update pedidos;
                Util.AcaoInterna(false);
            }
            if(faturamentos.size()>0) {
                Util.AcaoInterna(true);
                update faturamentos;
                Util.AcaoInterna(false);
            }
        }
        else if(Trigger.isBefore && Trigger.isDelete){
            List<WorkOrder> ordens_de_trabalho = [
                SELECT  Id, (
                            SELECT  Id
                            FROM    Pedidos__r
                        )
                FROM    WorkOrder 
                WHERE   Id IN :ordens_de_trabalho_id
            ];
            for(WorkOrder ordem_de_trabalho_trg : Trigger.old){
                for(WorkOrder ordem_de_trabalho_sql : ordens_de_trabalho){
                    if((ordem_de_trabalho_trg.Id == ordem_de_trabalho_sql.Id) && (ordem_de_trabalho_sql.Pedidos__r.size() > 0)){
                        ordem_de_trabalho_trg.addError('Não é possível excluir uma ordem de trabalho com pedidos vinculados.');
                    }
                }
            }
        }

    }
}