({
	handleSuccess : function(component, event, helper) {
        
    },

    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Tudo certo!",
            "message": "Mensagem Enviada!"
        });
        toastEvent.fire();
    },
    
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        cmp.set("v.setMeOnInit", "controller init magic!");
    },
    
    changeValue : function (component, event, helper) {
      component.set("v.assuntoEmail", "work change");
    },
})