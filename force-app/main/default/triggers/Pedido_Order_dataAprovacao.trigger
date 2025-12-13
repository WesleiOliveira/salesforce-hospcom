trigger Pedido_Order_dataAprovacao on Order (before update) {
    List<Order> ordersToUpdate = new List<Order>();

    try {
        for (Order order : Trigger.new) {
            if (order.Status != 'Rascunho' && order.Status != 'Desativado' && order.Status != 'Ativo' && order.Status != 'Em Andamento' && order.Status != 'Reprovado' && order.Status != 'Cancelado' && order.Status != 'Finalizado') {
                ProcessInstance approvalProcessInstance = [
                    SELECT Id, TargetObjectId, CreatedDate
                    FROM ProcessInstance
                    WHERE TargetObjectId = :order.Id
                    AND Status = 'Approved'
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

                if (approvalProcessInstance != null) {
                    Date approvalDate = approvalProcessInstance.CreatedDate.date();
                    order.Data_de_aprova_o_do_PV__c = approvalDate;
                    ordersToUpdate.add(order);
                }
            }
        }

        // Move a operação de atualização para fora do loop
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    } catch(Exception e) {
        System.debug('Error: ' + e);
    }
}