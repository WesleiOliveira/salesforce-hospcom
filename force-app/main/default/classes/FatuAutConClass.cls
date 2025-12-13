public class FatuAutConClass {
    
    public static String FluxoInicial(Faturamento__c faturamento){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
        if(faturamento.Nome_da_Conta2__c == null){
            
            if(faturamento.Pedido__c != null){
                Order pedido = new order();
                pedido = ObtemPedido(faturamento.Pedido__c);
                if(pedido.AccountId != null)
                    faturamento.Nome_da_Conta2__c = pedido.AccountId;
                else
                    retorno = msg_erro;
            }
            
            else if(faturamento.Oportunidade__c != null){
                Opportunity oportunidade = new Opportunity();
                oportunidade = ObtemOpp(faturamento.Oportunidade__c);
                if(oportunidade.AccountId != null)
                    faturamento.Nome_da_Conta2__c = oportunidade.AccountId;
                else
                    retorno = msg_erro;
            }
            
            else if(faturamento.Ordem_de_Trabalho__c != null){
                WorkOrder ordem_de_trabalho = new WorkOrder();
                ordem_de_trabalho = ObtemOt(faturamento.Ordem_de_Trabalho__c);
                if(ordem_de_trabalho.AccountId != null)
                    faturamento.Nome_da_Conta2__c = ordem_de_trabalho.AccountId;
                else
                    retorno = msg_erro;
            }
            
            else{
                retorno = msg_erro;
            }
        }
        
        return retorno;
    }
    
    public static Order ObtemPedido(Id pedido_id){
    	Order pedido = new order();
        pedido = [
            SELECT	Id, AccountId	
            FROM 	Order
            WHERE	Id = :pedido_id
        ];
        return pedido;
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