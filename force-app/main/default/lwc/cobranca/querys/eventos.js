export async function load(controller, accountId, executeSoql, utils) {
    controller.eventosIsLoading = true;

    // Validação de parâmetros
    if (!accountId) {
        console.error('ID da conta é obrigatório');
        controller.eventosIsLoading = false;
        return null;
    }

    const query = `SELECT
        Id,
        Descricao_evento__c,
        Cliente__c,
        Cliente__r.Name,
        Fontawesome__c,
        CreatedDate,
        Tipo__c,
        CreatedBy.Id,
        CreatedBy.Name,
        CreatedBy.FirstName,
        CreatedBy.SmallPhotoUrl,
        CreatedBy.FullPhotoUrl,
        CreatedBy.MediumPhotoUrl,
        agente__c
    FROM Evento_Financeiro__c 
    WHERE Cliente__c = '${accountId}'
    ORDER BY CreatedDate DESC`;

    try {
        const result = await executeSoql({ soql: query });

        if (!result || result.length === 0) {
            console.log('Nenhum evento financeiro encontrado para esta conta');
            controller.eventos = [];
            return;
        }

        // Busca todas as partes de uma vez para todos os eventos
        const eventosIds = result.map(e => e.Id).join("','");
        const parteQuery = `SELECT 
            Id, 
            Evento_Financeiro__c,
            Conta_a_receber__c, 
            Conta_a_receber__r.Name 
        FROM parte_evento_financeiro__c 
        WHERE Evento_Financeiro__c IN ('${eventosIds}')`;

        const partesResult = await executeSoql({ soql: parteQuery });

        // Cria um mapa de partes por evento
        const partesPorEvento = {};
        if (partesResult && partesResult.length > 0) {
            partesResult.forEach(parte => {
                const eventoId = parte.Evento_Financeiro__c;
                if (!partesPorEvento[eventoId]) {
                    partesPorEvento[eventoId] = [];
                }
                partesPorEvento[eventoId].push({
                    Id: parte.Id,
                    ContasAreceberId: parte.Conta_a_receber__c,
                    ContasAreceberNome: parte.Conta_a_receber__r?.Name || 'Sem nome',
                    url: `https://hospcom.my.site.com/Sales/s/detail/${parte.Conta_a_receber__c}`
                });
            });
        }

        // Mapeia os dados para o formato desejado
        const eventosFormatados = result.map(evento => {
            // Verifica se agente__c está true
            const isAgente = evento.agente__c === true;

            // Define a foto e nome do criador
            let criadorFoto = null;
            let criadorNome = 'Não encontrado';
            let criadorId = 'Não encontrado';

            if (isAgente) {
                criadorNome = 'Manu';
                criadorId = evento.CreatedBy?.Id || 'Não encontrado';
                criadorFoto = 'https://hospcom.my.salesforce.com/servlet/servlet.ImageServer?id=015U400000Mrfd4&oid=00Di0000000JVhH&lastMod=1754077807000';
            } else if (evento.CreatedBy) {
                criadorNome = evento.CreatedBy.Name || evento.CreatedBy.FirstName || 'Não encontrado';
                criadorId = evento.CreatedBy.Id || 'Não encontrado';
                // Prioriza SmallPhotoUrl, depois MediumPhotoUrl, depois FullPhotoUrl
                criadorFoto = evento.CreatedBy.SmallPhotoUrl ||
                    evento.CreatedBy.MediumPhotoUrl ||
                    evento.CreatedBy.FullPhotoUrl ||
                    null;
            }
            const dataFormatada = utils.formatarDataBrasileira(evento.CreatedDate);
            const dataHoraFormatada = utils.formatarDataHora(evento.CreatedDate);

            return {
                Cliente__r_Name: evento.Cliente__r?.Name || 'Não encontrado',
                Id: evento.Id,
                Tipo__c: evento.Tipo__c || 'Erro',
                Fontawesome__c: evento.Fontawesome__c || 'Erro',
                Descricao_evento__c: evento.Descricao_evento__c || 'Erro',
                iconId: `icon-${evento.Id}`,

                // Campos de data separados
                RawData: evento.CreatedDate,
                Data: dataFormatada,
                DataHora: dataHoraFormatada,
                CreatedDate: evento.CreatedDate,

                // Informações do criador
                CreatedById: criadorId,
                CreatedBy_Name: criadorNome,
                CreatedBy_PhotoUrl: criadorFoto,

                // URLs alternativas caso precise de tamanhos diferentes
                CreatedBy_SmallPhotoUrl: isAgente
                    ? 'https://hospcom.my.salesforce.com/servlet/servlet.ImageServer?id=015U400000Mrfd4&oid=00Di0000000JVhH&lastMod=1754077807000'
                    : evento.CreatedBy?.SmallPhotoUrl || null,
                CreatedBy_MediumPhotoUrl: isAgente
                    ? 'https://hospcom.my.salesforce.com/servlet/servlet.ImageServer?id=015U400000Mrfd4&oid=00Di0000000JVhH&lastMod=1754077807000'
                    : evento.CreatedBy?.MediumPhotoUrl || null,
                CreatedBy_FullPhotoUrl: isAgente
                    ? 'https://hospcom.my.salesforce.com/servlet/servlet.ImageServer?id=015U400000Mrfd4&oid=00Di0000000JVhH&lastMod=1754077807000'
                    : evento.CreatedBy?.FullPhotoUrl || null,

                // Propriedades auxiliares para o template
                hasCriadorPhoto: criadorFoto !== null,
                isAgente: isAgente,

                // Notas vinculadas (contas a receber)
                Notas: partesPorEvento[evento.Id] || []
            };
        });

        // Atribui os dados ao controller
        controller.eventos = eventosFormatados;

    } catch (err) {
        controller.eventos = [];
        console.error('Erro ao carregar eventos financeiros:', err);
    } finally {
        controller.eventosIsLoading = false;

        // Log apenas dos primeiros dados para debug
        if (controller.eventos.length > 0) {
            console.log('Primeiro evento (debug):', {
                nome: controller.eventos[0].CreatedBy_Name,
                foto: controller.eventos[0].CreatedBy_PhotoUrl,
                data: controller.eventos[0].Data,
                dataHora: controller.eventos[0].DataHora,
                isAgente: controller.eventos[0].isAgente,
                quantidadeNotas: controller.eventos[0].Notas.length,
                notas: controller.eventos[0].Notas
            });
        }
    }
}

export function formatarMesAnoDetalhado(data) {
    const agora = new Date();
    const mesAtual = agora.getMonth();
    const anoAtual = agora.getFullYear();
    const mesEvento = data.getMonth();
    const anoEvento = data.getFullYear();

    const meses = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    // Mês atual
    if (anoEvento === anoAtual && mesEvento === mesAtual) {
        return 'Este mês';
    }

    // Mês anterior
    const mesAnterior = mesAtual === 0 ? 11 : mesAtual - 1;
    const anoMesAnterior = mesAtual === 0 ? anoAtual - 1 : anoAtual;
    if (anoEvento === anoMesAnterior && mesEvento === mesAnterior) {
        return 'Mês passado';
    }

    // Mesmo ano
    if (anoEvento === anoAtual) {
        return meses[mesEvento];
    }

    // Outros anos
    return `${meses[mesEvento]} ${anoEvento}`;
}