trigger AtivoDoContratoDuplicado on Ativos_do_Contrato__c (before insert) {
	// Set to store Contratos ids
	Set <Id> contratoSet = new Set<Id>();
	// Set to store Ativos numbers
	Set <Id> ativoSet = new Set<Id>();
 
	// Iterate through each Ativos_do_Contrato__c and add their Contratos and Ativos to their respective Sets
	for (Ativos_do_Contrato__c atv:trigger.new) {
	contratoSet.add(atv.Contrato_de_Servico__c);
	ativoSet.add(atv.Ativo_Locado__c);
	}
 
	// New list to store the found Contratos and Ativos numbers
	List <Ativos_do_Contrato__c> ativoContr = new List<Ativos_do_Contrato__c>();
 
	// Populating the list using SOQL
	ativoContr = [SELECT Contrato_de_Servico__c, Ativo_Locado__c FROM Ativos_do_Contrato__c WHERE Contrato_de_Servico__c IN :contratoSet AND Ativo_Locado__c IN :ativoSet];
 
	// Iterating through each Ativos_do_Contrato__c record to see if the same Contrato and Ativo was found
	for (Ativos_do_Contrato__c atv:trigger.new) {
	If (ativoContr.size() > 0) {
	// Displaying the error
	atv.Ativo_Locado__c.adderror( 'Este ativo já está vinculado a este contrato.' );
}
}
}