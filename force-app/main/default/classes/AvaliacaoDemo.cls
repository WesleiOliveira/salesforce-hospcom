public class AvaliacaoDemo {
    public Order pedido 									{get;set;}
    public avaliacaoDeDemonstracao__c avaliacao				{get;set;}
    public List<OrderItem> itens	 						{get;set;}
    
	public AvaliacaoDemo(ApexPages.StandardController controller) {
        
        avaliacao = [SELECT ID, Pedido__c FROM avaliacaoDeDemonstracao__c WHERE ID = :((SObject)controller.getRecord()).Id];
        
        pedido = [
                        SELECT  Account.RecordType.Name, Account.Raz_o_Social__c, Account.Name, Account.CNPJ__c, Account.CPF__pc, Data_da_demonstracao__c,
                    			Tempo_de_demonstracao__c, Faturamento_feito__r.Raz_o_Social__c, Faturamento_feito__r.CNPJ__c, Faturamento_feito__r.BillingCity, 
                    			TotalAmount, BillingStreet, BillingCity, BillingState, BillingPostalCode, Numero_do_Pedido__c, CurrencyISOCode,
                    			Vendedor__r.Contact.cpf__c, Vendedor__r.name, Data_de_termino__c, Natureza_de_Opera_o__c
                        FROM    Order
                        WHERE   Id = : avaliacao.Pedido__c
                ];
        
        itens = [SELECT ID, Product2Id, Product2.Name, Product2.ProductCode, Product2.Modelo__c, Product2.Marca__c, Description, Quantity FROM OrderItem WHERE OrderId = :pedido.ID];
    }
}