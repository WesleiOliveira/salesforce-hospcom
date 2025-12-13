({
    doInit : function(cmp, event, helper) {
        console.log("iniciado")
    },
    
    onRender : function(cmp, event, helper) {
        $("#copiaLink").on("click", function(){
            console.log("clicado")
            
            //var link = window.location.href;
            var link = window.location.href;
            var dummy = document.createElement('input');
            document.body.appendChild(dummy);
            dummy.setAttribute('value', link);
            dummy.select();
            document.execCommand('copy');
            document.body.removeChild(dummy);
            $("#sucesso").show()
            console.log('Link copiado com sucesso!');            
            
        });
    }
})