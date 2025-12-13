({
    onRender : function(component, event, helper) {
        document.getElementById('currentYear').textContent = new Date().getFullYear();
        
        helper.mainFunction(component, event, helper);
    }
})