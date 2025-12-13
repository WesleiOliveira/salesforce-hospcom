({
    doInit: function (component, event, helper) {
        helper.loadModelos(component, event, helper);
    },

    handleModeloChange: function (component, event, helper) {
        let modeloId = component.get("v.selectedModeloId");
        if (modeloId) {
            helper.loadChecklist(component, event, helper, modeloId);
        } else {
            component.set("v.checklist", null);
        }
    },

    handleInputChange : function(component, event, helper) {
        let respostas = component.get("v.respostas") || {};
        let src       = event.getSource();
        let name      = src.get("v.name");
        let value;
        
        // se for checkbox, usa checked; senão, usa value
        if (src.get("v.type") === "checkbox") {
            value = src.get("v.checked");
        } else {
            value = src.get("v.value");
        }
        
        respostas[name] = value;
        component.set("v.respostas", respostas);
    },
    

    salvarChecklist: function (component, event, helper) {
        
        console.log("salvar checklist")
        var respostas = component.get("v.respostas");
        console.log("salvar checklist 2")

        helper.enviaChecklist(component, event, helper, respostas);
        //console.log('Respostas:', JSON.stringify(respostas, null, 2));
        //alert('Checklist salvo (simulado): ' + JSON.stringify(respostas));
        // Aqui você pode adicionar a lógica de salvar no Checklist_Preenchido__c
    }
})