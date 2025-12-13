({
    doInit : function(component, event, helper) {
        component.set("v.offset", 0);
        component.set("v.limit", 7);
        helper.loadMoreData(component , event, helper);
    },
    
    loadMore: function(component, event, helper){
  		var offset = component.get("v.offset");
        component.set("v.offset", offset + 7);
        console.log(offset);
        console.log(component.get("v.offset"));
		helper.loadMoreData(component, event, helper);
    }

})