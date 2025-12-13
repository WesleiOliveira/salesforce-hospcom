public class ViagemTransacoes{
	
    @AuraEnabled
    public static String ObterTransacoes(String viagem_id){
		Retorno retorno = new Retorno();
		List<Transacao__c> transacoes = [
			SELECT	Categoria__c, Valor__c, Tipo__c, Adiantamento__c, Valor_valido__c 
			FROM	Transacao__c
			WHERE 	Viagem__c = :viagem_id
		];
		
		for(Transacao__c transacao : transacoes){
			Boolean existe = false;
			for(Resumo resumo : retorno.resumos)
				if(resumo.despesa == transacao.Categoria__C)
					existe = true;
			if(!existe){
				Resumo resumo = new Resumo();
				resumo.despesa = transacao.Categoria__C;
				retorno.resumos.add(resumo);
			}
		}
		
		for(Transacao__c transacao : transacoes){
			for(Resumo resumo : retorno.resumos){
				if(resumo.despesa == transacao.Categoria__C){
					if(transacao.Tipo__c == 'Requisição'){
						resumo.requisitado += transacao.Valor__c;
						if(transacao.Adiantamento__c=='Sim')
							resumo.adiantado += transacao.Valor__c;
					}else{
						resumo.quitado += transacao.Valor__c;
						resumo.validado += transacao.Valor_valido__c;
					}
					resumo.saldo = resumo.validado - (resumo.adiantado*-1);
				}
			}
		}
		
		return JSON.serialize(retorno);
	}
	public class Retorno{
		List<Resumo> resumos;

		public Retorno(){
			resumos = new List<Resumo>();
		}
	}
	public class Resumo{
		String despesa;
		Decimal requisitado=0;
		Decimal adiantado=0;
		Decimal quitado=0;
		Decimal validado=0;
		Decimal saldo=0;
	}
}