public class FatuObtProcClass {
    
    public static Void FluxoInicial(Faturamento__c faturamento){
        
        // Cria registros associados
        Opportunity oportunidade = new Opportunity();
        WorkOrder ordem_de_trabalho = new WorkOrder();
        Order pedido = new Order();
        
        System.debug(LoggingLevel.INFO, 'faturamento.Oportunidade__c: ' + faturamento.Oportunidade__c);        
        
        // pesquisa registros associados
        If(faturamento.Oportunidade__c != null){
            oportunidade = [
                SELECT 	RecordType.Name, Contrato_de_Servico__r.RecordType.Name
                FROM	Opportunity
                WHERE	Id = :faturamento.Oportunidade__c
            ];
            System.debug(LoggingLevel.INFO, 'oportunidade.RecordType.Name: ' + oportunidade.RecordType.Name);
            System.debug(LoggingLevel.INFO, 'oportunidade.Contrato_de_Servico__r.RecordType.Name: ' + oportunidade.Contrato_de_Servico__r.RecordType.Name);
        }
        else if (faturamento.Ordem_de_Trabalho__c != null){
            ordem_de_trabalho = [
                SELECT	Id, Oportunidade_Relacionada__c, Oportunidade_Relacionada__r.Contrato_de_Servico__r.RecordType.Name,
                		ServiceContract.RecordType.Name
                FROM	WorkOrder
                WHERE	Id = :faturamento.Ordem_de_Trabalho__c
            ];
        }
        else if(faturamento.Pedido__c != null){
            pedido = [
                SELECT	Opportunity.RecordType.Name, Ordem_de_Trabalho__c,  Ordem_de_Trabalho__r.Oportunidade_Relacionada__c,
                		Ordem_de_Trabalho__r.Oportunidade_Relacionada__r.Contrato_de_Servico__r.RecordType.Name,
                		Ordem_de_Trabalho__r.ServiceContract.RecordType.Name,
                		Opportunity.Contrato_de_Servico__r.RecordType.Name
                FROM	Order
                WHERE	Id = :faturamento.Pedido__c
            ];
        }
                
		// Inspeciona associações
        if(oportunidade.Contrato_de_Servico__r.RecordType.Name == 'SERVIÇOS' ||
           pedido.Opportunity.Contrato_de_Servico__r.RecordType.Name == 'SERVIÇOS')
            faturamento.Procedencia__c = 'Contrato de Serviço';
            
        else if(oportunidade.Contrato_de_Servico__r.RecordType.Name == 'LOCAÇÃO' ||
               	pedido.Opportunity.Contrato_de_Servico__r.RecordType.Name == 'LOCAÇÃO')
            faturamento.Procedencia__c = 'Contrato de Locação';
        
        else if(ordem_de_trabalho.ServiceContract.RecordType.Name == 'SERVIÇOS' ||
                pedido.Ordem_de_Trabalho__r.ServiceContract.RecordType.Name == 'SERVIÇOS' ||
                ordem_de_trabalho.Oportunidade_Relacionada__r.Contrato_de_Servico__r.RecordType.Name == 'SERVIÇOS' || 
                pedido.Ordem_de_Trabalho__r.Oportunidade_Relacionada__r.Contrato_de_Servico__r.RecordType.Name == 'SERVIÇOS')
        	faturamento.Procedencia__c = 'Serviço Avulso (Contrato de Serviço)';
            
        else if(ordem_de_trabalho.ServiceContract.RecordType.Name == 'LOCAÇÃO' || 
                pedido.Ordem_de_Trabalho__r.ServiceContract.RecordType.Name == 'LOCAÇÃO' ||
                ordem_de_trabalho.Oportunidade_Relacionada__r.Contrato_de_Servico__r.RecordType.Name == 'LOCAÇÃO' || 
                pedido.Ordem_de_Trabalho__r.Oportunidade_Relacionada__r.Contrato_de_Servico__r.RecordType.Name == 'LOCAÇÃO')
            faturamento.Procedencia__c = 'Serviço Avulso (Contrato de Locação)';
            
        else if(ordem_de_trabalho.Oportunidade_Relacionada__c != null || 
                pedido.Ordem_de_Trabalho__r.Oportunidade_Relacionada__c != null ||
            	pedido.Opportunity.RecordType.Name == 'Serviço' ||
                oportunidade.RecordType.Name == 'Serviço' || 
                ordem_de_trabalho.Id != null ||
                pedido.Ordem_de_Trabalho__c != null)
            faturamento.Procedencia__c = 'Serviço Avulso';
        
        else if(pedido.Opportunity.RecordType.Name == 'Comercial' ||
            	oportunidade.RecordType.Name == 'Comercial')
            faturamento.Procedencia__c = 'Comercial';
        
        else if(pedido.Opportunity.RecordType.Name == 'Governo' ||
                pedido.Opportunity.RecordType.Name == 'Governo Estimativa' ||
            	oportunidade.RecordType.Name == 'Governo'  ||
                oportunidade.RecordType.Name == 'Governo Estimativa')
            faturamento.Procedencia__c = 'Governo';
        else 
            faturamento.Procedencia__c = null;
            
    }
    
}