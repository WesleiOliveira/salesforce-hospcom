export async function load(controller, AccountId, executeSoql, utils, filtro) {
    //console.log("Loading Contas a receber com filtro:", filtro);
    controller.contasAReceberIsLoading = true;

    if (!AccountId) {
        console.warn('AccountId não fornecido');
        controller.contasAReceber = [];
        return;
    }

    // CONSTRÓI O FILTRO BASEADO NO PARÂMETRO
    let filtroWhere = '';
    switch (filtro) {
        case 'pagos':
            filtroWhere = 'AND Cobranca_paga__c = true';
            break;
        case 'em_aberto':
            filtroWhere = 'AND Cobranca_paga__c = false';
            break;
        case 'todos':
        default:
            filtroWhere = ''; // Sem filtro adicional
            break;
    }

    const query = `SELECT 
        Id,
        Name,
        Titulo__c,
        Pedido__c,
        Pedido__r.Forma_de_pagamento2__c,
        Status__c,
        Tipo_do_titulo__c,
        Titulo_de_renegociacao__c,
        Situacao__c,
        Vencimento__c,
        Parcela__c,
        Valor_pago__c,
        Multa_calculada__c,
        Cobranca_paga__c,
        Valor_do_recebimento__c,
        Juros_calculado__c,
        Valor_a_pagar__c
    FROM Cobranca__c
    WHERE Conta__c = '${AccountId}' ${filtroWhere}
    ORDER BY Vencimento__c DESC`;

    try {
        const result = await executeSoql({ soql: query });

        if (result && result.length > 0) {
            const hoje = new Date();
            hoje.setHours(0, 0, 0, 0);

            const contasProcessadas = result.map(c => {

                let statusClass;
                let isPago = false;
                let containerClass = '';

                if (c.Situacao__c === 'Pago') {
                    statusClass = 'pago';
                    containerClass = 'container-pago';
                    isPago = true;
                }

                if (c.Situacao__c === 'Vence hoje') {
                    statusClass = 'vence-hoje';
                    containerClass = 'container-vence-hoje';
                }

                if (c.Situacao__c === 'Atrasado') {
                    statusClass = 'atrasado';
                    containerClass = 'container-atrasado';
                }

                if (c.Situacao__c === 'Em aberto') {
                    statusClass = 'em-aberto';
                    containerClass = 'container-em-aberto';
                }

                if (c.Situacao__c === 'Renegociado') {
                    statusClass = 'renegociado';
                    containerClass = 'container-renegociado';
                }
                const renegociacao = c.Tipo_do_titulo__c === 'Renegociação';



                const formaDePagamento = c.Pedido__r?.Forma_de_pagamento2__c ?? 'NAD'
                const boleto = formaDePagamento.toLowerCase().includes('boleto');
                const processedRecord = {
                    ...c,
                    docEntry: c.Titulo__c,
                    url: `https://hospcom.my.site.com/Sales/s/detail/${c.Id}`,
                    // Data formatada
                    Vencimento__c: c.Vencimento__c
                        ? (() => {
                            const [ano, mes, dia] = c.Vencimento__c.split('-');
                            return new Date(ano, mes - 1, dia).toLocaleDateString('pt-BR');
                        })()
                        : 'Não informada',
                    gerarBoleto: boleto && !isPago || renegociacao,
                    buscandoBoleto: false,
                    copiandoBoleto: false,
                    tooltipCopiado: false,
                    gerandoQRCode: false,
                    tooltipQRCodeCopiado: false,
                    formadePagamento: formaDePagamento,

                    Status__c: c.Situacao__c,
                    renegociado: c.Situacao__c === 'Renegociado',
                    pago: c.Situacao__c === 'Pago',
                    aberto: c.Situacao__c != 'Pago' && c.Tipo_do_titulo__c != 'Renegociado',

                    renegociacao: renegociacao,

                    // Campos monetários - valores reais mantidos + versões formatadas
                    Valor_a_pagar__cLabel: utils.formatarValor(c.Valor_a_pagar__c),
                    Valor_pago__cLabel: utils.formatarValor(c.Valor_pago__c || 0),
                    Valor_do_recebimento__cLabel: utils.formatarValor(c.Valor_do_recebimento__c),
                    Multa_calculada__cLabel: utils.formatarValor(c.Multa_calculada__c),
                    Juros_calculado__cLabel: utils.formatarValor(c.Juros_calculado__c),
                    // Classes e propriedades adicionais
                    statusClass: statusClass,
                    isPago: isPago,
                    containerClass: containerClass,
                    dataOriginal: c.Vencimento__c ? new Date(c.Vencimento__c) : null,
                    rowClass: 'table-row ' + statusClass,
                };

                // Debug dos valores monetários
                console.log(`Cobrança ${c.Id} - Valores monetários:`, {
                    original: {
                        Valor_a_pagar__c: c.Valor_a_pagar__c,
                        Valor_pago__c: c.Valor_pago__c,
                        Valor_do_recebimento__c: c.Valor_do_recebimento__c,
                        Multa_calculada__c: c.Multa_calculada__c,
                        Juros_calculado__c: c.Juros_calculado__c
                    },
                    formatado: {
                        Valor_a_pagar__cLabel: processedRecord.Valor_a_pagar__cLabel,
                        Valor_pago__cLabel: processedRecord.Valor_pago__cLabel,
                        Valor_do_recebimento__cLabel: processedRecord.Valor_do_recebimento__cLabel,
                        Multa_calculada__cLabel: processedRecord.Multa_calculada__cLabel,
                        Juros_calculado__cLabel: processedRecord.Juros_calculado__cLabel
                    },
                    status: status,
                    isPago: isPago
                });

                return processedRecord;
            });

            // Ordena: não pagas primeiro, depois pagas

            controller.contasAReceberIsLoading = false;
            controller.contasAReceber = contasProcessadas.sort((a, b) => {
                if (a.isPago !== b.isPago) {
                    return a.isPago - b.isPago;
                }

                if (a.dataOriginal && b.dataOriginal) {
                    return b.dataOriginal - a.dataOriginal;
                }

                if (a.dataOriginal && !b.dataOriginal) return -1;
                if (!a.dataOriginal && b.dataOriginal) return 1;

                return 0;
            });
        } else {
            controller.contasAReceber = [];
        }

        //console.log(`${controller.contasAReceber.length} contas a receber carregadas com filtro: ${filtro}`);

    } catch (err) {
        console.error('Erro ao carregar contas a receber:', err);
        controller.contasAReceber = [];
    } finally {
        controller.contasAReceberIsLoading = false;
    }

}