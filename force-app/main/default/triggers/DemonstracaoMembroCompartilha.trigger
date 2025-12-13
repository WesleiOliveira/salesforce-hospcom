trigger DemonstracaoMembroCompartilha on Membro_da_Equipe_da_Demonstracao__c (before insert, after insert, after update, after delete) {
	if(!Util.AcaoInterna()){
		
		Set<Id> demonstracoes_id = new Set<Id>();
		Set<Id> usuarios_id = new Set<Id>();
		for(Membro_da_Equipe_da_Demonstracao__c membro_demo : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			demonstracoes_id.add(membro_demo.Demonstracao__c);
			usuarios_id.add(membro_demo.Usuario__c);
		}
		
		List<Demonstracao__c> demonstracoes = [
			SELECT 	Id, OwnerId, Oportunidade__c, (
						SELECT	Id, UserOrGroupId
						FROM	Shares
						WHERE	UserOrGroupId IN :usuarios_id AND RowCause = 'Manual'
					)
			FROM 	Demonstracao__c 
			WHERE 	Id IN :demonstracoes_id
		];
		
		if(Trigger.isBefore){
			
			for(Membro_da_Equipe_da_Demonstracao__c membro_demo : (Trigger.isDelete ? Trigger.old : Trigger.new)){
				for(Demonstracao__c demonstracao : demonstracoes){
					if(membro_demo.Demonstracao__c == demonstracao.Id){
						if(demonstracao.Oportunidade__c != null)
							membro_demo.addError('Não é possível adicionar membros da equipe em demonstração vinculada a oportunidade. Em vez disso, adicione o mesmo usuário na equipe da oportunidade pai.');
						if(membro_demo.Usuario__c == demonstracao.OwnerId)
							membro_demo.addError('Não é possível adicionar o proprietário da demonstração como um membro da equipe. O mesmo já possui todos os acessos.');
					}
				}
			}
			
		}
		else if(Trigger.isAfter){
			List<Order> pedidos = [
				SELECT 	Id, Demonstracao__c, OwnerId, (
							SELECT	Id, UserOrGroupId
							FROM	Shares
							WHERE	UserOrGroupId IN :usuarios_id AND RowCause = 'Manual'
						)
				FROM 	Order 
				WHERE 	Demonstracao__c IN :demonstracoes_id
			];
			List<Faturamento__c> faturamentos = [
				SELECT 	Id, Pedido__r.Demonstracao__c, OwnerId, (
							SELECT	Id, UserOrGroupId
							FROM	Shares
							WHERE	UserOrGroupId IN :usuarios_id AND RowCause = 'Manual'
						)
				FROM 	Faturamento__c 
				WHERE 	Pedido__r.Demonstracao__c IN :demonstracoes_id
			];
			
			List<Demonstracao__Share> membros_demo = new List<Demonstracao__Share>();
			List<OrderShare> membros_ped = new List<OrderShare>();
			List<Faturamento__Share> membros_fat = new List<Faturamento__Share>();
			
			for(Membro_da_Equipe_da_Demonstracao__c membro_demo : (Trigger.isDelete ? Trigger.old : Trigger.new)){
				for(Demonstracao__c demonstracao : demonstracoes){
					if(membro_demo.Demonstracao__c == demonstracao.Id){
						for(Demonstracao__Share membro_demo_int : demonstracao.Shares){
							if(membro_demo.Usuario__c == membro_demo_int.UserOrGroupId){
								membros_demo.add(membro_demo_int);
							}
						}
					}
				}
				for(Order pedido : pedidos){
					if(membro_demo.Demonstracao__c == pedido.Demonstracao__c){
						for(OrderShare membro_ped : pedido.Shares){
							if(membro_demo.Usuario__c == membro_ped.UserOrGroupId){
								membros_ped.add(membro_ped);
							}
						}
					}
				}
				for(Faturamento__c faturamento : faturamentos){
					if(membro_demo.Demonstracao__c == faturamento.Pedido__r.Demonstracao__c){
						for(Faturamento__Share membro_fat : faturamento.Shares){
							if(membro_demo.Usuario__c == membro_fat.UserOrGroupId){
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
				for(Membro_da_Equipe_da_Demonstracao__c membro_demo : Trigger.new){
					for(Demonstracao__c demonstracao : demonstracoes){
						if((membro_demo.Demonstracao__c == demonstracao.Id) && membro_demo.Usuario__c != demonstracao.OwnerId){
							membros_demo.add(new Demonstracao__Share(
								ParentId = demonstracao.Id,
								UserOrGroupId = membro_demo.Usuario__c,
								AccessLevel = (membro_demo.Acesso_demonstracao__c=='Somente leitura'?'Read':'Edit')
							));
						}
					}
					for(Order pedido : pedidos){
						if((membro_demo.Demonstracao__c == pedido.Demonstracao__c) && membro_demo.Usuario__c != pedido.OwnerId){
							membros_ped.add(new OrderShare(
								OrderId = pedido.Id,
								UserOrGroupId = membro_demo.Usuario__c,
								OrderAccessLevel = (membro_demo.Acesso_demonstracao__c=='Somente leitura'?'Read':'Edit')
							));
						}
					}
					for(Faturamento__c faturamento : faturamentos){
						if((membro_demo.Demonstracao__c == faturamento.Pedido__r.Demonstracao__c) && membro_demo.Usuario__c != faturamento.OwnerId){
							membros_fat.add(new Faturamento__Share(
								ParentId = faturamento.Id,
								UserOrGroupId = membro_demo.Usuario__c,
								AccessLevel = (membro_demo.Acesso_demonstracao__c=='Somente leitura'?'Read':'Edit')
							));
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
		
}