({
    mainFunction: function (cmp, event, helper) {
        const fileInput = event.target.files[0];
        console.log("fileinput", fileInput);
        if (fileInput) {
            cmp.set("v.file", fileInput); // Armazena o arquivo bruto
            cmp.set("v.fileName", fileInput.name);
            document.getElementById("fileNameDisplay").textContent = fileInput.name;
        } else {
            helper.alertaErro(cmp, event, helper, data, "Nenhum aquivo selecionado");
        }
    },
    doInit: function (cmp, event, helper) {
        const recordId = cmp.get("v.recordId");
          console.log("id do pedido", recordId);
        if (!recordId) {
            const urlParams = new URLSearchParams(window.location.search);
            const id = urlParams.get("id");
            if (id) {
                cmp.set("v.recordId", id);
                console.log("ID encontrado na URL:", id);
            } else {
                console.log("ID não encontrado na URL");
            }
        } else {
            console.log("ID capturado do Salesforce:", recordId);
        }
    },
    uploadFile: function (cmp, event, helper) {
    const file = cmp.get("v.file");
    const fileName = cmp.get("v.fileName");
    if (!file) {
        helper.alertaErro(cmp, event, helper, "Erro", "Nenhum arquivo selecionado.");
        return;
    }

    const formData = new FormData();
    formData.append("image", file, fileName);

    fetch("https://leitor.hospcom.net/processar-imagem", {
        method: "POST",
        body: formData,
    })
    .then(response => response.json())
    .then(data => {
        if (data.dados_extracao) {
            const { data_transacao, numero_autorizacao, numeros_cartao, quantidade_parcelas, tipo_transacao, valor_transacao } = data.dados_extracao;
            if (!data_transacao || !numero_autorizacao || !quantidade_parcelas || !numeros_cartao || !tipo_transacao || !valor_transacao) {
                cmp.set("v.message", "Erro: Alguns campos obrigatórios estão vazios.");
                helper.alertaErro(cmp, event, helper, "Erro", "Alguns campos obrigatórios estão vazios.", "error");
                return;
            }

            cmp.set("v.dadosExtracao", data.dados_extracao);
            cmp.set("v.message", "Sucesso ao extrair os dados.");
            helper.alertaErro(cmp, event, helper, "Sucesso", "Dados extraídos com sucesso!", "success");

            // Enviar os dados extraídos
            const payloadData = {
                recordId: cmp.get("v.recordId"),
                dadosExtraidos: data.dados_extracao
            };

            this.enviarArquivo("https://integracao.hospcom.net/receberdados", payloadData, cmp, event, helper);
        } else {
            cmp.set("v.message", "Erro: Dados de extração não encontrados.");
            helper.alertaErro(cmp, event, helper, "Erro", "Dados de extração não encontrados.", "error");
        }
    })
    .catch(error => {
        console.error("Erro ao processar imagem:", error);
        helper.alertaErro(cmp, event, helper, "Erro", "Erro ao processar o arquivo.", "error");
    });
},

/*
    uploadFile: function (cmp, event, helper) {
        const file = cmp.get("v.file");
        const fileName = cmp.get("v.fileName");
        console.log("file", file);
        console.log("fileName", fileName);
        if (!file) {
            helper.alertaErro(cmp, event, helper, data, "Nenhum aquivo selecionado");
            return;
        }

        const formData = new FormData();
        console.log("formData", formData);
        formData.append("file", file, fileName);

        fetch("https://leitor.hospcom.net/processar-imagem", {
    method: "POST",
    body: formData,
})
    .then((response) => response.json())
    .then((data) => {
      //  if (data.dados_extracao) {
      //  cmp.set("v.message", "Sucesso ao extrair os dados: " + JSON.stringify(data.dados_extracao));
      //  helper.alertaErro(cmp, event, helper, "Sucesso", "Dados extraídos com sucesso!", "success");
   // } else {
    //    cmp.set("v.message", "Erro: Dados de extração não encontrados.");
    //    helper.alertaErro(cmp, event, helper, "Erro", "Dados de extração não encontrados.", "error");
   // }            

         if (data.dados_extracao) {
        const { data_transacao, numero_autorizacao, numeros_cartao, quantidade_parcelas, tipo_transacao, valor_transacao } = data.dados_extracao;
          
        if (
            !data_transacao ||
            !numero_autorizacao ||                    
            !quantidade_parcelas ||
            !numeros_cartao ||
            !tipo_transacao ||
            !valor_transacao
        ) {            
            cmp.set("v.message", "Erro: Alguns campos obrigatórios estão vazios.");
            helper.alertaErro(cmp, event, helper, "Erro", "Alguns campos obrigatórios estão vazios.", "error");
            return; 
        }
        
        cmp.set("v.dadosExtracao", data.dados_extracao); 
        cmp.set("v.message", "Sucesso ao extrair os dados: " + JSON.stringify(data.dados_extracao)); 
        helper.alertaErro(cmp, event, helper, "Sucesso", "Dados extraídos com sucesso!", "success");

    } else {        
        cmp.set("v.message", "Erro: Dados de extração não encontrados.");
        helper.alertaErro(cmp, event, helper, "Erro", "Dados de extração não encontrados.", "error");
    }
})
    
    .catch((error) => {       
        helper.alertaErro(cmp, event, helper, "Erro ao enviar o arquivo.");
    });
    },    
*/
        enviarArquivo: function (url, payload, cmp, event, helper) {
    try {
        // Primeiro, faz a requisição inicial para enviar o arquivo
        const response = $.ajax({
            url: url,
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify(payload),
        });

        if (response.success) {
            cmp.set("v.message", "Arquivo enviado com sucesso!");

            const endpointData = "https://integracao.hospcom.net/receberdados";
            const payloadData = {
                recordId: payload.recordId,
                dadosExtraidos: response.data || {},
            };

            // Agora, faz a requisição para enviar os dados extraídos
            const finalResponse = $.ajax({
                url: endpointData,
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify(payloadData),
            });

            // Caso a segunda requisição tenha sido bem-sucedida
            helper.alertaErro(cmp, event, helper, "Sucesso", "Dados extraídos enviados com sucesso!", "success");
            setTimeout(function() {
        window.location.reload();
    }, 3000);
        }else{
         setTimeout(function() {
        window.location.reload();
    }, 3000);
        }
    } catch (error) {
        // Em caso de erro, exibe uma mensagem de erro
        console.error("Erro durante o envio:", error);
        helper.alertaErro(cmp, event, helper, "Erro", "Erro ao enviar os dados: " + error.message, "error");
    }
},

        
      /* 
    enviarArquivo: function (url, payload, cmp, event, helper) {
        $.ajax({
            url: url,
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify(payload),
            success: function (response) {
                if (response.success) {
                    cmp.set("v.message", "Arquivo enviado com sucesso!");

                    const endpointData = "https://integracao.hospcom.net/receberdados";
                    const payloadData = {
                        recordId: payload.recordId,
                        dadosExtraidos: response.data || {},
                    };

                    $.ajax({
                        url: endpointData,
                        type: "POST",
                        contentType: "application/json",
                        data: JSON.stringify(payloadData),
                        success: function () {
                            helper.alertaErro(cmp, event, helper, "Sucesso", "Dados extraídos enviados com sucesso!", "success");
                        },
                        error: function (xhr, status, error) {
                            helper.alertaErro(cmp, event, helper, "Erro", "Erro ao enviar os dados: " + error, "error");
                        },
                    });
                } else {
                    helper.alertaErro(cmp, event, helper, "Erro", "Erro ao processar o arquivo no backend.", "error");
                }
            },
            error: function (jqXHR, status, error) {
                let errorMessage = "";

                console.error("Erro ao enviar arquivo:", {
                    status: jqXHR.status,
                    responseText: jqXHR.responseText || "Nenhuma resposta do servidor",
                    errorDetails: `HTTP ${jqXHR.status}: ${errorMessage}`,
                });

                helper.alertaErro(cmp, event, helper, "Erro", `Erro ${jqXHR.status}: ${errorMessage}`, "error");
            },
        });
    },*/


    alertaErro: function (cmp, event, helper, title, message, type) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
        });
        toastEvent.fire();
    },
});









/*({
    mainFunction: function (cmp, event, helper) {
             const fileInput = event.target.files[0];
        console.log("fileinput", fileInput);
    if (fileInput) {
        cmp.set("v.file", fileInput); // Armazena o arquivo bruto
        cmp.set("v.fileName", fileInput.name);
        document.getElementById("fileNameDisplay").textContent = fileInput.name;
    } else {
        cmp.set("v.message", "Nenhum arquivo selecionado.");
    }
    },
    doInit: function (cmp, event, helper) {
        const recordId = cmp.get("v.recordId");

        if (!recordId) {
            const urlParams = new URLSearchParams(window.location.search);
            const id = urlParams.get("id");
            if (id) {
                cmp.set("v.recordId", id);
                console.log("ID encontrado na URL:", id);
            } else {
                console.log("ID não encontrado na URL");
            }
        } else {
            console.log("ID capturado do Salesforce:", recordId);
        }
    },
   
uploadFile: function (cmp, event, helper) {
    const file = cmp.get("v.file");
    const fileName = cmp.get("v.fileName");
console.log("file", file);
    console.log("fileName", fileName);
    if (!file) {
        cmp.set("v.message", "Nenhum arquivo selecionado");
        return;
    }

    const formData = new FormData();
    console.log("formData", formData);
    formData.append("file", file, fileName);

    fetch("http://integracao.hospcom.net:5000/processar-imagem", {
        method: "POST",
        body: formData,
    })
    .then((response) => response.json())
.then((data) => {
    if (data.message) {
        cmp.set("v.message", data.message);
        // Acesse os dados extraídos e exiba ou processe
        if (data.dados_extracao) {
            console.log("Dados extraídos:", data.dados_extracao);
            cmp.set("v.dadosExtracao", data.dados_extracao); // Atualize uma variável em seu componente
        }
    } else {
        cmp.set("v.message", "Erro no processamento.");
    }
})
.catch((error) => {
    cmp.set("v.message", "Erro ao conectar com o servidor.");
    console.error("Erro ao enviar o arquivo:", error);
});
    
},
    
    

    enviarArquivo: function (url, payload, cmp, event, helper) {
        $.ajax({
            url: url,
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify(payload),
            success: function (response) {
                if (response.success) {
                    cmp.set("v.message", "Arquivo enviado com sucesso!");

                    const endpointData = "https://integracao.hospcom.net/receberdados";
                    const payloadData = {
                        recordId: payload.recordId,
                        dadosExtraidos: response.data || {},
                    };

                    $.ajax({
                        url: endpointData,
                        type: "POST",
                        contentType: "application/json",
                        data: JSON.stringify(payloadData),
                        success: function () {
                            helper.alertaErro(cmp, event, helper, "Sucesso", "Dados extraídos enviados com sucesso!", "success");
                        },
                        error: function (xhr, status, error) {
                            helper.alertaErro(cmp, event, helper, "Erro", "Erro ao enviar os dados: " + error, "error");
                        },
                    });
                } else {
                    helper.alertaErro(cmp, event, helper, "Erro", "Erro ao processar o arquivo no backend.", "error");
                }
            },
            error: function (jqXHR, status, error) {
                let errorMessage = "";

                console.error("Erro ao enviar arquivo:", {
                    status: jqXHR.status,
                    responseText: jqXHR.responseText || "Nenhuma resposta do servidor",
                    errorDetails: `HTTP ${jqXHR.status}: ${errorMessage}`,
                });

                helper.alertaErro(cmp, event, helper, "Erro", `Erro ${jqXHR.status}: ${errorMessage}`, "error");
            },
        });
    },
    
    
    alertaErro: function (cmp, event, helper, title, message, type) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
        });
        toastEvent.fire();
    },
});*/