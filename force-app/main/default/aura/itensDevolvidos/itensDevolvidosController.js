({
    doInit: function(component, event, helper) {
        helper.fetchRecords(component);
    },

    handleInputChange: function(component, event) {
        let index = event.getSource().get("v.dataset.index");
        let value = event.getSource().get("v.value");

        let records = component.get("v.records");
        records[index].Quantidade__c = value;
        component.set("v.records", records);
    },

    saveRecords: function(component, event, helper) {
    let action = component.get("c.updateRecords");
    action.setParams({ recordsJson: JSON.stringify(component.get("v.records")) });

    action.setCallback(this, function(response) {
        let state = response.getState();
        if (state === "SUCCESS") {
            // Mostrar toast de sucesso
            component.find("notifLib").showToast({
                "title": "Sucesso",
                "message": "Registros atualizados com sucesso!",
                "variant": "success"
            });

            // Aguarda um pouco e recarrega a página
            window.setTimeout(
                $A.getCallback(function() {
                    window.location.reload();
                }), 1500 // 1.5 segundos de delay
            );
        } else {
            // Erro ao salvar
            component.find("notifLib").showToast({
                "title": "Erro",
                "message": "Erro ao salvar os registros.",
                "variant": "error"
            });
            console.error("Erro:", response.getError());
        }
    });

    $A.enqueueAction(action);
}


});