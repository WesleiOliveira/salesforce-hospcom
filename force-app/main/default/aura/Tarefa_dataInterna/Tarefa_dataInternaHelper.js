({
    checkUserAccess: function(component) {
        var action = component.get("c.getTaskDetails");
        action.setParams({ taskId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                console.log(result);
                console.log(result.task);                
                console.log(result.podeEditar);
                
                component.set("v.task", result.task);
                component.set("v.canEdit", result.podeEditar);
            } else {
                console.error("Failed to retrieve task details: " + response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    saveTask: function(component) {
        var action = component.get("c.updateTaskInternalDate");
        action.setParams({
            taskId: component.get("v.recordId"),
            newDate: component.find("internalDate").get("v.value")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success, maybe show a toast or refresh view
                
            } else {
                console.error("Failed to update task: " + response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
})