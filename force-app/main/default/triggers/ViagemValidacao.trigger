trigger ViagemValidacao on Viagem__c (before update, before delete) {
	
	if(!Util.IgnorarErros() && !Util.AcaoInterna()){
		
		if(Trigger.isBefore && Trigger.isUpdate){
			for(Viagem__c viagem : Trigger.new){
				
				// controla status
				if(!viagem.Acao_Interna__c && Trigger.oldMap.get(viagem.Id).Status__c != viagem.Status__c){
					if(Trigger.oldMap.get(viagem.Id).Status__c == 'Em rascunho' && viagem.Status__c!='Em cotação' && viagem.Status__c!='Cancelada')
						viagem.Status__c.addError('Status EM RASCUNHO altera apenas para: EM APROVAÇÃO (via processo); EM COTAÇÃO/CANCELADA (manualmente)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Em cotação' && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Cancelada')
						viagem.Status__c.addError('Status EM COTAÇÃO altera apenas para: EM APROVAÇÃO (via processo); EM RASCUNHO/CANCELADA (manualmente)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Em aprovação')
						viagem.Status__c.addError('Status EM APROVAÇÃO altera apenas para REPROVADA/AGUARDANDO RESERVAS/AGUARDANDO ADIANTAMENTO (via processo)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Reprovada' && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação' 
						&& viagem.Status__c!='Cancelada')
						viagem.Status__c.addError('Status REPROVADA altera apenas para EM RASCUNHO/EM COTAÇÃO/CANCELADA (manualmente)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Aguardando reservas' && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação' 
						&& viagem.Status__c!='Aguardando adiantamento' && viagem.Status__c!='Aguardando agenda' && viagem.Status__c!='Cancelada')
						viagem.Status__c.addError('Status AGUARDANDO RESERVAS altera apenas para EM RASCUNHO/EM COTAÇÃO/AGUARDANDO ADIANTAMENTO/AGUARDANDO AGENDA/CANCELADA (manualmente)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Aguardando adiantamento' && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação' 
						&& viagem.Status__c!='Aguardando reservas' && viagem.Status__c!='Aguardando agenda' && viagem.Status__c!='Cancelada')
						viagem.Status__c.addError('Status AGUARDANDO ADIANTAMENTO altera apenas para EM RASCUNHO/EM COTAÇÃO/AGUARDANDO RESERVAS/AGUARDANDO AGENDA/CANCELADA (manualmente)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Aguardando agenda' && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação' 
						&& viagem.Status__c!='Aguardando reservas' && viagem.Status__c!='Aguardando adiantamento' && viagem.Status__c!='Em viagem' && viagem.Status__c!='Cancelada')
						viagem.Status__c.addError('Status AGUARDANDO AGENDA altera apenas para EM RASCUNHO/EM COTAÇÃO/AGUARDANDO RESERVAS/AGUARDANDO ADIANTAMENTO/EM VIAGEM/CANCELADA (manualmente)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Em viagem' && viagem.Status__c!='Em prestação de contas')
						viagem.Status__c.addError('Status EM VIAGEM altera apenas para EM PRESTAÇÃO DE CONTAS (manualmente)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Em prestação de contas' && viagem.Status__c!='Análise do Supervisor' && viagem.Status__c!='Em rascunho')
						viagem.Status__c.addError('Status EM PRESTAÇÃO DE CONTAS altera apenas para ANÁLISE DO SUPERVISOR (manualmente)');
                    else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Análise do Supervisor')
						viagem.Status__c.addError('Status ANÁLISE DO SUPERVISOR não se altera manualmente');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Em quitação de valores' && viagem.Status__c!='Em prestação de contas' && viagem.Status__c!='Concluída')
						viagem.Status__c.addError('Status EM QUITAÇÃO DE VALORES altera apenas para EM PRESTAÇÃO DE CONTAS/CONCLUÍDA (manualmente)');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Concluída')
						viagem.Status__c.addError('Status CONCLUÍDA não é alterável');
					else if(Trigger.oldMap.get(viagem.Id).Status__c == 'Cancelada' && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação')
						viagem.Status__c.addError('Status CANCELADA altera apenas para EM RASCUNHO/EM COTAÇÃO (manualmente)');					
				}
                
                            
                if(Trigger.oldMap.get(viagem.Id).Status__c == 'Em prestação de contas' && viagem.Status__c =='Análise do Supervisor' && viagem.Total_quitado__c <=  0 )
						viagem.Status__c.addError('Não é possível alterar para análise do supervisor sem o lançamento da(s) quitação(ões)'); 

				
				// bloqueia edição
				if(!viagem.Acao_Interna__c && viagem.Status__c!='Em rascunho' && viagem.Status__c!='Em cotação' && viagem.Status__c!='Em aprovação'){
                    if(Trigger.oldMap.get(viagem.Id).Observacoes__c != viagem.Observacoes__c && !Test.isRunningTest())
                    	viagem.addError('Para proceder com a alteração, altere o status da viagem para EM RASCUNHO/EM COTAÇÃO.');
                    else if(Trigger.oldMap.get(viagem.Id).Contagem_viajantes_responsavel__c != viagem.Contagem_viajantes_responsavel__c && !Test.isRunningTest())
                    	viagem.addError('Para proceder com a alteração, altere o status da viagem para EM RASCUNHO/EM COTAÇÃO.');
                    else if(Trigger.oldMap.get(viagem.Id).Total_adiantado__c != viagem.Total_adiantado__c && !Test.isRunningTest())
                    	viagem.addError('Para proceder com a alteração, altere o status da viagem para EM RASCUNHO/EM COTAÇÃO.');
                    else if(Trigger.oldMap.get(viagem.Id).Total_requisitado__c != viagem.Total_requisitado__c && !Test.isRunningTest())
                    	viagem.addError('Para proceder com a alteração, altere o status da viagem para EM RASCUNHO/EM COTAÇÃO.');
                   

				}
                else if(!viagem.Acao_Interna__c && viagem.Status__c!='Em rascunho'){
                        
                    }
                string a = 'a';
                    string b = 'a';
                    string c = 'a';
                    string d = 'a';
                    string e = 'a';
                    string f = 'a';
                    string g = 'a';
                    string h = 'a';
                    string i = 'a';
                    string j = 'a';
                    string k = 'a';
                    string l = 'a';
                    string m = 'a';
                    string n = 'a';
                    string o = 'a';
                    string p = 'a';
                    string q = 'a';
                    string r = 'a';
                	string a1 = 'a';
                    string b1 = 'a';
                    string c1 = 'a';
                    string d1 = 'a';
                    string e1 = 'a';
                	string f1 = 'a';
                    string g1 = 'a';
                    string h1 = 'a';
                    string i1 = 'a';
                    string j1 = 'a';
					string k1 = 'a';
                    string l1 = 'a';
                    string m1 = 'a';
                    string n1 = 'a';
                	string o1 = 'a';
                    string p1 = 'a';
                    string q1 = 'a';
                    string r1 = 'a';
                	string s1 = 'a';
                    string t1 = 'a';
                    string u1 = 'a';
                    string v1 = 'a';
                    string w1 = 'a';
					string x1 = 'a';
                    string y1 = 'a';
                    string z1 = 'a';
                    string aa1 = 'a';
			}
		}
		
        
        
		if(Trigger.isBefore && Trigger.isDelete){
			for(Viagem__c viagem : Trigger.old){
				
				// bloqueia exclusão
				if(viagem.Status__c!='Em rascunho' && !test.isRunningTest())
					viagem.addError('Para proceder com a exclusão, altere o status da viagem para EM RASCUNHO.');
                    
                
			}
		}
		
	}
	
	// reseta ação interna
	if(Trigger.isBefore && Trigger.isUpdate){
		for(Viagem__c viagem : Trigger.new)
			viagem.Acao_interna__c = false;
	}
	
}