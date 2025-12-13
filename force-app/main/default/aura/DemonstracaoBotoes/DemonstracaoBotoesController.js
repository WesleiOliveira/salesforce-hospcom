({
	
	doInit:function(component, event, helper){
		var valores;
		var action = component.get("c.ValidarPreenchimento");
		action.setParams({'demo_id':component.get("v.recordId")});
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
				valores = JSON.parse(response.getReturnValue());
				component.set("v.demonstracao_valida", true);
				component.set("v.mensagem_valida", valores.retorno);
				component.set("v.tipo", valores.tipo);
				component.set("v.tipos", valores.tipos);
			}else{
				component.set("v.demonstracao_valida", false);
				component.set("v.mensagem_valida", 'Erro ao efetuar chamada.');
			}
        });
		
        $A.enqueueAction(action);
	},
	
	
	AbrirPdfContrato: function(component, event, helper) {
        component.set("v.modal_pdf_contrato", true);
	},

	FecharPdfContrato: function(component, event, helper) {
		component.set("v.modal_pdf_contrato", false);
	},
	
	SalvarPdfContrato1: function(component, event, helper) {
		var action = component.get("c.SalvarPdfContrato");
		action.setParams({'demo_id':component.get("v.recordId")});
        action.setCallback(this, function(response){
			component.set("v.modal_pdf_contrato", false);
			var toastEvent = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
				toastEvent.setParams({"message":"O PDF Contrato foi salvo com sucesso para a demonstração","type":"success"});
				$A.get('e.force:refreshView').fire();
			}
            else
				toastEvent.setParams({"message":"Ocorreu um erro ao salvar o O PDF Contrato.","type":"error"});
			toastEvent.fire();
        });
        $A.enqueueAction(action);
	},

	
	AbrirPdfChecklist: function(component, event, helper) {
        component.set("v.modal_pdf_checklist", true);
	},

	FecharPdfChecklist: function(component, event, helper) {
		component.set("v.modal_pdf_checklist", false);
	},
	
	SalvarPdfChecklist1: function(component, event, helper) {
		var action = component.get("c.SalvarPdfChecklist");
		action.setParams({'demo_id':component.get("v.recordId"), 'tipo':component.get("v.tipo")});
        action.setCallback(this, function(response){
			component.set("v.modal_pdf_checklist", false);
			var toastEvent = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
				toastEvent.setParams({"message":"O PDF Checklist foi salvo com sucesso para a demonstração","type":"success"});
				$A.get('e.force:refreshView').fire();
			}
            else
				toastEvent.setParams({"message":"Ocorreu um erro ao salvar o O PDF Checklist.","type":"error"});
			toastEvent.fire();
        });
        $A.enqueueAction(action);
	},


	AbrirPdfRegistro: function(component, event, helper) {
        component.set("v.modal_pdf_registro", true);
	},

	FecharPdfRegistro: function(component, event, helper) {
		component.set("v.modal_pdf_registro", false);
	},
    
    AbrirPdfProposta: function(component, event, helper) {
        component.set("v.modal_pdf_proposta", true);
	},
     FecharPdfProposta: function(component, event, helper) {
        component.set("v.modal_pdf_proposta", false);
	},
	
})