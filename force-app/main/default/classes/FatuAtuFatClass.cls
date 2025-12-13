public class FatuAtuFatClass {
    
    public static String FluxoInicial(Faturamento__c faturamento){
        String retorno = null;
        String msg_erro = 'Informe esse campo';
        
        if(faturamento.Faturamento_Feito2__c == null){
            
            if(faturamento.Pedido__c != null){
                Order pedido = new order();
                pedido = ObtemPedido(faturamento.Pedido__c);
                if(pedido.Faturamento_Feito__c != null)
                    faturamento.Faturamento_Feito2__c = pedido.Faturamento_Feito__c;
                else
                    retorno = msg_erro;
            }
            
            else if(faturamento.Oportunidade__c != null){
                Opportunity oportunidade = new Opportunity();
                oportunidade = ObtemOpp(faturamento.Oportunidade__c);
                if(oportunidade.Faturamento_Feito2__c != null)
                    faturamento.Faturamento_Feito2__c = oportunidade.Faturamento_Feito2__c;
                else
                    retorno = msg_erro;
            }
            
            else if(faturamento.Ordem_de_Trabalho__c != null){
                WorkOrder ordem_de_trabalho = new WorkOrder();
                ordem_de_trabalho = ObtemOt(faturamento.Ordem_de_Trabalho__c);
                if(ordem_de_trabalho.Faturamento_Feito2__c != null)
                    faturamento.Faturamento_Feito2__c = ordem_de_trabalho.Faturamento_Feito2__c;
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
            SELECT	Id, Faturamento_Feito__c	
            FROM 	Order
            WHERE	Id = :pedido_id
        ];
        return pedido;
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