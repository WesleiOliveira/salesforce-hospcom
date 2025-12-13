trigger FaturamentoCompartilha on Faturamento__c (before insert, after insert) {
    if(!Util.AcaoInterna()){
		
		Set<Id> faturamentos_id = new Set<Id>();
		Set<Id> pedidos_id = new Set<Id>();
		Set<Id> contratos_de_servico_id = new Set<Id>();
		for(Faturamento__c faturamento : Trigger.new){
			faturamentos_id.add(faturamento.Id);
			if(faturamento.Pedido__c!=null)
				pedidos_id.add(faturamento.Pedido__c);
			if(faturamento.Contrato_de_servico__c!=null)
				contratos_de_servico_id.add(faturamento.Contrato_de_servico__c);
		}
		
		if(Trigger.isBefore){
			if(pedidos_id.size()>0){
				List<Order> pedidos = [
					SELECT	Id, OwnerId, Departamento3__c
					FROM	Order
					WHERE	Id IN :pedidos_id
				];
				for(Faturamento__c faturamento : Trigger.new){
					for(Order pedido : pedidos){
						if(pedido.Id == faturamento.Pedido__c){
							faturamento.OwnerId = pedido.OwnerId;
							faturamento.Departamento3__c = pedido.Departamento3__c;
						}
					}
				}
			}
			if(contratos_de_servico_id.size()>0){
				List<Contrato_de_Servi_o__c> contratos_de_servico = [
					SELECT	Id, OwnerId, Departamento__c
					FROM	Contrato_de_Servi_o__c
					WHERE	Id IN :contratos_de_servico_id
				];
				for(Faturamento__c faturamento : Trigger.new){
					for(Contrato_de_Servi_o__c contrato_de_servico : contratos_de_servico){
						if(contrato_de_servico.Id == faturamento.Contrato_de_servico__c){
							faturamento.OwnerId = contrato_de_servico.OwnerId;
							faturamento.Departamento3__c = contrato_de_servico.Departamento__c;
						}
					}
				}
			}
		}
		else if(Trigger.isAfter){
			List<Faturamento__Share> membros_fat = [
				SELECT	Id
				FROM	Faturamento__Share
				WHERE	ParentId IN :faturamentos_id AND RowCause = 'Manual'
			];
			if(membros_fat.size()>0){
				Util.AcaoInterna(true);
				delete membros_fat;
				Util.AcaoInterna(false);
				membros_fat.clear();
			}
			if(pedidos_id.size()>0){
				List<OrderShare> membros_ped = [
					SELECT	Id, OrderId, UserOrGroupId, OrderAccessLevel
					FROM	OrderShare
					WHERE	OrderId IN :pedidos_id AND RowCause = 'Manual' AND UserOrGroup.IsActive = true
				];
				for(Faturamento__c faturamento : Trigger.new){
					for(OrderShare membro_ped : membros_ped){
						if(faturamento.Pedido__c == membro_ped.OrderId){
							membros_fat.add(new Faturamento__Share(
								ParentId = faturamento.Id,
								UserOrGroupId = membro_ped.UserOrGroupId,
								AccessLevel = membro_ped.OrderAccessLevel
							));
						}
					}
				}
				if(membros_fat.size()>0){
					Util.AcaoInterna(true);
					insert membros_fat;
					Util.AcaoInterna(false);
				}
			}
		}
	}
}