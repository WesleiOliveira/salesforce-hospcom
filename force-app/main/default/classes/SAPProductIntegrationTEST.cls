//Para rodar este teste desativar a trigger ProdutoPreenchimento e UpdateStandardPrices.
@isTest(seeAllData=true)
public class SAPProductIntegrationTEST {
	@isTest
    private static void SAPProductIntegration_TEST(){
        Test.startTest();

        Product2 updatedProduct = [SELECT Id, Observacoes__c, Integrado__c FROM Product2 WHERE Id = '01t5A000008DBk0QAG'];//01t5A000008DBk0QAG
        updatedProduct.Observacoes__c = updatedProduct.Observacoes__c + '.';
        update updatedProduct;

        //Product2 p = new Product2(Name='Test Product', Valor_de_Venda__c = 20000, Tipo_do_Produto__c='Peça', isActive=true);
        //insert p;
		//p.Name = 'Test';
		//update p;

        Test.stopTest();
    }    
     
}