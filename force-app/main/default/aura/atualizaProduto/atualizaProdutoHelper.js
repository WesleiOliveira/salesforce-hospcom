({
    MAX_FILE_SIZE: 2000000, /* 1 000 000 * 3/4 to account for base64 */
    
    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecorId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        //var recordId = '01t5A000008Tr8b'
        
        return recordId
    },
    //---------------------------------------------------
    
    save : function(component, event, helper) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        
        if (file.size > this.MAX_FILE_SIZE) {
            helper.exibirAlerta(component, event, helper, "error", "Erro!", "O arquivo selecionado excede o limite de 2mb")
            return;
        }
        
        var fr = new FileReader();
        
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            
            fileContents = fileContents.substring(dataStart);
            
            //CREAT CROP
            
             $("#caixa").append("   <div class = 'imageCropping'>  <div class='image' id='divImage'>  </div> <div class='preview' > </div>  </div>   ")
            
             
             
             
             
            $("#divImage").append("<img id='image' src='data:image/jpg;base64," + encodeURIComponent(fileContents) +"'/>")
            
            //rotaciona a imagem em sentido horaio
            $("#rotateHorario").click(function(){
                
                cropper.rotate(90);
            });
            //rotaciona a imagem em sentido ante horaio
            $("#rotateAnteHorario").click(function(){
                
                cropper.rotate(-90);
            });
            
            
            
            const image = document.getElementById('image');
            var cropper = new Cropper(image, {
                preview: '.preview',
                aspectRatio: 1 / 1,
                movable: true,
                zoomable: true,
                rotatable: true,
                scalable: true
                
            });
            //FIM CREAT CROP

            //PEGANDO NOVA IMAGEM CORTADA E ATUALIZANDO
            $("#azul").click(function(){
                $('#spinnerDiv').show()
                var croppedimage = cropper.getCroppedCanvas({
                    fillColor: '#fff',
                }).toDataURL("image/png");
                
                var croppedimageFormat =croppedimage.split(",");
                helper.saveImage(component, event, helper, croppedimageFormat[1]);
                
               
            });
            
            
            //self.upload(component, file, fileContents);
        };
        
        fr.readAsDataURL(file);
    },
    
           /* 
        	*  upload: function(component, file, fileContents) {
            *   console.log("chegou")
            *  console.log(encodeURIComponent(fileContents))
            * },
            */
            
            saveImage: function(component, event, helper, image){
                //CHAMA A FUNÇÃO DO APEX
                var action = component.get("c.insertImage");
                
                // DEFININDO UM NOVO NOME DA IMAGEM
                const date = new Date().toLocaleString();
                var name = $("#upload-photo").val().split('\\').pop() + "-"+ date;
                
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
                      
                        //ATUALIZANDO DADOS DO SALESFORCE
                        var idProductor = helper.retornaRecorId(component, event, helper)
                        var action = component.get("c.uploadProduct");
                        
                        action.setParams({
                            id :idProductor,
                            url: result
                        });    
                        
                        //CALLBACK DA REQUISIÇÃO---------------------------
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            
                            
                            if (state === "SUCCESS") {
                                
                                
                                
                                $(".container-arrasteSolta").css("display", "flex");
                                $(".container-cropp").css("display"," none");
                                
                                $("#upload-photo").val("");
                                $('#temArquivo').html(" Nenhum arquivo selecionado");
                                $("#salvar").css("background", "#f2f2f2")
                                $("#cancela-cropper").css("background", "#f2f2f2")
                                $("#cancela-cropper").css("color", "#fff");
                                
                                $(".imageCropping").remove();
                                	$('#spinnerDiv').hide()
                                  helper.exibirAlerta(component, event, helper, "success", "Sucesso", "Imagem atualizada com sucesso!")
                                
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
            },
            
            
            
            showToast : function(component, event, helper) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro!",
                    "message": "Arquivo ultrapassa 2mB"
                });
                toastEvent.fire();
            }
            ,
            
            exibirAlerta : function(component, event, helper, type, title, message) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : type,
                    "title": title,
                    "message": message
                });
                toastEvent.fire();
            }
            
            
            
            //valida o save para trocar de pagina
            
            
    
    
})