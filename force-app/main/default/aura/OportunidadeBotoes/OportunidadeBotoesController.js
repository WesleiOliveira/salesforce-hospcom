({
	
	AbrirCloneOportunidade: function(component, event, helper) {
		var valores;
		var acao = component.get("c.PrepararCloneOportunidade");
		acao.setParams({'opp_id':component.get("v.recordId")});
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				valores = JSON.parse(response.getReturnValue());
				component.set("v.nome", valores.nome);
				component.set("v.proprietarios", valores.proprietarios);
				component.set("v.produtos", valores.produtos);
				component.set("v.proprietario", valores.proprietario);
				component.set("v.produto", valores.produto);
				component.set("v.modal_clone_oportunidade", true);
			}
        });
        $A.enqueueAction(acao);			
	},
	
	FecharCloneOportunidade: function(component, event, helper) {
		component.set("v.modal_clone_oportunidade", false);
		component.set("v.clone_de_acordo", false);
	},
	
	ConcordarCloneOportunidade : function(component, event, helper) {
		component.set("v.clone_de_acordo", true);
	},
	
    
    
    ClonarOportunidade1: function(component, event, helper) {

    // Ativa o carregamento
    component.set("v.loading", true);

    const body = {
        idoportunidade: component.get("v.recordId"),
        nomeoportunidade: component.get("v.nome"),
        idproprietario: component.get("v.proprietario"),
        opp_prods: component.get("v.produto")
    };

    fetch("https://integracao.hospcom.net/oportunidade", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    })
    .then(response => response.json())
    .then(retorno => {
     console.log("retorno", retorno);
        console.log("retornando", retorno.result)
    var toast = $A.get("e.force:showToast");

    if (retorno.message === "ok") {
        toast.setParams({
            type: "success",
            title: "Sucesso",
            message: "A oportunidade foi clonada com êxito"
        });

        // 🔥 ID da nova oportunidade
        const newOppId = retorno.result.clone;

        // 🔥 Redireciona para a nova oportunidade
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "/opportunity/" + newOppId + "/view"
        });
        navEvt.fire();

    } else {
    console.log("erro em alguma coisa")
        toast.setParams({
            type: "error",
            title: "Erro",
            message: retorno.mensagem
        });
    }

    toast.fire();
    component.set("v.modal_clone_oportunidade", false);
    component.set("v.loading", false);
})
},
    /*.then(retorno => {

        var toast = $A.get("e.force:showToast");

        if (retorno.mensagem === "") {
            toast.setParams({
                type: "success",
                title: "Sucesso",
                message: "A oportunidade foi clonada com êxito"
            });
        } else {
            toast.setParams({
                type: "error",
                title: "Erro",
                message: retorno.mensagem
            });
        }

        toast.fire();
        component.set("v.modal_clone_oportunidade", false);

        // Desativa carregamento
        component.set("v.loading", false);
    })
    .catch(error => {
        console.error("Erro na API:", error);

        var toast = $A.get("e.force:showToast");
        toast.setParams({
            type: "error",
            title: "Erro",
            message: "Falha ao chamar a API externa."
        });
        toast.fire();

        // Desativa carregamento
        component.set("v.loading", false);
    });
},*/

	
	/*
	 
	 * ClonarOportunidade1: function(component, event, helper) {
		var retorno;
		var acao = component.get("c.ClonarOportunidade");
		acao.setParams({
			"opp_id":component.get("v.recordId"), 
			"opp_nome":component.get("v.nome"),
			"opp_prop":component.get("v.proprietario"),
			"opp_prods":component.get("v.produto")
		});
        acao.setCallback(this, function(response){
			var mensagem = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
				retorno = JSON.parse(response.getReturnValue());
				if(retorno.mensagem=='')
					mensagem.setParams({
						"type":"success", "title":"Sucesso", "message":"A oportunidade foi clonada com êxito",
				        "messageTemplate": "A oportunidade {0} foi clonada com êxito.",
						"messageTemplateData": [{
							"url": retorno.url_base + '/' + retorno.oportunidade.Id,
							"label": retorno.oportunidade.Numero_OP__c,
						}]
				});
				else
					mensagem.setParams({"type":"error", "title":"Erro", "message":retorno.mensagem});
			}
			else
				mensagem.setParams({"type":"error", "title":"Erro", "message":"Não foi possível realizar a clonagem."});
			mensagem.fire();
			component.set("v.modal_clone_oportunidade", false);
        });
        $A.enqueueAction(acao);			
	},
	
	
	*/
	AbrirAlteraCatalogo: function(component, event, helper) {
		var valores;
		var acao = component.get("c.PrepararAlteraCatalogo");
		acao.setParams({'opp_id':component.get("v.recordId")});
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				valores = JSON.parse(response.getReturnValue());
				component.set("v.catalogos", valores.catalogos);
				component.set("v.pendencias", valores.pendencias);
				component.set("v.catalogo", valores.catalogo);
				component.set("v.catalogo_atual", valores.catalogo_atual);
				component.set("v.catalogo_alerta", valores.catalogo_alerta);
				
				component.set("v.pendencia","");
				var pendencias = component.get("v.pendencias");
				for(var i=0; i<pendencias.length; i++)
					if(pendencias[i].value==component.get("v.catalogo") && pendencias[i].label != '')
						component.set("v.pendencia", "Os seguintes produtos serão EXCLUÍDOS pois não possuem entrada no catálogo selecionado: " + pendencias[i].label);
					
				component.set("v.modal_altera_catalogo", true);
			}
        });
        $A.enqueueAction(acao);			
	},
	
	AlterarAlteraCatalogo: function(component, event, helper) {
		component.set("v.pendencia","");
		var pendencias = component.get("v.pendencias");
		for(var i=0; i<pendencias.length; i++)
			if(pendencias[i].value==component.get("v.catalogo") && pendencias[i].label != '')
				component.set("v.pendencia", "Os seguintes produtos serão EXCLUÍDOS pois não possuem entrada no catálogo selecionado: " + pendencias[i].label);
	},
	
	FecharAlteraCatalogo: function(component, event, helper) {
		component.set("v.modal_altera_catalogo", false);
	},
	
	AlterarCatalogo1: function(component, event, helper) {
		var retorno;
		var acao = component.get("c.AlterarCatalogo");
		acao.setParams({
			"opp_id":component.get("v.recordId"), 
			"cat_id":component.get("v.catalogo"),
		});
        acao.setCallback(this, function(response){
			var mensagem = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
				retorno = JSON.parse(response.getReturnValue());
				if(retorno.mensagem=='')
					mensagem.setParams({
						"type":"success", "title":"Sucesso", "message":"O catálogo foi alterado com êxito",
				        "messageTemplate": "O catálogo foi alterado com êxito para {0}.",
						"messageTemplateData": [retorno.catalogo_novo]
				});
				else
					mensagem.setParams({"type":"error", "title":"Erro", "message":retorno.mensagem});
			}
			else
				mensagem.setParams({"type":"error", "title":"Erro", "message":"Não foi possível alterar o catálogo."});
			mensagem.fire();
			component.set("v.modal_altera_proprietario", false);
        });
        $A.enqueueAction(acao);		
		$A.get('e.force:refreshView').fire();		
	},
	
	
	
	AbrirAlteraProprietario: function(component, event, helper) {
		var valores;
		var acao = component.get("c.PrepararAlteraProprietario");
		acao.setParams({'opp_id':component.get("v.recordId")});
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				valores = JSON.parse(response.getReturnValue());
				component.set("v.proprietarios2", valores.proprietarios2);
				component.set("v.proprietario2", valores.proprietario2);
				component.set("v.proprietario_atual", valores.proprietario_atual);
				component.set("v.modal_altera_proprietario", true);
			}
        });
        $A.enqueueAction(acao);			
	},

	FecharAlteraProprietario: function(component, event, helper) {
		component.set("v.modal_altera_proprietario", false);
	},
	
	AlterarProprietario1: function(component, event, helper) {
		var retorno;
		var acao = component.get("c.AlterarProprietario");
		acao.setParams({
			"opp_id":component.get("v.recordId"), 
			"prop_id":component.get("v.proprietario2"),
		});
        acao.setCallback(this, function(response){
			var mensagem = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
				retorno = JSON.parse(response.getReturnValue());
				if(retorno.mensagem=='')
					mensagem.setParams({
						"type":"success", "title":"Sucesso", "message":"O proprietário foi alterado com êxito",
				        "messageTemplate": "O proprietário foi alterado com êxito para {0}.",
						"messageTemplateData": [retorno.proprietario_novo]
				});
				else
					mensagem.setParams({"type":"error", "title":"Erro", "message":retorno.mensagem});
			}
			else
				mensagem.setParams({"type":"error", "title":"Erro", "message":"Não foi possível alterar o proprietário."});
			mensagem.fire();
			component.set("v.modal_altera_proprietario", false);
        });
        $A.enqueueAction(acao);		
		$A.get('e.force:refreshView').fire();		
	},

})