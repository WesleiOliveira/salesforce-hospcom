({
    startCarousel: function(component, event, helper) {
        helper.startAutoScroll(component);
    },
    
    nextLogos: function(component, event, helper) {
        helper.changeIndex(component, 1);
    },
    
    prevLogos: function(component, event, helper) {
        helper.changeIndex(component, -1);
    }
})