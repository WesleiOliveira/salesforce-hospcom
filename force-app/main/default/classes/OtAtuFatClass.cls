public class OtAtuFatClass {
    
    public static String FluxoInicial(WorkOrder ordem_de_trabalho){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
        if(ordem_de_trabalho.Faturamento_Feito2__c == null){
            
            if(ordem_de_trabalho.Oportunidade_Relacionada__c != null){
                Opportunity oportunidade = new Opportunity();
                oportunidade = ObtemOpp(ordem_de_trabalho.Oportunidade_Relacionada__c);
                if(oportunidade.Faturamento_Feito2__c != null)
                    ordem_de_trabalho.Faturamento_Feito2__c = oportunidade.Faturamento_Feito2__c;
                else
                    retorno = msg_erro;
            }
            
            else if(ordem_de_trabalho.ServiceContractId != null){
                ServiceContract contrato_de_servico = new ServiceContract();
                contrato_de_servico = ObtemContr(ordem_de_trabalho.ServiceContractId);
                if(contrato_de_servico.Faturamento_feito__c != null)
                    ordem_de_trabalho.Faturamento_Feito2__c = contrato_de_servico.Faturamento_feito__c;
                else
                    retorno = msg_erro;
            }
            
            else{
                retorno = msg_erro;
            }
        }
        
        return retorno;
    }
    
    public static Opportunity ObtemOpp(Id oportunidade_id){
    	Opportunity oportunidade = new Opportunity();
        oportunidade = [
            SELECT	Id, Faturamento_Feito2__c	
            FROM 	Opportunity
            WHERE	Id = :oportunidade_id
        ];
        return oportunidade;
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