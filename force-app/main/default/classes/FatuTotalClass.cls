public class FatuTotalClass {
    
    public static Void FluxoInicial(Faturamento__c faturamento){
        if(faturamento.Oportunidade__c != null)
            FluxoFatuOpp(faturamento.Oportunidade__c);
        else if(faturamento.Ordem_de_Trabalho__c != null)
            FluxoFatuOt(faturamento.Ordem_de_Trabalho__c);
        else if(faturamento.Pedido__c != null)
            FluxoFatuPed(faturamento.Pedido__c);
        
		if(faturamento.Faturamento_pai__c != null)
            FluxoFatuFatu(faturamento.Faturamento_pai__c);
    }
    
    public static Void FluxoFatuOpp(Id oportunidade_id){
        Double valor_total = TotalFatusOpp(oportunidade_id);
        valor_total += TotalFatusPeds(oportunidade_id);
		valor_total += TotalFatusOts(oportunidade_id);
		valor_total += TotalFatusPedsOts(oportunidade_id);
        AtualTotalOpp(oportunidade_id, valor_total);
    }
    
    public static Void FluxoFatuOt(Id ordem_trabalho_id){
        Double valor_total = TotalFatusOt(ordem_trabalho_id);
        valor_total += TotalFatusPeds(ordem_trabalho_id);
        AtualTotalOt(ordem_trabalho_id, valor_total);
		
		WorkOrder ordem_de_trabalho = ObtemOrdemDeTrabalho(ordem_trabalho_id);
		if(ordem_de_trabalho.Oportunidade_Relacionada__c != null)
            FluxoFatuOpp(ordem_de_trabalho.Oportunidade_Relacionada__c);
    }
    
    public static Void FluxoFatuPed(Id pedido_id){
        Double valor_total = TotalFatusPed(pedido_id);
        AtualTotalPed(pedido_id, valor_total);
        
        Order pedido = ObtemPedido(pedido_id);
        if(pedido.OpportunityId != null)
            FluxoFatuOpp(pedido.OpportunityId);
        else if(pedido.Ordem_de_trabalho__c != null)
            FluxoFatuOt(pedido.Ordem_de_trabalho__c);
    }
	
    public static Void FluxoFatuFatu(Id faturamento_id){
        Double valor_total = TotalFatusFatu(faturamento_id);
        AtualTotalFatu(faturamento_id, valor_total);
    }
    
    public static Double TotalFatusOpp(Id oportunidade_id){
		List<Faturamento__c> faturamentos = new List<Faturamento__c>();
        faturamentos = [
            SELECT	Valor_Faturado__c
            FROM	Faturamento__c
            WHERE   Oportunidade__c = :oportunidade_id
        ];
        Double valor_total = 0;
        for(Faturamento__c fatutemp : faturamentos)
            valor_total += fatutemp.Valor_Faturado__c;
        return valor_total;
    }
    
    public static Double TotalFatusOt(Id ordem_de_trabalho_id){
		List<Faturamento__c> faturamentos = new List<Faturamento__c>();
        faturamentos = [
            SELECT	Valor_Faturado__c
            FROM	Faturamento__c
            WHERE   Ordem_de_trabalho__c = :ordem_de_trabalho_id
        ];
        Double valor_total = 0;
        for(Faturamento__c fatutemp : faturamentos)
            valor_total += fatutemp.Valor_Faturado__c;
        return valor_total;
    }
    
    public static Double TotalFatusPeds(Id objeto_pai_id){
        List<Order> pedidos = new List<Order>();
        if(objeto_pai_id.getSObjectType().getDescribe().getName() == 'Opportunity'){
            pedidos = [
                SELECT	id
                FROM 	Order
                WHERE   OpportunityId = :objeto_pai_id
            ];
        }
        else if(objeto_pai_id.getSObjectType().getDescribe().getName() == 'WorkOrder'){
            pedidos = [
                SELECT	id
                FROM 	Order
                WHERE   Ordem_de_trabalho__c = :objeto_pai_id
            ];
        }
        List<Id> pedidos_id = new List<Id>();
        for(Order pedido : pedidos)
            pedidos_id.add(pedido.Id);
        
        Double valor_total = 0;
		if(pedidos_id.size() > 0){
			List<Faturamento__c> faturamentos = new List<Faturamento__c>();
			faturamentos = [
				SELECT	Valor_Faturado__c
				FROM	Faturamento__c
				WHERE   Pedido__c IN :pedidos_id
			];
			for(Faturamento__c fatutemp : faturamentos)
				valor_total += fatutemp.Valor_Faturado__c;
		}
        return valor_total;
    }
	
	public static Double TotalFatusFatu(Id faturamento_id){
		List<Faturamento__c> faturamentos = new List<Faturamento__c>();
        faturamentos = [
            SELECT	Valor_Faturado__c
            FROM	Faturamento__c
            WHERE   Faturamento_pai__c = :faturamento_id
        ];
        Double valor_total = 0;
        for(Faturamento__c fatutemp : faturamentos)
            valor_total += fatutemp.Valor_Faturado__c;
        return valor_total;
    }
	
	public static Double TotalFatusOts(Id oportunidade_id){
        List<WorkOrder> ordens_de_trabalho = new List<WorkOrder>();
		ordens_de_trabalho = [
			SELECT	id
			FROM 	WorkOrder
			WHERE   Oportunidade_Relacionada__c = :oportunidade_id
		];
        List<Id> ordens_de_trabalho_id = new List<Id>();
        for(WorkOrder ordem_de_trabalho : ordens_de_trabalho)
            ordens_de_trabalho_id.add(ordem_de_trabalho.Id);
        
        Double valor_total = 0;
		if(ordens_de_trabalho_id.size()>0){
			List<Faturamento__c> faturamentos = new List<Faturamento__c>();
			faturamentos = [
				SELECT	Valor_Faturado__c
				FROM	Faturamento__c
				WHERE   Ordem_de_Trabalho__c IN :ordens_de_trabalho_id
			];
			for(Faturamento__c fatutemp : faturamentos)
				valor_total += fatutemp.Valor_Faturado__c;
		}
        return valor_total;
    }
	
	public static Double TotalFatusPedsOts(Id oportunidade_id){
        List<WorkOrder> ordens_de_trabalho = new List<WorkOrder>();
		ordens_de_trabalho = [
			SELECT	id
			FROM 	WorkOrder
			WHERE   Oportunidade_Relacionada__c = :oportunidade_id
		];
        List<Id> ordens_de_trabalho_id = new List<Id>();
        for(WorkOrder ordem_de_trabalho : ordens_de_trabalho)
            ordens_de_trabalho_id.add(ordem_de_trabalho.Id);
        
        Double valor_total = 0;
		if(ordens_de_trabalho_id.size()>0){
			List<Order> pedidos = new List<Order>();
			pedidos = [
				SELECT	id
				FROM 	Order
				WHERE   Ordem_de_trabalho__c IN :ordens_de_trabalho_id
			];
			List<Id> opedidos_id = new List<Id>();
			for(Order pedido : pedidos)
				opedidos_id.add(pedido.Id);
			
			if(opedidos_id.size()>0){
				List<Faturamento__c> faturamentos = new List<Faturamento__c>();
				faturamentos = [
					SELECT	Valor_Faturado__c
					FROM	Faturamento__c
					WHERE   Pedido__c IN :opedidos_id
				];
				for(Faturamento__c fatutemp : faturamentos)
					valor_total += fatutemp.Valor_Faturado__c;
			}
		}
        return valor_total;
    }
    
    public static Double TotalFatusPed(Id pedido_id){
		List<Faturamento__c> faturamentos = new List<Faturamento__c>();
        faturamentos = [
            SELECT	Valor_Faturado__c
            FROM	Faturamento__c
            WHERE   Pedido__c = :pedido_id
        ];
        Double valor_total = 0;
        for(Faturamento__c fatutemp : faturamentos)
            valor_total += fatutemp.Valor_Faturado__c;
        return valor_total;
    }   
    
    public static Void AtualTotalOpp(Id oportunidade_id, Double total_faturado){
        Opportunity oportunidade = new Opportunity();
        oportunidade = [
            SELECT	Id, Total_Faturado__c
            FROM	Opportunity
            WHERE	Id = :oportunidade_id
        ];
        oportunidade.Total_Faturado__c = total_faturado;
        update oportunidade;
    }
    
    public static Void AtualTotalOt(Id ordem_trabalho_id, Double total_faturado){
        WorkOrder ordem_trabalho = new WorkOrder();
        ordem_trabalho = [
            SELECT	Id, Total_Faturado__c
            FROM	WorkOrder
            WHERE	Id = :ordem_trabalho_id
        ];
        ordem_trabalho.Total_Faturado__c = total_faturado;
        update ordem_trabalho;
    }
    
    public static Void AtualTotalPed(Id pedido_id, Double total_faturado){
        Order pedido = new Order();
        pedido = [
            SELECT	Id, Total_Faturado__c
            FROM	Order
            WHERE	Id = :pedido_id
        ];
        pedido.Total_Faturado__c = total_faturado;
        update pedido;
    }
    
    public static Void AtualTotalFatu(Id faturamento_id, Double total_faturado){
        Faturamento__c faturamento = new Faturamento__c();
        faturamento = [
            SELECT	Id, Total_Faturado__c
            FROM	Faturamento__c
            WHERE	Id = :faturamento_id
        ];
        faturamento.Valor_Faturado__c = total_faturado;
        update faturamento;
    }
    
    public static Order ObtemPedido(Id pedido_id){
        Order pedido = new Order();
        pedido = [
            SELECT  Id, OpportunityId, Ordem_de_trabalho__c
            FROM    Order
            WHERE   Id = :pedido_id
        ];
        return pedido;
    }
    
    public static WorkOrder ObtemOrdemDeTrabalho(Id ordem_de_trabalho_id){
        WorkOrder ordem_de_trabalho = new WorkOrder();
        ordem_de_trabalho = [
            SELECT  Id, Oportunidade_Relacionada__c
            FROM    WorkOrder
            WHERE   Id = :ordem_de_trabalho_id
        ];
        return ordem_de_trabalho;
    }
    
}