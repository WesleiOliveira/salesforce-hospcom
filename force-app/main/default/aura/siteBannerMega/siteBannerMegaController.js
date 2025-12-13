({
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        cmp.set("v.setMeOnInit", "controller init magic!");
    },
    
    funcTeste : function (cmp, event, helper){
        console.log("its work");
        helper.soql(cmp, "SELECT Id, Name FROM Product2 WHERE Marca__c = 'MINDRAY' LIMIT 10")
        .then(function (produtos) {
            console.log(produtos[0])
            $( ".divTeste" ).append( "<p>" + produtos[0].Id +"</p>");
        })
        .catch(function (error) {
            console.log(error)
        })
        
        
    },
    
})