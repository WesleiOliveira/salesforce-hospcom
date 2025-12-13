({
	onRender : function(cmp, event, helper) {
		console.log("ON RENDER")
        helper.mainHelper(cmp, event, helper)
	},
    
    aprovaRegistro: function(cmp, event, helper){
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO DO APEX
        var action =  cmp.get("c.aprova");
        var recordId = cmp.get('v.recordId');
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idCompromisso: recordId,
        });
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            console.log("CALLBACK")
            var state = response.getState();
            var result = response.getReturnValue();
            
            //TESTANDO O SUCESSO
            if (state === "SUCCESS") {
                helper.alertaErro(cmp, event, helper, "Compromisso aprovado", "TUDO OK!", "Success", "dismissable")
                helper.hideSpinner(cmp);
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
})