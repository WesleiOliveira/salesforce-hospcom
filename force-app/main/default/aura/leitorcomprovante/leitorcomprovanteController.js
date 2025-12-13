({
    onFileChange: function (cmp, event, helper) {
        helper.mainFunction(cmp, event, helper);
    },
    uploadFile: function (cmp, event, helper) {
        helper.uploadFile(cmp, event, helper);
    },
});

/*({
    onRender: function (cmp, event, helper) {
        const fileInput = event.target.files[0];

        if (fileInput) {
            const reader = new FileReader();
            reader.onload = function (e) {
                const base64 = e.target.result.split(",")[1]; // Extraindo apenas o base64
                cmp.set("v.fileContents", base64);
                cmp.set("v.fileName", fileInput.name);
                document.getElementById("fileNameDisplay").textContent = fileInput.name;
            };
            reader.readAsDataURL(fileInput);
        }
    },
    doInit: function (cmp, event, helper) {
        // Verificar se o componente tem o atributo `recordId`
        const recordId = component.get("v.recordId");

        if (!recordId) {
            // Caso o `recordId` não esteja disponível no componente, tenta pegar da URL
            const urlParams = new URLSearchParams(window.location.search);
            const id = urlParams.get("id"); // Pega o 'id' da URL
            if (id) {
                cmp.set("v.recordId", id); // Define o `recordId` no componente
                console.log("ID encontrado na URL:", id);
            } else {
                console.log("ID não encontrado na URL");
            }
        } else {
            console.log("ID capturado do Salesforce:", recordId);
        }
    },
    uploadFile: function (cmp, event, helper) {
        const fileContents = cmp.get("v.fileContents");
        const fileName = cmp.get("v.fileName");
        const recordId = cmp.get("v.recordId"); // Obtém o ID do pedido

       if (!fileContents || !fileName) {
            console.log("Chamando helper.alertaErro...");
            helper.alertaErro(component, "Erro", "Por favor, selecione um arquivo antes de enviar.", "error");
            console.log("helper.alertaErro foi chamado.");
            return;
        }

        const endpointUpload = "https://integracao.hospcom.net/receberArquivo";
        const payloadUpload = {
            recordId: recordId, // Inclui o ID do pedido
            nomeArquivo: fileName,
            base64Data: fileContents,
        };

        // Fazendo o upload
        helper.enviarArquivo(endpointUpload, payloadUpload, cmp);
    }
});*/









/*({
    handleFileChange: function (component, event) {
        const fileInput = event.target.files[0];

        if (fileInput) {
            const reader = new FileReader();
            reader.onload = function (e) {
                const base64 = e.target.result.split(",")[1]; // Extraindo apenas o base64
                component.set("v.fileContents", base64);
                component.set("v.fileName", fileInput.name);
                document.getElementById("fileNameDisplay").textContent = fileInput.name;
            };
            reader.readAsDataURL(fileInput);
        }
    },
    doInit: function (component, event, helper) {
        // Verificar se o componente tem o atributo `recordId`
        const recordId = component.get("v.recordId");
        
        if (!recordId) {
            // Caso o `recordId` não esteja disponível no componente, tenta pegar da URL
            const urlParams = new URLSearchParams(window.location.search);
            const id = urlParams.get('id');  // Pega o 'id' da URL
            if (id) {
                component.set("v.recordId", id);  // Define o `recordId` no componente
                console.log("ID encontrado na URL:", id);
            } else {
                console.log("ID não encontrado na URL");
            }
        } else {
            console.log("ID capturado do Salesforce:", recordId);
        }
    },
    uploadFile: function (component, helper) {
        const fileContents = component.get("v.fileContents");
        console.log("filecontents", fileContents);
        const fileName = component.get("v.fileName");
        console.log("nome do arquivo", fileName);
        const recordId = component.get("v.recordId"); // Obtém o ID do pedido
        console.log("id", recordId);
          
        if (!fileContents || !fileName) {
            helper.alertaErro(component, "Erro", "Por favor, selecione um arquivo antes de enviar.", "error");
            return;
        }

        const endpointUpload = "https://integracao.hospcom.net/receberArquivo";
          if (!endpointUpload) {
            helper.alertaErro(component, "Erro", "Por favor, selecione um arquivo antes de enviar.", "error");
            return;
        }
        const payloadUpload = {
            recordId: recordId,  // Inclui o ID do pedido
            nomeArquivo: fileName,
            base64Data: fileContents,
        }
           
         
        // Fazendo o upload
        $.ajax({
            url: endpointUpload,
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify(payloadUpload),
            success: function (uploadResult) {
                if (uploadResult.success) {
                    component.set("v.message", "Arquivo enviado com sucesso!");

                    // Envia dados adicionais
                    const endpointData = "https://integracao.hospcom.net/receberdados";
                    const payloadData = {
                        recordId: recordId, // Vincula os dados ao pedido
                        dadosExtraidos: uploadResult.data || {}
                    };

                    $.ajax({
                        url: endpointData,
                        type: "POST",
                        contentType: "application/json",
                        data: JSON.stringify(payloadData),
                        success: function () {
                            helper.alertaErro(component, "Sucesso", "Dados extraídos enviados com sucesso!", "success");
                        },
                        error: function (xhr, status, error) {
                            helper.alertaErro(component, "Erro", "Erro ao enviar os dados: " + error, "error");
                        },
                    });
                } else {
                    helper.alertaErro(component, "Erro", "Erro ao processar o arquivo no backend.", "error");
                }
            },
            error: function (xhr, status, error) {
                helper.alertaErro(component, "Erro", "Erro ao enviar o arquivo: " + error, "error");
            },
        });
    },

    alertaErro: function (component, title, message, type) {
    console.log("Exibindo mensagem de erro:", title, message);
    const toastEvent = $A.get("e.force:showToast");
    if (toastEvent) {
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            mode: 'sticky'
        });
        console.log("Mensagem atualizada para:", component.get("v.message"));
        toastEvent.fire();
    } else {
        // Fallback para exibir mensagens no console, se o evento não estiver disponível
        alert(`${title}: ${message}`);
    }
}
});*/