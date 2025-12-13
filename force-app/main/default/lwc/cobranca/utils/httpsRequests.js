//Arquivo destinado para centralizar chamadas à APIs

export async function startAConversation(number, message, userId, accountName) {

    if (!number || !message || !accountName) {
        throw new Error("Número ou mensagem não podem ser vazios");
    }

    const url = 'https://workflowwebhook.hospcom.net/webhook/785e6135-c15a-4737-b0af-4368e9d82290';

    const body = {
        number: number,
        initialMsg: message,
        userId: userId,
        name: accountName
    };

    console.log("payload chatwoot: ", body);

    console.log("Enviando POST para iniciar conversa:", body);

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(body)
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        console.log("Resposta do webhook:", result);

        // Retorna o conversationId
        return result.conversationId;

    } catch (error) {
        console.error("Erro na requisição startAConversation:", error);
        throw error; // permite que o caller trate o erro
    }
}


export async function salvarEvento(descricao, tipo, accountId, userId, n, contasAReceber) {
    if (!descricao || !tipo || !accountId || !userId || !contasAReceber) {
        return 400;
    }
    const numero = n ? n : null;
    const ligacao = tipo === 'Contato com Cliente'

    const url = 'https://workflowwebhook.hospcom.net/webhook/58d0561f-3c62-497b-9b14-940fb2102c3d';

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                descricao,
                tipo,
                accountId,
                userId,
                numero,
                ligacao,
                contasAReceber
            })
        });

        return response.status;

    } catch (error) {
        console.error('Erro na requisição:', error);
        return 500; // erro genérico
    }
}

export async function gerarAcordo(payload) {
    if (!payload) {
        throw new Error("Payload não informado");
    }

    console.log("Payload: ", JSON.stringify(payload));

    const url = 'https://integracao.hospcom.net/baixarenegotiation';

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });
        console.log("Resonse httpsrequest: ", response);

        if (!response.ok) {
            // se o status for 400, 500 etc.
            throw new Error(`Erro ao gerar acordo: ${response.status} ${response.statusText}`);
        }

        const data = await response.json();

        console.log(JSON.stringify(data));
        return data.docEntry;


    } catch (error) {
        console.error("Erro no fetch gerarAcordo:", error);
        throw error;
    }
}
export async function atualizaContasAReceber(docEntry, accountId, contasAReceberNegociadas) {
    if (!docEntry || !accountId) {
        throw new Error("dados não informados");
    }

    const url = `https://workflowwebhook.hospcom.net/webhook/70b68933-346f-4943-ba11-f5e238bc5be6`;

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                docEntry,
                accountId,
                contasAReceberNegociadas
            })
        });

        if (!response.ok) {
            // Lança erro de acordo com o status
            switch (response.status) {
                case 404:
                    throw new Error("Nenhum cobrança não encontrado (400)");
                case 500:
                    throw new Error("Erro interno do servidor (500)");
                default:
                    throw new Error(`Erro desconhecido: ${response.status} ${response.statusText}`);
            }
        }


        const data = await response.json();
        return data.Id;

    } catch (error) {
        console.error("Erro ao atualizar Contas a Receber:", error);
        throw error;
    }
}


export async function buscarBoleto(docentry) {
    const url = `https://workflowwebhook.hospcom.net/webhook/7c83e980-8c27-4d3f-922f-e2be5ac733f7?docentry=${encodeURIComponent(docentry)}`;

    try {
        const response = await fetch(url);

        // Tratamento específico por código de status
        switch (response.status) {
            case 200:
                // Sucesso - boleto encontrado e retornado
                const blob = await response.blob();

                // Verifica se é realmente um PDF
                if (blob.type !== "application/pdf") {
                    throw new Error("Arquivo retornado não é um boleto válido");
                }

                return { success: true, blob, message: "Boleto encontrado com sucesso" };

            case 201:
                // Sucesso - mas boleto não foi encontrado
                return { success: false, blob: null, message: "Boleto não encontrado" };

            case 400:
                // Parâmetros incorretos
                throw new Error("Dados inválidos para busca do boleto");

            case 500:
                // Erro interno do servidor
                throw new Error("Erro no servidor. Tente novamente mais tarde");

            default:
                // Outros códigos de erro
                throw new Error(`Erro inesperado: ${response.status} - ${response.statusText}`);
        }

    } catch (error) {
        console.error('Erro ao buscar boleto:', error);
        throw error;
    }
}


export async function obterDadosDoBoleto(docentry) {
    const url = `https://workflowwebhook.hospcom.net/webhook/340102a1-d716-47c9-88c4-d174958bcabd?docentry=${encodeURIComponent(docentry)}`;

    try {
        const response = await fetch(url);
        console.log('Response status:', response.status);
        console.log('Response headers:', response.headers);

        // Tratamento específico por código de status
        switch (response.status) {
            case 200:
                // Sucesso - boleto encontrado e retornado
                const data = await response.json(); // ← AQUI ESTÁ A CORREÇÃO
                console.log('Dados recebidos:', data);

                const cod = data.DigitalLine;
                const chave = data.QrCodePix;

                return {
                    success: true,
                    cod,
                    chave,
                    message: "Dados obtidos com sucesso",
                    data // Opcional: retorna todos os dados para debug
                };

            case 201:
                // Sucesso - mas boleto não foi encontrado
                // Mesmo assim pode ter uma mensagem no corpo
                let message201 = "Boleto não encontrado";
                try {
                    const errorData = await response.json();
                    message201 = errorData.message || message201;
                } catch (e) {
                    // Se não conseguir fazer parse, usa mensagem padrão
                }

                return {
                    success: false,
                    cod: null,
                    chave: null,
                    message: message201
                };

            case 400:
                // Parâmetros incorretos
                let message400 = "Dados inválidos para busca do boleto";
                try {
                    const errorData = await response.json();
                    message400 = errorData.message || message400;
                } catch (e) {
                    // Se não conseguir fazer parse, usa mensagem padrão
                }
                throw new Error(message400);

            case 500:
                // Erro interno do servidor
                let message500 = "Erro no servidor. Tente novamente mais tarde";
                try {
                    const errorData = await response.json();
                    message500 = errorData.message || message500;
                } catch (e) {
                    // Se não conseguir fazer parse, usa mensagem padrão
                }
                throw new Error(message500);

            default:
                // Outros códigos de erro
                let messageDefault = `Erro inesperado: ${response.status} - ${response.statusText}`;
                try {
                    const errorData = await response.json();
                    messageDefault = errorData.message || messageDefault;
                } catch (e) {
                    // Se não conseguir fazer parse, usa mensagem padrão
                }
                throw new Error(messageDefault);
        }

    } catch (error) {
        console.error('Erro ao buscar dados do boleto:', error);

        // Se for erro de rede ou parse
        if (error.name === 'TypeError' || error.name === 'SyntaxError') {
            throw new Error('Erro de conexão ou resposta inválida do servidor');
        }

        // Re-throw outros erros
        throw error;
    }

}
export async function updateNotasDoSap(controller) {
    console.log("Sincronizando")
    const url = 'https://workflowwebhook.hospcom.net/webhook/3b0cb814-81d7-4cb1-b742-8297c3bdc45a'

    fetch(url, {
        method: 'GET'
    })
        .then(response => {
            if (response.status === 200) {
                console.log('Sucesso: Notas atualizadas');
                controller.toast('Sucesso', 'Notas sícronizadas. Por favor recarregue a página', 'success', 'pester');
            } else if (response.status === 400) {
                console.error('Erro 400: Requisição inválida');
            } else if (response.status === 500) {
                console.error('Erro 500: Erro no servidor');
            }
        })
        .catch(error => {
            console.error('Erro na requisição:', error);
        })
        .finally(() => {
            controller.atualizandoLogs = false
        });

}