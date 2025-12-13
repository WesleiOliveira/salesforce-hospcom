({
	onRender : function(component, event, helper) {
        console.log("Ok.");
        
        $("#titulo").click(function(){
            console.log("Ok CLICK");
            
            // Convert the div to image (canvas)
			var element = document.getElementById('element-to-print')
            document.body.appendChild(element);
            console.log(element.innerHTML);
            
            
            html2canvas(element, {
                ignoreElements: function (node) {
                    return node.nodeName === 'IFRAME';
                }
            }).then(function (canvas) {
                console.log(canvas.toDataURL("image/jpeg", 0.9));
            });
            
            
            
            
            
        });
        
        console.log("Ok 2");
        
        
        
    }
})