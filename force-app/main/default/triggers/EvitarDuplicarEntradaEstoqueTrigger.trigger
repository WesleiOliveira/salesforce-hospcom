trigger EvitarDuplicarEntradaEstoqueTrigger on Entrada_de_Estoque__c (before insert) {
    // Conjunto para armazenar as chaves de integração novas
    Set<String> chavesNovas = new Set<String>();

    // Mapeia o registro por chave, para marcar erro depois
    Map<String, Entrada_de_Estoque__c> mapNovos = new Map<String, Entrada_de_Estoque__c>();

    // Coleta todas as chaves do trigger.new
    for (Entrada_de_Estoque__c est : Trigger.new) {
        if (est.chave_integracao__c != null) {
            chavesNovas.add(est.chave_integracao__c);
            mapNovos.put(est.chave_integracao__c, est);
        }
    }

    // Consulta duplicados no banco
    Map<String, Entrada_de_Estoque__c> duplicados = new Map<String, Entrada_de_Estoque__c>();
    for (Entrada_de_Estoque__c existente : [
        SELECT Id, chave_integracao__c
        FROM Entrada_de_Estoque__c
        WHERE chave_integracao__c IN :chavesNovas
    ]) {
        duplicados.put(existente.chave_integracao__c, existente);
    }

    // Adiciona erro aos que já existem
    for (String chave : duplicados.keySet()) {
        Entrada_de_Estoque__c novoRegistro = mapNovos.get(chave);
        if (novoRegistro != null) {
            novoRegistro.chave_integracao__c.addError('Já existe uma entrada de estoque com essa chave de integração.');
        }
    }
}