public class OrdemDeTrabalhoCascata {
	
	public static List<Order>		pedidos_de_venda;
    
	// métodos externos -------------------------------------------------------------------
	
	public static Void Status(WorkOrder ordem_de_trabalho){
        if(pedidos_de_venda==null)
            ObtemPedidosDeVenda(ordem_de_trabalho.Id);
        
        String novo_status = null;
		if(ordem_de_trabalho.Status == 'AGUARDANDO FATURAMENTO')
			novo_status  = 'Aguardando Faturamento Cliente';
		else if(ordem_de_trabalho.Status == 'DISPONIVEL PARA ENTREGA')
			novo_status = 'Faturado';
		else if(ordem_de_trabalho.Status == 'ENTREGUE' || 
			   (ordem_de_trabalho.Status == 'FECHADO CONCLUÍDO' && ordem_de_trabalho.Sub_status__c == 'FINALIZADO'))
			novo_status = 'Entregue';
		else if(ordem_de_trabalho.Status == 'FECHADO CONCLUÍDO' && ordem_de_trabalho.Sub_status__c != 'FINALIZADO')
			novo_status = 'Cancelado';

        for(Integer cont=0; cont<pedidos_de_venda.size(); cont++){
            pedidos_de_venda[cont].Status = novo_status;
			pedidos_de_venda[cont].Status_Permissao__c = true;
		}
	}
		
	public static Void Efetivar(){
		if(pedidos_de_venda!=null && pedidos_de_venda.size()>0){
			update pedidos_de_venda;
			
			if(pedidos_de_venda[0].Status_Permissao__c==true)
				for(Integer cont=0; cont<pedidos_de_venda.size();cont++)
					pedidos_de_venda[cont].Status_Permissao__c=false;
			update pedidos_de_venda;
		}
	}
	
	// métodos internos -------------------------------------------------------------------
	
    static Void ObtemPedidosDeVenda(Id ordem_de_trabalho_id){
		pedidos_de_venda = new List<Order>();
		
		// pedidos da ot
		List<Order> pedidos_ot = new List<Order>();
        pedidos_ot = [
            SELECT	Id, Status	
            FROM 	Order
            WHERE	Ordem_de_trabalho__c = :ordem_de_trabalho_id
        ];
		if(pedidos_ot.size()>0)
			pedidos_de_venda.addAll(pedidos_ot);
		
		// pedidos das opps da ot
		List<Opportunity> oportunidades_ot = new List<Opportunity>();
		List<Id> oportunidade_ot_id = new List<Id>();
		oportunidades_ot = [
			SELECT	Id
			FROM 	Opportunity
			WHERE	Ordem_de_trabalho_Relacionada__c = :ordem_de_trabalho_id
		];
		if(oportunidades_ot.size()>0){
			for(Opportunity oportunidade_temp : oportunidades_ot)
				oportunidade_ot_id.add(oportunidade_temp.Id);
			List<Order> pedidos_opp_ot = new List<Order>();
			pedidos_opp_ot = [
				SELECT	Id, Status	
				FROM 	Order
				WHERE	OpportunityId IN :oportunidade_ot_id
			];
			if(pedidos_opp_ot.size()>0)
				pedidos_de_venda.addAll(pedidos_opp_ot);
		}
		
	}
    
}