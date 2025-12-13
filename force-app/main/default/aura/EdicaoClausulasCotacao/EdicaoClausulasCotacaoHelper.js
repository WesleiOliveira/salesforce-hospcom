({
    loadRecord: function(component, recordId, richTextFields) {
        var action = component.get("c.loadRecord");
        action.setParams({
            "recordId": recordId,
            "richTextFields": richTextFields
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                for (var i = 0; i < richTextFields.length; i++) {
                    var richTextField = richTextFields[i];
                    component.set("v." + richTextField, record[richTextFields[i]]);
                }
            }
            else {
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    saveRecord: function(component, recordId, richTextFields) {
        var record = {};
        for (var i = 0; i < richTextFields.length; i++) {
            var richTextField = richTextFields[i];
            record[richTextFields[i]] = component.get("v." + richTextField);
        }
        var action = component.get("c.saveRecord");
        action.setParams({
            "recordId": recordId,
            "record": record
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Record saved successfully.");
            }
            else {
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})