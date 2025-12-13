({
	
	doInit:function(component, event, helper){
		
		var valores;
		var acao = component.get("c.Inicializacao");
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				valores = JSON.parse(response.getReturnValue());
				component.set("v.marcas", valores.marcas);
				component.set("v.familias", valores.familias);
				component.set("v.tipos", valores.tipos);
			}
        });
        $A.enqueueAction(acao);			
	},
	
	Bloqueio:function(component, event, helper){
		console.log('verifica');
		if(component.get("v.nome")!='' && component.get("v.marca")!='' && component.get("v.familia")!='' && 
			component.get("v.tipo")!='' && component.get("v.valor")!='' && component.get("v.valor")!=null)
			component.set("v.bloqueio", false);
		else
			component.set("v.bloqueio", true);
		
        $A.enqueueAction(acao);			
	},
	
	
	Salvar1 : function(component, event, helper) {
		if(true){
			var retorno;
			var acao = component.get("c.Criar");
			acao.setParams({
				"codigo":component.get("v.codigo"), 
				"nome":component.get("v.nome"), 
				"marca":component.get("v.marca"), 
				"modelo":component.get("v.modelo"), 
				"familia":component.get("v.familia"), 
				"tipo":component.get("v.tipo"), 
				"descricao":component.get("v.descricao"),
				"valor":component.get("v.valor")
			});
			acao.setCallback(this, function(response){
				var mensagem = $A.get("e.force:showToast");
				if(response.getState() === "SUCCESS"){
					retorno = JSON.parse(response.getReturnValue());
					if(retorno.mensagem==''){
						mensagem.setParams({
							"type":"success", "title":"Sucesso", "message":"O produto foi criado com êxito",
							"messageTemplate": "O produto {0} foi criado com êxito.",
							"messageTemplateData": [{
								"url": retorno.url_base + '/' + retorno.produto.Id,
								"label": component.get("v.nome"),
							}]
						});
						$A.get('e.force:refreshView').fire();
                        
                        component.set("v.codigo", '');
                        component.set("v.nome", '');
                        component.set("v.marca", '');
                        component.set("v.modelo", '');
                        component.set("v.familia", '');
                        component.set("v.tipo", '');
                        component.set("v.descricao", '');
                        component.set("v.valor", '');
                        
                        component.set("v.activeSections",[]);
					}
					else
						mensagem.setParams({"type":"error", "title":"Erro", "message":retorno.mensagem});
				}
				else
					mensagem.setParams({"type":"error", "title":"Erro", "message":"Não foi possível criar o produto."});
				console.log('fire');
				mensagem.fire();
			});
			$A.enqueueAction(acao);	
		}
	}
})