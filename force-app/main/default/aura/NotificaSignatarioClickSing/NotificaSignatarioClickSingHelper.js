({
    enviarLembrete: function(component, event, helper) {
        const recordId = cmp.get(v.recordId);
        if(!recordId){
            return;
        }
        let query = `SELECT Id, idDocAutentique__c FROM Contrato_de_Servi_o__c WHERE Id = '${recordId}'`;       

        helper.soql(component, query)
            .then(function (resultados) {
                if (resultados.length === 0) {
                    alert("Nenhum resultado encontrado.");
                    return;
                }
                console.log("resultados", resultados);
                const chave = resultados[0].idDocAutentique__c;
                component.set("v.chaveDocumento", chave);
                console.log("chave", chave);

                const mensagem = component.get("v.mensagem");
                const url = 'http://integracao.hospcom.net/notificacao/' + chave;

                fetch(url, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ mensagem: mensagem })
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error("Erro ao enviar lembrete.");
                    }
                    return response.json();
                })
                .then(data => {
                    console.log("Resultado da notificação:", data);

                    let msg = "";

                    if (data.enviados.length > 0) {
                        msg += "✅ Notificações enviadas com sucesso para:\n";
                        data.enviados.forEach(pessoa => {
                            msg += `• ${pessoa.nome} <${pessoa.email}>\n`;
                        });
                    }

                    if (data.nao_enviados.length > 0) {
                        msg += "\n⚠️ Não foi possível enviar para:\n";
                        data.nao_enviados.forEach(pessoa => {
                            msg += `• ${pessoa.nome} <${pessoa.email}> — ${pessoa.motivo}\n`;
                        });
                    }

                    alert(msg || "Nenhuma notificação foi enviada.");
                })
                .catch(error => {
                    console.error("Erro:", error);
                    alert("Erro ao enviar lembrete: " + error.message);
                });
            });
    }
})