({
    consultaAssinatura: function(cmp, event, helper){
        var recordId = cmp.get("v.recordId")
        
        var query = "SELECT assinaturaTermino__c FROM WorkOrder WHERE id = '"+recordId+"'"
        console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (assinaturaTermino) {
            
            if(assinaturaTermino[0].assinaturaTermino__c){
                
                var canvas = cmp.find('signature-pad').getElement();
                var ratio = Math.max(window.devicePixelRatio || 1, 1);
                var assinaturaURL = assinaturaTermino[0].assinaturaTermino__c
                
                canvas.width = canvas.offsetWidth * ratio;
                canvas.height = canvas.offsetHeight * ratio;
                canvas.getContext("2d").scale(ratio, ratio);
                
                var signaturePad = new SignaturePad(canvas, {
                    minWidth: .25,
                    maxWidth: 2,
                    throttle: 0
                });
                
                console.log("assinatura", assinaturaTermino[0].assinaturaTermino__c)
                signaturePad.fromDataURL(assinaturaURL, {
                    width: canvas.offsetWidth,
                    height: canvas.offsetHeight
                });
                
                signaturePad.off();
                
            }else{
                helper.handleInit(cmp, event, helper);
            }
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    handleInit : function(component, event, helper) {
        
        $("#buttonCancelar").click(function(){
            $("#divMestre").hide()
        })
        
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
                    var action = component.get("c.uploadWorkOrder");
                    
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
        
    },
    
    
})