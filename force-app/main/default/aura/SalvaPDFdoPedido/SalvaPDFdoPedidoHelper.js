({
    
    helperMethod : function(component, event, helper) {
        
        console.log("entrou helper method")
                
        //CHAMA A FUNÇÃO DO APEX
        var action =  component.get("c.SalvarPdf");
        var idPedido = component.get("v.recordId")
        
        console.log(idPedido)
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            ped_id: idPedido
        });
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            console.log("CALLBACK")
            var state = response.getState();
            var result = response.getReturnValue();
            
            //TESTANDO O SUCESSO
            if (state === "SUCCESS") {
                console.log("SUCESSO", result)
                component.set("v.resultado", 'PDF salvo com sucesso!');
                component.set("v.desabilitado", true);
                
                /* helper.alertaErro(cmp, event, helper, "Pedido aprovado.", "TUDO OK!", "Success", "dismissable")
                helper.hideSpinner(cmp);*/
            }else if (state === "INCOMPLETE") {
                console.log("incompleto")
                component.set("v.resultado", 'Erro ao salvar.');
            } else if (state === "ERROR") {
                var errors = response.getError();
                /* helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO.", "Error", "dismissable")*/
                component.set("v.resultado", 'Erro ao salvar.');
                
                console.log("erro: ", response.getError())
            }
        });
        $A.enqueueAction(action);
    }
})