({
    
    campoConsulta :  "id ,name ,(SELECT id, Name, Status_do_Item__c, Requisi_o_Interna_Relacionada__c, Categoria__c ,Quantidade__c FROM Itens_Requeridos__r)" 
    ,
    objetoConsulta :'Requisi_o_Interna__c',
    
    helperMethod : function(cmp, event, helper) {
        
        console.log("teste 1 ")
        
        helper.render(cmp, event, helper)  
        console.log("teste 2 ")             
        helper.selectItem(cmp, event, helper)
        
    }
    ,
    
    
    
    
    render: function(cmp, event, helper){
        
        
        const recordId = cmp.get("v.recordId")
        
        
        console.log("teste")
        var query = "SELECT " + helper.campoConsulta + " FROM "+ helper.objetoConsulta +" WHERE id = '"+recordId+"'"
        console.log(query)
        //REALIZA A CONSULTA
        
        console.log("REALIZA A CONSULTA")
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (idsAutentique) {
            
            
            //console.log("tá indo")
            
            //console.log(idsAutentique)
            
            $("#subTitulo")[0].textContent =  idsAutentique[0].Name
            
            idsAutentique[0].Itens_Requeridos__r.forEach(function(resultado){
                console.log(resultado.Id)
                console.log(resultado.Quantidade__c)
                console.log(resultado.Status_do_Item__c)
                //APPEND 
                
                $("#container-itens").append("<div class= 'item-requisicao' data-idItem='"+ resultado.Id + "'> <div class = 'td select'> <label> <input type='checkbox'  class = 'check'/> </label>  </div>  <div class = 'td'> <p>"+ resultado.Name  +" </p> </div> <div class = 'td' data-status='aprovado'> <p>" + resultado.Status_do_Item__c + "</p> </div> <div class = 'td'> <p>"+ resultado.Categoria__c +" </p> </div> <div class = 'td'> <p>"+ resultado.Quantidade__c + "</p> </div> </div>");
                
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log("error")
            console.log(error)
        })
    }
    ,
    
    selectItem :  function(cmp, event, helper){
        /*document.querySelectorAll(".item-requisicao").forEach(element => element.addEventListener('click', () =>{
    element.style.backgroundColor = "#00ff00"})
	)*/
        helper.salvarAlteracoe(cmp, event, helper)
        
        
        $("#selectAll").change(function(){
            
            
            if ( $(this).is(":checked")) {
                $('.check').prop('checked',true);
                
            } else {
                $('.check').prop('checked',false);
            }       
        });
        
        
        $(".select").charge(function(){
            
        })
    },
    
    salvarAlteracoe: function(cmp, event, helper){
        
        
        //EVENTO DE CLIQUE NO BOTAO
        $("#salvar").on("click", function(){
            console.log("clique salvar")
            var itensChecados = []
            var status = $("#status").val()
            
            //LOOP EM TODOS ITENS
            $(".item-requisicao").each(function(){
                
                //VERIFICA SE ITEM ATUAL TA CHECADO
                if($(this).find(".check").is(":checked")){
                    
                    //RECEBER O ID DO ITEM ATUAL
                    var idItem = $(this).attr("data-iditem")
                    
                    itensChecados.push(idItem)
                }
            });
            
            
            function arrayToString(arr) {
                return arr.join(',');
            }
            
            
            const idsList = arrayToString(itensChecados);
            
            
            
            
            
            
            console.log(status)
            
            
            
            
            if(!(idsList == "" || status == null)){//CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
                var action = cmp.get("c.atualizaItem");
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    idsItens: idsList,
                    statusAtual: status
                });
                //----------------------------------------------------
                console.log( "parametros colocados" )
                
                
                //CALLBACK DA REQUISIÇÃO---------------------------
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        helper.exibirAlerta(cmp, event, helper, "success", "Sucesso", "Status do produto atualizado com  sucesso")
                        
                        
                        
                        
                        $('.check').prop('checked',false);
                        console.log("checou!")
                        $('#selectAll').prop('checked',false);
                        console.log("checou!")
                        
                        
                          setTimeout(location.reload(), 3000);
                        //helper.hideSpinner(cmp);
                        //helper.alertaErro(cmp, event, helper, "DOCUMENTO ENVIADO PRA ASSINATURA!", "SUCESSO", "success", "Operação concluída!", "dismissable")
                        //window.location.reload()
                    }
                    else if (state === "INCOMPLETE") {
                        helper.exibirAlerta(component, event, helper, "error", "Erro!", "Erro ao atualizar status dos iteins. Entre em contao como time de Desenvolvimento para mais detalhes")
                        
                        
                      
                        
                        
                        console.log("incompleto")
                        //helper.alertaErro(cmp, event, helper, "ERRO DURANTE O ENVIO", "ENVIO INCOMPLETO", "error", "Erro: ", "sticky")
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.log("erro")
                            helper.exibirAlerta(component, event, helper, "error", "Erro!", "Ero ao atualizar status dos iteins. Entre em contao como time de Desenvolvimento para mais detalhes")
                            
                            //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO ENVIAR DOCUMENTO", "error", "Erro: ", "sticky")
                            reject(errors[0].message);
                        } else {
                            
                            helper.exibirAlerta(component, event, helper, "error", "Erro!", "Erro ao atualizar status dos iteins. Entre em contao como time de Desenvolvimento para mais detalhes")
                            
                            console.log("deu pau")
                            //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                            reject("Erro desconhecido");
                        }
                    }
                });
                
                $A.enqueueAction(action);
                
                //document.querySelectorAll(".item-requisicao").forEach((e) => {console.log(e.children[2].getAttribute("data-status"))})
                
            }else{
                if(idsList == ""){
                    helper.exibirAlerta(cmp, event, helper, "error", "Sucesso", "Selecione pelo menos um item para atualizar seu status!")
                }if(status == null){
                    helper.exibirAlerta(cmp, event, helper, "error", "Sucesso", "Selecione um status para atualizar os status de um item!")
                    return
                }else{
                }
            }
            
        });
    },
    
    exibirAlerta : function(cmp, event, helper, type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
    
    
    
})