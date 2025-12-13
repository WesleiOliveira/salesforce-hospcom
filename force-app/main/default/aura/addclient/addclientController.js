({
    myAction: function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        console.log("id:", recordId);

        
        var iframeSrc = 'https://integracao.hospcom.net/qrcode?link=https://oldsite.hospcom.net/cadastro-cliente&eventId=' + recordId;

        component.set("v.iframeSrc", iframeSrc);
    }
})