trigger ContratoDeServicoCompartilha on Contrato_de_Servi_o__c (after update, before delete) {
	if(!Util.AcaoInterna()){
		
		Set<Id> contratos_de_servico_id = new Set<Id>();
		for(Contrato_de_Servi_o__c conrtato_de_servico : (Trigger.isDelete ? Trigger.old : Trigger.new)){
			contratos_de_servico_id.add(conrtato_de_servico.Id);
		}
		
		if(Trigger.isAfter && Trigger.isUpdate){
			List<Faturamento__c> faturamentos = [
				SELECT 	Id, Contrato_de_servico__c, OwnerId, Departamento3__c, (
							SELECT	Id
							FROM	Shares
							WHERE	RowCause = 'Manual'
						)
				FROM 	Faturamento__c 
				WHERE 	Contrato_de_servico__c IN :contratos_de_servico_id
			];
			
			List<Faturamento__Share> membros_fat = new List<Faturamento__Share>();
			for(Faturamento__c faturamento : faturamentos){
				for(Faturamento__Share membro_fat : faturamento.Shares){
					membros_fat.add(membro_fat);
				}
			}
			if(membros_fat.size()>0) {
				Util.AcaoInterna(true);
				delete membros_fat;
				Util.AcaoInterna(false);
				membros_fat.clear();
			}
			
			for(Contrato_de_Servi_o__c conrtato_de_servico : Trigger.new){
				for(Faturamento__c faturamento : faturamentos){
					if(conrtato_de_servico.Id == faturamento.Contrato_de_servico__c){
						faturamento.OwnerId = conrtato_de_servico.OwnerId;
						faturamento.Departamento3__c = conrtato_de_servico.Departamento__c;						
					}
				}
			}
			if(faturamentos.size()>0) {
				Util.AcaoInterna(true);
				update faturamentos;
				Util.AcaoInterna(false);
			}
		}
		else if(Trigger.isBefore && Trigger.isDelete){
			List<Contrato_de_Servi_o__c> contratos_de_servico = [
				SELECT 	Id, (
							SELECT	Id
							FROM	Faturamentos__r
						)
				FROM 	Contrato_de_Servi_o__c 
				WHERE 	Id IN :contratos_de_servico_id
			];
			for(Contrato_de_Servi_o__c contrato_de_servico_trg : Trigger.old){
				for(Contrato_de_Servi_o__c contrato_de_servico_sql : contratos_de_servico){
					if((contrato_de_servico_trg.Id == contrato_de_servico_sql.Id) && (contrato_de_servico_sql.Faturamentos__r.size() > 0)){
						contrato_de_servico_trg.addError('Não é possível excluir um contrato de serviço com faturamentos vinculados.');
					}
				}
			}
		}
	}
}