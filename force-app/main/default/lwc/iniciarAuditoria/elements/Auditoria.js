export async function load(executeSoql, Auditoria_id) {
    console.log("Carregando dados da auditoria");

    if (!Auditoria_id) {
        throw new Error("Parâmetros não encontrados");
    }

    const query = `SELECT Id, Name, OwnerId, Tipo_da_Auditoria__c, Empresa_Auditada__r.Name, Responsavel__r.Name, Nome_do_planejamento__c, Observa_o__c,
                Data_da_Auditoria__c, Auditado__r.Name, Disponivel_para_Auditar__c
                FROM Auditoria__c
                WHERE Id = '${Auditoria_id}'`;

    console.log("Query Auditoria: ", query);


    const result = await executeSoql({ soql: query });

    if (result && result.length > 0) {
        const rawData = result[0];

        // Objeto tratado com todos os campos
        const auditoriaTratada = {
            id: rawData.Id || 'Não encontrado',
            Nome: rawData.Name || 'Não encontrado',

            // Empresa Auditada
            empresaAuditadaId: rawData.Empresa_Auditada__c || 'Não encontrado',
            empresaAuditadaNome: rawData.Empresa_Auditada__r?.Name || 'Não encontrado',

            // Responsável
            responsavelId: rawData.Responsavel__c || 'Não encontrado',
            responsavelNome: rawData.Responsavel__r?.Name || 'Não encontrado',

            // Auditado
            auditadoId: rawData.Auditado__c || 'Não encontrado',
            auditadoNome: rawData.Auditado__r?.Name || 'Não encontrado',

            proprietario: rawData.OwnerId || 'Error',

            // Outros campos
            nomePlanejamento: rawData.Nome_do_planejamento__c || 'Não encontrado',
            observacao: rawData.Observa_o__c || 'Não encontrado',
            dataAuditoria: rawData.Data_da_Auditoria__c || 'Não encontrado',
            disponivelParaAuditar: rawData.Disponivel_para_Auditar__c ?? false,
            tipoDaAuditoria: rawData.Tipo_da_Auditoria__c || 'Error',

            // Data formatada (se existir)
            dataAuditoriaFormatada: formatarData(rawData.Data_da_Auditoria__c),

            // Dados brutos (caso precise acessar depois)
            _dadosBrutos: rawData
        };

        console.log("Auditoria tratada:", JSON.stringify(auditoriaTratada, null, 2));
        return auditoriaTratada;
    } else {
        throw new Error("Nenhuma auditoria encontrada com o ID fornecido");
    }
}
function formatarData(dataString) {
    if (!dataString) return 'Não encontrado';

    try {
        const [ano, mes, dia] = dataString.split('-');
        return `${dia}/${mes}/${ano}`;
    } catch (e) {
        console.error("Erro ao formatar data:", e);
        return dataString; // Retorna a data original se houver erro
    }
}