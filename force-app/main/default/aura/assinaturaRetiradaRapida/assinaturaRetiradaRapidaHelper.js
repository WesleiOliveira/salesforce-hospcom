({
    handleInit : function(component, event, helper) {
        
        $("#buttonCancelar").click(function(){
            $("#divMestre").hide()
        })
        
        $("#colherAssinatura").click(function(){
            //alert("funcionalidade em desenvolvimento")
            
            $("#divMestre").show()
            
            var canvas = component.find('signature-pad').getElement();
            var ratio = Math.max(window.devicePixelRatio || 1, 1);
            
            canvas.width = canvas.offsetWidth * ratio;
            canvas.height = canvas.offsetHeight * ratio;
            canvas.getContext("2d").scale(ratio, ratio);
            
            var signaturePad = new SignaturePad(canvas, {
                minWidth: .25,
                maxWidth: 2,
                throttle: 0
            });
            
            $("#limparButton").click(function(){
                console.log("clique limpar")
                signaturePad.clear();
            });
            
            $("#buttonPronto").click(function(){
                $('#spinnerDiv').css("display", "flex");
                //console.log("clique pronto")
                var image = signaturePad.toDataURL().split(",")[1];
                
                console.log("salvando imagem")
                //CHAMA A FUNÇÃO DO APEX
                var action = component.get("c.insertImage");
                
                // DEFININDO UM NOVO NOME DA IMAGEM
                const date = new Date().toLocaleString();
                var name = "OT_SIGNATURE_" + date;
                
                console.log("IMAGE", image)
                console.log("name", name)
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    image: image,
                    name:name,
                    dataType: 'jpg',
                    contentType: 'image/jpg',
                    folderName: 'Imagens'
                });
                
                //CALLBACK DA REQUISIÇÃO---------------------------
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    var result = response.getReturnValue();
                    
                    
                    //TESTANDO O SUCESSO
                    if (state === "SUCCESS") {
                        console.log("RESULTADO", result)
                        
                        //ATUALIZANDO DADOS DO SALESFORCE
                        var idOrdemDeTrabalho = component.get("v.recordId");
                        var action = component.get("c.uploadRetirada");
                        
                        console.log("ID REGISTRO", idOrdemDeTrabalho)
                        
                        
                        action.setParams({
                            id :idOrdemDeTrabalho,
                            url: result
                        });    
                        
                        //CALLBACK DA REQUISIÇÃO---------------------------
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            
                            
                            if (state === "SUCCESS") {
                                location.reload();
                                console.log("assinatura atualizada")
                                
                            }else if (state === "INCOMPLETE") {
                                console.log("incompleto")
                                console.log(response)
                                
                            } else if (state === "ERROR") {
                                console.log("erro")
                                console.log(response.getError())
                            }
                        });
                        
                        $A.enqueueAction(action);
                        
                        
                        var result = response.getReturnValue();
                        
                    }else if (state === "INCOMPLETE") {
                        console.log("incompleto")
                        console.log(response)
                        
                    } else if (state === "ERROR") {
                        console.log("erro")
                        console.log(response.getError())
                    }
                });
                
                $A.enqueueAction(action);
                
                
                //console.log(data)
            })
            
        })
        
    },

    
})