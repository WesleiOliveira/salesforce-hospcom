({
    alertaErro: function (title, message, type) {
        const toast = $A.get("e.force:showToast");
        toast.setParams({
            title: title,
            message: message,
            type: type,
            mode: 'dismissible'
        });
        toast.fire();
    }
});