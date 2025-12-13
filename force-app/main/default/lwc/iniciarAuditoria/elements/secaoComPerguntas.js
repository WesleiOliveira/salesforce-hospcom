//Load perguntas ativas para o tipo de auditoria junto suas seções
export async function load(executeSoql, tipoDaAuditoria) {
    console.log("Carregando perguntas ativas para o tipo de auditoria");

    if (!tipoDaAuditoria) {
        throw new Error("Tipo não encontrado");
    }

    const query = `SELECT Id, Nome_da_Secao__c, Tipo__c, Pergunta__c, Posicao__c, Posicao_da_Secao__c, Name
                    FROM Pergunta_de_Auditoria__c
                    WHERE Tipo_de_Auditoria__c = '${tipoDaAuditoria}'
                        and Status__c = 'Ativo'
                    ORDER BY Posicao_da_Secao__c, Posicao__c`;

    const result = await executeSoql({ soql: query });
    
    console.log('Resultado da query:', result);

    if (result && result.length > 0) {
        const perguntasComSecaoRaw = result;
        
        console.log('Perguntas raw:', perguntasComSecaoRaw);
        
        // Organizar dados por seção e retornar
        const secoes = organizarPorSecao(perguntasComSecaoRaw);
        
        console.log('Seções organizadas:', secoes);
        
        return secoes;
    } else {
        throw new Error("Nenhuma pergunta encontrada para o tipo de auditoria fornecido");
    }
}

// Função para organizar perguntas por seção
function organizarPorSecao(perguntas) {
    const secoesMap = new Map();
    
    perguntas.forEach(pergunta => {
        const nomeSecao = pergunta.Nome_da_Secao__c;
        const posicaoSecao = pergunta.Posicao_da_Secao__c;
        
        if (!secoesMap.has(nomeSecao)) {
            secoesMap.set(nomeSecao, {
                nome: nomeSecao,
                posicao: posicaoSecao,
                perguntas: []
            });
        }
        
        secoesMap.get(nomeSecao).perguntas.push({
            id: pergunta.Id,
            name: pergunta.Name,
            tipo: pergunta.Tipo__c,
            pergunta: pergunta.Pergunta__c,
            posicao: pergunta.Posicao__c,
            radioName: `pergunta_${pergunta.Id}` // Adicionar nome único para o radio
        });
    });
    
    // Converter Map para Array e ordenar por posição da seção
    const secoesArray = Array.from(secoesMap.values()).sort((a, b) => a.posicao - b.posicao);
    
    // Ordenar perguntas dentro de cada seção e adicionar número da seção
    secoesArray.forEach((secao, index) => {
        secao.perguntas.sort((a, b) => a.posicao - b.posicao);
        secao.numeroSecao = index + 1; // Adicionar número sequencial
    });
    
    return secoesArray;
}
// Função auxiliar para coletar respostas do formulário (se precisar exportar)
export function coletarRespostas() {
    const respostas = [];

    $('.card-pergunta').each(function () {
        const idPergunta = $(this).data('id');
        const radioName = `pergunta_${idPergunta}`;
        const respostaSelecionada = $(`input[name="${radioName}"]:checked`).val();

        if (respostaSelecionada) {
            respostas.push({
                perguntaId: idPergunta,
                resposta: respostaSelecionada
            });
        }
    });

    return respostas;
}