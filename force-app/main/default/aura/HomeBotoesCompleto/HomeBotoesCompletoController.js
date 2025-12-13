({
	doInit:function(component, event, helper){
		var valores;
		var acao = component.get("c.PrepararPainel");
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				valores = JSON.parse(response.getReturnValue());
				if(valores.paineis.length > 1){
					component.set("v.exibir",true);
					component.set("v.paineis",valores.paineis);
					component.set("v.painel",valores.painel);					
				}
			}
        });
        $A.enqueueAction(acao);			
	},
	
	Atualizar:function(component, event, helper) {
		var retorno;
		var acao = component.get("c.AlterarPainel");
		acao.setParams({'config':event.getSource().get("v.value")});
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				retorno = JSON.parse(response.getReturnValue());
				if(retorno.mensagem=='')
					location.reload();
			}
        });
		$A.enqueueAction(acao);	
    }
})