trigger PedidoCompartilha on Order (before insert, after insert, before delete) {
    if(!Util.AcaoInterna()){
		
		Set<Id> pedidos_id = new Set<Id>();
		Set<Id> demonstracoes_id = new Set<Id>();
		Set<Id> oportunidades_id = new Set<Id>();
		Set<Id> ordens_de_trabalho_id = new Set<Id>();
		for(Order pedido : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			pedidos_id.add(pedido.Id);			if(pedido.Demonstracao__c!=null)
				demonstracoes_id.add(pedido.Demonstracao__c);
			else if(pedido.OpportunityId!=null)
				oportunidades_id.add(pedido.OpportunityId);
			else if(pedido.Ordem_de_trabalho__c!=null)
				ordens_de_trabalho_id.add(pedido.Ordem_de_trabalho__c);
		}
		
		if(Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate)){
			if(demonstracoes_id.size()>0){
				List<Demonstracao__c> demonstracoes = [
					SELECT	Id, OwnerId, Departamento__c
					FROM	Demonstracao__c
					WHERE	Id IN :demonstracoes_id
				];
				for(Order pedido : Trigger.new){
					for(Demonstracao__c demonstracao : demonstracoes){
						if(pedido.Demonstracao__c == demonstracao.Id){
							pedido.OwnerId = demonstracao.OwnerId;
							pedido.Departamento3__c = demonstracao.Departamento__c;
						}
					}
				}
			}
			if(oportunidades_id.size()>0){
				List<Opportunity> oportunidades = [
					SELECT	Id, OwnerId, Departamento__c
					FROM	Opportunity
					WHERE	Id IN :oportunidades_id
				];
				for(Order pedido : Trigger.new){
					for(Opportunity oportunidade : oportunidades){
						if(pedido.OpportunityId == oportunidade.Id){
							pedido.OwnerId = oportunidade.OwnerId;
							pedido.Departamento3__c = oportunidade.Departamento__c;
						}
					}
				}
			}
			if(ordens_de_trabalho_id.size()>0){
				List<WorkOrder> ordens_de_trabalho = [
					SELECT	Id, OwnerId, Departamento__c
					FROM	WorkOrder
					WHERE	Id IN :ordens_de_trabalho_id
				];
				for(Order pedido : Trigger.new){
					for(WorkOrder ordem_de_trabalho : ordens_de_trabalho){
						if(pedido.Ordem_de_trabalho__c == ordem_de_trabalho.Id){
							pedido.OwnerId = ordem_de_trabalho.OwnerId;
							pedido.Departamento3__c = ordem_de_trabalho.Departamento__c;
						}
					}
				}
			}
			//if(Trigger.isUpdate){
			//	List<Faturamento__c> faturamentos = [
			//		SELECT	Id, Pedido__c, OwnerId, Departamento3__c
			//		FROM	Faturamento__c
			//		WHERE	Pedido__c IN :pedidos_id
			//	];
			//	for(Order pedido : Trigger.new){
			//		for(Faturamento__c faturamento : faturamentos){
			//			if(pedido.Id == faturamento.Pedido__c){
			//				faturamento.OwnerId = pedido.OwnerId;
			//				faturamento.Departamento3__c = pedido.Departamento3__c;
			//			}
			//		}
			//	}
			//	Util.AcaoInterna(true);
			//	update faturamentos;
			//	Util.AcaoInterna(false);
			//}
		}
		
		else if(Trigger.isAfter && (Trigger.IsInsert || Trigger.isUpdate)){
			List<OrderShare> membros_ped = new List<OrderShare>();
			List<Faturamento__Share> membros_fat = new List<Faturamento__Share>();
			List<Faturamento__c> faturamentos = new List<Faturamento__c>();
			
			//if(Trigger.isUpdate){
			//	List<Order> pedidos = [
			//		SELECT 	Id, (
			//					SELECT	Id
			//					FROM	Shares
			//					WHERE	RowCause = 'Manual'
			//				)
			//		FROM 	Order 
			//		WHERE 	Id IN :pedidos_id
			//	];
			//	faturamentos = [
			//		SELECT 	Id, OwnerId, Pedido__r.OpportunityId, Pedido__r.Demonstracao__c, (
			//					SELECT	Id
			//					FROM	Shares
			//					WHERE	RowCause = 'Manual'
			//				)
			//		FROM 	Faturamento__c 
			//		WHERE 	Pedido__c IN :pedidos_id
			//	];
			//	for(Order pedido : pedidos){
			//		for(OrderShare membro_ped : pedido.Shares){
			//			membros_ped.add(membro_ped);
			//		}
			//	}
			//	for(Faturamento__c faturamento : faturamentos){
			//		for(Faturamento__Share membro_fat : faturamento.Shares){
			//			membros_fat.add(membro_fat);
			//		}
			//	}
			//	if(membros_ped.size()>0){
			//		Util.AcaoInterna(true); delete membros_ped;
			//		Util.AcaoInterna(false); membros_ped.clear();
			//	}
			//	if(membros_fat.size()>0){ 
			//		Util.AcaoInterna(true); delete membros_fat;
			//		Util.AcaoInterna(false); membros_fat.clear();
			//	}
			//}
			
			if(demonstracoes_id.size()>0){
				List<Demonstracao__Share> membros_demo = [
					SELECT	ParentId, UserOrGroupId, AccessLevel
					FROM	Demonstracao__Share
					WHERE	ParentId IN :demonstracoes_id AND UserOrGroup.IsActive = true AND RowCause = 'Manual'
				];
				
				for(Order pedido : Trigger.new){
					for(Demonstracao__Share membro_demo : membros_demo){
						if((pedido.Demonstracao__c == membro_demo.ParentId) && membro_demo.UserOrGroupId != pedido.OwnerId){
							membros_ped.add(new OrderShare( OrderId = pedido.Id, UserOrGroupId = membro_demo.UserOrGroupId, OrderAccessLevel = membro_demo.AccessLevel ));
						}
					}
				}
				if(membros_ped.size()>0) {
					Util.AcaoInterna(true); insert membros_ped; Util.AcaoInterna(false);
				}
				
				//if(Trigger.isUpdate){
				//	for(Faturamento__c faturamento : faturamentos){
				//		for(Demonstracao__Share membro_demo : membros_demo){
				//			if((faturamento.Pedido__r.Demonstracao__c == membro_demo.ParentId) && membro_demo.UserOrGroupId != faturamento.OwnerId){
				//				membros_fat.add(new Faturamento__Share( ParentId = faturamento.Id, UserOrGroupId = membro_demo.UserOrGroupId, AccessLevel = membro_demo.AccessLevel ));
				//			}
				//		}
				//	}
				//	if(membros_fat.size()>0) {
				//		Util.AcaoInterna(true); insert membros_fat;	Util.AcaoInterna(false);
				//	}
				//}
			}
			if(oportunidades_id.size()>0){
				List<OpportunityTeamMember> membros_opp = [
					SELECT	OpportunityId, UserId, OpportunityAccessLevel
					FROM	OpportunityTeamMember
					WHERE	OpportunityId IN :oportunidades_id AND User.IsActive = true AND
							(OpportunityAccessLevel = 'Read' OR OpportunityAccessLevel = 'Edit')
				];
				
				for(Order pedido : Trigger.new){
					for(OpportunityTeamMember membro_opp : membros_opp){
						if((pedido.OpportunityId == membro_opp.OpportunityId) && membro_opp.UserId != pedido.OwnerId){
							membros_ped.add(new OrderShare(
                                OrderId = pedido.Id,
                                UserOrGroupId = membro_opp.UserId,
                                OrderAccessLevel = membro_opp.OpportunityAccessLevel)
                            );
						}
					}
				}
				if(membros_ped.size()>0) {
					Util.AcaoInterna(true); insert membros_ped; Util.AcaoInterna(false);
				}
				
				//if(Trigger.isUpdate){
				//	for(Faturamento__c faturamento : faturamentos){
				//		for(OpportunityTeamMember membro_opp : membros_opp){
				//			if((faturamento.Pedido__r.OpportunityId == membro_opp.OpportunityId) && membro_opp.UserId != faturamento.OwnerId){
				//				membros_fat.add(new Faturamento__Share( ParentId = faturamento.Id, UserOrGroupId = membro_opp.UserId, AccessLevel = membro_opp.OpportunityAccessLevel));
				//			}
				//		}
				//	}
				//	if(membros_fat.size()>0) {
				//		Util.AcaoInterna(true); insert membros_fat; Util.AcaoInterna(false);
				//	}
				//}
			}
		}
		
		else if(Trigger.isBefore && Trigger.isDelete){
			List<Order> pedidos = [
				SELECT 	Id, (
							SELECT	Id
							FROM	Faturamentos__r
						)
				FROM 	Order 
				WHERE 	Id IN :pedidos_id
			];
			for(Order pedido_trg : Trigger.old){
				for(Order pedido_sql : pedidos){
					if((pedido_trg.Id == pedido_sql.Id) && (pedido_sql.Faturamentos__r.size() > 0)){
						pedido_trg.addError('Não é possível excluir um pedido com faturamentos vinculados.');
					}
				}
			}
		}
	}
}