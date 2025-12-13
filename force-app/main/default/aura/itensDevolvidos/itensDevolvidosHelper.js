({
    fetchRecords: function(component) {
        let recordId = component.get("v.recordId");
        let queryString = "SELECT Id, Name, Quantidade__c, C_digo_do_produto_do_pedido__c, nomeProduto__c FROM Item_da_Solicita_o_de_devolu_o__c WHERE Solicita_o_de_devolu_o__c = '" + recordId + "'";
		console.log(queryString);
        let action = component.get("c.executeSoql"); // Se necessário
        action.setParams({ soql: queryString });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.records", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    }
});