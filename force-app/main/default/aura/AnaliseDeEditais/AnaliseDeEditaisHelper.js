({
    showToast: function (title, message, type) {
        const toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type, // 'success', 'error', 'warning', 'info'
                mode: 'dismissible'
            });
            toastEvent.fire();
        } else {
            alert(`${title}: ${message}`); // Fallback
        }
    },

    sendMsg: function (cmp, event, helper, msg, id) {
        console.log('Mensagem enviada pelo usuário:', msg);
        console.log('ThreadId:', id);
        console.log(cmp.get("v.btn"));

        const btn = cmp.get("v.btn");
        //URl do arquivo do drive
        const driveURL = 'https://drive.google.com/file/d/'

        cmp.set("v.digitando", true);

        //N8N WORKFLOW_ID: xa5TnlqDF0mWUskq
        const url = 'https://workflowwebhook.hospcom.net/webhook/7983d3ca-79ae-4ca4-9ae6-e88038475cf8';

        // Adiciona a mensagem do usuário ao histórico
        let historico = cmp.get("v.historico") || [];
        const dataHoraAtual = new Date().toLocaleString('pt-BR', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit'
        });

        historico.push({
            role: 'user',
            content: msg,
            created_at: dataHoraAtual,
        });
        cmp.set("v.historico", historico);
        cmp.set("v.mensagem", "");


        //Auto scroll
        setTimeout(() => {
            const chatDiv = cmp.find("chatHistory");
            if (chatDiv && chatDiv.getElement) {
                const el = chatDiv.getElement();
                el.scrollTop = el.scrollHeight;
            }
        }, 50);

        // Envia mensagem para o n8n e aguarda resposta do agente
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ msg: msg, id: id, btn: btn })
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Erro na resposta do servidor');
                }
                return response.json();
            })
            .then(data => {
                console.log('Resposta do agente:', data);

                if (!data || !data.value || !data.created_at) {
                    throw new Error('Formato inválido da resposta do agente');
                }

                cmp.set("v.digitando", false);
                cmp.set("v.threadId", data.id);

                let historico = cmp.get("v.historico") || [];

                // Monta a lista de arquivos em um array de objetos { fileURL, fileName, fileId }
                const arquivos = (data.driveId || []).map((driveId, i) => ({
                    fileURL: driveURL + driveId + '/view',
                    fileName: (data.fileName && data.fileName[i]) || 'Arquivo desconhecido',
                    fileId: driveId
                }));

                historico.push({
                    role: 'assistant',
                    content: data.value,
                    created_at: data.created_at,
                    arquivosFontes: arquivos
                });

                cmp.set("v.historico", historico);

                // Scroll automatico
                setTimeout(() => {
                    const chatEl = cmp.find("chatHistory");
                    if (chatEl && chatEl.getElement) {
                        const domEl = chatEl.getElement();
                        domEl.scrollTop = domEl.scrollHeight;
                    }
                }, 50);
            })
            .catch(error => {
                console.error('Erro ao obter resposta do assistente:', error);
                cmp.set("v.digitando", false);

            });
    },

    //Consulta analises e atribui à Variavel que faz o display dos containers das analises
    //Até o momento ( 02/07/25) não há um filtro para a busca. Possivelmente no futuro 
    //Filtrar pelo agente da analise    
    queryAnalises: function (cmp, helper) {
        cmp.set("v.analises", [])
        let query = `SELECT Id, Name, Nome_do_Termo_de_Referencia__c, Custo_da_Analise__c, Numero_do_Item__c,Nome_do_Equipamento__c, Cobertura__c, CreatedDate, Status__c FROM Analise_de_Equipamento__c ORDER BY CreatedDate DESC `;

        console.log('query: ', query)

        helper.soql(cmp, query)
            .then(function (result) {
                // Formata a data antes de setar no atributo
                let analisesFormatadas = result.map(function (item) {
                    item.DataFormatada = new Date(item.CreatedDate).toLocaleDateString('pt-BR');
                    item.CustoFormatado = parseFloat(item.Custo_da_Analise__c).toLocaleString('pt-BR', {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2
                    });

                    if (item.Cobertura__c <= 40) item.cor = 'vermelho';
                    else if (item.Cobertura__c <= 60) item.cor = 'amarelo';
                    else item.cor = 'verde';

                    // Adiciona campo para controle
                    if(item.Status__c === 'em fila'){
                        item.aguardando = true;                        
                    } else{
                        item.aguardando = false; 
                    }

                    return item;
                });



                console.log('Analise: ', analisesFormatadas)
                cmp.set("v.analises", analisesFormatadas);
            })
            .catch(function (error) {
                console.log('Erro ao executar query: ', error);
            }).finally(function () {
                helper.monitorarStatus(cmp, helper);
            });
    },

    queryAnaliseClicada: function (cmp, helper, recordId) {
        let query = `
            SELECT Id, Numero_do_Item__c, Nome_do_Equipamento__c, Nome_do_Termo_de_Referencia__c, Custo_da_Analise__c,
                Quantidade__c, Valor__c, Nome_do_Agente__c, Cobertura__c, Analise__c, threadId__c,
                Nota_para_a_Analise__c, Feedback__c, CreatedDate
            FROM Analise_de_Equipamento__c
            WHERE Id = '${recordId}'
        `;

        console.log('Query executada:', query);

        return helper.soql(cmp, query).then(function (result) {
            if (result && result.length > 0) {
                let analise = result[0];

                // ✅ Formatar custo com 2 casas decimais
                analise.CustoFormatado = parseFloat(analise.Custo_da_Analise__c).toLocaleString('pt-BR', {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2
                });

                let coberturaFinal = parseInt(analise.Cobertura__c, 10);
                if (isNaN(coberturaFinal) || coberturaFinal < 0) {
                    coberturaFinal = 0;
                }


                // Cancela animação anterior (se houver)
                const anterior = cmp.get("v.intervalId");
                if (anterior) {
                    clearInterval(anterior);
                }

                cmp.set("v.coberturaAnimada", 0);
                let contador = -1;

                // Inicia novo intervalo
                const novoIntervalo = setInterval(function () {
                    contador++;
                    cmp.set("v.coberturaAnimada", contador);

                    if (contador >= coberturaFinal) {
                        clearInterval(novoIntervalo);
                        cmp.set("v.intervalId", null);
                    }
                }, 20);

                // Salva o ID do intervalo
                cmp.set("v.intervalId", novoIntervalo);



                // Formata a data
                let data = new Date(analise.CreatedDate);
                analise.DataFormatada = data.toLocaleDateString('pt-BR');

                // Define a cor com base na Cobertura__c
                if (analise.Cobertura__c <= 40) {
                    analise.cor = 'vermelho';
                } else if (analise.Cobertura__c <= 60) {
                    analise.cor = 'amarelo';
                } else {
                    analise.cor = 'verde';
                }

                console.log('Resultado da query:', analise);
                cmp.set("v.analise", analise);
            } else {
                console.warn('Nenhum resultado encontrado para Id:', recordId);
            }
        }).catch(function (error) {
            console.error('Erro ao executar query:', error);
        });
    },



    verificaCamposObrigatorios: function (component, helper) {
        console.log("🔍 Iniciando verificação dos campos obrigatórios...");

        let camposValidos = true;

        const termoRef = component.find("inputTermo");
        const numItem = component.find("inputItem");
        const descricao = component.find("inputDescricao");
        const valor = component.find("inputValor");

        // Termo de Referência
        if (!termoRef.checkValidity()) {
            console.warn("❌ Campo Termo de Referência inválido");
            termoRef.reportValidity();
            camposValidos = false;
        }

        // Nº do Item
        if (!numItem.checkValidity()) {
            console.warn("❌ Campo Nº do Item inválido");
            numItem.reportValidity();
            camposValidos = false;
        }

        // Descrição
        if (!descricao.checkValidity()) {
            console.warn("❌ Campo Descrição inválido");
            descricao.reportValidity();
            camposValidos = false;
        }

        // VALOR — conversão do formato brasileiro
        let valorRaw = valor.get("v.value");
        let valorConvertido = null;

        if (typeof valorRaw === "string" && valorRaw.trim() !== "") {
            valorConvertido = parseFloat(valorRaw.replace(/\./g, "").replace(",", "."));

            console.log("💰 Valor convertido:", valorConvertido);

            if (
                isNaN(valorConvertido) ||
                valorConvertido < 0 ||
                !/^\d+(\.\d{1,2})?$/.test(valorConvertido.toFixed(2))
            ) {
                console.warn("❌ Campo Valor inválido após conversão:", valorConvertido);
                valor.setCustomValidity("Insira um valor em reais com até 2 casas decimais");
                valor.reportValidity();
                camposValidos = false;
            } else {
                valor.setCustomValidity("");
                valor.reportValidity();
            }
        } else {
            // Campo está vazio — não é obrigatório
            console.log("ℹ️ Campo Valor vazio (opcional)");
            valor.setCustomValidity("");
            valor.reportValidity();
        }

        console.log("✅ Todos os campos válidos?", camposValidos);

        return camposValidos;
    },

    salvaNovaAnalise: function (component, helper) {
        console.log("💾 Iniciando processo de salvar nova análise...");
        const analise = component.get("v.novaAnalise");
        fetch('https://integracao.hospcom.net/Inseri/editais/Sales', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                AnaliseEdital: analise
            })
        })
            .then(response => response.json())
            .then(result => {
                helper.showToast("Sucesso!", "Análise Enviada", "success");
                console.log("SUCESSO!!!")
                let recordId = result.resultado.id;
                console.log("Registro criado: ", recordId);

                helper.enviaParaAgente(component, helper, recordId);
                helper.queryAnalises(component, helper);


            })
            .catch(error => {
                console.error('Error:', error)
                helper.showToast("Erro", "Por favor, consulte o departamento de desenvolvimento", "error");
            });
    },

    enviaParaAgente: function (cmp, helper, recordId) {
        console.log("Enviando para agente...")

        fetch('https://workflowwebhook.hospcom.net/webhook/1fee3389-4518-45d7-a0e5-5e93c722c4a5', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                recordId: recordId,

            })
        })
            .then(response => response)
            .then(result => {
                if (result.status === 200) {
                    console.log("Sucesso!!!")
                    cmp.set("v.saving3", false)
                    cmp.set("v.isLoading", false)
                    



                    cmp.set("v.novaAnalise", {
                        //  sobjectType: "Analise_de_Equipamento__c",
                        Nome_do_Termo_de_Referencia__c: '',
                        Nome_do_Equipamento__c: '',
                        Numero_do_Item__c: null,
                        Quantidade__c: null,
                        Descricao__c: '',
                        Valor__c: null
                    });
                }
            })
            .catch(error => {
                helper.showToast("Erro", "Por favor, consulte o departamento de desenvolvimento", "error");
                console.error('Error:', error)
                cmp.set("v.saving3", false)

            }).finally(function () {
                cmp.set("v.btnSalvarNovaAnalise", false)
            });        

    },

    salvarFeedback: function (component, helper) {
        console.log("🔄 Iniciando salvarFeedback...");

        const analise = component.get("v.analise");
        console.log("📦 Dados da análise:", JSON.parse(JSON.stringify(analise)));

        const nota = analise.Nota_para_a_Analise__c;

        // Validação da nota
        if (nota === undefined || nota === null || isNaN(nota) || nota < 0 || nota > 100) {
            console.error("nota inválida: ", analise.Nota_para_a_Analise__c)
            return
        }

        component.set("v.analiseAlterada", false);

        const payload = [
            {
                body: {
                    recordId: analise.Id,
                    feedback: analise.Feedback__c,
                    nota: analise.Nota_para_a_Analise__c
                }
            }
        ];

        console.log("📤 Enviando payload:", JSON.stringify(payload, null, 2));

        fetch("https://workflowwebhook.hospcom.net/webhook/8a487656-0782-4c60-864d-199c5280480a", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        })
            .then(response => {
                console.log("📥 Status da resposta:", response.status);

                if (response.status === 200) {
                    component.set("v.analiseAlterada", false);
                    helper.showToast("Sucesso", "Feedback salvo com sucesso.", "success");
                } else {
                    helper.showToast("Erro", "Falha ao salvar feedback (status: " + response.status + ").", "error");
                }
            })
            .catch(error => {
                console.error("❌ Erro no fetch:", error);
                helper.showToast("Erro", "Erro de conexão ao salvar feedback.", "error");
            });
    },
    queryHistoricoChat: function (cmp, helper, threadId) {
        const url = 'https://workflowwebhook.hospcom.net/webhook/2cbd3c5f-707c-40e3-a337-c67fe5e2a545';

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                threadId: threadId
            })
        })
            .then(response => response.json())
            .then(result => {
                // Verifica o tipo do retorno
                console.log("Resultado da API:", result);

                // Normaliza para garantir que sempre será um array
                const data = Array.isArray(result) ? result : [result];

                // Cria a lista de histórico
                const historico = data.map(item => ({
                    role: item.role,
                    content: item.value,
                    created_at: item.created_at
                }));
                historico.pop();
                historico.reverse();
                console.log("Historico completo:", historico); // Verifique todos os itens aqui

                // Agora sim, sobrescreve com todos os itens do histórico
                cmp.set("v.historico", historico);
            })
            .catch(error => {
                console.error('Erro ao buscar histórico:', error);
                cmp.set("v.historico", []);
            });
    },

    monitorarStatus: function (component, helper) {
        console.log("Iniciando monitoramento de status");
        const analises = component.get("v.analises");
        const idsEmFila = analises
        .filter(a => a.aguardando)
        .map(a => a.Id);
        
        if (idsEmFila.length === 0) {
            console.log("Nenhuma análise em fila");
            return;
        }
        
        const intervalo = setInterval(function () {
            helper.showToast("Carregando", "Analisando...", "info");
            console.log("Executando consulta SOQL");
            helper.soql(component, `SELECT Id, Status__c, Cobertura__c, Custo_da_Analise__c FROM Analise_de_Equipamento__c WHERE Id IN ('${idsEmFila.join("','")}')`)
                .then(function (result) {
                    let atual = component.get("v.analises");
                    let mudou = false;

                    result.forEach(update => {
                        let item = atual.find(a => a.Id === update.Id);
                        if (item && update.Status__c === 'ok') {
                            item.Status__c = 'ok';
                            item.aguardando = false;
                            item.Cobertura__c = update.Cobertura__c;
                            item.CustoFormatado = parseFloat(update.Custo_da_Analise__c).toLocaleString('pt-BR', {
                                minimumFractionDigits: 2,
                                maximumFractionDigits: 2
                            });
                            item.cor = item.Cobertura__c <= 40 ? 'vermelho' :
                                item.Cobertura__c <= 60 ? 'amarelo' : 'verde';
                            mudou = true;
                        }
                    });

                    if (mudou) {
                        component.set("v.analises", atual);
                        console.log("Analises atualizadas");
                    }

                    const aindaEmFila = atual.filter(a => a.aguardando);
                    if (aindaEmFila.length === 0) {
                        console.log("Todas as análises foram processadas");
                        clearInterval(intervalo);
                    }
                })
                .catch(function (error) {
                    console.error('Erro ao realizar SOQL:', error);
                    clearInterval(intervalo);  // Limpa o intervalo em caso de erro
                });
        }, 5000); // a cada 5 segundos
    }



})