({
    apex: function(cmp, method, params) {
        return new Promise(function (resolve, reject) {
            var action = cmp.get("c." + method);
            action.setParams(params);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    getRecordsTypes: function(cmp, nomeObjeto){
        return new Promise(function (resolve, reject) {
            var action = cmp.get("c.obterTiposDeRegistros");
            
            action.setParams({nomeObjeto: nomeObjeto
                             });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    getPicklist: function(cmp, objeto, campo){
        return new Promise(function (resolve, reject) {
            var action = cmp.get("c.listagem");
            
            action.setParams({nomeObjeto: objeto,
                              nomeCampo: campo
                             });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    uploadPDF: function(cmp, fileName, pagina, idPC){
        return new Promise(function (resolve, reject) {
            console.log("UPLOAD PDF CALLING", fileName, pagina, idPC)
            var action = cmp.get("c.uploadPDF");
            
            action.setParams({fileName: fileName,
                              pagina: pagina,
                              idPC: idPC
                             });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                            reject(errors[0].message);
                        } else {
                            console.log("Unknown error");
                            reject("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action);
        });
    },
    
    criaLog: function(cmp, conteudo, titulo, tipo, contentType, pasta){
        return new Promise(function (resolve, reject) {
            var action = cmp.get("c.saveDoc");
            
            action.setParams({text: conteudo,
                              name: titulo,
                              dataType: tipo,
                              contentType: contentType,
                              folderName: pasta
                             });
            
            action.setCallback(this, function(response) {
		        console.log(response.getState(), response.getError());
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        JSON.stringfy(errors));//[0].message);
                            //reject(errors[0].message);
                        } else {
                            console.log("Unknown error");
                            reject("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action);
        });
    },

    soql: function (cmp, query) {
        //console.log("SOQL Executado no Helper Apex")
        return new Promise(function (resolve, reject) {
            var action = cmp.get("c.executeSoql");
            action.setParams({soql: query});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    ativarPedidoCompra: function(cmp, id) {
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.changeStatusPurchaseOrder");
            action.setParams({id: id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                helper.criaLog(cmp, `${response.getError()} \n\n ${response} \n\n ${JSON.stringify(response)}`, `${id} - ${state}`, 'txt', 'text/plain', '00l6e000002NiLZAA0')
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
 
    updateAddressPedido: function(cmp, id, type, street, city, state, postalcode) {
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.updateOrderAdress");
            action.setParams({
            	id: id, 
	            type: type, 
                street: street, 
                city: city, 
                state: state, 
                postalcode: postalcode
        	});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
        
    ativarPedidoVenda: function(cmp, id) {
        return new Promise((resolve, reject) => {
            var action = cmp.get("c.changeStatusSalesOrder");
            action.setParams({id: id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.criaLog(cmp, `${errors[0].message}`, `${id} - ${state}`, 'txt', 'text/plain', 'LOG INTEGRACAO SAP 2.0');
                        console.log("Error message: " +
                                    errors[0].message);
                        reject(errors[0].message);
                    } else {
                        console.log("Unknown error");
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },
 	
})