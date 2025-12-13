@isTest(seeAllData=true)
public class QuoteLineProdFilhoTest {
    @isTest static void teste1(){
        Test.startTest();
        QuoteLineItem ILC = new QuoteLineItem();
            ILC.QuoteId = '0Q06e000002r2vKCAQ';
        	ILC.Item__c = 1;
            ILC.Quantity = 1;
            ILC.Product2Id = '01t6e000009YctD';
            ILC.PricebookEntryId = '01u6e000019caK2';
            ILC.UnitPrice = 120000;
            insert ILC;
        QuoteLineItem ILC2 = new QuoteLineItem();
            ILC2.QuoteId = '0Q06e000002r2vKCAQ';
        	ILC2.Item__c = 2;
        	ILC2.Item_Pai__c = 1;
            ILC2.Quantity = 1;
            ILC2.Product2Id = '01t6e000009YctD';
            ILC2.PricebookEntryId = '01u6e000019caK2';
            ILC2.UnitPrice = 120000;
            insert ILC2;
        Test.stopTest();
    }
}