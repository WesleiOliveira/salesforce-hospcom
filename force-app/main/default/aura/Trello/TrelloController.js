({
    doInit: function(cmp) {
        cmp.set("v.setMeOnInit", "controller init magic!");
    },
    
    onRender : function(cmp, event, helper){
        
        const testeee = document.getElementById('testeee');
        
        testeee.addEventListener('click', function (){
        	console.log('asdf');                                                    
        });
    },

})