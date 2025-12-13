trigger EvitaDuplicatasTrigger on Despesa__c (before insert) {
    // Conjunto para armazenar as chaves de integração novas
    Set<String> chavesNovas = new Set<String>();

    // Mapeia o registro por chave, para marcar erro depois
    Map<String, Despesa__c> mapNovos = new Map<String, Despesa__c>();

    // Coleta todas as chaves do trigger.new
    for (Despesa__c est : Trigger.new) {
        if (est.Chave_despesa__c != null) {
            chavesNovas.add(est.Chave_despesa__c);
            mapNovos.put(est.Chave_despesa__c, est);
        }
    }

    // Consulta duplicados no banco
    Map<String, Despesa__c> duplicados = new Map<String, Despesa__c>();
    for (Despesa__c existente : [
        SELECT Id, Chave_despesa__c
        FROM Despesa__c
        WHERE Chave_despesa__c IN :chavesNovas
    ]) {
        duplicados.put(existente.Chave_despesa__c, existente);
    }

    // Adiciona erro aos que já existem
    for (String chave : duplicados.keySet()) {
        Despesa__c novoRegistro = mapNovos.get(chave);
        if (novoRegistro != null) {
            novoRegistro.addError('Já existe uma entrada de estoque com essa chave de integração.');
        }
    }
}