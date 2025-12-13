({
	handleClick : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = 'https://hospcom.my.salesforce.com/apex/DetalhesDaVaga?&id='+ recordId;
		window.open(url);
	},
    createRecord : function (component, event, helper) {
    var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
        "entityApiName": "Vagas_Dispon_veis__c"
    });
    createRecordEvent.fire();
}
})