trigger enviaContratoFornecimento on Contrato_de_Fornecimento_de_Insumo__c (after update) {
    
    for (Contrato_de_Fornecimento_de_Insumo__c ctr : Trigger.new) {
        if (ctr.Status__c == 'Aprovado' && Trigger.oldMap.get(ctr.Id).Status__c != 'Aprovado') {
            Clicksign.enviarContratoFornecimento(ctr.Id);
        }
    }
}