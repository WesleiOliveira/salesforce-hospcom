({
    idConta: "",
    idCotacao: "",
    mainMethod: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        helper.getStatus(cmp, recordId, helper);
        helper.getAnaliseDeCredito(cmp, recordId, helper);

        $("#button342u3423").off().on("click", function () {
            $("#containerPopup4358498").css("display", "flex")
            $("#overlay4567").css("display", "flex")
            helper.simulaAprovacao(cmp, event, helper)
        });

        $(".button342u3423546").off().on("click", function () {
            $("#containerPopup4358498").css("display", "none")
            $("#xyz").css("display", "none")
            $("#overlay4567").css("display", "none")
        });

        $("#abrirAnalises").off().on("click", function () {
            var recordId = cmp.get("v.recordId");
            helper.abrirAnalises(cmp, recordId, helper)
        });

        $("#solicitarNovaAnalise").off().on("click", function () {
            helper.solicitaNovaAnalise(cmp, event, helper)
        });

        $("#buttonEnviar32423").off().on("click", function () {
            helper.enviaAprovacao(cmp, event, helper)
        });

        this.buscaTarefa(cmp, event, helper, recordId);

    },
    abrirAnalises: function (cmp, recordId, helper) {
        const analises = cmp.get("v.analiseDeCredito");

        // Verifica se há registros válidos
        if (!Array.isArray(analises) || analises.length === 0) {
            console.warn("Nenhuma análise de crédito disponível para abrir.");
            return;
        }

        if (analises.length === 1) {
            // Apenas uma análise de crédito – redireciona para o registro individual
            const analiseId = analises[0].Id;
            const url = `https://hospcom.my.site.com/Sales/s/analise-de-credito/${analiseId}`;
            window.open(url, "_blank"); // Abre em nova aba
        } else {
            // Mais de uma análise – redireciona para a lista relacionada da cotação
            const url = `https://hospcom.my.site.com/Sales/s/quote/related/${recordId}/An_lises_de_Cr_dito__r`;
            window.open(url, "_blank"); // Abre em nova aba
        }
    },


    enviaAprovacao: function (cmp, event, helper) {
        var action = cmp.get("c.enviarAprovacao");
        var recordId = cmp.get("v.recordId");

        helper.alertaErro(cmp, event, helper, "", "Carregando...", "info", "", "dismissable")

        action.setParams({
            quoteId: recordId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                helper.alertaErro(cmp, event, helper, "Proposta enviada para aprovação", "Ok!", "success", "", "dismissable")
                $("#containerPopup4358498").css("display", "none")
                $("#overlay4567").css("display", "none")

            } else if (state == "ERROR") {
                var errors = response.getError();
                console.error("Erro ao chamar Apex:", errors);
            }
        });

        $A.enqueueAction(action);
    },

    solicitaNovaAnalise: function (cmp, event, helper) {
        var cotacao = cmp.get("v.cotacao");
        if (!cotacao) {
            console.error("Erro: ", errors);
            return;
        }
        var createRecordEvent = $A.get("e.force:createRecord");

        createRecordEvent.setParams({
            "entityApiName": "Analise_de_Credito__c",
            "defaultFieldValues": {
                'Cotacao__c': cotacao.Id,
                'Conta__c': cotacao.AccountId,
                'Oportunidade__c': cotacao.OpportunityId,
                'Valor_solicitado__c': cotacao.Saldo_parcelado__c
            }
        });
        createRecordEvent.fire();
    },

    alertaErro: function (cmp, event, helper, error, title, type, tipoMensagem, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": tipoMensagem + " " + error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },

    simulaAprovacao: function (cmp, event, helper) {
        var action = cmp.get("c.validateQuote");
        var recordId = cmp.get("v.recordId");

        helper.alertaErro(cmp, event, helper, "", "Gerando simulação...", "info", "", "dismissable")

        action.setParams({
            quoteId: recordId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                var retorno = response.getReturnValue();
                helper.preencheView(cmp, event, helper, JSON.parse(retorno))

            } else if (state == "ERROR") {
                var errors = response.getError();
                console.error("Erro ao chamar Apex:", errors);
            }
        });

        $A.enqueueAction(action);
    },

    preencheView: function (cmp, event, helper, data) {
        console.log("Valor retornado:", data);
        const existeAnaliseDeCredito = cmp.get("v.existeAnaliseDeCredito")

        var testesData = data.validados
        var errosData = data.errors
        var etapa = 0

        //CAMPOS PARA DESABILITAR O BOTAO DE ENVIAR
        const camposInvalidos = [
            !data.entradaValidada,
            !data.valorParcelaValidado,
            !data.valorTotalValidado,
            data.necessitaAnalise
        ];
        console.log(camposInvalidos);
        //DESABILITA BOTAO ENVIAR
        if (camposInvalidos.some(Boolean)) {
            $("#buttonEnviar32423").css("display", "none")
        }

        //LIMPA DIV COM AS ETAPAS
        $("#body3489473").empty()
        $("#text47854843Title").empty()

        if (data.necessitaAnalise && !existeAnaliseDeCredito) {
            $("#solicitarNovaAnalise").css("display", "flex")
        }
        if (data.necessitaAnalise && existeAnaliseDeCredito) {
            $("#abrirAnalises").css("display", "flex")

        }

        helper.idConta = data.idConta;
        helper.idCotacao = data.idCotacao;

        $("#text47854843Title").html("Simulação Nº " + data.simulacao)

        testesData.forEach((element, indice) => {
            console.log(element)

            var titulo = indice + 1 + "º" + " Etapa"
            var subtitulo = element

            var html = "<div class='step'>\
<div>\
<div class='circle verde'><i class='fa fa-check'></i></div>\
</div>\
<div>\
<div class='title'>"+ titulo + "</div>\
<div class='caption'>"+ subtitulo + "</div>\
</div>\
</div>";
            etapa = indice + 1

            $("#body3489473").append(html);
        });

        errosData.forEach((element, indice) => {
            console.log(element)

            var titulo = etapa + 1 + "º" + " Etapa"
            var subtitulo = element

            var html = "<div class='step step-active'>\
<div>\
<div class='circle'><i class='fa fa-times'></i></div>\
</div>\
<div>\
<div class='title'>"+ titulo + "</div>\
<div class='caption'>"+ subtitulo + "</div>\
</div>\
</div>";

            $("#body3489473").append(html)
            etapa = etapa + 1
        });

        if (!data.success) {

            var html = "<div class='step'>\
<div>\
<div class='circle amarelo'><i class='fa fa-key'></i></div>\
</div>\
<div>\
<div class='title'>Aprovador</div>\
<div class='caption'>"+ data.aprovador + "</div>\
</div>\
</div>";

            $("#body3489473").append(html)
        }


    },
    getDataMaisDoisDiasUteis: function () {
        const hoje = new Date();
        let count = 0;

        while (count < 2) {
            hoje.setDate(hoje.getDate() + 1);
            const diaSemana = hoje.getDay();
            if (diaSemana !== 0 && diaSemana !== 6) { // não é domingo nem sábado
                count++;
            }
        }

        const ano = hoje.getFullYear();
        const mes = String(hoje.getMonth() + 1).padStart(2, '0');
        const dia = String(hoje.getDate()).padStart(2, '0');

        return `${ano}-${mes}-${dia}`;
    },
    buscaTarefa: function (component, event, helper, recordId) {
        const query = `
    SELECT Id, AssuntoJuridco__c, CreatedDate, Status, Owner.Name 
    FROM Task 
    WHERE AssuntoJuridco__c  = 'Revisão de contrato' 
    AND WhatId = '${recordId}'
    LIMIT 1
    `;

        helper
            .soql(component, query)
            .then(function (tasks) {
                if (tasks && tasks.length > 0) {
                    component.set("v.task", tasks[0]);
                    component.set("v.existeTarefa", true);
                } else {
                    console.warn("Nenhuma tarefa encontrada");
                    component.set("v.existeTarefa", false);
                }
            })
            .catch(function (error) {
                console.error("Erro na consulta SOQL:", error);
                component.set("v.existeTarefa", false); // também seta como falso em caso de erro
            });
    },
    getStatus: function (cmp, quoteId, helper) {
        const formatBRL = (value) => {
            return new Intl.NumberFormat('pt-BR', {
                style: 'currency',
                currency: 'BRL'
            }).format(value);
        };

        console.log("Passou aqui", quoteId);

        const query = `SELECT Status, OpportunityId, Name, AccountId,  totalPrice, Condicao_de_pagamento__c, Saldo_parcelado__c, Despesa_Financeira__c FROM Quote WHERE Id = '${quoteId}'`;
        console.log("query: ", query)
        console.log("Passou aqui 1")
        helper.soql(cmp, query).then(function (quote) {
            if (quote && quote.length > 0) {
                console.log("Passou aqui 2")
                console.log(quote[0].Status)
                console.log(quote.Status)
                console.log(quote[0])

                quote[0].TotalPrice = formatBRL(quote[0].TotalPrice);
                quote[0].Saldo_parcelado__c = formatBRL(quote[0].Saldo_parcelado__c);


                cmp.set("v.statusDaCotacao", quote[0].Status);
                cmp.set("v.cotacao", quote[0]);
            } else {
                console.warn("Nenhum resultado encontrado para a cotação:", quoteId);
            }
        }).catch(function (error) {
            console.error("Erro na consulta SOQL:", error);
        });
    },

    getAnaliseDeCredito: function (cmp, quoteId, helper) {
        if (!quoteId) {
            console.warn("O ID da cotação (quoteId) não foi fornecido.");
            return;
        }

        const query = `
SELECT Id, Name, Status__c
FROM Analise_de_Credito__c
WHERE Cotacao__c = '${quoteId}'
AND Status__c != 'Cancelado'
AND Status__c != 'Negado'
AND Status__c != 'Aprovado'
`;

        helper.soql(cmp, query)
            .then(function (result) {
                if (Array.isArray(result) && result.length > 0) {
                    cmp.set("v.analiseDeCredito", result);
                    cmp.set("v.existeAnaliseDeCredito", true);
                    console.info("Análises de crédito encontradas:", result);
                } else {
                    cmp.set("v.analiseDeCredito", []);
                    cmp.set("v.existeAnaliseDeCredito", false);
                    console.warn("Nenhuma análise de crédito encontrada para a cotação:", quoteId);
                }
            })
            .catch(function (error) {
                cmp.set("v.analiseDeCredito", []);
                cmp.set("v.existeAnaliseDeCredito", false);
                console.error("Erro ao executar a consulta de Análise de Crédito:", error);
            });
    }



})