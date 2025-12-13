({
	doInit: function(component, event, helper){
        component.set('v.colunas', [
            {label: 'Objeto', fieldName: 'objeto', type: 'text'},
			{label: 'Registro', type: 'button', typeAttributes: {label:{fieldName:'nome'}, variant:'Base'}},
            {label: 'Dias corridos', fieldName: 'tempo', type: 'text'}
        ]);
		
		// { label: 'Registro', fieldName: 'id', type: 'url', typeAttributes: { label: {fieldName: 'nome'}, target: '_self'}},
		
		var valores;
		var acao = component.get("c.VerificaAprovacoes");
        acao.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				valores = JSON.parse(response.getReturnValue());
				if(valores.pendencias.length > 0){
					component.set("v.exibir",true);
					component.set("v.pendencias",valores.pendencias);
				}else
                    component.set("v.exibir",false);
			}
        });
        $A.enqueueAction(acao);
	},
	
	AbrirAprovacoes: function(component, event, helper) {
        component.set("v.modal_pendencias", true);
	},

	FecharAprovacoes: function(component, event, helper) {
		component.set("v.modal_pendencias", false);
	},
        
	Redireciona: function(component, event, helper) {
		component.set("v.modal_pendencias", false);
		var acao = $A.get("e.force:navigateToSObject");
		acao.setParams({
		  "recordId": (event.getParam('row')).id,
		  "slideDevName": "related"
		});
		acao.fire();
	},
        
	
})