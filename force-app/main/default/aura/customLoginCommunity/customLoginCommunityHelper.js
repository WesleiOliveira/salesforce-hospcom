({
    
    mainFunction : function(cmp, event, helper){
        $( document ).ready(function() {
            console.log( "ready!" );
            
        });
        
        
        $("#checkShowPass").change(function() {
            if(this.checked) {
                $("#senha").attr('type', 'text');
            }else{
                $("#senha").attr('type', 'password');
            }
        });
        
        
        //EVENTO DE CLIQUE NO BOTAO ESQUECI SENHA
        $("#esqueciSenhaButton").on( "click", function() {
            console.log("clicado esqueci senha")
            $("#colunaDefault").hide(1000)
            $("#colunaRedefine").show(1000)
        });
        
        //EVENTO DE CLIQUE NO BOTAO ESQUECI SENHA
        $("#voltarLogin").on( "click", function() {
            window.location.reload();
        });
        
        //EVENTO DO BOTAO REDEFINIR
        $("#buttonRedefinir").on( "click", function() {
            var emailUsuario = $("#emailRedefinir").val()
            helper.redefineSenhaUsuario(cmp, event, helper, emailUsuario)
        });
        
        
        $("#buttonEntrar").click(function () {
            
            $("#alertErro").hide()
            $("#spinnerload").show()
            
            var usuario = $("#usuario").val()
            var senha = $("#senha").val()
            
            $("#lembre").change(function() {
                if(this.checked) {
                    console.log("check")
                    localStorage.setItem("login", usuario);
                    localStorage.setItem('senha', senha);
                }else{
                    console.log("un-check")
                    localStorage.setItem("login", null);
                    localStorage.setItem('senha', null);
                }
            });
            
            
            console.log(usuario)
            console.log(senha)
            
            //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
            var action = cmp.get("c.doLogin");
            
            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                username: usuario,
                password: senha
            });
            //----------------------------------------------------
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var link = response.getReturnValue()
                    
                    window.location.href = link;
                    //alert("sucesso")
                    //console.log(response)
                    
                }
                else if (state === "INCOMPLETE") {
                    $("#alertErro").show()
                    $("#alertErro").html("A solicitação nao pode ser processada")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    
                    if (errors && errors[0] && errors[0].message) {
                        $("#spinnerload").hide()
                        $("#alertErro").show()
                        $("#alertErro").html(errors[0].message)
                        reject(errors[0].message);
                        
                    } else {
                        $("#spinnerload").hide()
                        $("#alertErro").show()
                        $("#alertErro").html("Ocorreu um erro desconhecido")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
            
            
        })
    },
    
    
    redefineSenhaUsuario: function(cmp, event, helper, emailRedefinir){
        console.log("redefinindo", emailRedefinir)
        
        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.recoveryPassword");
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            username: emailRedefinir
        });
        //----------------------------------------------------
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("sucesso")
                $("#alertSucess").show()
                $("#alertSucess").html("Tudo certo! Verifique sua caixa de entrada de e-mail.")
                
            }
            else if (state === "INCOMPLETE") {
                $("#alertErro").show()
                $("#alertErro").html("A solicitação nao pode ser processada")
            } else if (state === "ERROR") {
                var errors = response.getError();
                
                if (errors && errors[0] && errors[0].message) {
                    $("#spinnerload").hide()
                    $("#alertErro").show()
                    $("#alertErro").html(errors[0].message)
                    reject(errors[0].message);
                    
                } else {
                    $("#spinnerload").hide()
                    $("#alertErro").show()
                    $("#alertErro").html("Ocorreu um erro desconhecido")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})