public class NovoPDFdoPedido {
    public Order pedido 					{get;set;}
    public List<OrderItem> itens_pais 		{get;set;}
    public List<OrderItem> itens_filhos 	{get;set;}
    public List<OrderItem> itens_semN 		{get;set;}
    public List<OrderItem> itens_incorretos	{get;set;}
    public List<OrderItem> itens_por_codigo	{get;set;}
    public List<OrderItem> itens_ag_entrega	{get;set;}
    
    public Boolean divergencia				{get;set;}
	
	public NovoPDFdoPedido(ApexPages.StandardController controller) {
        pedido = [
                        SELECT  Account.RecordType.Name, Account.Raz_o_Social__c, Account.Name, Account.CNPJ__c, Account.CPF__pc, Data_da_demonstracao__c,
                    			Tempo_de_demonstracao__c, Faturamento_feito__r.Raz_o_Social__c, Faturamento_feito__r.CNPJ__c, Faturamento_feito__r.BillingCity, 
                    			TotalAmount, BillingStreet, BillingCity, BillingState, BillingPostalCode, Numero_do_Pedido__c, CurrencyISOCode,
                    			Vendedor__r.Contact.cpf__c, Vendedor__r.name, Data_de_termino__c, Natureza_de_Opera_o__c
                        FROM    Order
                        WHERE   Id = :((SObject)controller.getRecord()).Id
                ];
        itens_pais = [
            			SELECT Product2.Name, Description, Product2.Marca__c, Product2.Modelo__c, Product2.ProductCode, Product2.PosicaoEstoque__c, Product2.Posicao_no_Estoque_153__c, UnitPrice, Quantity, TotalPrice, Status__c, Item__c, Item_Pai__c, Descricao_da_linha__c
            			FROM OrderItem
            			WHERE OrderId =: pedido.Id AND Item__c != null
            			ORDER BY Ordem__c
        			];
        itens_filhos = [
            			SELECT Product2.Name, Description, Product2.Marca__c, Product2.Modelo__c, Product2.ProductCode, Product2.PosicaoEstoque__c, Product2.Posicao_no_Estoque_153__c, UnitPrice, Quantity, TotalPrice, Status__c, Item__c, Item_Pai__c, Descricao_da_linha__c
            			FROM OrderItem
            			WHERE OrderId =: pedido.Id AND Item_pai__c != null 
            			ORDER BY Product2.Name
        			];
        itens_semN = [
            			SELECT Product2.Name, Description, Product2.Marca__c, Product2.Modelo__c, Product2.ProductCode, Product2.PosicaoEstoque__c, Product2.Posicao_no_Estoque_153__c, UnitPrice, Quantity, TotalPrice, Status__c, Item__c, Item_Pai__c, Descricao_da_linha__c
            			FROM OrderItem
            			WHERE OrderId =: pedido.Id AND Item_pai__c = null and Item__c = null
        			];
        itens_incorretos = [
            			SELECT Product2.Name, Description, Product2.Marca__c, Product2.Modelo__c, Product2.ProductCode, Product2.PosicaoEstoque__c, Product2.Posicao_no_Estoque_153__c, UnitPrice, Quantity, TotalPrice, Status__c, Item__c, Item_Pai__c, Descricao_da_linha__c
            			FROM OrderItem
            			WHERE OrderId =: pedido.Id AND Item_pai__c != null and Item__c != null
        			];
        itens_por_codigo = [
            			SELECT Product2.Name, Description, Product2.Marca__c, Product2.Modelo__c, Product2.ProductCode, Product2.PosicaoEstoque__c, Product2.Posicao_no_Estoque_153__c, UnitPrice, Quantity, TotalPrice, Status__c, Item__c, Item_Pai__c, Descricao_da_linha__c
            			FROM OrderItem
            			WHERE OrderId =: pedido.Id 
            			ORDER BY Product2.NAME
        			];
        itens_ag_entrega = [
            			SELECT Product2.Name, Description, Product2.Marca__c, Product2.Modelo__c, Product2.ProductCode, Product2.PosicaoEstoque__c, Product2.Posicao_no_Estoque_153__c, UnitPrice, Quantity, TotalPrice, Status__c, Item__c, Item_Pai__c, Descricao_da_linha__c, Numero_do_pedido_de_compra2__c, Prazo_de_recebimento_da_compra__c	
            			FROM OrderItem
            			WHERE OrderId =: pedido.Id AND Status__c like 'CMP%'
            			ORDER BY Product2.ProductCode
        			];
        if(itens_incorretos.size() > 0)
            divergencia = true;
        
         for (OrderItem item : itens_pais) {
            if (item.Description == null) continue;

            String description = item.Description.trim();
            String formattedDescription;

            if (description.startsWith('{')) {
                // Caso seja JSON
                try {
                    Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(description);
                    List<Object> dataList = (List<Object>) jsonData.get('data');
                    List<String> formattedLots = new List<String>();

                    for (Object dataItem : dataList) {
                        Map<String, Object> dataMap = (Map<String, Object>) dataItem;
                        formattedLots.add('Lote: ' + dataMap.get('lts') + ' — Qtd: ' + dataMap.get('qtd'));
                    }

                    formattedDescription = String.join(formattedLots, '; ');
                } catch (Exception e) {
                    System.debug('Erro ao processar JSON: ' + e.getMessage());
                    formattedDescription = 'Descrição inválida';
                }
            } else if (description.contains(',')) {
                // Caso seja uma lista de números de série
                List<String> serialNumbers = description.split(',');
                formattedDescription = 'Números de Série: ' + String.join(serialNumbers, ', ');
            } else {
                // Caso não seja nenhum dos dois formatos
                formattedDescription = 'Formato desconhecido: ' + description;
            }

            item.Description = formattedDescription;
        }
        
	}
}