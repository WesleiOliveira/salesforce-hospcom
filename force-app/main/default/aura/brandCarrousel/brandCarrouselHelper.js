({
    changeIndex: function(component, increment) {
        let currentIndex = component.get("v.currentIndex");
        let logos = component.get("v.logos");
        let newIndex = currentIndex + increment;
        
        if (newIndex < 0) {
            newIndex = logos.length - 4;
        } else if (newIndex + 4 > logos.length) {
            newIndex = 0;
        }

        component.set("v.currentIndex", newIndex);
    },
    
    startAutoScroll: function(component) {
        window.setInterval(
            $A.getCallback(function() {
                let increment = 1;
                this.changeIndex(component, increment);
            }.bind(this)), 3000 // 3 segundos para mudar automaticamente
        );
    }
})