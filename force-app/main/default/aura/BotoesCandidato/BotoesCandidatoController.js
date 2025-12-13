({
	handleClick : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = 'https://hospcom--c.na49.visual.force.com/apex/Curriculo?&id='+ recordId;
		window.open(url);
	},
    createRecord : function (component, event, helper) {
    var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
        "entityApiName": "Recrutamento__c"
    });
    createRecordEvent.fire();
},
    editRecord : function(component, event, helper) {
    var editRecordEvent = $A.get("e.force:editRecord");
    editRecordEvent.setParams({
         "recordId": component.get("v.recordId")
   });
    editRecordEvent.fire();
}
})