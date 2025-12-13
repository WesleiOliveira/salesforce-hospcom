({
    data: [],
    ncmClicado: '',
    
    helperMethod : function(cmp, event, helper) {
        helper.consultaDados(cmp, event, helper)
    },
    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO-------------------------------------------------------------
    alertaErro: function (cmp, event, helper, error, title, type, tipoMensagem, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": tipoMensagem + " " + error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    //----------------------------------------------------------------------------------------------
    
    eventsAfterConsulta: function(cmp, event, helper){
        
        $( "#divBusca34895234" ).on( "click", function() {
            var tipo = $(this).attr("data-tipo")
            
            if(tipo == "Pesquisar"){
                helper.executarBusca(cmp, event, helper)
                helper.buttonChange(cmp, event, helper, 'pesquisar')
            }else{
                var codigoNCM = helper.ncmClicado
                helper.salvaNcm(cmp, event, helper, codigoNCM)
            }

        });
        
        $(document).on("click", function(event) {
            // Verifica se o clique foi fora da div resultadosncmsearch342 e fora da div divBusca34895234
            if (!$(event.target).closest("#resultadosncmsearch342").length && 
                !$(event.target).closest("#divBusca34895234").length) {
                // Se foi fora, esconde a div
                $("#resultadosncmsearch342").css("display", "none");
            }
        });
        
        //Disparar busca ao pressionar Enter no campo de entrada
        $("#divInput853497538").on("keydown", function(event) {
            helper.buttonChange(cmp, event, helper, 'pesquisar')
            if (event.key === "Enter" || event.keyCode === 13) {
                helper.executarBusca(cmp, event, helper)
            }
        }); 
    },
    
    salvaNcm : function(cmp, event, helper, codigoNCM){
        
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.atualiza"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idSolicitacao: recordId,
            codigoNCM: codigoNCM,
        });
        //--------------------------------------------------
        
        helper.alertaErro(cmp, event, helper, "", "Aguarde...", "info", "", "dismissable")

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCESSO")
                
                helper.alertaErro(cmp, event, helper, "", "NCM SALVO", "success", "", "dismissable")
                location.reload();

            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE O SALVAMENTO", "OPERAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("erro", errors[0].message)
                    
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO SALVAR O NCM", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("erro desconhecido")
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    buttonChange:function(cmp, event, helper, status){
        console.log("BUTTON CHANGE")

        if(status == 'pesquisar'){
            var html = "<i class='fa fa-search' aria-hidden='true'></i>Pesquisar"
            $("#divBusca34895234").css("background-color", "#00345c")
            $("#divBusca34895234").attr("data-tipo", "Pesquisar")
        }else{
            var html = "<i class='fa fa-search' aria-hidden='true'></i>Salvar NCM"
            $("#divBusca34895234").css("background-color", "#90c42f")
            $("#divBusca34895234").attr("data-tipo", "Salvar")
        }
        
        $("#divBusca34895234").empty().append(html)
        
        console.log("BUTTON CHANGE FIM")
        
    },
    
    executarBusca: function(cmp, event, helper){
        console.log("EXECUTANDO BUSCA")
    	const searchTerm = $("#divInput853497538").val()
            
            const searchResults = helper.data.Nomenclaturas.filter(item =>
            item.Descricao.toLowerCase().includes(searchTerm.toLowerCase())
            );
            
            var resultados = ''
            
            searchResults.forEach((element) => {
            resultados = resultados + "<div class='resultado457432' data-ncm='"+element.Codigo+"'>"+element.Codigo+" - "+element.Descricao.replaceAll("-","")+"</div>"
        });
        
        $("#resultadosncmsearch342").empty().append(resultados)
        $("#resultadosncmsearch342").css("display", "flex")
        
        $( ".resultado457432" ).off().on( "click", function() {
            var ncmClicado = $(this).attr("data-ncm")
            $("#divInput853497538").val($(this).html())
            helper.ncmClicado = ncmClicado
            $("#resultadosncmsearch342").css("display", "none")
            helper.buttonChange(cmp, event, helper, 'salvar')
        });
        console.log("EXECUTANDO BUSCA FIM")
	},
    
    consultaDados: function(cmp, event, helper){
        fetch($A.get('$Resource.ncmList'))
        .then(response => response.json())
        .then(data => {
            console.log('JSON Data: ', data);
            helper.data = data
            helper.eventsAfterConsulta(cmp, event, helper)
        })
            .catch(error => console.error('Error fetching JSON:', error));	
        }
            
            
})