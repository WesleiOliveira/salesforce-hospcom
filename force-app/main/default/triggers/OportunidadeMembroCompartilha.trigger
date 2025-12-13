trigger OportunidadeMembroCompartilha on OpportunityTeamMember (after insert, after update, after delete) {
	if(!Util.AcaoInterna()){
		
		Set<Id> oportunidades_id = new Set<Id>();
		Set<Id> usuarios_id = new Set<Id>();
		for(OpportunityTeamMember membro_opp : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			oportunidades_id.add(membro_opp.OpportunityId);
			usuarios_id.add(membro_opp.UserId);
		}
		
		List<Demonstracao__c> demonstracoes = [
			SELECT 	Id, Oportunidade__c, OwnerId, (
						SELECT	Id, UserOrGroupId
						FROM	Shares
						WHERE	UserOrGroupId IN :usuarios_id AND RowCause = 'Manual'
					)
			FROM 	Demonstracao__c 
			WHERE 	Oportunidade__c IN :oportunidades_id
		];
		List<Order> pedidos = [
			SELECT 	Id, OpportunityId, Demonstracao__r.Oportunidade__c, OwnerId, (
						SELECT	Id, UserOrGroupId
						FROM	Shares
						WHERE	UserOrGroupId IN :usuarios_id AND RowCause = 'Manual'
					)
			FROM 	Order 
			WHERE 	OpportunityId IN :oportunidades_id OR 
					Demonstracao__r.Oportunidade__c IN :oportunidades_id
		];
		List<Faturamento__c> faturamentos = [
			SELECT 	Id, Pedido__r.OpportunityId, Pedido__r.Demonstracao__r.Oportunidade__c, OwnerId, (
						SELECT	Id, UserOrGroupId
						FROM	Shares
						WHERE	UserOrGroupId IN :usuarios_id AND RowCause = 'Manual'
					)
			FROM 	Faturamento__c 
			WHERE 	Pedido__r.OpportunityId IN :oportunidades_id OR
					Pedido__r.Demonstracao__r.Oportunidade__c IN :oportunidades_id
		];
		
		List<Demonstracao__Share> membros_demo = new List<Demonstracao__Share>();
		List<OrderShare> membros_ped = new List<OrderShare>();
		List<Faturamento__Share> membros_fat = new List<Faturamento__Share>();
		
		for(OpportunityTeamMember membro_opp : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			for(Demonstracao__c demonstracao : demonstracoes){
				if(membro_opp.OpportunityId == demonstracao.Oportunidade__c){
					for(Demonstracao__Share membro_demo : demonstracao.Shares){
						if(membro_opp.UserId == membro_demo.UserOrGroupId){
							membros_demo.add(membro_demo);
						}
					}
				}
			}
			for(Order pedido : pedidos){
				if(membro_opp.OpportunityId == pedido.OpportunityId || membro_opp.OpportunityId == pedido.Demonstracao__r.Oportunidade__c){
					for(OrderShare membro_ped : pedido.Shares){
						if(membro_opp.UserId == membro_ped.UserOrGroupId){
							membros_ped.add(membro_ped);
						}
					}
				}
			}
			for(Faturamento__c faturamento : faturamentos){
				if(membro_opp.OpportunityId == faturamento.Pedido__r.OpportunityId || membro_opp.OpportunityId == faturamento.Pedido__r.Demonstracao__r.Oportunidade__c){
					for(Faturamento__Share membro_fat : faturamento.Shares){
						if(membro_opp.UserId == membro_fat.UserOrGroupId){
							membros_fat.add(membro_fat);
						}
					}
				}
			}
		}
		
		if(membros_demo.size()>0){
			Util.AcaoInterna(true);
			delete membros_demo;
			Util.AcaoInterna(false);
			membros_demo.clear();
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
		
		if(Trigger.isInsert || Trigger.isUpdate){
			for(OpportunityTeamMember membro_opp : Trigger.new){
				if(membro_opp.OpportunityAccessLevel == 'Read' || membro_opp.OpportunityAccessLevel == 'Edit'){
					for(Demonstracao__c demonstracao : demonstracoes){
						if((membro_opp.OpportunityId == demonstracao.Oportunidade__c) && membro_opp.UserId != demonstracao.OwnerId){
							membros_demo.add(new Demonstracao__Share(
								ParentId = demonstracao.Id,
								UserOrGroupId = membro_opp.UserId,
								AccessLevel = membro_opp.OpportunityAccessLevel
							));
						}
					}
					for(Order pedido : pedidos){
						if((membro_opp.OpportunityId == pedido.OpportunityId || membro_opp.OpportunityId == pedido.Demonstracao__r.Oportunidade__c) 
							&& membro_opp.UserId != pedido.OwnerId){
							membros_ped.add(new OrderShare(
								OrderId = pedido.Id,
								UserOrGroupId = membro_opp.UserId,
								OrderAccessLevel = membro_opp.OpportunityAccessLevel
							));
						}
					}
					for(Faturamento__c faturamento : faturamentos){
						if((membro_opp.OpportunityId == faturamento.Pedido__r.OpportunityId || membro_opp.OpportunityId == faturamento.Pedido__r.Demonstracao__r.Oportunidade__c) 
							&& membro_opp.UserId != faturamento.OwnerId){
							membros_fat.add(new Faturamento__Share(
								ParentId = faturamento.Id,
								UserOrGroupId = membro_opp.UserId,
								AccessLevel = membro_opp.OpportunityAccessLevel
							));
						}
					}
				}
			}
			
			if(membros_demo.size()>0) {
				Util.AcaoInterna(true);
				insert membros_demo;
				Util.AcaoInterna(false);
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