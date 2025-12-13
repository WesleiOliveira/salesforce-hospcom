({    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO-------------------------------------------------------------
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
    //----------------------------------------------------------------------------------------------
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    showSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "flex");
    },
    //-------------------------------------------
    
    //FUNÇÃO QUE OCULTA O SPINNER DE CARREGAMENTO-  
    hideSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "none");
    },
    //--------------------------------------------
    
    helperMethod : function(cmp, event, helper) {
        const dataAtual = new Date();
        const nomeMesAtual = dataAtual.toLocaleString('pt-BR', { month: 'long' });
        
        const dataMesPassado = new Date(dataAtual.setMonth(dataAtual.getMonth() - 1));
        const nomeMesPassado = dataMesPassado.toLocaleString('pt-BR', { month: 'long' });
        
        $("#periodoAtual").val(nomeMesPassado)
        
        $("#fecharButton").on( "click", function() {
            
            var mesReferencia = $("#periodoAtual").val()
            
            let text = "Deseja mesmo finalizar e bloquear o período de "+mesReferencia+"? Essa ação não poderá ser revertida";
            
            if (confirm(text) == true) {
                
                var action = cmp.get("c.atualizarTarefasPorMes"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
                
                var mesReferencia = $("#periodoAtual").val()
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    mesReferencia: mesReferencia
                });        
                //--------------------------------------------------
                
                //CALLBACK DA REQUISIÇÃO---------------------------
                action.setCallback(this, function (response) {
                    var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                    
                    //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                    if (state === "SUCCESS") {
                        console.log("sucesso")
                        helper.alertaErro(cmp, event, helper, "PERÍODO FECHADO", "SUCESSO!", "success", "", "dismissable")
                        helper.hideSpinner(cmp);
                        location.reload();
                    }
                    //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                    else if (state === "INCOMPLETE") {
                        //helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.log("error", errors[0].message)
                            //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                            reject(errors[0].message);
                        } else {
                            console.log("Erro desconhecido");
                            //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                            reject("Erro desconhecido");
                        }
                    }
                });
                
                $A.enqueueAction(action);
            }
        });
    }
    
    
})