@isTest(SeeAllData=true)
private class AtivoDoContratoDuplicadoTest {
    
    static testMethod void testAdder() {
        Ativos_do_Contrato__c Atv = New Ativos_do_Contrato__c(Ativo_Locado__c='02i6e00000N5nRa', Contrato_de_Servico__c='a1Y6e00000BXtSd', Item_do_Contrato__c = 3, Valor_Unitario_Mensal__c = 1, Quantidade__c = 1, Data_de_entrega__c = system.today(), Local_de_Entrega__c = 'Teste' );
		insert Atv;
}
}