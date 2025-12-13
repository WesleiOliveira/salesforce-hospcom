({
	doInit: function(component, event, helper){
        component.set('v.colunas', [
            {label: 'Despesa', fieldName: 'despesa', type: 'text'},
            {label: 'Requisitado', fieldName: 'requisitado', type: 'currency', typeAttributes:{currencyCode: 'BRL'}},
            {label: 'Adiantado', fieldName: 'adiantado', type: 'currency', typeAttributes:{currencyCode: 'BRL'}},
            {label: 'Quitado', fieldName: 'quitado', type: 'currency', typeAttributes:{currencyCode: 'BRL'}},
            {label: 'Validado', fieldName: 'validado', type: 'currency', typeAttributes:{currencyCode: 'BRL'}},
            {label: 'Saldo', fieldName: 'saldo', type: 'currency', typeAttributes:{currencyCode: 'BRL'}}
        ]);
		
		var valores;
		var acao = component.get("c.ObterTransacoes");
		acao.setParams({"viagem_id":component.get("v.recordId")});
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				valores = JSON.parse(response.getReturnValue());
				if(valores.resumos.length > 0){
					component.set("v.exibir",true);
					component.set("v.resumos",valores.resumos);
				}else
                    component.set("v.exibir",false);
			}
        });
        $A.enqueueAction(acao);
	}
	
})