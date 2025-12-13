({


    doInit: function (cmp, event, helper) {
        console.log("===INICIADO===")
        //-----------------SET DATE--------------------
        const now = new Date().toLocaleString('pt-BR', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit'
        });

        //-------------------------------------------------

        cmp.set("v.novaAnalise", {
            //  sobjectType: "Analise_de_Equipamento__c",
            Nome_do_Termo_de_Referencia__c: '',
            Nome_do_Equipamento__c: '',
            Numero_do_Item__c: null,
            Quantidade__c: null,
            Descricao__c: '',
            Valor__c: null
        });

        helper.queryAnalises(cmp, helper);

        cmp.set("v.historico", [
            {
                role: "assistant",
                content: "Olá!👋 Como posso ajudar?",
                created_at: now
            }
        ]);

    },
    handleAgenteSelecionado: function (component, event, helper) {
        const valorSelecionado = event.getSource().get("v.value");
        if (valorSelecionado) {
            component.set("v.agenteSelecionado", valorSelecionado);
        }
    },
    trocarAgente: function (component, event, helper) {
        component.set("v.agenteSelecionado", "");
    },

    openPdfModal: function (component, event, helper) {
        const fileId = event.currentTarget.dataset.fileid;
        const url = 'https://drive.google.com/file/d/' + fileId + '/preview';
        component.set("v.pdfUrl", url);
        component.set("v.isPdfModalOpen", true);
    },

    closePdfModal: function (component, event, helper) {
        component.set("v.isPdfModalOpen", false);
        component.set("v.pdfUrl", null);
    },


    iniciaObjAnalise: function (cmp) {
        cmp.set("v.novaAnalise", {
            //   sobjectType: "Analise_de_Equipamento__c",
            Nome_do_Termo_de_Referencia__c: '',
            Nome_do_Equipamento__c: '',
            Numero_do_Item__c: null,
            Quantidade__c: null,
            Descricao__c: '',
            Valor__c: null
        });
    },

    handleNovaAnaliseClick: function (component, event, helper) {
        $('#NovaAnaliseBtn').css("display", "none");
        component.set("v.chatOn", true);
        const novaAnalise = component.find("novaAnalise");
        const fullContainer = component.find("analiseFullContainer");
        const chat = component.find("chat");

        $A.util.addClass(novaAnalise, "show");
        $A.util.removeClass(novaAnalise, "minimized");

        $A.util.addClass(chat, "minimized");
        $A.util.removeClass(fullContainer, "show");
    },

    handleAnaliseClick: function (component, event, helper) {
        const aguardando = event.currentTarget.getAttribute("data-aguardando") === 'true';
        if (aguardando) {
            alert("Esta análise ainda está em fila. Aguarde a conclusão.");
            return;
        }

        $('#NovaAnaliseBtn').css("display", "block");
        component.set("v.analiseAlterada", false);
        component.set("v.chatOn", true);

        const fullContainer = component.find("analiseFullContainer");
        $A.util.removeClass(fullContainer, "show");

        component.set("v.isLoading", true);
        let recordId = event.currentTarget.id;
        component.set("v.idDaAnaliseSelecionada", recordId);
        console.log("Clicado: ", recordId);

        helper.queryAnaliseClicada(component, helper, recordId)
            .then(() => {
                // Depois que os dados da análise forem carregados:
                const fullContainer = component.find("analiseFullContainer");
                const chat = component.find("chat");
                const novaAnalise = component.find("novaAnalise");

                $A.util.addClass(fullContainer, "show");
                $A.util.addClass(chat, "minimized");

                $A.util.removeClass(novaAnalise, "show");
                $A.util.addClass(novaAnalise, "minimized");

                // Insere a análise HTML
                let analise = component.get("v.analise");
                let descricaoHtml = analise.Analise__c || '';

                let descricaoEl = component.find("descricao");
                if (descricaoEl && descricaoEl.getElement) {
                    descricaoEl.getElement().innerHTML = descricaoHtml;
                }
                component.set("v.isLoading", false);
            })
            .catch(error => {
                console.error("Erro ao carregar análise:", error);
                component.set("v.isLoading", false);
            });
    },


    handleChatClick: function (component, event, helper) {
        const btn = event.target.getAttribute("data-type");
        component.set("v.btn", btn);
        component.set("v.historico", '');
        console.log("btn clicked: ", btn);
        $('#NovaAnaliseBtn').css("display", "block");
        const now = new Date().toLocaleString('pt-BR', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit'
        });

        if (btn === "chat") {

            component.set("v.chatOn", false);
            console.log("Passou aqui")
            component.set("v.historico", [
                {
                    role: "assistant",
                    content: "Olá!👋 Como posso ajudar?",
                    created_at: now
                }
            ]);
            console.log(JSON.stringify(component.get("v.historico")));


        } else {
            const threadId = component.get("v.analise.threadId__c");
            console.log(JSON.stringify(component.get("v.analise.threadId__c")))
            console.log("ThreadId: ", threadId);
            helper.queryHistoricoChat(component, helper, threadId);
        }




        const fullContainer = component.find("analiseFullContainer");
        const chat = component.find("chat");
        const novaAnalise = component.find("novaAnalise");

        $A.util.removeClass(fullContainer, "show");
        $A.util.removeClass(chat, "minimized");

        $A.util.removeClass(novaAnalise, "show");
        $A.util.addClass(novaAnalise, "minimized");


    },

    sendMsg: function (cmp, event, helper) {
        const btn = cmp.get("v.btn");
        console.log("btn clicked: ", btn);
        let id = '';
        if (btn === "analise") {
            id = cmp.get("v.analise.threadId__c");
        } else {
            id = cmp.get("v.threadId");

        }

        const msg = cmp.get("v.msg")


        cmp.set("v.msg", "");

        console.log("UserMsg: ", msg);
        console.log("threadId: ", id);

        helper.sendMsg(cmp, event, helper, msg, id);
    },


    salvarAnalise: function (component, event, helper) {
        component.set("v.btnSalvarNovaAnalise", false)
        component.set("v.saving3", true)

        if (helper.verificaCamposObrigatorios(component, helper)) {
            helper.salvaNovaAnalise(component, helper);
        }
      
    },
    salvarFeedback: function (component, event, helper) {
        helper.salvarFeedback(component, helper);
    },
    marcarAlterado: function (cmp, event, helper) {
        cmp.set("v.analiseAlterada", true);
    },
        ativaSalvarbtn: function (cmp) {
        cmp.set("v.btnSalvarNovaAnalise", true)
    }



})