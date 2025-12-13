({
    doInit: function(component, event, helper) {
        // Call helper to check user access and fetch the task details
        helper.checkUserAccess(component);
    },
    
    updateTask: function(component, event, helper) {
        // Call helper to handle task update
        helper.saveTask(component);
    }
})