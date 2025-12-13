@isTest(seeAllData=true)
public class TesteChecklistAtivosdoContrato {
	static testMethod void TestedeContratoLocacao(){
            Contrato_de_Servi_o__c cs = new Contrato_de_Servi_o__c();    
            Ativos_do_Contrato__c ativodocontrato = new Ativos_do_Contrato__c(
            Ativo_Locado__c = '02i5A00000DWUl6',
            Contrato_de_Servico__c = 'a1Y5A000009wfoE'
        );
        insert ativodocontrato;
        
        test.startTest();
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ativodocontrato);
            checklistdeativo registro = new checklistdeativo(stdCtrl);
		test.stopTest();
    }
}