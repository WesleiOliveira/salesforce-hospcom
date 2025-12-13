public with sharing class GlobalAprovacao {
    
    @AuraEnabled
    public static String VerificaAprovacoes(){
		ValoresVerificaAprovacoes valores = new ValoresVerificaAprovacoes();

		List<ProcessInstance> processos = [
			SELECT 	Id, (
						SELECT 	Id, TargetObjectId, TargetObject.Name, ElapsedTimeInDays 
						FROM 	StepsAndWorkitems
						WHERE	IsPending = true AND ActorId = :UserInfo.GetUserId()
					)
			FROM 	ProcessInstance 
		];
		for(ProcessInstance processo : processos){
			for(ProcessInstanceHistory etapa : processo.StepsAndWorkitems){
				Pendencia pendencia = new Pendencia();
				pendencia.objeto = etapa.TargetObjectId.getSObjectType().getDescribe().getLabel();
				pendencia.nome = etapa.TargetObject.Name;
				pendencia.id = etapa.TargetObjectId;
				pendencia.tempo = String.valueOf(etapa.ElapsedTimeInDays.setScale(0));				
				valores.pendencias.add(pendencia);
			}
		}
		return JSON.serialize(valores);
	}public class ValoresVerificaAprovacoes{
		String url_base;
		List<Pendencia> pendencias;

		public ValoresVerificaAprovacoes(){
			url_base = Site.getBaseUrl();
			pendencias = new List<Pendencia>();
		}
	}public class Pendencia{
		String objeto;
		String nome;
		String id;
		String tempo;
	}
	
}