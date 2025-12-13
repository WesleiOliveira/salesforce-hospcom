@isTest(seeAllData=true)
public class Checklist_de_Aditivo_Test {
 static testMethod void test_listagem_cs(){ 
        Aditivos_Contratuais__c ac = new Aditivos_Contratuais__c();
        ac = [
            SELECT 	Id
            FROM	Aditivos_Contratuais__c
            WHERE	Id = 'a1j6e000008duk6'	// test:0WO3D000000D2R7 prod:0WO5A000000XezU
        ];


        List<Aditivo_Relacionado__c> Ativosdocontrato = [
            SELECT  Ativo_do_Contrato_Relacionado__r.Ativo_Locado__c
            FROM    Aditivo_Relacionado__c
            WHERE   Aditivo_Contratual_Relacionado__c = 'a1j6e000008duk6'
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ac);
            CheckList_de_Aditivo_Controller registro = new CheckList_de_Aditivo_Controller(stdCtrl);
		test.stopTest();
    }
    
    
}