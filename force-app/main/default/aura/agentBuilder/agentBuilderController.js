({
    loadAgent: function (cmp, event, helper) {

        // Escuta a tecla Enter no textarea
        $(document).on('keypress', '[aura\\:id="barraDeMensagem"]', function (e) {
            if (e.which === 13 && !e.shiftKey) { // Enter sem Shift
                e.preventDefault();
                $A.getCallback(function () {
                    cmp.get("c.enviarMensagem").run();
                })();
            }
            console.log("Clicado: ", e);
        });


        const userId = $A.get("$SObjectType.CurrentUser.Id");
        cmp.set("v.userId", userId);
        console.log("UserId: ", userId)
        console.log("iniciado")
        helper.showSpinner(cmp);
        helper.loadAgent(cmp, helper);
        helper.queryUser(cmp, helper, userId);
    },

    onChangeCampo: function (cmp, event, helper) {
        const campo = event.target.getAttribute("data-campo");
        const valor = event.target.value;

        let agente = cmp.get("v.agenteEmEdicao");
        agente[campo] = valor;
        cmp.set("v.agenteEmEdicao", agente);
    },

    keyCheck: function (cmp, event, helper) {
        var domEvent = event.getParam("domEvent");
        var key = domEvent.key || domEvent.keyCode;

        console.log("Tecla pressionada:", key);

        // Verifica se foi Enter sem Shift (para evitar quebra de linha)
        if (key === 'Enter' || key === 13) {
            if (!domEvent.shiftKey) {
                domEvent.preventDefault(); // Evita nova linha no textarea

                // Chama o método enviarMensagem
                //helper.enviarMensagemHelper(cmp);
            }
        }
    },

    handleAgenteChange: function (component, event, helper) {
        helper.showSpinner(component);
        const selectedId = event.target.value;
        const agentes = component.get("v.agentes");

        const agente = agentes.find(a => a.Id === selectedId);

        if (agente) {
            component.set("v.agenteSelecionado", agente);
            console.log("Agente selecionado:", agente);
            helper.loadThread(component, helper);
        }
    },
    buscarUsuarios: function (component, event, helper) {
        const termo = component.get("v.buscaUsuario");
        console.log("Termo digitado:", termo);

        if (!termo || termo.length < 2) {
            component.set("v.resultadosUsuario", []);
            return;
        }

        const query = `
        SELECT Id, Name, Username 
        FROM User 
        WHERE IsActive = true 
        AND Name LIKE '%${termo}%'
        LIMIT 10
    `;
        console.log("Query:", query);

        helper.soql(component, query).then(function (result) {
            console.log("Resultado da busca:", result);

            const selecionados = component.get("v.usuariosCompartilhados").map(u => u.Id);
            const filtrado = result.filter(u => !selecionados.includes(u.Id));
            component.set("v.resultadosUsuario", filtrado);
        }).catch(function (error) {
            console.error("Erro ao buscar usuários:", error);
            component.set("v.resultadosUsuario", []);
        });
    },


    adicionarUsuario: function (component, event, helper) {
        const id = event.target.getAttribute("data-id");
        const lista = component.get("v.usuariosCompartilhados");
        const encontrados = component.get("v.resultadosUsuario").filter(u => u.Id === id);

        if (encontrados.length > 0) {
            lista.push(encontrados[0]);
            component.set("v.usuariosCompartilhados", lista);
            component.set("v.buscaUsuario", "");
            component.set("v.resultadosUsuario", []);
            console.log("Usuario selecionados: ", lista)
        }
    },

    removerUsuario: function (component, event, helper) {
        const id = event.target.getAttribute("data-id");
        const lista = component.get("v.usuariosCompartilhados");
        const novaLista = lista.filter(u => u.Id !== id);
        component.set("v.usuariosCompartilhados", novaLista);
    },
    editarAgente: function (component, event, helper) {
        $('#fileSpinner').css('display', 'block');
        helper.loadFiles(component, helper);
        component.set("v.showEditModal", true);
        helper.showSpinner(component);

        const btn = event.target.getAttribute("data-mode");
        component.set("v.mode", btn);
        console.log("Botao clicado: ", btn);
        if (btn === 'Editar') {


            const agente = component.get("v.agenteSelecionado");
            component.set("v.agenteEmEdicao", Object.assign({}, agente));
            console.log("Agente em edição: ", agente);
            // Se houver usuários compartilhados
            const idsString = agente.Compartilhado_com__c;

            if (idsString) {
                const ids = idsString.split(',').map(id => `'${id.trim()}'`).join(',');

                const query = `
            SELECT Id, Name, Username 
            FROM User 
            WHERE Id IN (${ids})
        `;

                helper.soql(component, query).then(function (usuarios) {
                    component.set("v.usuariosCompartilhados", usuarios);

                }).catch(function (error) {

                    console.error("Erro ao buscar usuários compartilhados:", error);
                    component.set("v.usuariosCompartilhados", []);
                });
            } else {

                component.set("v.usuariosCompartilhados", []);
            }
        } else {

            const agente = component.get("v.novoAgente");
            component.set("v.agenteEmEdicao", Object.assign({}, agente));
            //component.set("v.agenteSelecionado", Object.assign({}, agente));
            console.log("agenteNovo: ", agente)

        }
        helper.hideSpinner(component);

    },

    newThread: function (cmp, event, helper) {
        // helper.showSpinner(cmp);
        const agentId = cmp.get("v.agenteSelecionado.Id");
        console.log("AgentId: ", agentId);

        // Passo 1: Pega o array atual de threads
        let threads = cmp.get("v.threads");

        // Verifica se está inicializado como array
        if (!threads) {
            threads = [];
        }

        // Passo 2: Verifica se já existe algum objeto com Id = "0"
        const existeThread = threads.some(thread => thread.Id === "0");

        if (!existeThread) {
            // Passo 3: Cria o novo objeto
            let novoThread = {
                Agente_OpenAI__c: agentId,
                Id: "0",
                Name: "Nova conversa",
                Status__c: "ABERTA"
            };

            // Passo 4: Adiciona ao array
            threads.unshift(novoThread);

            // Passo 5: Atualiza o valor do atributo
            cmp.set("v.threads", threads);
            cmp.set("v.historico", null)
            cmp.set("v.threadSelecionada", novoThread);

        } else {
            console.log("Já existe um objeto com Id igual a '0'. Não será adicionado um novo.");
        }



    },

    cancelarEdicao: function (component, event, helper) {
        component.set("v.showEditModal", false);
        component.set("v.agenteEmEdicao", null);
        component.set("v.resultadosUsuario", []);
        component.set("v.buscaUsuario", '');
        component.set("v.usuariosCompartilhados", [])
        component.set("v.mode", "");
    },

    salvarAgente: function (component, event, helper) {
        const campos = [
            component.find("campoNome"),
            component.find("campoDescricao"),
            component.find("campoInstrucoes")
        ];

        let todosValidos = true;

        campos.forEach(campo => {
            if (!campo.checkValidity()) {
                campo.reportValidity();
                todosValidos = false;
            }
        });

        if (!todosValidos) {
            return; // bloqueia o avanço
        }

        helper.showSpinner(component);
        const agente = {
            agentId: component.get("v.agenteEmEdicao.assistent_id__c")
                ? component.get("v.agenteEmEdicao.assistent_id__c")
                : undefined,

            recordId: component.get("v.agenteEmEdicao.Id")
                ? component.get("v.agenteEmEdicao.Id")
                : undefined,

            share: component.get("v.usuariosCompartilhados").map(u => u.Id),
            name: component.get("v.agenteEmEdicao.Name"),
            description: component.get("v.agenteEmEdicao.Descricao__c"),
            instruction: component.get("v.agenteEmEdicao.Intrucoes__c")
        };

        console.log(agente);
        helper.updateAgent(component, agente, helper);

    },
    abrirConfirmacaoExclusao: function (component, event, helper) {
        component.set("v.exibirConfirmacaoExclusao", true);
    },

    fecharConfirmacaoExclusao: function (component, event, helper) {
        component.set("v.exibirConfirmacaoExclusao", false);
    },
    deleteAgent: function (cmp, event, helper) {
        cmp.set("v.exibirConfirmacaoExclusao", false);
        helper.showSpinner(cmp);
        const agentId = cmp.get("v.agenteSelecionado.assistent_id__c");
        helper.deleteAgent(cmp, helper, agentId);

    },
    openThread: function (cmp, event, helper) {

        // Pega o ID do atributo data-threadId
        const clickedId = event.currentTarget.getAttribute("data-threadId");
        console.log("clickedId:", clickedId);

        if (clickedId === cmp.get("v.threadSelecionada.Id")) {
            return
        }
        helper.showSpinner(cmp);
        cmp.set("v.threadSelecionada", null);
        cmp.set("v.historico", null);

        // Recupera a lista de threads
        const threads = cmp.get("v.threads");

        // Encontra a thread correspondente
        const threadSelecionada = threads.find(t => t.Id === clickedId);

        // Atualiza o valor no componente
        cmp.set("v.threadSelecionada", threadSelecionada);

        // Debug no console
        console.log('Thread selecionada:', threadSelecionada.Id);

        helper.loadMessages(cmp, helper);

        // Caso a thread selecionada tenha um nome editado, garante que as mudanças sejam refletidas
        if (cmp.get("v.threadSelecionada.Name") !== threadSelecionada.Name) {
            const updatedThreads = threads.map(thread => {
                if (thread.Id === clickedId) {
                    thread.Name = cmp.get("v.threadSelecionada.Name");  // Atualiza o nome
                }
                return thread;
            });

            // Atualiza o array de threads 
            cmp.set("v.threads", updatedThreads);

        }
    },
    handleNameChange: function (cmp, event, helper) {
        // Pega o novo nome da thread
        const novoNome = event.target.value;  // Usando event.target para pegar o valor

        // Recupera o array de threads e a thread selecionada
        const threads = cmp.get("v.threads");
        const threadSelecionada = cmp.get("v.threadSelecionada");

        // Encontra o índice da thread selecionada no array
        const index = threads.findIndex(thread => thread.Id === threadSelecionada.Id);

        // Se a thread for encontrada, atualize o nome
        if (index !== -1) {
            // Atualiza o nome no array de threads
            threads[index].Name = novoNome;
            cmp.set("v.threads", threads);    // Atualiza o array de threads no componente

            // Atualiza o nome na threadSelecionada diretamente
            threadSelecionada.Name = novoNome;
            cmp.set("v.threadSelecionada", threadSelecionada);  // Atualiza o valor da threadSelecionada
        }

        helper.updateThread(cmp, helper, threadSelecionada);
    },

    enviarMensagem: function (cmp, event, helper) {

        const mensagem = cmp.get("v.msg");
        console.log("msg value: ", mensagem);

        if (mensagem.trim().length === 0) {
            return;
        }
        const novaMensagem = {
            role: 'user',
            content: mensagem,
            created_at: new Date().toLocaleString('pt-BR', {
                day: '2-digit', month: '2-digit', year: 'numeric',
                hour: '2-digit', minute: '2-digit'
            }),
        };

        let historico = cmp.get("v.historico") || [];

        historico.push(novaMensagem);


        cmp.set("v.historico", historico);

        cmp.set("v.digitando", true);

        cmp.set("v.msg", "");



        setTimeout(() => {
            const chatDiv = cmp.find("chatHistory");
            if (chatDiv && chatDiv.getElement) {
                const el = chatDiv.getElement();
                el.scrollTop = el.scrollHeight;
            }
        }, 50);
        helper.enviarMensagemAgent(cmp, helper, novaMensagem);

    },
    onChangeMensagem: function (cmp, event, helper) {
        const msg = cmp.find("barraDeMensagem").get("v.value");
        cmp.set("v.msg", msg);
    },
    handleUploadFinished: function (component, event, helper) {
        helper.loadFiles(component, helper);

        const uploadedFiles = event.getParam("files");
        console.log("Arquivos enviados:", uploadedFiles);

        // Atualiza a lista de arquivos na tela
        let existing = component.get("v.uploadedFiles") || [];
        component.set("v.uploadedFiles", existing.concat(uploadedFiles));

        let agentId = component.get("v.agenteSelecionado.assistent_id__c");
        console.log("agentId: ", agentId);

        if (uploadedFiles.length > 0) {
            const file = uploadedFiles[0];
            const payload = {
                documentId: file.documentId,
                contentVersionId: file.contentVersionId,
                name: file.name,
                agentId: agentId
            };

            helper.enviarArquivo(component, helper, payload);
        }
    },

})