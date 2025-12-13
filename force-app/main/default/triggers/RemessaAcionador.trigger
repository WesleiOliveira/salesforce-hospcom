trigger RemessaAcionador on Order (after update) {
    // Lista de pedidos que tiveram o campo NSs__c preenchido
    List<Id> ordersWithNSs = new List<Id>();
    
    for (Order ord : Trigger.new) {
        // Verifica se NSs__c foi preenchido e mudou em relação ao valor anterior
        if (!String.isBlank(ord.NSs__c) && String.isBlank(Trigger.oldMap.get(ord.Id).NSs__c)) {
            ordersWithNSs.add(ord.Id);
        }
    }
    
    // Se houver pedidos com NSs__c preenchido, chama a classe
    if (!ordersWithNSs.isEmpty()) {
        for (Id orderId : ordersWithNSs) {
            try {
                ItensRemessa.createOrderItems(orderId);
            } catch (Exception e) {
                // Gerencie exceções, registre logs ou envie mensagens de erro, conforme necessário
                System.debug('Erro ao criar OrderItems: ' + e.getMessage());
            }
        }
    }
}