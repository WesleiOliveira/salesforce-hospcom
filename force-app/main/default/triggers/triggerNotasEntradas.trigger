trigger triggerNotasEntradas on Nota_fiscal_de_pedido_de_compra__c (before insert) {
    Set<String> nomes = new Set<String>();
    Set<Id> pedidos = new Set<Id>();

    // Coleta nomes e pedidos das novas notas
    for (Nota_fiscal_de_pedido_de_compra__c nf : Trigger.new) {
        if (nf.Name != null) nomes.add(nf.Name);
        if (nf.Pedido_de_Compra__c != null) pedidos.add(nf.Pedido_de_Compra__c);
    }

    // Busca registros existentes que possam ser duplicados
    List<Nota_fiscal_de_pedido_de_compra__c> existentes = [
        SELECT Id, Name, Pedido_de_Compra__c
        FROM Nota_fiscal_de_pedido_de_compra__c
        WHERE Name IN :nomes AND Pedido_de_Compra__c IN :pedidos
    ];

    // Valida duplicidade (só bloqueia se os dois coincidirem)
    for (Nota_fiscal_de_pedido_de_compra__c nf : Trigger.new) {
        for (Nota_fiscal_de_pedido_de_compra__c existente : existentes) {
            if (
                nf.Name == existente.Name &&
                nf.Pedido_de_Compra__c == existente.Pedido_de_Compra__c
            ) {
                nf.addError('Já existe uma Nota Fiscal com o mesmo Nome e Pedido de Compra.');
            }
        }
    }
}










/*trigger triggerNotasEntradas on Nota_fiscal_de_pedido_de_compra__c (before insert) {
    Set<String> nomes = new Set<String>();
    Set<String> pedidos = new Set<String>();

    // Coleta todos os nomes e pedidos que estão sendo inseridos
    for (Nota_fiscal_de_pedido_de_compra__c nf : Trigger.new) {
        if (nf.Name != null) {
            nomes.add(nf.Name);
        }
        if (nf.Pedido_de_Compra__c != null) {
            pedidos.add(nf.Pedido_de_Compra__c);
        }
    }

    // Busca registros já existentes com o mesmo Name ou Pedido de Compra
    Map<String, Nota_fiscal_de_pedido_de_compra__c> duplicadosPorNome = new Map<String, Nota_fiscal_de_pedido_de_compra__c>();
    Map<String, Nota_fiscal_de_pedido_de_compra__c> duplicadosPorPedido = new Map<String, Nota_fiscal_de_pedido_de_compra__c>();

    for (Nota_fiscal_de_pedido_de_compra__c existente : [
        SELECT Id, Name, Pedido_de_Compra__c
        FROM Nota_fiscal_de_pedido_de_compra__c
        WHERE Name IN :nomes OR Pedido_de_Compra__c IN :pedidos
    ]) {
        duplicadosPorNome.put(existente.Name, existente);
        if (existente.Pedido_de_Compra__c != null)
            duplicadosPorPedido.put(existente.Pedido_de_Compra__c, existente);
    }

    // Valida duplicações
    for (Nota_fiscal_de_pedido_de_compra__c nf : Trigger.new) {
        if ((nf.Name != null && duplicadosPorNome.containsKey(nf.Name)) ||
            (nf.Pedido_de_Compra__c != null && duplicadosPorPedido.containsKey(nf.Pedido_de_Compra__c))) {
            nf.addError('Já existe uma Nota Fiscal com o mesmo Nome ou Pedido de Compra.');
        }
    }


}*/