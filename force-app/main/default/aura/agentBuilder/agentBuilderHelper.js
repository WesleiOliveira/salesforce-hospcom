({

    showSpinner: function (cmp) {
        $('#spinner').css('display', 'block');

    },
    hideSpinner: function (cmp) {
        $('#spinner').css('display', 'none');

    },
    updateAgent: function (component, agente, helper) {
        const userId = component.get("v.userId");
        const payload =
        {
            ownerId: userId,
            recordId: agente.recordId,
            agentId: agente.agentId,
            share: agente.share,
            name: agente.name,
            description: agente.description,
            instruction: agente.instruction,
        };
        console.log("Payload: ", JSON.stringify(payload))
        fetch("https://workflowwebhook.hospcom.net/webhook/updateAgent", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        })
            .then(response => {
                if (response.status !== 200) {
                    helper.mostrarToast("Erro ", `Status: ${response.status}`, "error");
                    throw new Error("Erro : " + response.status);
                }
                return;
            })
            .then(data => {

                helper.mostrarToast("Sucesso", "Agente atualizado com sucesso!", "success");
            })
            .catch(error => {
                helper.mostrarToast("Erro", error.message, "error");
            })
            .finally(() => {
                helper.loadAgent(component, helper);
                component.set("v.showEditModal", false);
                component.set("v.agenteEmEdicao", null);
                component.set("v.resultadosUsuario", []);
                component.set("v.buscaUsuario", '');
                component.set("v.usuariosCompartilhados", []);

            });

    },


    deleteAgent: function (cmp, helper, agentId) {
        console.log("agent id: ", agentId);

        const url = 'https://workflowwebhook.hospcom.net/webhook/deleteAgent';

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ agentId: agentId })
        })
            .then(response => {
                if (response.ok) {
                    helper.mostrarToast("Sucesso", "Agente excluído!", "success");
                } else {
                    helper.mostrarToast("Erro ", `Status: ${response.status}`, "error");
                }
            })
            .catch(error => {
                console.error('Erro na requisição:', error);
            }).finally(() => {
                cmp.set("v.showEditModal", false);
                cmp.set("v.agenteEmEdicao", null);
                cmp.set("v.resultadosUsuario", []);
                cmp.set("v.buscaUsuario", '');
                cmp.set("v.usuariosCompartilhados", []);
                helper.loadAgent(cmp, helper);


            });


    },

    mostrarToast: function (titulo, mensagem, tipo) {
        const toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: titulo,
                message: mensagem,
                type: tipo,
                mode: 'dismissible'
            });
            toastEvent.fire();
        } else {
            alert(`${titulo}: ${mensagem}`);
        }
    },

    loadAgent: function (cmp, helper) {
        helper.mostrarToast("Carregando", "Aguarde um momento...", "info");

        console.log("carregando agentes...");

        const query = 'SELECT Id, Name, assistent_id__c, OwnerId, Intrucoes__c, Descricao__c, Compartilhado_com__c FROM Agent__c WHERE Ativo__c = true ORDER BY CreatedDate DESC';
        console.log("Query: ", query);

        helper.soql(cmp, query).then(function (result) {
            console.log("Agente encontrado: ", result);

            cmp.set("v.agentes", result);


            if (result && result.length > 0) {
                cmp.set("v.agenteSelecionado", result[0]);
                cmp.set("v.carregado", true);
                $('#initialContainer').css('display', 'none');

                helper.loadThread(cmp, helper);
            }
            else {
                helper.hideSpinner(cmp);
                cmp.set("v.carregado", false);
                $('#initialContainer').css('display', 'block');
            }
        }).catch(function (error) {
            console.error("Erro ao buscar agente: ", error);
        }).finally(function () {
            //cmp.set("v.agentIsLoading", false);
        });

    },

    loadThread: function (cmp, helper) {
        helper.mostrarToast("Carregando", "Aguarde um momento...", "info");
        cmp.set("v.threadSelecionada", null);
        cmp.set("v.threads", null);
        console.log("Carregando thread...");
        const recordId = cmp.get("v.agenteSelecionado.Id");
        console.log("recordId: ", recordId);

        const query = `SELECT Id, Name, Status__c, thread_id__c, Agente_OpenAI__c FROM Thread__c WHERE Agente_OpenAI__c = '${recordId}' AND Status__c != 'FECHADA' ORDER BY CreatedDate DESC`;

        helper.soql(cmp, query).then(function (result) {
            console.log("thread encontrada: ", result);
            cmp.set("v.threads", result);


            if (result && result.length > 0) {
                cmp.set("v.threadSelecionada", result[0]);
            }

            helper.loadMessages(cmp, helper);

        }).catch(function (errr) {
            console.error("Erro ao buscar thread: ", errr);
        });

    },

    newThread: function (cmp, helper, agentId) {
        console.log("Criando nova thread...");
        helper.hideSpinner(cmp);
    },

    loadMessages: function (cmp, helper) {
        helper.mostrarToast("Carregando", "Aguarde um momento...", "info");
        cmp.set("v.historico", null);
        console.log("Carregando mensagens...");
        let threadId = cmp.get("v.threadSelecionada.Id");
        console.log("threadSelecionada: ", threadId);

        const query = `
        SELECT Id, content__c, CreatedDate, Thread__c, role__c
        FROM Thread_Message__c
        WHERE Thread__c = '${threadId}'
        ORDER BY CreatedDate ASC
        `;

        helper.soql(cmp, query).then(function (result) {
            console.log("Mensagens encontradas: ", result);

            const mensagensFormatadas = result.map(msg => {
                const dataFormatada = new Date(msg.CreatedDate).toLocaleString('pt-BR', {
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                });

                return {
                    role: msg.role__c === 'user' ? 'user' : 'assistant',
                    content: helper.formatarConteudo(msg.content__c),
                    created_at: dataFormatada

                };
            });

            cmp.set("v.historico", mensagensFormatadas);


            // Scroll automático após carregar histórico
            setTimeout(() => {
                const chatEl = cmp.find("chatHistory");
                if (chatEl && chatEl.getElement) {
                    const domEl = chatEl.getElement();
                    domEl.scrollTop = domEl.scrollHeight;
                }
            }, 50);

        }).catch(function (error) {
            console.error("Erro ao buscar mensagens: ", error);
        }).finally(function () {
            helper.hideSpinner(cmp);
        });
    },
    updateThread: function (cmp, helper, thread) {
        // Verifica se o ID da thread é 0, e retorna sem fazer nada
        if (thread.Id === "0") {
            helper.newThread(cmp, helper, thread);
            return;
        }

        const payload = {
            Agente_OpenAI__c: thread.Agente_OpenAI__c,
            Id: thread.Id,
            Name: thread.Name,
            Status__c: thread.Status__c
        };
        console.log("Payload:", payload);

        const url = 'https://workflowwebhook.hospcom.net/webhook/33ece78c-f5fe-49c9-9257-ad69b10c2412';

        // Envia a requisição POST usando fetch
        fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        })
            .then(function (response) {
                // Verifica se o status da resposta é 200 (OK)
                if (response.status !== 200) {
                    console.error("Erro ao atualizar thread. Status:", response.status);
                } else {
                    console.log("Thread atualizada com sucesso.");
                }
            })
            .catch(function (error) {
                // Tratamento de erro caso a requisição falhe
                console.error("Erro ao fazer a requisição:", error);
            });
    },
    enviarMensagemAgent: function (cmp, helper, novaMensagem) {
        const agent = cmp.get("v.agenteSelecionado");

        const thread = cmp.get("v.threadSelecionada");

        if (!thread) {

        }

        console.log("agent: ", JSON.stringify(agent));
        console.log("thread: ", JSON.stringify(thread));

        // Monta o payload
        const payload = {
            msg: {
                content: novaMensagem.content,
                created_at: novaMensagem.created_at
            },
            agent: {
                recordId: agent.Id,
                agentId: agent.assistent_id__c
            },
            thread: {
                recordId: thread.Id,
                threadId: thread.thread_id__c,
                name: thread.Name
            }
        };

        const url = 'https://workflowwebhook.hospcom.net/webhook/message';

        // Faz a requisição usando fetch
        fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        })
            .then(function (response) {
                // Verifica se a resposta foi bem-sucedida
                if (response.status === 200) {
                    response.json().then((data) => {
                        // Verifica se a resposta contém os dados necessários
                        if (data && data.value && data.created_at) {
                            // Cria a nova mensagem (resposta do assistente)
                            const resposta = {
                                role: 'assistant',
                                content: helper.formatarConteudo(data.value),
                                created_at: data.created_at
                            };

                            // Recupera o histórico existente ou inicializa um array vazio
                            let historico = cmp.get("v.historico") || [];

                            // Adiciona a nova resposta ao histórico
                            historico.push(resposta);

                            // Atualiza o histórico no componente
                            cmp.set("v.digitando", false)
                            cmp.set("v.historico", historico);



                            // Atualiza o threadSelecionada com os novos dados da thread
                            const threadData = {
                                Id: data.threadRecordId,
                                thread_id__c: data.threadId,
                                Name: data.threadName,
                                Agente_OpenAI__c: data.agentId,
                                Status__c: "ABERTA"
                            };
                            console.log(JSON.stringify(threadData))
                            // Atualiza a thread no componente
                            cmp.set("v.threadSelecionada", threadData);

                            let threads = cmp.get("v.threads") || [];

                            const threadIndex = threads.findIndex(thread => thread.Id === "0");

                            threads[threadIndex] = Object.assign({}, threads[threadIndex], {
                                Id: data.threadRecordId,
                                thread_id__c: data.threadId,
                                Name: data.threadName,
                                Agente_OpenAI__c: data.agentId,
                                Status__c: "ABERTA"
                            });
                            console.log("Nova Thread att: ", JSON.stringify(threads))
                            cmp.set("v.threads", threads);
                        } else {
                            console.error("Dados da resposta não estão completos:", data);
                        }
                    });
                } else {
                    console.error("Erro ao enviar mensagem. Status:", response.status);
                }
            })
            .catch(function (error) {
                console.error("Erro na requisição:", error);
            })
            .finally(() => {
                // Rola a tela para a última mensagem após processar a resposta
                setTimeout(() => {
                    const chatDiv = cmp.find("chatHistory");
                    if (chatDiv && chatDiv.getElement) {
                        const el = chatDiv.getElement();
                        el.scrollTop = el.scrollHeight;
                    }
                }, 50);
            });
    },
    newThread: function (cmp, helper, thread) {

        const payload = {
            Agente_OpenAI__c: thread.Agente_OpenAI__c,
            Id: thread.Id,
            Name: thread.Name,
            Status__c: thread.Status__c
        };
        console.log("Payload:", payload);

        const url = 'https://workflowwebhook.hospcom.net/webhook/createThread';

        // Envia a requisição POST usando fetch
        fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        })
            .then(function (response) {
                // Verifica se o status da resposta é 200 (OK)
                if (response.status === 200) {
                    response.json().then((data) => {

                        const threadData = {
                            Id: data.threadRecordId,
                            thread_id__c: data.threadId,
                            Name: data.threadName,
                            Agente_OpenAI__c: data.agentId,
                            Status__c: "ABERTA"
                        };
                        console.log(JSON.stringify(threadData));

                        cmp.set("v.threadSelecionada", threadData);

                        let threads = cmp.get("v.threads") || [];

                        const threadIndex = threads.findIndex(thread => thread.Id === "0");

                        threads[threadIndex] = Object.assign({}, threads[threadIndex], {
                            Id: data.threadRecordId,
                            thread_id__c: data.threadId,
                            Name: data.threadName,
                            Agente_OpenAI__c: data.agentId,
                            Status__c: "ABERTA"
                        });
                        console.log("Nova Thread att: ", JSON.stringify(threads))
                        cmp.set("v.threads", threads);

                    });
                } else {
                    console.error("Erro ao criar Thread.");
                }
            })
            .catch(function (error) {
                // Tratamento de erro caso a requisição falhe
                console.error("Erro ao fazer a requisição:", error);
            });

    },
    queryUser: function (cmp, helper, userId) {
        const query = `SELECT Id, gerente_Ou_Gestor__c FROM user WHERE Id = '${userId}'`
        helper.soql(cmp, query).then(function (result) {


            cmp.set("v.gestor", result[0].gerente_Ou_Gestor__c);

            console.log("Usuario gestor = ", cmp.get("v.gestor"))

        }).catch(function (errr) {
            console.error("Erro ao buscar user: ", errr);
        });
    },
    loadFiles: function (cmp, helper) {
        $('#fileSpinner').css('display', 'block');
        console.log("🔄 Iniciando carregamento de arquivos...");

        const recordId = cmp.get("v.agenteSelecionado.Id");
        console.log("RecordId: ", recordId);

        const queryLinks = `
        SELECT ContentDocumentId 
        FROM ContentDocumentLink 
        WHERE LinkedEntityId = '${recordId}'
    `;

        helper.soql(cmp, queryLinks) // <-- aqui é o ponto crítico!
            .then(function (resLinks) {
                const links = resLinks.records || resLinks;
                console.log("📎 Links encontrados:", links);

                if (!links || links.length === 0) {
                    $('#fileContainer').empty().append('<p>Nenhum arquivo encontrado.</p>');
                    return [];
                }

                const documentIds = links
                    .map(link => link.ContentDocumentId)
                    .filter(id => !!id)
                    .map(id => `'${id}'`)
                    .join(",");

                if (!documentIds) {
                    console.warn("⚠️ Nenhum ContentDocumentId válido.");
                    $('#fileContainer').empty().append('<p>Nenhum arquivo válido encontrado.</p>');
                    return [];
                }

                const queryVersions = `
                SELECT Id, Title, FileExtension, ContentDocumentId 
                FROM ContentVersion 
                WHERE ContentDocumentId IN (${documentIds})
                AND IsLatest = true
                ORDER BY Title
            `;

                console.log("📄 SOQL dos arquivos:", queryVersions);
                helper.mostrarToast("Carregando", "Aguarde um momento...", "info");
                return helper.soql(cmp, queryVersions); // <- aqui também
            })
            .then(function (resVersions) {

                if (!resVersions || resVersions.length === 0) {
                    $('#fileContainer').empty().append('<p>Nenhum arquivo encontrado.</p>');
                    $('#fileSpinner').css('display', 'none');
                    return;
                }

                console.log("✅ Arquivos carregados:", resVersions);

                const arquivos = resVersions;
                const container = $('#fileContainer');
                container.empty();

                $('#fileSpinner').css('display', 'none');
                arquivos.forEach(function (file) {
                    const fileLink = $('<a>')
                        .attr('href', '/sfc/servlet.shepherd/version/download/' + file.Id)
                        .attr('target', '_blank')
                        .addClass('slds-text-link')
                        .text(file.Title);

                    const deleteBtn = $('<button>')
                        .addClass('modal-close')
                        .attr('title', 'Excluir arquivo')
                        .attr('style', 'color:red')
                        .html('x')
                        .click(function () {
                            helper.deleteFile(cmp, helper, file);
                        });

                    const fileDiv = $('<div>')
                        .addClass('fileItem slds-p-vertical_x-small slds-flex slds-align-center')
                        .append(fileLink)
                        .append(deleteBtn);

                    container.append(fileDiv);
                });
            })
    },

    deleteFile: function (cmp, helper, file) {
        $('#fileSpinner').css('display', 'block');
        const agentId = cmp.get("v.agenteSelecionado.assistent_id__c");

        const payload = JSON.stringify({
            Id: file.Id,
            Title: file.Title,
            FileExtension: file.FileExtension,
            ContentDocumentId: file.ContentDocumentId,
            agentId: agentId
        });
        

        const url = 'https://workflowwebhook.hospcom.net/webhook/deletefile';

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: payload
        }).then(response => {
            if (response.status === 200) {
                helper.loadFiles(cmp, helper);
            }
        }).catch(error => {
            console.error(error);
        }).finally(() => {
            $('#fileSpinner').css('display', 'none');
        });
    },
    enviarArquivo: function (cmp, helper, payload) {

        console.log("Payload: ", JSON.stringify(payload))

        const url = 'https://workflowwebhook.hospcom.net/webhook/uploadfile';

        fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        }).then(response => {
            if (response.status === 200) {
                console.log("yeap");
            }
        }).catch(error => {
            console.error(error);
        });
    },


    formatarConteudo: function (texto) {
        if (!texto) return "";

        var html = texto;

        // Remove aspas iniciais/finais se existirem
        if (html.startsWith('"') && html.endsWith('"')) {
            html = html.substring(1, html.length - 1);
        }

        // Negrito: **texto**
        html = html.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>");

        // Itálico: *texto*
        html = html.replace(/\*(.*?)\*/g, "<em>$1</em>");

        // Títulos
        html = html.replace(/^### (.*$)/gim, "<h3>$1</h3>");
        html = html.replace(/^## (.*$)/gim, "<h2>$1</h2>");
        html = html.replace(/^# (.*$)/gim, "<h1>$1</h1>");

        // Listas: - item ou * item
        html = html.replace(/^- (.*$)/gim, "<li>$1</li>");
        html = html.replace(/^\* (.*$)/gim, "<li>$1</li>");

        // Agrupar <li> em <ul>
        html = html.replace(/(<li>[\s\S]*?<\/li>)/g, "<ul>$1</ul>");

        // Quebras de linha
        html = html.replace(/\n/g, "<br/>");

        return html.trim();
    }


})