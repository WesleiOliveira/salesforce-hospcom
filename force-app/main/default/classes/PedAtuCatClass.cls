public class PedAtuCatClass {
    
    public static Void FluxoInicial(Order pedido){
        if(pedido.OpportunityId != null){
            AtuCatOpp(pedido.OpportunityId, pedido);
        }else if(pedido.Ordem_de_trabalho__c != null){
            AtuCatOt(pedido.Ordem_de_trabalho__c, pedido);
        }
    }

    public static void AtuCatOpp(Id oportunidade_id, Order pedido){
        Opportunity oportunidade = new Opportunity();
        oportunidade = [
            SELECT	Pricebook2Id
            FROM 	Opportunity
            WHERE	Id = :oportunidade_id
        ];
        
        pedido.Pricebook2Id = oportunidade.Pricebook2Id;
    }
    
    public static void AtuCatOt(Id ordem_de_trabalho_id, Order pedido){
        WorkOrder ordem_de_trabalho = new WorkOrder();
        ordem_de_trabalho = [
            SELECT	Pricebook2Id
            FROM 	WorkOrder
            WHERE	Id = :ordem_de_trabalho_id
        ];
        
        pedido.Pricebook2Id = ordem_de_trabalho.Pricebook2Id;
    }
}