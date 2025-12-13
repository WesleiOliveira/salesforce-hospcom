@isTest(seeAllData=true)
public class OrdemDeTrabalhoTeste { 
	
    static testMethod void Teste1(){ 
        test.startTest();
		
		WorkOrder ordem_de_trabalho = new WorkOrder(
			AccountId = '001i00000087gnb',
			// ContactId = '00331000038okC5',
			Faturamento_Feito2__c = '001i00000085QYb',
			AssetId = '02i6e00000N7iqu',
			Data_Entrada_Equipamento__c = System.Today()-2,
			Subject = 'ot de teste',
			CreatedDate = System.Today(),
			Data_Agendada_para_Servi_o__c = System.Now()+1,
			Data_Prevista_para_o_Fim_do_Servi_o__c = System.Now()+2,
			RecordTypeId = '01231000000tb5gAAA',
			Categoria__c = 'AVULSO',
			Status = 'AGENDADO',
			Priority = 'MÉDIA',
			T_cnico_Respons_vel__c = 'TATIANE ALVES',
			Local_de_Atendimento__c = 'INTERNO'
		);
		insert ordem_de_trabalho;
        
        test.stopTest();
    }
	
    static testMethod void Teste2(){ 
        test.startTest();
		
		WorkOrder ordem_de_trabalho = new WorkOrder();
		ordem_de_trabalho = [select id from workorder where id = '0WO5A000002CmLV'];
		ordem_de_trabalho.ContactId = null;
		update ordem_de_trabalho;
        
        test.stopTest();
    }
	
    static testMethod void Teste3(){ 
        test.startTest();
		
		WorkOrder ordem_de_trabalho = new WorkOrder();
		ordem_de_trabalho = [select id from workorder where id = '0WO5A000000XfNg'];
		delete ordem_de_trabalho;
        
        test.stopTest();
    }
	
}