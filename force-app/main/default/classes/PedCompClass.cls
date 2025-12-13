public class PedCompClass {
    
    public static void FluxoPedCri(Order pedido){
		Order pedido_temp = new Order();
        pedido_temp = [
            SELECT	Id, OpportunityId, Opportunity.OwnerId, 
            		Ordem_de_trabalho__c, Ordem_de_trabalho__r.OwnerId
            FROM	Order
            WHERE	Id = :pedido.Id
        ];
        
		if((pedido_temp.OpportunityId != null ? pedido_temp.Opportunity.OwnerId : pedido_temp.Ordem_de_trabalho__r.OwnerId) != pedido.OwnerId){
			OrderShare compartilhamento = new OrderShare(
				OrderId = pedido.Id,
				UserOrGroupId = pedido_temp.OpportunityId != null ? pedido_temp.Opportunity.OwnerId : pedido_temp.Ordem_de_trabalho__r.OwnerId,
				OrderAccessLevel = 'Edit'
			);
			insert compartilhamento;
		}
	}    
    
    public static void FluxoPedAtu(Order pedido_old, Order pedido_new){
		Order pedido_temp = new Order();
        pedido_temp = [
            SELECT	Id, OwnerId, 
					OpportunityId, Opportunity.OwnerId, 
            		Ordem_de_trabalho__c, Ordem_de_trabalho__r.OwnerId
            FROM	Order
            WHERE	Id = :pedido_new.Id
        ];
        
		if(pedido_old.OwnerId == (pedido_temp.OpportunityId != null ? pedido_temp.Opportunity.OwnerId : pedido_temp.Ordem_de_trabalho__r.OwnerId) &&
		   pedido_new.OwnerId != (pedido_temp.OpportunityId != null ? pedido_temp.Opportunity.OwnerId : pedido_temp.Ordem_de_trabalho__r.OwnerId)){
			OrderShare compartilhamento_novo = new OrderShare(
				OrderId = pedido_new.Id,
				UserOrGroupId = (pedido_temp.OpportunityId != null ? pedido_temp.Opportunity.OwnerId : pedido_temp.Ordem_de_trabalho__r.OwnerId),
				OrderAccessLevel = 'Edit'
			);
			insert compartilhamento_novo;
		}
		else if(pedido_old.OwnerId != (pedido_temp.OpportunityId != null ? pedido_temp.Opportunity.OwnerId : pedido_temp.Ordem_de_trabalho__r.OwnerId) &&
		        pedido_new.OwnerId == (pedido_temp.OpportunityId != null ? pedido_temp.Opportunity.OwnerId : pedido_temp.Ordem_de_trabalho__r.OwnerId)){
			List<OrderShare> compartilhamento_antigo = new List<OrderShare>();
			compartilhamento_antigo = [
				SELECT	Id
				FROM	OrderShare
				WHERE	OrderId  = :pedido_temp.Id	AND 
						RowCause = 'Manual' 		AND 
						UserOrGroupId = :(pedido_temp.OpportunityId != null ? pedido_temp.Opportunity.OwnerId : pedido_temp.Ordem_de_trabalho__r.OwnerId)
			];
			if(compartilhamento_antigo.size() > 0)
				delete compartilhamento_antigo;
		}
	}    
    
    public static void FluxoOppAtu(Opportunity oportunidade_old, Opportunity oportunidade_new){
		List<Order> pedidos = new List<Order>();
		pedidos = [
			SELECT	Id, OwnerId
			FROM	Order
			WHERE	OpportunityId = :oportunidade_new.Id
		];
        List<Id> pedidos_id = new List<Id>();
		for(Order pedido : pedidos)
			pedidos_id.add(pedido.Id);
		
		List<OrderShare> compartilhamentos = new List<OrderShare>();
		compartilhamentos = [
			SELECT 	Id
			FROM	OrderShare
			WHERE	OrderId IN :pedidos_id 	AND 
					RowCause = 'Manual' 	AND 
					UserOrGroupId = :oportunidade_old.OwnerId
		];
		delete compartilhamentos;
		
		List<OrderShare> compartilhamentos_novos = new List<OrderShare>();
        for(Order pedido : pedidos)
            if(pedido.OwnerId != oportunidade_new.OwnerId)
                compartilhamentos_novos.add( new OrderShare(
                    OrderId = pedido.Id,
                    UserOrGroupId = oportunidade_new.OwnerId,
                    OrderAccessLevel = 'Edit'
                ));
        if(compartilhamentos_novos.size()>0)
			insert compartilhamentos_novos;
	}    
    
    public static void FluxoOtAtu(WorkOrder ordem_de_trabalho_old, WorkOrder ordem_de_trabalho_new){
		List<Order> pedidos = new List<Order>();
		pedidos = [
			SELECT	Id, OwnerId
			FROM	Order
			WHERE	Ordem_de_Trabalho__c = :ordem_de_trabalho_new.Id
		];
        List<Id> pedidos_id = new List<Id>();
		for(Order pedido : pedidos)
			pedidos_id.add(pedido.Id);
		
		List<OrderShare> compartilhamentos = new List<OrderShare>();
		compartilhamentos = [
			SELECT 	Id
			FROM	OrderShare
			WHERE	OrderId IN :pedidos_id 	AND 
					RowCause = 'Manual' 	AND 
					UserOrGroupId = :ordem_de_trabalho_old.OwnerId
		];
		delete compartilhamentos;
		
		List<OrderShare> compartilhamentos_novos = new List<OrderShare>();
        for(Order pedido : pedidos)
            if(pedido.OwnerId != ordem_de_trabalho_new.OwnerId)
                compartilhamentos_novos.add( new OrderShare(
                    OrderId = pedido.Id,
                    UserOrGroupId = ordem_de_trabalho_new.OwnerId,
                    OrderAccessLevel = 'Edit'
                ));
        if(compartilhamentos_novos.size()>0)
			insert compartilhamentos_novos;
	}    
    
}