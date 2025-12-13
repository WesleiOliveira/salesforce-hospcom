public class PedStaCalss {
    
    public static Void FluxoInicial(OrderItem item_de_pedido){
		System.Debug(LoggingLevel.INFO, 'a');
		List<OrderItem> itens_de_pedido = new List<OrderItem>();
        itens_de_pedido = [
            SELECT	Status__c
            FROM 	OrderItem
            WHERE	OrderId = :item_de_pedido.OrderId
        ];
        
		Integer qtd_total=0, 
				qtd_novo=0, qtd_aberto=0, 
				qtd_entregue=0, qtd_atendido=0, 
				qtd_cancelado=0, 
				qtd_andamento=0;
        for(OrderItem item_temp : itens_de_pedido){
            if(item_temp.Status__c == 'Novo')
                qtd_novo++;
            else if(item_temp.Status__c == 'Aberto')
                qtd_aberto++;
            else if(item_temp.Status__c == 'Entregue')
                qtd_entregue++;
            else if(item_temp.Status__c == 'Atendido')
                qtd_atendido++;
			else if(item_temp.Status__c == 'Cancelado')
				qtd_cancelado++;
			else
                qtd_andamento++;
            qtd_total++;
        }
        System.Debug(LoggingLevel.INFO, 'qtd_total: ' + qtd_total);
        System.Debug(LoggingLevel.INFO, 'qtd_novo: ' + qtd_novo);
        System.Debug(LoggingLevel.INFO, 'qtd_aberto: ' + qtd_aberto);
        System.Debug(LoggingLevel.INFO, 'qtd_entregue: ' + qtd_entregue);
        System.Debug(LoggingLevel.INFO, 'qtd_atendido: ' + qtd_atendido);
        System.Debug(LoggingLevel.INFO, 'qtd_cancelado: ' + qtd_cancelado);
        System.Debug(LoggingLevel.INFO, 'qtd_andamento: ' + qtd_andamento);
		System.Debug(LoggingLevel.INFO, 'b');
		Order pedido = new Order();
        pedido = [
            SELECT	Id, Status, Status_Permissao__c, Tipo__c, Ordem_de_trabalho__c, OpportunityId, Opportunity.Ordem_de_trabalho_Relacionada__c
            FROM	Order
            WHERE 	Id = :item_de_pedido.OrderId
        ];
		pedido.Status_Permissao__c = true;
        System.Debug(LoggingLevel.INFO, 'c');
        System.Debug(LoggingLevel.INFO, 'pedido.Id: ' + pedido.Id);
        System.Debug(LoggingLevel.INFO, 'pedido.Tipo__c: ' + pedido.Tipo__c);
		
		// para Comercial e Governo
		if(pedido.Tipo__c == 'Governo' || pedido.Tipo__c == 'Comercial'){
			System.Debug(LoggingLevel.INFO, 'd');
            if((qtd_novo == (qtd_total - qtd_cancelado)) && (qtd_cancelado < qtd_total)){
                if(pedido.Status == 'Em Andamento' || 
                   pedido.Status == 'Entregue Parcial' ||
                   pedido.Status == 'Entregue Total' ||
				   pedido.Status == 'Cancelado'){
                    pedido.Status = 'Ativo';  
                }
            }
			else if((qtd_andamento > 0) && (qtd_entregue == 0))
				pedido.Status = 'Em Andamento';
			else if((qtd_entregue > 0) && (qtd_entregue < (qtd_total - qtd_cancelado)))
				pedido.Status = 'Entregue Parcial';
			else if(qtd_entregue == (qtd_total - qtd_cancelado))
				pedido.Status = 'Entregue Total';     
			else if(qtd_cancelado == qtd_total)
				pedido.Status = 'Cancelado';
        }
		// para Serviço
		else if(pedido.Tipo__c == 'Serviço'){
			System.Debug(LoggingLevel.INFO, 'e');
            if((qtd_aberto == (qtd_total - qtd_cancelado)) && (qtd_cancelado < qtd_total)){
                if(pedido.Status == 'Em Andamento' ||
                   pedido.Status == 'Atendido Parcial' ||
                   pedido.Status == 'Atendido Total' ||
                   pedido.Status == 'Aguardando Faturamento Cliente' ||
                   pedido.Status == 'Faturado' ||
                   pedido.Status == 'Entregue' ||
				   pedido.Status == 'Cancelado'){
                    pedido.Status = 'Ativo';  
                }
            }
			else if((qtd_andamento > 0) && (qtd_atendido == 0))
				pedido.Status = 'Em Andamento';
			else if((qtd_atendido > 0) && (qtd_atendido < (qtd_total - qtd_cancelado)))
				pedido.Status = 'Atendido Parcial';
            else if((qtd_atendido == (qtd_total - qtd_cancelado))){
				String novo_status = null;
				System.Debug(LoggingLevel.INFO, '1');
				if(pedido.Ordem_de_trabalho__c != null){
					System.Debug(LoggingLevel.INFO, '2');
					WorkOrder ordem_de_trabalho = new WorkOrder();
					ordem_de_trabalho = [
						SELECT 	Status, Sub_status__c
						FROM	WorkOrder
						WHERE	Id = :pedido.Ordem_de_trabalho__c
					];
					if(ordem_de_trabalho.Status == 'AGUARDANDO FATURAMENTO')
						novo_status  = 'Aguardando Faturamento Cliente';
					else if(ordem_de_trabalho.Status == 'DISPONIVEL PARA ENTREGA')
						novo_status = 'Faturado';
					else if(ordem_de_trabalho.Status == 'ENTREGUE' || 
					       (ordem_de_trabalho.Status == 'FECHADO CONCLUÍDO' && ordem_de_trabalho.Sub_status__c == 'FINALIZADO'))
						novo_status = 'Entregue';
					else if(ordem_de_trabalho.Status == 'FECHADO CONCLUÍDO' && ordem_de_trabalho.Sub_status__c != 'FINALIZADO')
						novo_status = 'Cancelado';
				}
				
				else if(pedido.OpportunityId != null && pedido.Opportunity.Ordem_de_trabalho_Relacionada__c != null){
					System.Debug(LoggingLevel.INFO, '3');
					WorkOrder ordem_de_trabalho = new WorkOrder();
					ordem_de_trabalho = [
						SELECT 	Status, Sub_status__c
						FROM	WorkOrder
						WHERE	Id = :pedido.Opportunity.Ordem_de_trabalho_Relacionada__c
					];
					if(ordem_de_trabalho.Status == 'AGUARDANDO FATURAMENTO')
						novo_status  = 'Aguardando Faturamento Cliente';
					else if(ordem_de_trabalho.Status == 'DISPONIVEL PARA ENTREGA')
						novo_status = 'Faturado';
					else if(ordem_de_trabalho.Status == 'ENTREGUE' || 
					       (ordem_de_trabalho.Status == 'FECHADO CONCLUÍDO' && ordem_de_trabalho.Sub_status__c == 'FINALIZADO'))
						novo_status = 'Entregue';
					else if(ordem_de_trabalho.Status == 'FECHADO CONCLUÍDO' && ordem_de_trabalho.Sub_status__c != 'FINALIZADO')
						novo_status = 'Cancelado';
				}
				
				if(novo_status == null)
					novo_status = 'Atendido Total';
				System.Debug(LoggingLevel.INFO, 'novo_status: ' + novo_status);
				pedido.Status = novo_status;
			}
			else if(qtd_cancelado == qtd_total)
				pedido.Status = 'Cancelado';
        }
        update pedido;
		
		pedido.Status_Permissao__c = false;
        update pedido;
    }
    
}