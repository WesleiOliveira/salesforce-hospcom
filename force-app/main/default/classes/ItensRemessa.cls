public class ItensRemessa {
    public static void createOrderItems(Id orderId) {
        // Recupera o ID do usuário atual
        Id currentUserId = UserInfo.getUserId();

        try {
            // Marca o campo Ignorar_erros__c como true
            User currentUser = [SELECT Id, Ignorar_erros__c FROM User WHERE Id = :currentUserId LIMIT 1];
            currentUser.Ignorar_erros__c = true;
            update currentUser;

            // Recupera o pedido e o campo NSs__c
            Order order = [SELECT Id, Pricebook2Id, NSs__c, CurrencyISOCode FROM Order WHERE Id = :orderId LIMIT 1];

            if (String.isBlank(order.NSs__c)) {
                throw new CustomException('O campo NSs__c está vazio.');
            }

            // Extrai os números de série do campo NSs__c
            List<String> serialNumbers = order.NSs__c.split(',');

            // Consulta os ativos com base nos números de série
            List<Asset> assets = [SELECT Id, SerialNumber, Product2.ProductCode, Product2Id
                                  FROM Asset
                                  WHERE SerialNumber IN :serialNumbers];

            if (assets.isEmpty()) {
                throw new CustomException('Nenhum ativo correspondente encontrado para os números de série fornecidos.');
            }

            // Agrupa os ativos por ProductCode
            Map<String, List<String>> productCodeToSerials = new Map<String, List<String>>();
            Map<String, Id> productCodeToProductId = new Map<String, Id>();
            for (Asset asset : assets) {
                if (!productCodeToSerials.containsKey(asset.Product2.ProductCode)) {
                    productCodeToSerials.put(asset.Product2.ProductCode, new List<String>());
                }
                productCodeToSerials.get(asset.Product2.ProductCode).add(asset.SerialNumber);
                productCodeToProductId.put(asset.Product2.ProductCode, asset.Product2Id);
            }

            // Consulta as entradas de tabela de preços para os produtos
            List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, Product2.ProductCode
                                                     FROM PricebookEntry
                                                     WHERE Product2Id IN :productCodeToProductId.values()
                                                     AND Pricebook2Id = :order.Pricebook2Id
                                                     AND CurrencyISOCode = :order.CurrencyISOCode
                                                     AND IsActive = true];

            Map<String, Id> productCodeToPricebookEntryId = new Map<String, Id>();
            for (PricebookEntry pbe : pricebookEntries) {
                productCodeToPricebookEntryId.put(pbe.Product2.ProductCode, pbe.Id);
            }

            // Cria os OrderItems
            List<OrderItem> orderItemsToInsert = new List<OrderItem>();
            for (String productCode : productCodeToSerials.keySet()) {
                if (!productCodeToPricebookEntryId.containsKey(productCode)) {
                    throw new CustomException('Nenhuma entrada de tabela de preços encontrada para o produto: ' + productCode);
                }

                List<String> serialsList = productCodeToSerials.get(productCode);
                String serials = String.join(serialsList, ', ');
                Integer quantity = serialsList.size(); // Define a quantidade com base no número de ativos

                orderItemsToInsert.add(new OrderItem(
                    OrderId = order.Id,
                    PricebookEntryId = productCodeToPricebookEntryId.get(productCode),
                    Quantity = quantity,
                    UnitPrice = 0, 
                    Status__c = 'Novo',
                    Numeros_de_serie__c = serials
                ));
            }

            if (!orderItemsToInsert.isEmpty()) {
                insert orderItemsToInsert;
            }
        } catch (Exception e) {
            // Registra o erro para depuração ou envia uma mensagem apropriada
            System.debug('Erro ao criar OrderItems: ' + e.getMessage());
            throw e;
        } finally {
            // Redefine o campo Ignorar_erros__c para false
            User currentUser = [SELECT Id, Ignorar_erros__c FROM User WHERE Id = :currentUserId LIMIT 1];
            currentUser.Ignorar_erros__c = false;
            update currentUser;
        }
    }

    // Exceção personalizada para erros na lógica
    public class CustomException extends Exception {}
}