({
    // ✅ Verifica se pode exibir o botão ou não
    verificarFaturamento: function (cmp) {
        const idRegistro = cmp.get("v.recordId");
        console.log("id do registro", idRegistro)
 // const idRegistro = '801U400000ToCDgIAN';
        const query = `
            SELECT Id, Pedido__r.OrderNumber,  Pedido__r.Faturado__c, Pedido__r.Faturamento_Feito__r.Id, Pedido__r.Nome_da_conta__c
            FROM Solicita_es_de_faturamento__c
            WHERE Id = '${idRegistro}'
        `;

        this.soql(cmp, query)
            .then(result => {
                if (result && result.length > 0) {
                    const faturamentofeito = result[0].Pedido__r.Faturamento_Feito__r.Id;
                const conta = result[0].Pedido__r.Nome_da_conta__c;
                    console.log("Faturado__c:", faturamentofeito, conta );

                    // Se for 100, mostra o botão
                    if (faturamentofeito == '001i00000085QYbAAM' && conta == 'GDB COMERCIO E SERVICOS LTDA GO') {
                console.log("resultdado mostrando true")
                        cmp.set("v.mostrarBotao", true);
                    } else {
                        cmp.set("v.mostrarBotao", false);
            console.log("resultdado mostrando false&&&&&&")
                       // this.alertaErro(cmp, null, null,
                         //   "Aviso", "🚫 O pedido não está 100% faturado.", "warning");
                    }
                }
            })
            .catch(error => {
                console.error(error);
            });
    },
                
                
      buscarPedidos: function (cmp, event, helper) {
    // 👉 Ativa o SPINNER de carregamento
    cmp.set("v.isLoading", true);

    const idRegistro = cmp.get("v.recordId");

    const query = `
        SELECT Id, Pedido__r.Id, Pedido__r.Faturado__c, Pedido__r.OrderNumber
        FROM Solicita_es_de_faturamento__c
        WHERE Id = '${idRegistro}'
    `;

    this.soql(cmp, query)
        .then(resultados => {
            const pedido = resultados[0];
            return fetch(`https://integracao.hospcom.net/created/purshase/${pedido.Pedido__r.OrderNumber}`, {
                method: 'GET'
            });
        })
        .then(response => {
            return response.json().then(data => {
                // 👉 Desativa o SPINNER
                cmp.set("v.isLoading", false);
              console.log("data", data.data);
                if (response.ok) {
                    this.alertaErro(cmp, null, null, "Sucesso!", "✅ Pedido enviado!", "success");
                } else {
                    this.alertaErro(
                        cmp,
                        null,
                        null,
                        "Erro!",
                        `⚠️ ${data.data}`,
                        "error"
                    );
                }
            });
        })
        .catch(error => {
            console.error("Erro na requisição:", error);
            // 👉 Garante que o spinner sempre desliga, mesmo com erro
            cmp.set("v.isLoading", false);
            this.alertaErro(cmp, null, null, "Erro!", "❌ Erro inesperado na requisição", "error");
        });
},
          
                
                

    // ✅ Envia pedido para API somente se já estiver faturado
   /* buscarPedidos: function (cmp, event, helper) {
        this.alertaErro(cmp, null, null, "Aguarde...", "⏳ Enviando pedido para o SAP...", "info");
        const idRegistro = cmp.get("v.recordId");
    //  const idRegistro = '801U400000ToCDgIAN';
        const query = `
            SELECT Id, Pedido__r.Id, Pedido__r.Faturado__c, Pedido__r.OrderNumber
            FROM Solicita_es_de_faturamento__c
            WHERE Id = '${idRegistro}'
        `;

        this.soql(cmp, query)
            .then(resultados => {
                const pedido = resultados[0];
                if (!pedido || pedido.Pedido__r.Faturado__c !== 100) {
                    return this.alertaErro(
                        cmp, null, null, "Erro!",
                        "⚠️ Pedido não está 100% faturado!", "error"
                    );
                }

                return fetch(`https://integracao.hospcom.net/created/purshase/${pedido.Pedido__r.OrderNumber}`, {
                    method: 'GET'
                });
            })
             .then(response => {
    console.log("response", response);

    return response.json().then(data => {
                console.log("resultado data", data)
        if (response.ok) {
            this.alertaErro(cmp, null, null, "Sucesso!", "✅ Pedido enviado!", "success");
        } else {
            this.alertaErro(
                cmp,
                null,
                null,
                "Erro!",
                `⚠️ ${data.data || 'Erro ao processar a solicitação'}`,
                "error"
            );
        }
    });
})
.catch(error => {
    console.error("Erro na requisição:", error);
    this.alertaErro(cmp, null, null, "Erro!", "❌ Erro inesperado na requisição", "error");
});
},
*/
    alertaErro: function (cmp, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type,
                "mode": 'pester'
            });
            toastEvent.fire();
        }
    }
});