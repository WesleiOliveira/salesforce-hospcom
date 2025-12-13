({
    onPageReferenceChanged: function(cmp, event, helper) {
        console.log("alert")
        $A.get('e.force:refreshView').fire();
    }
 })