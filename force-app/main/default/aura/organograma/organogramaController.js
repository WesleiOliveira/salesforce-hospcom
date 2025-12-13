({
	onRender : function(component, event, helper) {
		$(document).ready(function() {
            $('.popup').click(function() {
				$(this).find('.popuptext').toggleClass("show");
            });
        });
	}
})