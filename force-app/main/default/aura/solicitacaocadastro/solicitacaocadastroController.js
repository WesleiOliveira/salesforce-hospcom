({
	handleSuccess : function(component, event, helper) {
        var showToast = $A.get("e.force:showToast");
        var idnovo = event.getParam("id");
        component.set("v.recordId",idnovo);
        component.set("v.disabled",false);
        component.set("v.bdisabled",false);
        component.set("v.disabled2",false);
        component.set("v.aprovado",true);
        showToast.setParams({
           	"variant": "success",
            "title": "Solicitação Enviada"
        });
        showToast.fire();
    },
    
    refresh: function(component, event, helper) {
	location.reload();
    },
});