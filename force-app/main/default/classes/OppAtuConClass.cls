public class OppAtuConClass {
    
    public static String FluxoInicial(Opportunity oportunidade){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
        if(oportunidade.AccountId == null){
            
            if(oportunidade.Contrato_de_Servico__c != null){
                ServiceContract contrato_de_servico = new ServiceContract();
                contrato_de_servico = ObtemContr(oportunidade.Contrato_de_Servico__c);
                if(contrato_de_servico.AccountId != null)
                    oportunidade.AccountId = contrato_de_servico.AccountId;
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
            SELECT	Id, AccountId	
            FROM 	ServiceContract
            WHERE	Id = :contrato_de_servico_id
        ];
        return contrato_de_servico;
    }  
    
}