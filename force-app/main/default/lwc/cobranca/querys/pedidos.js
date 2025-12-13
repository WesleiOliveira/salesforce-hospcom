// ./querys/pedidos

export async function load(controller, AccountId, executeSoql, utils) {
    console.log("Loading orders");
    controller.pedidosIsLoading = true;

    // Validação de entrada
    if (!AccountId) {
        console.warn('AccountId não fornecido para loadPedidos');
        controller.pedidos = [];
        return;
    }

    const query = `SELECT
                        Id,
                        OrderNumber,
                        EffectiveDate,
                        TotalAmount,
                        Status
                    FROM Order
                    WHERE AccountId = '${AccountId}'
                    ORDER BY EffectiveDate DESC`;

    try {
        const result = await executeSoql({ soql: query });

        if (result && result.length > 0) {
            // Processar os dados se necessário
            controller.pedidos = result.map(pedido => ({
                ...pedido,

                // Formatação de data se necessário
                EffectiveDate: new Date(pedido.EffectiveDate).toLocaleDateString('pt-BR'),
                TotalAmount: utils.formatarValor(pedido.TotalAmount)
            }));
        } else {
            console.log('Nenhum pedido encontrado para a conta:', AccountId);
            controller.pedidos = [];
        }

    } catch (err) {
        console.error('Erro ao carregar pedidos:', err);
        controller.pedidos = null;

        // Tratamento específico de erros
        if (err.message?.includes('INVALID_FIELD')) {
            console.error('Campo inválido na query. Verifique se todos os campos existem no objeto Order.');
        }

        throw err; // Re-throw para permitir tratamento upstream
    } finally { controller.pedidosIsLoading = false; }
}
export async function loadPedidosDeContasAReceber(controller, contasAReceber) {
    console.log("Filtrando pedidos de contas a receber");

    // Validação de entrada
    if (!contasAReceber || !Array.isArray(contasAReceber) || contasAReceber.length === 0) {
        console.warn('contasAReceber não fornecido ou vazio para loadPedidosDeContasAReceber');
        controller.pedidosContasReceber = [];
        return;
    }

    // Validar se os pedidos já foram carregados
    if (!controller.pedidos || !Array.isArray(controller.pedidos)) {
        console.warn('controller.pedidos não está carregado. Execute load() primeiro.');
        controller.pedidosContasReceber = [];
        return;
    }

    try {
        // Extrair os IDs dos pedidos das contas a receber (campo Pedido__c)
        const pedidosIds = contasAReceber
            .map(conta => conta.Pedido__c)
            .filter(id => id) // Remove valores null/undefined/vazios
            .filter((id, index, array) => array.indexOf(id) === index); // Remove duplicatas

        if (pedidosIds.length === 0) {
            console.warn('Nenhum ID de pedido válido encontrado nas contas a receber');
            controller.pedidosContasReceber = [];
            return;
        }

        console.log(`Filtrando ${pedidosIds.length} pedidos únicos das contas a receber`);

        // Filtrar pedidos que já estão carregados no controller
        controller.pedidosContasReceber = controller.pedidos
            .filter(pedido => pedidosIds.includes(pedido.Id))
            .map(pedido => ({
                ...pedido,
                // Adicionar informações das contas a receber relacionadas
                contasReceberRelacionadas: contasAReceber.filter(conta => conta.Pedido__c === pedido.Id)
            }));

        console.log(`✅ ${controller.pedidosContasReceber.length} pedidos filtrados das contas a receber`);

        // Log de debug para verificar correspondências
        const pedidosEncontrados = controller.pedidosContasReceber.map(p => p.Id);
        const pedidosNaoEncontrados = pedidosIds.filter(id => !pedidosEncontrados.includes(id));

        if (pedidosNaoEncontrados.length > 0) {
            console.warn(`⚠️ ${pedidosNaoEncontrados.length} pedidos não encontrados em controller.pedidos:`, pedidosNaoEncontrados);
        }

    } catch (err) {
        console.error('Erro ao filtrar pedidos das contas a receber:', err);
        controller.pedidosContasReceber = [];
        throw err;
    }
}