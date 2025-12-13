public class PedAtuConClass {
    
    public static String FluxoInicial(Order pedido){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
        if(pedido.AccountId == null){
            
            if(pedido.OpportunityId != null){
                Opportunity oportunidade = new Opportunity();
                oportunidade = ObtemOpp(pedido.OpportunityId);
                if(oportunidade.AccountId != null)
                    pedido.AccountId = oportunidade.AccountId;
                else
                    retorno = msg_erro;
            }
            
            else if(pedido.Ordem_de_trabalho__c != null){
                WorkOrder ordem_de_trabalho = new WorkOrder();
                ordem_de_trabalho = ObtemOt(pedido.Ordem_de_trabalho__c);
                if(ordem_de_trabalho.AccountId != null)
                    pedido.AccountId = ordem_de_trabalho.AccountId;
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
            SELECT	Id, AccountId	
            FROM 	Opportunity
            WHERE	Id = :oportunidade_id
        ];
        return oportunidade;
    }
    
    public static WorkOrder ObtemOt(Id ordem_de_trabalho_id){
    	WorkOrder ordem_de_trabalho = new WorkOrder();
        ordem_de_trabalho = [
            SELECT	Id, AccountId	
            FROM 	WorkOrder
            WHERE	Id = :ordem_de_trabalho_id
        ];
        return ordem_de_trabalho;
    }  
    
}