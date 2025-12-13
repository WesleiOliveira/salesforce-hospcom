({
	onRender : function(cmp, event, helper) {
		console.log("ON RENDER")
        helper.mainHelper(cmp, event, helper)
	},
    
    aprovaRegistro: function(cmp, event, helper){
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO DO APEX
        var action =  cmp.get("c.aprovaPedido");
        
        // DEFININDO UM NOVO NOME DA IMAGEM
        var workItemId = helper.workItemId
        var comentario = $("#comentarioInput").val()
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            workItemId: workItemId,
            comentario: comentario
        });
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            console.log("CALLBACK")
            var state = response.getState();
            var result = response.getReturnValue();
            
            //TESTANDO O SUCESSO
            if (state === "SUCCESS") {
                helper.alertaErro(cmp, event, helper, "Pedido aprovado.", "TUDO OK!", "Success", "dismissable")
                helper.hideSpinner(cmp);
                location.reload();

            }else if (state === "INCOMPLETE") {
                console.log("incompleto")
                console.log(response)                
            } else if (state === "ERROR") {
                var errors = response.getError();
                helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO.", "Error", "dismissable")
                
                console.log("erro")
                console.log("erro: ", response.getError())
            }
        });
        $A.enqueueAction(action);
    },
    
    reprovaRegistro: function(cmp, event, helper){
        helper.showSpinner(cmp);
        
        var motivo = $("#motivos").val()
        var recordId = cmp.get('v.recordId');
        
        
        if(!motivo){
            alert("O Motivo deve ser preenchido para reprovar um pedido")
            helper.hideSpinner(cmp);
            return 0;
        }
        
        //CHAMA A FUNÇÃO DO APEX
        var action =  cmp.get("c.rejeitaPedido");
        
        // DEFININDO UM NOVO NOME DA IMAGEM
        var workItemId = helper.workItemId
        console.log("WORKITEMId: ", workItemId);
        var comentario = $("#comentarioInput").val()
        
        console.log(workItemId, comentario, motivo)
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            workItemId: workItemId,
            comentario: comentario,
            idPedido: recordId,
            motivo: motivo
        });
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            console.log("CALLBACK")
            var state = response.getState();
            var result = response.getReturnValue();
            
            console.log('status',  state);
            console.log('status',  result);
            //TESTANDO O SUCESSO
            if (state === "SUCCESS") {
                helper.alertaErro(cmp, event, helper, "Pedido reprovado.", "TUDO OK!", "Success", "dismissable")
                helper.hideSpinner(cmp);
                location.reload();
            }else if (state === "INCOMPLETE") {
                console.log("incompleto")
                console.log(response)                
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO.", "Error", "dismissable")
                
                console.log("erro")
                console.log("erro: ", response.getError())
            }
        });
        $A.enqueueAction(action);
    }

})