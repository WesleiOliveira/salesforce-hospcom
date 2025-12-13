/* Controlador de componente */ 
({ 
downloadDocument : function(component, event, helper){ 

  var sendDataProc = component.get("v.sendData"); 
  var dataToSend = { 
     "label" : "This is test" 
  }; // estes são os dados que você deseja enviar para geração de PDF 

  //invoca o método js da página vf 
  sendDataProc(dataToSend, function(){ 
              //lida com retorno de chamada 
  }); 
} 
})