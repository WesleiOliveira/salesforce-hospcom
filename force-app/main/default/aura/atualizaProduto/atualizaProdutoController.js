({
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        cmp.set("v.setMeOnInit", "controller init magic!");
    },
    
    
    
    //FUNÇÃO EXECUTADA APÓS O TÉRMINO DA RENDERIZAÇAO DO COMPONENTE-----------------------------------------------------------
    onRender : function(cmp,event, helper){
       
        

        const coropBtn = document.getElementById('cropImgBtn');
        
        $("#cropImgBtn").click(function(){
            
        })
        
      
        
        window.setTimeout(
            $A.getCallback(function() {
                
                $(".container-cropp").css("display","none");
                $(".container-cropp").css("opacity","1");
            }), 500
        );
        
        
        
        
        
        
        const salvarFoto = document.querySelector("#salvar").addEventListener("click",function(){
            
            if($("#upload-photo").val()  == ""){
               
                helper.exibirAlerta(cmp, event, helper, "error","Houve um problema!", "Você nao selecionou nenhum arquivo!")
                
            }else{
                
                $(".container-arrasteSolta").css("display", "none");
                
                $(".container-cropp").css("display"," flex");
                
                
                helper.save(cmp, event, helper);
                helper.exibirAlerta(cmp, event, helper, "success","Sucesso!", "Arquivo carregado com sucesso!")
                
                }
            
        });
        
        
        //Exculiu o aquivo sele cionado
        $("#cancela-cropper").click(function(){
            $("#upload-photo").val("");
            $('#temArquivo').html(" Nenhum arquivo selecionado");
             $("#salvar").css("background", "#f2f2f2")
             $("#cancela-cropper").css("background", "#f2f2f2")
             $("#cancela-cropper").css("color", "#fff");
            
        })
        $("#cancela-crop").click(function(){
            $(".container-arrasteSolta").css("display", "flex");
            $(".container-cropp").css("display"," none");
            
            $("#upload-photo").val("");
            $('#temArquivo').html(" Nenhum arquivo selecionado");
            $("#salvar").css("background", "#f2f2f2")
            $("#cancela-cropper").css("background", "#f2f2f2")
            $("#cancela-cropper").css("color", "#fff");
            
            $(".imageCropping").remove();
        })
        
        //salvarFoto.e
        
        $("#upload-photo").change(function(){
            $("#temArquivo").html("Arquivo selecionado: " + $("#upload-photo").val().split('\\').pop());
            //botão de cortar
            //
            $("#cancela-cropper").css("background", "#bfbfbf"); 
            $("#cancela-cropper").css("color", "#0c375a");
            
            $("#salvar").css("background", "#0c375a");
            //botão de redefinir
            
            
            
        });
        
        
        
        //document.querySelector("#upload-photo").onchange() = fuction(){}
    },
    
    
    /*********/
    save : function(component, event, helper) {
        helper.save(component, event, helper);
    },
    
    waiting: function(component, event, helper) {
        $A.util.addClass(component.find("uploading").getElement(), "uploading");
        $A.util.removeClass(component.find("uploading").getElement(), "notUploading");
    },
    
    doneWaiting: function(component, event, helper) {
        $A.util.removeClass(component.find("uploading").getElement(), "uploading");
        $A.util.addClass(component.find("uploading").getElement(), "notUploading");
    }
    
    /*****texto de atualização do arquivo importado ****/
    
    
    
    /***********************/
    
    
})