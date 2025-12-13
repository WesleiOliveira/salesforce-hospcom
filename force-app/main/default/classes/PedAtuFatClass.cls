public class PedAtuFatClass {
    
    public static String FluxoInicial(Order pedido){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
        if(pedido.Faturamento_Feito__c == null){
            
            if(pedido.OpportunityId != null){
                Opportunity oportunidade = new Opportunity();
                oportunidade = ObtemOpp(pedido.OpportunityId);
                if(oportunidade.Faturamento_Feito2__c != null)
                    pedido.Faturamento_Feito__c = oportunidade.Faturamento_Feito2__c;
                else
                    retorno = msg_erro;
            }
            
            else if(pedido.Ordem_de_trabalho__c != null){
                WorkOrder ordem_de_trabalho = new WorkOrder();
                ordem_de_trabalho = ObtemOt(pedido.Ordem_de_trabalho__c);
                if(ordem_de_trabalho.Faturamento_Feito2__c != null)
                    pedido.Faturamento_Feito__c = ordem_de_trabalho.Faturamento_Feito2__c;
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
    
    public static WorkOrder ObtemOt(Id ordem_de_trabalho_id){
    	WorkOrder ordem_de_trabalho = new WorkOrder();
        ordem_de_trabalho = [
            SELECT	Id, Faturamento_Feito2__c	
            FROM 	WorkOrder
            WHERE	Id = :ordem_de_trabalho_id
        ];
        return ordem_de_trabalho;
    }  
    
}