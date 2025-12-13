public class vinculaConsumiveis {
    @AuraEnabled
    public static String sendSelectedItems(String comodatoItemId, List<String> orderItemIds, Integer quantity) {
        // Lógica para processar os IDs recebidos
        System.debug('ID do item de Comodato: ' + comodatoItemId);
        System.debug('IDs dos itens de pedido: ' + orderItemIds);
        
        List<Vinculo_de_venda_consumivel__c> vinculos = new List<Vinculo_de_venda_consumivel__c>();
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();  // Lista para armazenar os OrderItems a serem atualizados
        
        // Consultando todos os OrderItems que precisam ser atualizados
        List<OrderItem> orderItems = [SELECT Id, Quantidade_vinculada_comodato__c FROM OrderItem WHERE Id IN :orderItemIds];
        
        for (String orderItemId : orderItemIds) {
            Vinculo_de_venda_consumivel__c vvc = new Vinculo_de_venda_consumivel__c();
            vvc.Produto_do_pedido__c = orderItemId;
            vvc.Ativo_do_comodato__c = comodatoItemId;
            vvc.Quantidade__c = quantity;
            vinculos.add(vvc);
            
            // Encontrando o OrderItem correspondente e somando a quantidade
            for (OrderItem oi : orderItems) {
                if (oi.Id == orderItemId) {
                    // Atualizando o campo Quantidade_vinculada_comodato__c
                    oi.Quantidade_vinculada_comodato__c = (oi.Quantidade_vinculada_comodato__c != null ? oi.Quantidade_vinculada_comodato__c : 0) + quantity;
                    orderItemsToUpdate.add(oi);
                }
            }
        }
        
        try {
            // Inserindo os novos vínculos
            // Atualizando os OrderItems com as novas quantidades
            if (!orderItemsToUpdate.isEmpty()) {
                update orderItemsToUpdate;
            }
            insert vinculos;       
            
            
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String sendSelectedItems2(String comodatoItemId, List<String> consumiveis, Integer quantity) {
        // Lógica para processar os IDs recebidos
        System.debug('ID do item de Comodato: ' + comodatoItemId);
        System.debug('IDs dos itens de pedido: ' + consumiveis);
        
        List<Vinculo_consumivel_requerido__c> vinculos = new List<Vinculo_consumivel_requerido__c>();
        List<Consumivel_de_comodato__c> consumiveisToUpdate = new List<Consumivel_de_comodato__c>();  // Lista para armazenar os OrderItems a serem atualizados
        
        // Consultando todos os OrderItems que precisam ser atualizados
        List<Consumivel_de_comodato__c> consumiveisIds = [SELECT Id, Quantidade_vinculada__c FROM Consumivel_de_comodato__c WHERE Id IN :consumiveis];
        
        for (String consumivelId : consumiveis) {
            Vinculo_consumivel_requerido__c vvc = new Vinculo_consumivel_requerido__c();
            vvc.Consum_vel_de_comodato__c = consumivelId;
            vvc.Ativo_do_comodato__c = comodatoItemId;
            vvc.Quantidade__c = quantity;
            vinculos.add(vvc);
            
            // Encontrando o OrderItem correspondente e somando a quantidade
            for (Consumivel_de_comodato__c oi : consumiveisIds) {
                if (oi.Id == consumivelId) {
                    // Atualizando o campo Quantidade_vinculada_comodato__c
                    oi.Quantidade_vinculada__c = (oi.Quantidade_vinculada__c != null ? oi.Quantidade_vinculada__c : 0) + quantity;
                    consumiveisToUpdate.add(oi);
                }
            }
        }
        
        try {
            // Inserindo os novos vínculos
            // Atualizando os OrderItems com as novas quantidades
            if (!consumiveisToUpdate.isEmpty()) {
                update consumiveisToUpdate;
            }
            insert vinculos;       
            
            
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> executeSoql(String soql) {
        List<sObject> result = Database.query(soql);
        return result;
        
    }
}