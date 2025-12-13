({
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        cmp.set("v.setMeOnInit", "controller init magic!");
        
    },
    
    onRender : function(cmp,event, helper){
        console.log("ON RENDER")
        helper.mainHelper(cmp, event, helper)
        
        
        
        $("#divNewCompromisso").off().on( "click", function() {
            console.log("CLIQUE ADD")
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "event"
            });
            createRecordEvent.fire();
        });
        
        var expanded = false;
        
        $("#selectBox").off().on( "click", function() {
            var checkboxes = document.getElementById("checkboxes");
            if (!expanded) {
                checkboxes.style.display = "flex";
                expanded = true;
            } else {
                checkboxes.style.display = "none";
                expanded = false;
            }
        });
    },
    
    saveCheckout: function(cmp, event, helper){  
        console.log("SAVE CHECKOUT")
        var justificativa = $("#divPaiPopupCheckout").find("#justificativa").val()
        var feedback = $("#divPaiPopupCheckout").find("#feedbackCompromisso").val()
        var contatoAtendido = $("#divPaiPopupCheckout").find("#contatoTratado").val()
        var idCompromisso = helper.idCompromisso
        var imgString = "76867,0003938dd"
        var checkInRealizado = true
        
        console.log("DADOS: ", justificativa, feedback, contatoAtendido, idCompromisso)

        if(helper.proximoDaLocalizacao == false){
            if(!justificativa){
                helper.alertaErro(cmp, event, helper, "VOCE DEVE PREENCHER UMA JUSTIFICATIVA", "ERRO!", "Error", "dismissable")
                return
            }
            
            if(!contatoAtendido){
                helper.alertaErro(cmp, event, helper, "VOCE DEVE SELECIONAR UM CONTATO QUE FOI ATENDIDO NA VISITA, CASO NAO ESTEJA DISPONÍVEL, CADASTRE NA CONTA DO CLIENTE", "ERRO!", "Error", "dismissable")
                return                
            }
            
            /*if(!imgString){
                helper.alertaErro(cmp, event, helper, "VOCE DEVE ANEXAR UMA IMAGEM DO CHECKOUT", "ERRO!", "Error", "dismissable")
                return                
            }*/
            checkInRealizado = false
        }
        
        if(helper.eventoAtualAtrasado == true){
            if(!justificativa){
                helper.alertaErro(cmp, event, helper, "SEU EVENTO ATRASOU, VOCÊ DEVE INCLUIR UMA JUSTIFICATIVA", "ERRO!", "Error", "dismissable")
                return
            }
            
            if(!contatoAtendido){
                helper.alertaErro(cmp, event, helper, "VOCE DEVE SELECIONAR UM CONTATO QUE FOI ATENDIDO NA VISITA, CASO NAO ESTEJA DISPONÍVEL, CADASTRE NA CONTA DO CLIENTE", "ERRO!", "Error", "dismissable")
                return                
            }
            
            /*if(!imgString){
                helper.alertaErro(cmp, event, helper, "SEU EVENTO ATRASOU, VOCÊ DEVE INCLUIR UMA IMAGEM PARA JUSTIFICAR", "ERRO!", "Error", "dismissable")
                return                
            }*/
            checkInRealizado = false
        }
        
        if(!contatoAtendido){
            helper.alertaErro(cmp, event, helper, "VOCÊ DEVE INSERIR O CONTATO ATENDIDO NO COMPROMISSO. CASO NÃO ESTEJA DISPONÍVEL, DEVE-SE CADASTRAR NA CONTA DO CLIENTE.", "ERRO!", "Error", "dismissable")
            return
        }
        
        if(!feedback){
            helper.alertaErro(cmp, event, helper, "VOCÊ DEVE INSERIR UM FEEDBACK DO COMPROMISSO", "ERRO!", "Error", "dismissable")
        	return
        }
        
        /*if(!imgString){
            helper.alertaErro(cmp, event, helper, "VOCÊ DEVE INSERIR UMA FOTO DO COMPROMISSO", "ERRO!", "Error", "dismissable")
        	return
        }*/
        
        //CHAMA A FUNÇÃO DO APEX
        var action =  cmp.get("c.atualizaCompromisso");
        
        // DEFININDO UM NOVO NOME DA IMAGEM
        var name = new Date().toLocaleString() + "checkout"
        var imagem = imgString.split(",")[1];
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            contatoTratado: contatoAtendido,
            eventoId: idCompromisso,
            checkInRealizado: checkInRealizado,
            justificativa: justificativa,
            feedback : feedback,
            image: imagem,
            name: name,
            dataType: 'jpg',
            contentType: 'image/jpg',
            folderName: 'Imagens'
        });
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            console.log("CALLBACK")
            var state = response.getState();
            var result = response.getReturnValue();
            
            //TESTANDO O SUCESSO
            if (state === "SUCCESS") {
                $("#divPaiPopupCheckout").hide()
                helper.alertaErro(cmp, event, helper, "Seu check-out foi concluído com sucesso", "TUDO OK!", "Success", "dismissable")
                helper.mainHelper(cmp, event, helper)
                
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