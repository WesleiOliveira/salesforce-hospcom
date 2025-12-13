({
    afterRender: function (cmp, helper) {
        var afterRend = this.superAfterRender();
        //helper.addListeners(cmp)
        return afterRend;
    },
})