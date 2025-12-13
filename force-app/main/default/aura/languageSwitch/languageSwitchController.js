({
    changeLanguage: function (component, event, helper) {
        // Obtém o idioma da bandeira clicada
        const languageLocaleKey = event.target.dataset.lang;
        const userId = $A.get("$SObjectType.CurrentUser.Id");

        if (!languageLocaleKey) {
            alert("Idioma não identificado.");
            return;
        }

        // Logs para depuração
        console.log("ID do Usuário:", userId);
        console.log("Idioma Selecionado:", languageLocaleKey);

        // Configura a chamada ao método Apex
        const action = component.get("c.updateUserLanguage");
        action.setParams({
            userId: userId,
            languageLocaleKey: languageLocaleKey
        });

        // Define o callback para tratar a resposta
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                location.reload()
            } else {
                const errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Erro ao atualizar idioma:", errors[0].message);
                    alert("Erro: " + errors[0].message);
                }
            }
        });

        // Executa a ação
        $A.enqueueAction(action);
    }
});