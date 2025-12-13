({
	doInit:function(component, event, helper){
		var acao = component.get("c.Inicializar");
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				var retorno = JSON.parse(response.getReturnValue());
				console.log(retorno);
				component.set("v.retorno", retorno);
				component.set("v.opcao", retorno.opcao);
				component.set("v.opcoes", retorno.opcoes);
				component.set("v.exibir", (retorno.tipo_usuario=='' ? false : true));
			}
        });
        $A.enqueueAction(acao);	
	},
	
	AlteraOpcao:function(component, event, helper){
		var acao = component.get("c.BuscarMeta");
		component.set("v.retorno.opcao", component.get("v.opcao"));
		acao.setParams({"retorno_json": JSON.stringify(component.get("v.retorno"))});
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				var retorno = JSON.parse(response.getReturnValue());
				console.log(retorno);
				component.set("v.retorno", retorno);
			}
        });
        $A.enqueueAction(acao);	
	}
})