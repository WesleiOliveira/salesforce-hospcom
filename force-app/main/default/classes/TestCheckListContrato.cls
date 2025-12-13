@isTest(seeAllData=true)
public class TestCheckListContrato {
 static testMethod void test_listagem_cs(){ 
        Contrato_de_Servi_o__c cs = new Contrato_de_Servi_o__c();
       /* cs = [
            SELECT 	Id
            FROM	Contrato_de_Servi_o__c
            WHERE	Id = '0WO3D000000D2R7'	// test:0WO3D000000D2R7 prod:0WO5A000000XezU
        ];
*/

        List<Ativos_do_Contrato__c> Ativosdocontrato = [
            SELECT  Ativo_Locado__c
            FROM    Ativos_do_Contrato__c
            WHERE   Id = 'a1h5A00000Dqt6W'
        ];

        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(cs);
            ContratoChecklist registro = new ContratoChecklist(stdCtrl);
		test.stopTest();
    }
    
    
}