//Carrega contas disponiveis
//Variaves de controle para paginação em lote
export let offset = 0;
export let limit = 20;

// Track current filters to detect changes
let currentFilters = {
    nomeDaConta: '',
    fila: '',
    regua: ''
};
// Helper function para truncar texto
const truncateText = (text, maxLength = 25) => {
    if (!text) return 'Não fornecido';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength).trim() + '...';
};


export async function loadContas(nomeDaConta, fila, regua, controller, utils, executeSoql, forceReset = false) {
    controller.loadingContas = true;

    //  FILTROS PARA ACCOUNT (Conta)
    let filtrosAccount = '';

    // Nome da conta (busca)
    const termo = nomeDaConta.trim(); 
    filtrosAccount += ` AND (Raz_o_Social__c LIKE '%${termo}%' 
                            OR CNPJ__c LIKE '%${termo}%' 
                            OR Name LIKE '%${termo}%' 
                            OR CPF__pc LIKE '%${termo}%')`;

    if (fila && fila !== 'todos') {
        filtrosAccount += ` AND Ownership = '${fila}'`;
    }

    //  FILTROS PARA COBRANCA__C
    let filtrosCobranca = '';

    // Sempre filtrar por valor diferente de 0
    filtrosCobranca += ' AND Valor_a_pagar__c != 0';

    if (regua && regua !== '') {
        filtrosCobranca += ` AND Atraso__c <= ${regua}`;
    }

    //console.log("Filtros Account:", filtrosAccount);
    //console.log("Filtros Cobranca:", filtrosCobranca);
    //console.log("Current filters:", { nomeDaConta, fila, regua });

    const filtersChanged = (
        currentFilters.nomeDaConta !== nomeDaConta ||
        currentFilters.fila !== fila ||
        currentFilters.regua !== regua ||
        forceReset
    );

    if (filtersChanged) {
        //console.log("🔄 FILTERS CHANGED - Resetting pagination and replacing data");
        // Reset pagination for new search/filter
        offset = 0;
        controller.hasMore = true;
        controller.contas = []; // Clear existing data

        // Update current filters tracking
        currentFilters = { nomeDaConta, fila, regua };
    } else {
        //console.log("📄 PAGINATION - Appending more data");
    }

    if (!controller.hasMore) {
        controller.loadingContas = false;
        return;
    }

    //console.log(`Loading with offset: ${offset}, limit: ${limit}`);

    //  QUERY COM FILTROS SEPARADOS
    const soqlContas = `
        SELECT Id, Type, Name, Tipo__c,
               Telefone_do_ultimo_contato__c,
               Total_em_aberto__c,
               Phone,
               Raz_o_Social__c,
               CNPJ__c,
               Email_do_ltimo_contato__c,
               Key_Account__c,
               CPF__pc, 
               Score__c
        FROM Account
        WHERE Id IN (
            SELECT Conta__c
            FROM Cobranca__c
            WHERE Id != ''
              ${filtrosCobranca}
        )
        AND Id != ''
        ${filtrosAccount}
        ORDER BY Raz_o_Social__c, Name ASC
        LIMIT ${limit} OFFSET ${offset}
    `;

    //console.log("Query final:", soqlContas);

    try {
        //console.log("Passou aqui 1 ")
        const contasResult = await executeSoql({ soql: soqlContas });

        // Check if we have more pages
        if (contasResult.length < limit) {
            controller.hasMore = false;
            //console.log("No more pages available");
        }

        //console.log("Passou aqui 2")

        const contaIds = contasResult.map(conta => conta.Id);
        const soqlSomas = `
            SELECT Conta__c, SUM(Valor_a_pagar__c) totalCobrancas, COUNT(Id) quantidadeCobrancas
            FROM Cobranca__c
            WHERE Conta__c IN ('${contaIds.join("', '")}')
              ${filtrosCobranca}
            GROUP BY Conta__c`;

        //console.log("Query de somas:", soqlSomas);
        const somasResult = await executeSoql({ soql: soqlSomas });
        //console.log("Passou aqui 3")
        // Criar mapa de somas para lookup eficiente
        const somasMap = {};
        somasResult.forEach(soma => {
            somasMap[soma.Conta__c] = {
                total: soma.totalCobrancas || 0,
                quantidade: soma.quantidadeCobrancas || 0
            };
        });


        //console.log("Passou aqui 4")

        // Processar contas com os valores das cobranças
        const contasComValores = contasResult.map(conta => {
            const somaCobrancas = somasMap[conta.Id] || { total: 0, quantidade: 0 };
            const nome = conta.Raz_o_Social__c || conta.Name;
            //console.log("Passou aqui 5")
            let identificador;
            let identificadorLabel;
            if (conta.CNPJ__c) {
                identificador = `CNPJ: ${conta.CNPJ__c}`;
                identificadorLabel = 'CNPJ'
            }
            if (conta.CPF__pc) {
                identificadorLabel = 'CPF'
                identificador = `CPF: ${conta.CPF__pc}`;
            }


            return {
                id: conta.Id,
                nome: nome || 'Não fornecido',
                nomeCompleto: nome || 'Não fornecido',
                nomeFormatado: truncateText(nome, 30),
                tipo: conta.Type || 'Não fornecido',
                tipoRegua: conta.Tipo__c || 'Não informado',
                telefone: conta.Telefone_do_ultimo_contato__c || conta.Phone || 'Não fornecido',
                email: conta.Email_do_ltimo_contato__c || 'Não fornecido',
                emailFormatado: truncateText(conta.Email_do_ltimo_contato__c, 25),

                valorTotalCobrancas: somaCobrancas.total, // Valor bruto para cálculos
                valorFormatado: utils.formatarValor(somaCobrancas.total), // Valor formatado para exibição
                KeyAccount: conta.Key_Account__c,
                valorLabel: utils.formatarValor(conta.Total_em_aberto__c),
                // Informações de cobrança para debug
                totalCobrancas: somaCobrancas.quantidade,
                filtrosAplicados: {
                    regua: regua,
                    fila: fila,
                    temFiltroFila: fila && fila !== 'todos'
                },
                cnpj: conta.CNPJ__c || 'Não informado',
                cpf: conta.CPF__pc || 'Não informado',
                identificador: identificador || 'Não informado',
                identificadorLabel: identificadorLabel || 'ERRO'
            };
        });
        //console.log("Passou aqui 6")

        // 🔥 KEY LOGIC: Replace vs Append based on whether filters changed
        if (filtersChanged || controller.contas.length === 0) {
            // New search/filter - REPLACE data
            controller.contas = contasComValores;
            //console.log(`🆕 Replaced data with ${contasComValores.length} new contas`);
        } else {
            // Pagination - APPEND data
            controller.contas = [...controller.contas, ...contasComValores];
            //console.log(`➕ Appended ${contasComValores.length} contas. Total: ${controller.contas.length}`);
        }

        // Update offset for next pagination
        offset += limit;

        // 🔥 ADICIONAL: Log da soma total de todas as cobranças carregadas
        const somaGeralCobrancas = controller.contas.reduce((soma, conta) => soma + (conta.valorTotalCobrancas || 0), 0);
        //console.log(`💰 Soma total de cobranças: ${utils.formatarValor(somaGeralCobrancas)}`);

        // Log final state
        //console.log(`Final state - Total contas: ${controller.contas.length}, HasMore: ${controller.hasMore}, Next offset: ${offset}`);

    } catch (err) {
        console.error("Error loading contas:", err);
        console.error("Query that failed:", soqlContas);
        if (filtersChanged) {
            controller.contas = []; // Only clear on new search if error
        }
        controller.hasMore = false;
    } finally {
        controller.loadingContas = false;
        controller.isLoading = false;
        controller.contasCarregadas = true;
        console.log("Loading completed");
    }
}



// For manual search (Enter key, search button)
export function searchContas(nomeDaConta, fila, regua, controller, utils, executeSoql) {
    //console.log("🔍 Manual search triggered");
    return loadContas(nomeDaConta, fila, regua, controller, utils, executeSoql, true); // forceReset = true
}

// For filter changes (fila, regua dropdowns)
export function filterContas(nomeDaConta, fila, regua, controller, utils, executeSoql) {
    //console.log("🏷️ Filter change triggered");
    return loadContas(nomeDaConta, fila, regua, controller, utils, executeSoql, true); // forceReset = true
}

// Reset all filters and pagination
export function resetContas(controller) {
    //console.log("🔄 Resetting all filters and pagination");
    offset = 0;
    controller.hasMore = true;
    controller.contas = [];
    controller.error = null;
    currentFilters = { nomeDaConta: '', fila: '', regua: '' };
}



//Carrega campos da conta clicada
export async function load(controller, id, executeSoql, utils) {
    // Validação de parâmetros
    if (!id) {
        console.error('ID da conta é obrigatório');
        return null;
    }

    const query = `
        SELECT 
            Id,
            Name,
            Raz_o_Social__c,
            Phone,
            ultimo_contato_conta__c,
            ultimo_contato_conta__r.Name,
            Telefone_do_ultimo_contato__c,
            Email_do_ltimo_contato__c,
            Email_cliente__c,
            Valor_em_atraso__c,
            Total_em_aberto__c,
            Valor_total_em_pedido_em_compra__c,
            CNPJ__c,
            BillingStreet,
            BillingCity,
            BillingState,
            BillingPostalCode,
            BillingCountry,
            Industry,
            Key_Account__c
        FROM Account
        WHERE Id = '${id}'
        LIMIT 1`;

    try {
        const result = await executeSoql({ soql: query });

        if (!result || result.length === 0) {
            console.warn('Nenhuma conta encontrada com o ID:', id);
            controller.conta = null;
            return null;
        }

        const rawData = result[0];
        const nome = rawData.Raz_o_Social__c || rawData.Name;

        // Formata a conta usando o padrão de map
        const contaFormatada = {
            Id: rawData.Id ?? 'Não encontrado',
            Name: nome ?? 'Não encontrado',
            NameTruncado: truncateText(nome, 50),
            Phone: rawData.Phone ?? 'Não encontrado',
            ultimo_contato_conta__c: rawData.ultimo_contato_conta__c ?? 'Não encontrado',
            ultimo_contato_nome: rawData.ultimo_contato_conta__r?.Name ?? 'Não encontrado',
            Telefone_do_ultimo_contato__c: rawData.Telefone_do_ultimo_contato__c ?? 'Não encontrado',
            Email_do_ltimo_contato__c: rawData.Email_do_ltimo_contato__c ?? 'Não encontrado',
            Email_cliente__c: rawData.Email_cliente__c ?? 'Não encontrado',

            // Campos monetários formatados
            Valor_em_atraso__c: rawData.Valor_em_atraso__c != null ? utils.formatarValor(rawData.Valor_em_atraso__c) : 'Não encontrado',
            Total_em_aberto__c: rawData.Total_em_aberto__c != null ? utils.formatarValor(rawData.Total_em_aberto__c) : 'Não encontrado',
            Valor_total_em_pedido_em_compra__c: rawData.Valor_total_em_pedido_em_compra__c != null ? utils.formatarValor(rawData.Valor_total_em_pedido_em_compra__c) : 'Não encontrado',

            CNPJ__c: rawData.CNPJ__c ?? 'Não encontrado',
            BillingStreet: rawData.BillingStreet ?? 'Não encontrado',
            BillingCity: rawData.BillingCity ?? 'Não encontrado',
            BillingState: rawData.BillingState ?? 'Não encontrado',
            BillingPostalCode: rawData.BillingPostalCode ?? 'Não encontrado',
            BillingCountry: rawData.BillingCountry ?? 'Não encontrado',
            Industry: rawData.Industry ?? 'Não encontrado',
            Key_Account__c: rawData.Key_Account__c ?? 'Não encontrado',

            // Endereço concatenado
            endereco: (() => {
                const enderecoParts = [
                    rawData.BillingCity,
                    rawData.BillingState,
                    rawData.BillingCountry
                ].filter(part => part != null && part.trim() !== '');

                return enderecoParts.length > 0 ? enderecoParts.join(', ') : 'Não encontrado';
            })(),
            url: `/Sales/s/account/${rawData.Id}`

        };

        controller.conta = contaFormatada;
        //console.log('Conta carregada:', controller.conta);

        return controller.conta;

    } catch (err) {
        console.error('Erro ao carregar conta:', err);
        controller.conta = null;
        throw err;
    }
}