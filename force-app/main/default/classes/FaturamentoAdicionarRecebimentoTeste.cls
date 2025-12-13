@isTest(SeeAllData=true)
public class FaturamentoAdicionarRecebimentoTeste { 
	
    static testMethod void Teste1(){ 
        Faturamento__c faturamento = new Faturamento__c();
        faturamento = [
            SELECT 	Id
            FROM	Faturamento__c
            WHERE	Id = 'a085A00001lcXyS'	//test:a085A00001lcXyS prod:a085A00001lcXyS
        ];

        test.startTest();
            ApexPages.StandardController controlador = new ApexPages.StandardController(faturamento);
            FaturamentoAdicionarRecebimento adicionador = new FaturamentoAdicionarRecebimento(controlador);
        	adicionador.Adicionar();
		test.stopTest();
    }
    
}