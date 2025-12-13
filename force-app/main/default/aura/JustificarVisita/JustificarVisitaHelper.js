({
    salvarEvent: function (component, recordId, justificativa, anexo, feedback, currentUser) {
        console.log("Iniciando salvarEvent");

        // Monta o corpo da requisição
        const payload = {
            recordId: recordId,
            justificativa: justificativa,
            anexo: anexo ? anexo.url || anexo : null,
            feedback: feedback,
            user: currentUser
        };
//https://workflow.hospcom.net/workflow/Wmd5fjLyKQBkqLnW/7bc9f8
        // Faz o POST para o webhook
        fetch("https://workflowwebhook.hospcom.net/webhook/2187d8c5-9ca6-4774-832a-416ea86c008c", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error("Erro ao chamar webhook: " + response.statusText);
                }
                return response.text();
            })
            .then(result => {
                console.log("Webhook chamado com sucesso:", result);
                component.set("v.showSuccess", true);

                // Limpa campos
                component.set("v.justificativa", "");
                component.set("v.feedback", "");
                component.set("v.anexoFile", null);

                // Oculta mensagem após alguns segundos
                setTimeout(() => {
                    component.set("v.showSuccess", false);
                    location.reload();
                }, 3000);
            })
            .catch(error => {
                console.error("Erro ao chamar webhook:", error);
                alert("Erro ao salvar justificativa: " + error.message);
                component.set("v.desativarBotao", false);
            });
    }
})