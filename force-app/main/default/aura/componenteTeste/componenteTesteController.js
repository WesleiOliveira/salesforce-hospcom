({
 	handleClick: function(component, event, helper) {
        $( "#menuProdutos" ).css("display: block!important;")
      
    },
    
    handleRecordChanged: function(component, event, helper) {
  switch(event.getParams().changeType) {
    case "ERROR":
          console.log("error");
      // handle error
      break;
    case "LOADED":
      console.log(JSON.parse(JSON.stringify(component.get("v.record"))));
      console.log(JSON.parse(JSON.stringify(component.get("v.simpleRecord"))));
      console.log(component.get("v.simpleRecord")["Name"]);
      break;
    case "REMOVED":
      console.log("removed")
      break;
    case "CHANGED":
       console.lgo("changed")   
      // more stuff
      break;
  }
},
    

})