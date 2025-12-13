export async function querySolicitacao(controller, recordId, executeSoql) {
    // Adiciona aspas em torno do recordId para interpolação correta na query SOQL
    const query = `
    SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById,
           LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate,
           LastViewedDate, LastReferencedDate, ConnectionReceivedId, ConnectionSentId,
           Pedido__c, Faturamento__c, Status__c, Tipo__c, Quantidade_devolvida__c,
           PedidoGerado__c, Categoria__c, Erro_inserir_no_sap__c,
           Valor_total_da_Solicita_o__c, Observacoes__c
    FROM Solicita_o_de_devolu_o__c
    WHERE Id = '${recordId}'
  `;

    console.log('Query:', query);

    try {
        const result = await executeSoql({ soql: query });

        if (result && result.length > 0) {
            controller.sd = result[0];
            controller.isParcial = controller.sd.Tipo__c === 'Parcial';
            controller.statusIgualANovo = controller.sd.Status__c === 'Novo';

            console.log('Solicitacao loaded successfully:', controller.sd);
            return controller.sd;
        } else {
            console.warn('No records found for recordId:', recordId);
            controller.sd = null;
            controller.isParcial = false;
            return null;
        }
    } catch (error) {
        console.error('Error querying Solicitacao:', error);
        controller.sd = null;
        controller.isParcial = false;
        throw error;
    }
}


export async function queryOrderItens(controller, orderId, recordId, executeSoql, utils) {
    //controller.loadingOrderItens = true;

    try {
        // Query corrigida (whrere → where)
        const query = `SELECT Id, OrderId, Product2.Name, Imagem__c, Quantity, UnitPrice, Description
                      FROM OrderItem 
                      WHERE OrderId = '${orderId}'
                        AND ID NOT IN(SELECT Produto_do_pedido__c FROM Item_da_Solicita_o_de_devolu_o__c WHERE Solicita_o_de_devolu_o__c = '${recordId}')
                        AND Status__c in ('Aguardando conferência','Aguardando Coleta','Entregue Cliente','Faturado')
                      ORDER BY Product2.Name ASC`;

        console.log('Query:', query);

        const result = await executeSoql({ soql: query });

        if (result && result.length > 0) {
            // Processar os itens seguindo o padrão de loadContas
            const orderItensProcessados = result.map(item => {
                return {
                    id: item.Id,
                    orderId: item.OrderId,
                    productName: item.Product2?.Name ?? 'Produto não informado',
                    productNameFormatado: utils.truncateText(item.Product2?.Name || 'Produto não informado', 40),
                    imagem: item.Imagem__c ?? null,
                    quantity: item.Quantity ?? 0,
                    unitPrice: item.UnitPrice ?? 0, // Valor bruto para cálculos
                    unitPriceFormatado: utils.formatarValor(item.UnitPrice ?? 0), // Valor formatado para exibição
                    totalPrice: (item.Quantity ?? 0) * (item.UnitPrice ?? 0), // Total do item
                    totalPriceFormatado: utils.formatarValor((item.Quantity ?? 0) * (item.UnitPrice ?? 0)),
                    Description: item.Description || 'N/A'

                };
            });

            // Armazenar como array de objetos processados
            controller.orderItens = orderItensProcessados;

            // Calcular totais gerais
            const quantidadeTotal = controller.orderItens.reduce((soma, item) => soma + item.quantity, 0);
            const valorTotalItens = controller.orderItens.reduce((soma, item) => soma + item.totalPrice, 0);

            console.log(`✅ Order itens carregados: ${controller.orderItens.length} itens`);
            console.log(`📦 Quantidade total: ${quantidadeTotal}`);
            console.log(`💰 Valor total dos itens: ${utils.formatarValor(valorTotalItens)}`);

            return controller.orderItens;

        } else {
            console.warn('No order items found for orderId:', orderId);
            controller.orderItens = [];
            return [];
        }

    } catch (error) {
        console.error('Error querying OrderItem:', error);
        console.error('Query that failed:', query);
        controller.orderItens = [];
        throw error; // Re-throw to allow caller to handle
    } finally {
        // controller.loadingOrderItens = false;
        console.log("Order itens loading completed");
    }
}
export async function queryItensDaDevolucao(controller, recordId, executeSoql, utils) {
    try {
        const query = `SELECT Id, OrderId, Product2.Name, Imagem__c, Quantity, UnitPrice, Description
                      FROM OrderItem 
                      WHERE Id IN (
                          SELECT Produto_do_pedido__c FROM Item_da_Solicita_o_de_devolu_o__c 
                          WHERE Solicita_o_de_devolu_o__c = '${recordId}'
                      )
                      ORDER BY Product2.Name ASC`;

        console.log('Query Itens Devolução:', query);

        const result = await executeSoql({ soql: query });

        if (result && result.length > 0) {
            const itensDevolucaoProcessados = result.map(item => {
                const baseItem = {
                    id: item.Id,
                    orderId: item.OrderId,
                    productName: item.Product2?.Name ?? 'Produto não informado',
                    productNameFormatado: utils.truncateText(item.Product2?.Name || 'Produto não informado', 40),
                    imagem: item.Imagem__c ?? null,
                    quantity: item.Quantity ?? 0,
                    unitPrice: item.UnitPrice ?? 0,
                    unitPriceFormatado: utils.formatarValor(item.UnitPrice ?? 0),
                    totalPrice: (item.Quantity ?? 0) * (item.UnitPrice ?? 0),
                    totalPriceFormatado: utils.formatarValor((item.Quantity ?? 0) * (item.UnitPrice ?? 0)),
                    Description: item.Description || 'N/A'
                };

                // Adicionar propriedades de controle de quantidade para itens já devolvidos
                return {
                    ...baseItem,
                    returnQuantity: baseItem.quantity, // Quantidade atual para devolução
                    originalQuantity: baseItem.quantity, // Quantidade original do pedido
                    returnQuantityIsMin: baseItem.quantity <= 1,
                    returnQuantityIsMax: true
                };
            });

            controller.returnItems = itensDevolucaoProcessados;

            console.log(`✅ Itens de devolução carregados: ${controller.returnItems.length} itens`);
            return controller.returnItems;

        } else {
            console.log('Nenhum item de devolução encontrado para recordId:', recordId);
            controller.returnItems = [];
            return [];
        }

    } catch (error) {
        console.error('Error querying Itens de Devolução:', error);
        controller.returnItems = [];
        throw error;
    }
}