public class OppAtuFatClass {
    
    public static String FluxoInicial(Opportunity oportunidade){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
        if(oportunidade.Faturamento_Feito2__c == null){
            
            if(oportunidade.Contrato_de_Servico__c != null){
                ServiceContract contrato_de_servico = new ServiceContract();
                contrato_de_servico = ObtemContr(oportunidade.Contrato_de_Servico__c);
                if(contrato_de_servico.Faturamento_feito__c != null)
                    oportunidade.Faturamento_Feito2__c = contrato_de_servico.Faturamento_feito__c;
                else
                    retorno = msg_erro;
            }
            
            else{
                retorno = msg_erro;
            }
        }
        
        return retorno;
    }
    
    public static ServiceContract ObtemContr(Id contrato_de_servico_id){
    	ServiceContract contrato_de_servico = new ServiceContract();
        contrato_de_servico = [
            SELECT	Id, Faturamento_feito__c	
            FROM 	ServiceContract
            WHERE	Id = :contrato_de_servico_id
        ];
        return contrato_de_servico;
    }  
    
}