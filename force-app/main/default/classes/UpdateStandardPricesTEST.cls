@isTest(SeeAllData=true)
public class UpdateStandardPricesTEST {


    static testMethod void testAdder() {
        

        String pricebookid;

        // Using data from Org
        Pricebook2 pb = new Pricebook2(Name='Test', IsActive = true);
        insert pb;

        Product2 p2 = new Product2(Name='Test Product', Valor_de_Venda__c = 20000, Tipo_do_Produto__c='Peça', isActive=true);
        insert p2;

        // First insert a price for the standard price book
        Pricebook2 sPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry sPBE = new PricebookEntry(Pricebook2Id = sPB.Id, Product2Id = p2.Id, UnitPrice = 1000, IsActive = true);
        insert sPBE;

        
}
        static testMethod void teste2() {

    String pricebookid;

        // Using data from Org
        Pricebook2 pb = new Pricebook2(Name='Test', Description = 'Price Book 2009 Products', IsActive = true);
        insert pb;

        Product2 p2 = new Product2(Name='Test Product', Valor_de_Venda__c = 30000, Tipo_do_Produto__c='outros', isActive=true);
        insert p2;
        p2 = [SELECT Name, Valor_de_Venda__c, Tipo_do_Produto__c FROM Product2 WHERE Id =: p2.Id];
        System.assertEquals('Test Product', p2.Name);

        Pricebook2 sPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=sPB.Id, Product2Id=p2.Id, UnitPrice=30000, isActive=true);
        insert pbe;
        //pbe = [SELECT Name, UnitPrice FROM PricebookEntry WHERE Id =: pbe.Id];
        //System.assertEquals(p2.Valor_de_Venda__c, pbe.UnitPrice);
       }
}