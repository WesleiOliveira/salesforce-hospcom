({
	doInit : function(cmp, event, helper) {
        helper.setForecastValue(cmp, event, helper);
        helper.helperMethod(cmp, event, helper);
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