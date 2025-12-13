({
	
	doInit:function(component, event, helper){
		
		var action_1 = component.get("c.ValidarPreenchimento");
		action_1.setParams({'cot_id':component.get("v.recordId")});
        action_1.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				component.set("v.cotacao_valida", (response.getReturnValue()==''?true:false));
				component.set("v.mensagem_valida", response.getReturnValue());
			}else{
				component.set("v.cotacao_valida", false);
				component.set("v.mensagem_valida", 'Erro ao efetuar chamada.');
			}
        });
        $A.enqueueAction(action_1);	
		
		var action_2 = component.get("c.VerificarLicitacao");
		action_2.setParams({'cot_id':component.get("v.recordId")});
        action_2.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
					component.set("v.cotacao_licitacao", response.getReturnValue());
			}else{
				component.set("v.cotacao_licitacao", false);
				component.set("v.mensagem_licitacao", 'Erro ao efetuar chamada.');
			}
        });
		$A.enqueueAction(action_2);


		// var action3 = component.get("c.validaStatus");
		// action3.setParams({'cot_id':component.get("v.recordId")});
        
		// action3.setCallback(this, function(response){
		// 	component.set("v.valida_status", response.getReturnValue());
		// });
		// $A.enqueueAction(action3);
		
	},
	
	AbrirPdfProposta: function(component, event, helper) {
	
    var recordId = component.get("v.recordId");{
        
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/CotacaoProposta?Id="+ recordId;
            } else {
                component.set("v.modal_pdf_proposta", true);
            }       
        }
     },

	FecharPdfProposta: function(component, event, helper) {
		component.set("v.modal_pdf_proposta", false);
	},
	
	SalvarPdfCotacao1: function(component, event, helper) {
        console.log("entrou salvar pdf cotacao");
        
		var action = component.get("c.SalvarPdfCotacao");
		action.setParams({'cot_id':component.get("v.recordId")});

        action.setCallback(this, function(response){
			component.set("v.modal_pdf_proposta", false);
			var toastEvent = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
				toastEvent.setParams({"message":"O PDF foi salvo com sucesso para a cotação","type":"success"});
				$A.get('e.force:refreshView').fire();
			}
            else
				toastEvent.setParams({"message":"Ocorreu um erro ao salvar o O PDF da cotação.","type":"error"});
			toastEvent.fire();
        });
		
        $A.enqueueAction(action);
	},
    
    SalvarPdfProposta1: function(component, event, helper) {
		var action = component.get("c.SalvarPdfProposta");
		action.setParams({'cot_id':component.get("v.recordId")});

        action.setCallback(this, function(response){
			component.set("v.modal_pdf_proposta", false);
			var toastEvent = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
				toastEvent.setParams({"message":"O PDF foi salvo com sucesso para a cotação","type":"success"});
				$A.get('e.force:refreshView').fire();
			}
            else
				toastEvent.setParams({"message":"Ocorreu um erro ao salvar o O PDF da cotação.","type":"error"});
			toastEvent.fire();
        });
		
        $A.enqueueAction(action);
	},

	
	AbrirPdfDetalhes: function(component, event, helper) {
        component.set("v.modal_pdf_detalhes", true);
	},
    
    AbrirPdfContratos: function(component, event, helper) {
        var recordId = component.get("v.recordId");{
        if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/CotacaoContrato?Id="+ recordId;
        }else{
                component.set("v.modal_pdf_contratos", true);
        	}
		}
    },
    
    FecharPdfContratos: function(component, event, helper) {
		component.set("v.modal_pdf_contratos", false);
	},

	FecharPdfDetalhes: function(component, event, helper) {
		component.set("v.modal_pdf_detalhes", false);
	},

})