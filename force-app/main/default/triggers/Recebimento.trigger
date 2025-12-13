trigger Recebimento on Recebimentos__c (before insert, after insert, before update, after update, before delete, after delete) {
	
    if(RecebimentoControle.PrimeiraExecucao(Trigger.isBefore?'before':'after',Trigger.isInsert?'insert':(Trigger.isUpdate?'update':'delete'))){

		Integer cont=0, max=(Trigger.isInsert || Trigger.isUpdate) ? Trigger.new.size() : Trigger.old.size();
		String retorno = null;
		Boolean Bypass_Errors = [Select Bypass_Errors__c From User Where Id = :UserInfo.getUserId()][0].Bypass_Errors__c;
		
		// loop principal trigger
		for(cont=0; cont<max; cont++){

			// preenchimento cascata --------------------------------------------------------------
			
			// Recebimento *Parceiro (Valor Recebido) => Faturamento(Total recebido (parceiro)) 
			if(Trigger.isAfter){
				if(Trigger.isInsert){
                    if(Trigger.new[cont].NF_Representacao__c!=null){
                        RecebimentoCascata.ValorRecebido(Trigger.new[cont], 'new');
                        RecebimentoCascata.ValorComissao(Trigger.new[cont], 'new');
                    }
				}
				else if(Trigger.isDelete){
                    if(Trigger.old[cont].NF_Representacao__c!=null){
                        RecebimentoCascata.ValorRecebido(Trigger.old[cont], 'old');
                        RecebimentoCascata.ValorComissao(Trigger.old[cont], 'old');
                    }
				}else if(Trigger.isUpdate){
					if((Trigger.old[cont].NF_Representacao__c != Trigger.new[cont].NF_Representacao__c)){
						if(Trigger.old[cont].NF_Representacao__c == null){
							RecebimentoCascata.ValorRecebido(Trigger.new[cont], 'new');
							RecebimentoCascata.ValorComissao(Trigger.new[cont], 'new');
						}
						else if(Trigger.new[cont].NF_Representacao__c == null){
							RecebimentoCascata.ValorRecebido(Trigger.old[cont], 'old');
							RecebimentoCascata.ValorComissao(Trigger.old[cont], 'old');
						}
						else{
							RecebimentoCascata.ValorRecebido(Trigger.old[cont], 'old');
							RecebimentoCascata.ValorComissao(Trigger.old[cont], 'old');
							RecebimentoCascata.ValorRecebido(Trigger.new[cont], 'new');
							RecebimentoCascata.ValorComissao(Trigger.new[cont], 'new');
						}
					}
					else{
						if(Trigger.old[cont].Valor_Recebido__c != Trigger.new[cont].Valor_Recebido__c){
							RecebimentoCascata.ValorRecebido(Trigger.new[cont], 'new');
						}
						if(Trigger.old[cont].Valor_Comissao__c != Trigger.new[cont].Valor_Comissao__c){
							RecebimentoCascata.ValorComissao(Trigger.new[cont], 'new');
						}
					}
					
				}
			}
			
			RecebimentoCascata.Efetivar();
			
		} // fim do loop
		
	} // fim do controle de execução
	
}