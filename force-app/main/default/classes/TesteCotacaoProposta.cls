@isTest(seeAllData=true)
public class TesteCotacaoProposta {

        public Quote cotacao {get;set;}


 static testMethod void test_listagem_quote(){ 
             
        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Quote(Id = '0Q05A000002K66i'));
            CotacaoProposta registro = new CotacaoProposta(stdCtrl);
     
     update new opportunity(Id = '0065A00001YANlP', Faturamento_Feito2__c = '0015A00001yGbVZ');
     	 CotacaoProposta registro2 = new CotacaoProposta(stdCtrl);
     
     update new opportunity(Id = '0065A00001YANlP', Faturamento_Feito2__c = '0015A00001tSrPa');
     	 CotacaoProposta registro3 = new CotacaoProposta(stdCtrl);
     
     update new opportunity(Id = '0065A00001YANlP', Faturamento_Feito2__c = '0015A00002SZiBc');
     	 CotacaoProposta registro4 = new CotacaoProposta(stdCtrl);
     
		test.stopTest();
     
    } 
    static testMethod void test_listagem_quote2(){ 
             
        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Quote(Id = '0Q05A000002K66i'));
            NovaPropostaComercial registro = new NovaPropostaComercial(stdCtrl);
     
     update new opportunity(Id = '0065A00001YANlP', Faturamento_Feito2__c = '0015A00001yGbVZ');
     	 NovaPropostaComercial registro2 = new NovaPropostaComercial(stdCtrl);
     
     update new opportunity(Id = '0065A00001YANlP', Faturamento_Feito2__c = '0015A00001tSrPa');
     	 NovaPropostaComercial registro3 = new NovaPropostaComercial(stdCtrl);
     
     update new opportunity(Id = '0065A00001YANlP', Faturamento_Feito2__c = '0015A00002SZiBc');
     	 NovaPropostaComercial registro4 = new NovaPropostaComercial(stdCtrl);
     
		test.stopTest();
     
    } 
}