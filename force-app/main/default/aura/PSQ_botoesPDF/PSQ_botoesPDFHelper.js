({
    baixarDocumentos: function(cmp, event, helper) {
        var action = cmp.get("c.documentosOts");
        var recordId = cmp.get("v.recordId"); 

        action.setParams({
            idComodato: recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var documentos = response.getReturnValue();
                console.log("Documentos recebidos: ", documentos);
                
                documentos.forEach(function(doc) {
                    helper.downloadsPDF(cmp, event, helper, doc.bs64, doc.nome);
                });
            } else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO: " + response.getError());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("Erro: " + errors[0].message);
                    alert("Não foi possível baixar os arquivos");
                } else {
                    console.log("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },

    downloadsPDF: function(cmp, event, helper, pdf, name) {
        const linkSource = 'data:application/pdf;base64,' + pdf;
        const downloadLink = document.createElement("a");
        const fileName = name + ".pdf";
        downloadLink.href = linkSource;
        downloadLink.download = fileName;
        downloadLink.click();
    }
})