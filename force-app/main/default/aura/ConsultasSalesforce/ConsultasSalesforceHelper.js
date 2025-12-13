({
    alertaErro: function(component, event, helper, title, message, type) {
        console.log("passando aqui");
        const toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type
            });
            toastEvent.fire();
        } else {
            console.warn("force:showToast não disponível.");
            alert(`${title}: ${message}`);
        }
    }
})