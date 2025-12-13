({
    doInit2: function(cmp, event, helper) {
        var recordId = cmp.get("v.recordId")
        helper.processRecordId(cmp, recordId)
    },
    onRender2: function(cmp, event, helper) {
        console.log("onRenderrrrrrrrrr")
        helper.helperMethod(cmp, event, helper)
    }
})