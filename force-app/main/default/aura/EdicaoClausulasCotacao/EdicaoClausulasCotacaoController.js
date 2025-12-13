({
    doInit: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var richTextFields = component.get("v.richTextFields");
        helper.loadRecord(component, recordId, richTextFields);
    },

    saveRecord: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var richTextFields = component.get("v.richTextFields");
        helper.saveRecord(component, recordId, richTextFields);
    },
    handleRichTextChange: function(component, event, helper) {
    var inputId = event.getSource().getLocalId();
    var richTextField = inputId.replace("inputRichText-", "");
    var value = event.getParam("value");
    component.set("v." + richTextField, value);
}

})