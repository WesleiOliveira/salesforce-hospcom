({
    callApexMethod : function(component) {
        var action = component.get("c.atualizarValores");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isLoading", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    }
})