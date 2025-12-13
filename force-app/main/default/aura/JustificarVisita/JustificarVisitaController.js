({
    handleUploadFinished: function (component, event) {
        const uploadedFiles = event.getParam("files");

        if (uploadedFiles && uploadedFiles.length > 0) {
            const file = uploadedFiles[0];
            const url = '/sfc/servlet.shepherd/document/download/' + file.documentId;
            component.set("v.anexoFile", { id: file.documentId, url: url });
        }
    },

    doInit: function (cmp, event, helper) {
        const recordId = cmp.get("v.recordId");
        const query = `SELECT Subject FROM Event WHERE Id = '${recordId}'`;

        helper.soql(cmp, query)
            .then(function (result) {
                if (result && result.length > 0) {
                    const evento = result[0];
                    if (evento.Subject === 'Visita') {
                        cmp.set("v.compromissoIgualAVisita", true);
                    } else {
                        cmp.set("v.compromissoIgualAVisita", false);
                    }
                }
            })
            .catch(function (error) {
                console.error(error);
            });
    },



    handleJustificativaChange: function (component, event, helper) {
        component.set("v.justificativa", event.getParam("value"));
    },
    handleCancel: function (component, event, helper) {
        // Limpa campos
        component.set("v.justificativa", "");
        component.set("v.feedback", "");
        component.set("v.anexoFile", null);


    },
    salvar: function (component, event, helper) {
        component.set("v.desativarBotao", true);
        console.log("alerta")
        const recordId = component.get("v.recordId");
        const justificativa = component.get("v.justificativa");
        const feedback = component.get("v.feedback");
        const anexo = component.get("v.anexoFile");
        const currentUser = $A.get("$SObjectType.CurrentUser.Id");



        if (!justificativa) {
            alert("Por favor, preencha a justificativa antes de salvar.");
            return;
        }
        if (!feedback) {
            alert("Por favor, preencha o campo feedback antes de salvar.");
            return;
        }

        helper.salvarEvent(component, recordId, justificativa, anexo, feedback, currentUser);
    }
})