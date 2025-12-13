({
    handleSelect: function (component, event, helper) {
        console.log ('1');
        component.set("v.modal", true);
        
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue == "Checklist de Equipamentos")
        {
            component.set("v.pdf_CKL", true);
        }
    },
    FecharPdf: function(component, event, helper) {
		component.set("v.modal", false);        
        component.set("v.pdf_CKL", false);

	},
});