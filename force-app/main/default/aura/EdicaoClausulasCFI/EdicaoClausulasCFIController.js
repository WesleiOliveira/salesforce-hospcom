({
	doInit : function(component, event, helper) {
		        var recordId = component.get('v.recordId');
	},
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        "type" : 'success',
        "title": '',
        "message": 'Atualização realizada com sucesso.'
        });
		toastEvent.fire();
	}
})