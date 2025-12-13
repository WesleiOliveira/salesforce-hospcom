({
    doInit: function (cmp, event, helper) {
        const userId = $A.get("$SObjectType.CurrentUser.Id");
        cmp.set("v.userId", userId);

        const allowedUsers = [
            "005U4000006iHJRIA2",
            "00531000006UzZsAAK",
            "0055A000008pNJG",
            "0055A000008p65CQAQ",
           "0055A000008pNJGQA2",
            "0056e00000CrhsVAAR",
            "0056e00000Cqgd8AAB"
        ];

        const canShow = allowedUsers.includes(userId);
        cmp.set("v.showButton", canShow);
    },

    handleClick: function (cmp, event, helper) {
        const recordId = cmp.get("v.recordId");
        if (!recordId) {
            helper.alertaErro("Erro", "ID da conta não encontrado", "error");
            return;
        }

        cmp.set("v.isLoading", true);

        const url = 'https://integracao.hospcom.net/created/conta/' + recordId;
        console.log("URL chamada:", url);

        fetch(url, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        })
        .then(function (response) {
            const contentType = response.headers.get("content-type");
            const isJson = contentType && contentType.indexOf("application/json") !== -1;

            if (isJson) {
                return response.json().then(function (result) {
                    cmp.set("v.isLoading", false);

                    console.log("Response status:", response.status);
                    console.log("Response body:", result);

                    if (!response.ok || result.status === 'error') {
                        let msg = "Erro ao criar conta no SAP.";
                        if (result.message) msg = result.message;
                        helper.alertaErro("Erro", msg, "error");
                        return;
                    }

                    helper.alertaErro("Sucesso", "Conta criada com sucesso no SAP.", "success");
                });
            } else {
                cmp.set("v.isLoading", false);
                helper.alertaErro("Erro", "Resposta inválida do servidor.", "error");
            }
        })
        .catch(function (error) {
            console.error("Erro de rede:", error);
            cmp.set("v.isLoading", false);
            helper.alertaErro("Erro", "Falha ao integrar com SAP.", "error");
        });
    }
})