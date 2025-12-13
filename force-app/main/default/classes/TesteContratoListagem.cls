@isTest(SeeAllData=true)
public class TesteContratoListagem { 
	
    static testMethod void Test1(){
        
       
        Contrato_de_Servi_o__c cs = [SELECT Id FROM Contrato_de_Servi_o__c WHERE Id = 'a1Y6e00000C3Ss5EAF' LIMIT 1];
        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(cs);
            ContratoListagem LoopExampleExec = new ContratoListagem(stdCtrl);
		test.stopTest();
    }
    
}