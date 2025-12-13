({
    numerosSelecionados: '',
    contratoSelecionado: '',
    
    alertaErro: function(cmp, event, helper, error, title, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    processRecordId: function(cmp, recordId) {
        console.log('Record ID: ' + recordId);
        this.contratoSelecionado = recordId; // Define o recordId no atributo contratoSelecionado
    },
    
    helperMethod: function(cmp, event, helper) {
        $("#criaOtsMassa").on("click", function() {
            console.log("botaoInicial");
            $("#criaOtsMassa").css("display", "none");
            $("#boxMasterOts").css("display", "flex");
        });
        
        $("#closeSharePopup").on("click", function() {
            $("#criaOtsMassa").css("display", "flex");
            $("#boxMasterOts").css("display", "none");
        });
        
        $("#criarSubmit").on("click", function() {
            helper.numerosSelecionados = $('#textAreaNumerosSerie').val().replaceAll(/\n/g, ',').replaceAll(/\s+/g, '');
            helper.criaOts(cmp, event, helper);
        });
        console.log("HelperMethod");
    },
    
    
    criaOts: function(cmp, event, helper) {
        console.log("====DADOS====");
        console.log("NUMEROS", helper.numerosSelecionados);
        console.log("ID DO COMODATO", helper.contratoSelecionado);
        
        
        var action = cmp.get("c.gerar"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
        
        // DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX
        action.setParams({
            SN: helper.numerosSelecionados,
            comodato: helper.contratoSelecionado
        });
        
        // CALLBACK DA REQUISIÇÃO
        action.setCallback(this, function(response) {
            var state = response.getState(); // VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            if (state === "SUCCESS") {
                console.log("sucesso");
                var retorno = response.getReturnValue();
                helper.alertaErro(cmp, event, helper, retorno, "Tudo certo,", "Success", "dismissable");
            } else if (state === "INCOMPLETE") {
                // handler for incomplete state
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "Erro ao inserir ativos", "Error", "dismissable");
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "Error", "dismissable");
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    }
    
    
})