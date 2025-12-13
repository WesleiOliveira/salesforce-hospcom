({
    checklists : [],
    
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
        
    alertaErro: function (component, event, helper, error, title, type, tipoMensagem, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": tipoMensagem + " " + error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    showSpinner: function (cmp) {
        $('#spinnerCotacao').css("display", "flex");
    },
    //-------------------------------------------
    
    //FUNÇÃO QUE OCULTA O SPINNER DE CARREGAMENTO-  
    hideSpinner: function (cmp, event, helper) {
        if(!helper.identificadorErro){
            $('#spinnerCotacao').css("display", "none");
        }
    },
    //--------------------------------------------
    
    loadChecklist : function(component, event, helper, modeloId) {
        
        //console.log("load check", helper.checklists)
        //console.log("load check modelo", modeloId)
        const resultado = helper.checklists.find(item => item.Id === modeloId);
        const jsonChecklist = resultado.JSON_do_checklist__c;
        
        let parsed = JSON.parse(jsonChecklist);
        component.set("v.checklist", parsed);
        
    },
    
    enviaChecklist : function(component, event, helper, respostas) {
        var checklist = component.get("v.checklist");
        
        console.log("RESPOSTAS", JSON.stringify(respostas))
        console.log(JSON.stringify(checklist))
        
        // Fazemos deep clone para não mutar o original (opcional)
        const resultado = JSON.parse(JSON.stringify(checklist));
        
        resultado.secoes.forEach(secao => {
            secao.campos.forEach(campo => {
            // pega valor da resposta ou default ""
            const resp = respostas.hasOwnProperty(campo.nome)
                ? respostas[campo.nome]
                : "";
                campo.valor = resp;
            });
        });
    	console.log("RESULTADO", resultado)
    
       	var recordId = component.get("v.recordId");

    	console.log("apos recordId")

    
        var acao = component.get("c.salva");
    	acao.setParams({
            'ot': recordId,
            'idModeloChecklist' : 'a3rU4000000KFpJIAW',
            'json' : resultado
        });
        
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                retorno = JSON.parse(response.getReturnValue());
                if(retorno.mensagem==''){
                    alert("Checklist Salvo!")
                }
            }
        });
        $A.enqueueAction(acao);	
    },
    
    
    loadModelos: function (component, event, helper) {
        
        var query = "select id, name, JSON_do_checklist__c from Checklist_Modelo__c";
        
        console.log(query)
        helper.alertaErro(component, event, helper, "", "Carregando Checklists...", "info", "", "dismissable")
        
        helper.soql(component, query)
        .then(function (modelosChecklist) {
                        
            //console.log("modelosChecklist", modelosChecklist)
            helper.checklists = modelosChecklist
            component.set("v.modelos", modelosChecklist);
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
    },
})