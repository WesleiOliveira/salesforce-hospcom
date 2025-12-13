({
	handleClick : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = '/Sales/apex/Pdf_Evento?Id='+ recordId ;
		window.open(url);
	}
})