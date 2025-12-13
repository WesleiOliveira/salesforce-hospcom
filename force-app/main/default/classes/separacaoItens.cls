public class separacaoItens {
    
	@AuraEnabled
    public static void salvaComentario(String comentario, Id orderId) {
        // Obtém o ID da Ordem associada ao contexto atual (se necessário, ajuste a lógica para determinar a ordem correta)
        // Aqui vamos usar um exemplo genérico, assumindo que o ID da Ordem está disponível no contexto ou passado como parâmetro.
        
        // Simulação de ID da ordem (em uma implementação real, este ID viria do front-end ou lógica específica)
        //Id orderId = 'a0123456789ABCDE'; // Substituir por lógica de obtenção do ID correto
        
        // Validações básicas
        if (String.isBlank(comentario)) {
            throw new AuraHandledException('O comentário não pode estar vazio.');
        }
        
        // Consulta a Ordem
        Order ord = [SELECT Id, Comentarios__c FROM Order WHERE Id = :orderId LIMIT 1];
        
        // Atualiza o campo Comentarios__c
        ord.Comentarios__c = comentario;
        
        // Salva a alteração no banco
        try {
            update ord;
        } catch (DmlException e) {
            throw new AuraHandledException('Erro ao salvar o comentário: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void salvaNS(String json) {
        // Remover colchetes iniciais e finais da string JSON
        json = json.substring(1, json.length() - 1);
        
        // Separar os itens usando "},{"
        List<String> itens = json.split('},\\{');
        
        // Lista para armazenar os OrderItems a serem atualizados
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        Map<Id, String> idParaNumerosSerie = new Map<Id, String>(); // Map para armazenar o número de série por ID
        
        // Iterar sobre cada item na lista separada
        for (String item : itens) {
            // Limpar espaços em branco
            item = item.trim();
            
            // Extrair ID e Número de Série
            String idProduto = item.substringAfter('"idItem":"').substringBefore('",');
            String ns = item.substringAfter('"NumerosSerie":"').substringBefore('"}').replace('"', ''); // Remover aspas a mais
            
            // Adicionar ao mapa
            idParaNumerosSerie.put(Id.valueOf(idProduto), ns);
        }
        
        // Buscar os OrderItems de uma vez
        List<OrderItem> orderItems = [SELECT Id, OrderId FROM OrderItem WHERE Id IN :idParaNumerosSerie.keySet()];
        
        // Atualizar a descrição dos OrderItems e capturar o OrderId
        Id idPedido = null;
        for (OrderItem oi : orderItems) {
            // Atualizar a descrição com o número de série correto
            if (idParaNumerosSerie.containsKey(oi.Id)) {
                oi.Description = idParaNumerosSerie.get(oi.Id);
                idPedido = oi.OrderId; // Captura o OrderId
                orderItemsToUpdate.add(oi);
            }
        }
        
        // Buscar o pedido correspondente ao OrderId
        if (idPedido != null) {
            Order pedido = [SELECT Id, separado__c, Separado_por__c FROM Order WHERE Id = :idPedido LIMIT 1];
            // Atualizar os campos do pedido
            if (pedido != null) {
                pedido.separado__c = true;
                pedido.Separado_por__c = UserInfo.getUserId();
                
                // Atualizar os OrderItems e o pedido
                try {
                    update orderItemsToUpdate;
                    update pedido;
                } catch (DmlException e) {
                    System.debug('Um erro ocorreu: ' + e.getMessage());
                }
            }
        }
    }
}