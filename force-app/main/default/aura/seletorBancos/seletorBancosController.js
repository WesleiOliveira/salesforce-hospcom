({
    myAction : function(component, event, helper) {
        
        $("#salvaBanco324985").click(function(){
            
            var valorBanco = $("#bancos").val()
            console.log("clique salvar", valorBanco);
            
            //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
            var action = component.get("c.atualizarOuCriarRegistro");
            
            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                nome: 'banco_dia',
                metaData: valorBanco
            });
            //----------------------------------------------------
            
            helper.alertaErro(component, event, helper, "", "Processando Leitura...", "info", "", "dismissable")
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("SUCESSO")
                }
                else if (state === "INCOMPLETE") {
                    //helper.alertaErro(component, event, helper, "ERRO DURANTE O ENVIO", "ENVIO INCOMPLETO", "error", "Erro: ", "sticky")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("erro", errors[0].message)
                        
                        //helper.alertaErro(component, event, helper, errors[0].message, "ERRO AO ENVIAR DOCUMENTO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("erro desconhecido")
                        //helper.alertaErro(component, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
            
        });
    }
})