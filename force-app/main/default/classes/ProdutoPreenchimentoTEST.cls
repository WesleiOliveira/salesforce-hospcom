@isTest(SeeAllData=true)
public class ProdutoPreenchimentoTEST {
    
    static testMethod void testAdder() {
        
        Pricebook2 pb = new Pricebook2(Name='Test', IsActive = true);
        insert pb;
        
        Product2 p2 = new Product2(Name='Test Product', Valor_de_Venda__c = 20000, Tipo_do_Produto__c='Peça', isActive=true);
        insert p2;
        
        Product2 p3 = new Product2(Name='Test Product', ProductCode = '182', Tipo_do_Produto__c='Peça', isActive=true);
        try{
            insert p3;
        }
        catch(DmlException e){
            
        }
    }
}