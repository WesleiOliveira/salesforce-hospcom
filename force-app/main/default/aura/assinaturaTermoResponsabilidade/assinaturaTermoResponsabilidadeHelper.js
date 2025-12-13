({
    objetoConsulta: 'asset',
    campoConsulta: 'usuarioResponsavel__r.Contact.CPF__c, usuarioResponsavel__r.Contact.Email, usuarioResponsavel__r.Contact.LastName, usuarioResponsavel__r.Contact.FirstName, ContatoReponsavel__c, ContatoReponsavel__r.CPF__c, ContatoReponsavel__r.Email, ContatoReponsavel__r.LastName, ContatoReponsavel__r.FirstName, StatusAssinatura__c, idDocAutentique__c, RecordTypeId, usuarioResponsavel__c',
    //campoConsulta: 'Contact.CPF__c, Fase__c, Conjuge_do_fiador__r.CPF__pc, Fiador__r.CPF__pc, Testemunha__r.CPF__c, ContactId, idDocAutentique__c, StatusAssinatura__c, Contact.FirstName, Contact.LastName, Contact.Email, Testemunha__r.FirstName, Testemunha__r.LastName,  Testemunha__r.Email, Fiador__r.Name, Fiador__r.PersonEmail, Conjuge_do_fiador__c, Conjuge_do_fiador__r.PersonEmail, Conjuge_do_fiador__r.Name',
    tipoRegistroAtivo: "01231000000tbAgAAI",
    
    mainFunction: function(cmp, event, helper){
        helper.verificaEnvio(cmp, event, helper)
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    showSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "flex");
    },
    //-------------------------------------------
    
    //FUNÇÃO QUE OCULTA O SPINNER DE CARREGAMENTO-  
    hideSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "none");
    },
    //--------------------------------------------
    
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
    
    verificaEnvio: function(cmp, event, helper){
        
        var recordId = cmp.get("v.recordId")
        var query = "SELECT " + helper.campoConsulta + " FROM "+ helper.objetoConsulta +" WHERE id = '"+recordId+"'"
        
        //console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (idsAutentique) {
            
            idsAutentique.forEach(function(resultado){
                
                //console.log("resultado", resultado)
                
                if(String(resultado.RecordTypeId) == String(helper.tipoRegistroAtivo)){
                    ////console.log("é demo")
                    //se existe id do autentique, logo o fluxo de assinatura ja foi iniciado
                    //oculta o botao de envio
                    if(resultado.hasOwnProperty('idDocAutentique__c')){
                        
                        //EXISTE ID DE ASSINATURA, OCULTA BOTAO
                        $(".divButton").hide()
                        
                        //RECUPERA O STATUS DA ASSINATURA
                        var statusAssinatura = resultado.StatusAssinatura__c
                        
                        var fase = resultado.Fase__c
                        
                        if(fase == "Recusado"){
                            $("#assinaturaCancelada").show()
                        }
                        
                        //CHAMA FUNCAO PARA PROCESSAR A VISUALIZACAO DA PROGRESSBAR
                        helper.preencheVisualizacao(cmp, event, helper, statusAssinatura)
                        
                    }else{
                        //OCULTA O CONTAINER COM OS STATUS DA ASSINATURA
                        $(".containerPrincipalAssinatura").hide()
                        
                        //OUVINTE DO CLICK NO BOTAO
                        $("#enviaAssinatura").off().on( "click", function() {
                            helper.consultaInfos(cmp, event, helper)
                        });
                        
                    }
                }else{
                    //CASO O TIPO DE REGISTRO NAO SEJA COMPATÍVEL, OCULTA TODO COMPONENTE
                    $("#divPrincipal").hide()
                    //$(".divButton").hide()
                }
                
                
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            //console.log(error)
        })
    },
    
    consultaInfos: function(cmp, event, helper){
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        var recordId = cmp.get("v.recordId")
        var query = "SELECT " + helper.campoConsulta + " FROM "+ helper.objetoConsulta +" WHERE id = '"+recordId+"'"
        //console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (idsAutentique) {
            
            idsAutentique.forEach(function(resultado){
                                
                //OCULTA O CONTAINER COM OS STATUS DA ASSINATURA
                $(".containerPrincipalAssinatura").hide()
                
                if(resultado.hasOwnProperty('usuarioResponsavel__c')){
                    var nomeResponsavel = resultado.usuarioResponsavel__r.Contact.FirstName + " " +resultado.usuarioResponsavel__r.Contact.LastName;
                    var emailResponsavel = resultado.usuarioResponsavel__r.Contact.Email;
                    var cpfResponsavel = resultado.usuarioResponsavel__r.Contact.CPF__c;
                }else{
                    var nomeResponsavel = resultado.ContatoReponsavel__r.FirstName + " " +resultado.ContatoReponsavel__r.LastName;
                    var emailResponsavel = resultado.ContatoReponsavel__r.Email;
                    var cpfResponsavel = resultado.ContatoReponsavel__r.CPF__c;
                }
                
                //console.log(resultado)
                
                //Exibe Spinner de carregamento
                helper.hideSpinner(cmp);
                
                helper.confirmaEnvio(cmp, event, helper, recordId, nomeResponsavel,emailResponsavel,cpfResponsavel)
                
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            //console.log(error)
        })
    },
    
    confirmaEnvio: function(cmp, event, helper, recordId, nomeResponsavel,emailResponsavel,cpfResponsave){
        
        
        var textoConfirma = "<h5>Destinatários</h5>Responsavel: <br>" + nomeResponsavel+" - "+emailResponsavel
        var textoConfirmaConcat = ""
        
        //console.log("confirmando envio")
        //console.log("responsavel", nomeResponsavel + emailResponsavel + cpfResponsave)
        
        
        $("#destinatarios").empty().append(textoConfirma)
        $("#modalConfirma").css("display", "flex");
        
        $("#closeModal").click(function(){
            $("#modalConfirma").css("display", "none");
        });
        
        $("#enviarContrato").click(function(){
            $("#modalConfirma").css("display", "none");
            helper.enviaAssinatura(cmp, event, helper, recordId);
        });        
      
        
    },
    
    enviaAssinatura: function(cmp, event, helper, recordId){
        
        //console.log("enviando assinatura")

        
        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.enviarTermo");
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idContrato: recordId
        });
        //----------------------------------------------------
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.hideSpinner(cmp);
                helper.alertaErro(cmp, event, helper, "DOCUMENTO ENVIADO PRA ASSINATURA!", "SUCESSO", "success", "Operação concluída!", "dismissable")
                window.location.reload()
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE O ENVIO", "ENVIO INCOMPLETO", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO ENVIAR DOCUMENTO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //RECEBE O STATUS DA ASSINATURA, E GERA A PROGRESSBAR
    preencheVisualizacao: function(cmp, event, helper, statusAssinatura){
        var statusAtual = statusAssinatura
        var steps = ['Aguardando assinatura', 'Assinado']
        var indiceEdicaoSteps = steps.findIndex(v => v == statusAtual)
        
        steps[indiceEdicaoSteps] = '@' + steps[indiceEdicaoSteps]
        
        //INSTANCIA A BARRA DE PROGRESSO
        $('#steps').progressbar({
            steps: steps
        });
        
        if(statusAtual == "Assinado"){
            $("#buttonDownload").removeAttr("disabled");
        }
        
        helper.eventsAfterPreenche(cmp, event, helper);
        
    },
    
    eventsAfterPreenche: function(cmp, event, helper){
        
        //EVENTO DE CLIQUE NO BOTAO DOWNLOAD
        $("#buttonDownload").click(function(){
            helper.downloadDocumento(cmp, event, helper);
        });
        
        //EVENTO DE CLIQUE NO BOTAO DOWNLOAD
        $("#buttonCancela").click(function(){
            helper.cancelaDocumento(cmp, event, helper);
        });
        
        $(".current").on("click", function(){
            
            var fase = $(this).html()
            helper.consultaSignatarios(cmp, event, helper, fase);
        });
    },
    
    consultaSignatarios: function(cmp, event, helper, fase){
        
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO
        var action = cmp.get("c.consultarTermo");
        var recordId = cmp.get("v.recordId")
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX-----
        action.setParams({
            idContrato: recordId
        });
        //----------------------------------------------------
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respostaJson = JSON.parse(response.getReturnValue());
                var signatarios = respostaJson.document.signers;
                
                //console.log(signatarios);
                
                switch(fase) {
                    case "Assinatura do cliente":
                        var faseNum = 1;
                        break;
                    case "Aprovação financeira":
                        var faseNum = 2;
                        break;
                    case "Assinatura do administrador":
                        var faseNum = 3;
                        break;
                    default:
                        var faseNum = 0;
                        //console.log("ERROR SWITCH CASE")
                        break;
                };
                
                const agrupadoPorGrupo = signatarios.reduce((agrupado, elemento) => {
                    if (!agrupado[elemento.group]) {
                    agrupado[elemento.group] = [];
                };
                                                            agrupado[elemento.group].push(elemento);
                return agrupado;
            }, {});
            
            
            //console.log(agrupadoPorGrupo);
            //console.log(agrupadoPorGrupo[faseNum]);
            
            //LIMPA OS DADOS DO MODAL E ADICIONA NOVAMENTE
            $("#bodyModalFase").empty()
            
            for (key in agrupadoPorGrupo[faseNum]) {
                if(agrupadoPorGrupo[faseNum][key].hasOwnProperty("signature")){var status = " -> ASSINADO"}else{var status = " -> NÃO ASSINADO"}
                
                $("#bodyModalFase").append(agrupadoPorGrupo[faseNum][key].name + status + "<br>")
            }
            
            //EXIBE O MODAL
            $("#modalStatusFase").css("display", "flex");
            
            //EVENTO DE CLIQUE NO BOTAO FECHAR
            $("#closeModalFase").click(function(){
                $("#modalStatusFase").css("display", "none");
            });
            

            
            
            
            helper.hideSpinner(cmp);
                //helper.alertaErro(cmp, event, helper, "DOCUMENTO CANCELADO!", "SUCESSO", "success", "Operação concluída!", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE O CANCELAMENTO", "CANCELAMENTO INCOMPLETO", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CANCELAR DOCUMENTO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    downloadDocumento: function(cmp, event, helper){
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO
        var action = cmp.get("c.consultarTermo");
        var recordId = cmp.get("v.recordId")
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX-----
        action.setParams({
            idContrato: recordId
        });
        //----------------------------------------------------
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respostaJson = JSON.parse(response.getReturnValue())
                
                if(respostaJson.document.downloads.hasOwnProperty('signed_file_url')){
                    var link = respostaJson.document.downloads.signed_file_url
                    var win = window.open(link, '_blank');
                    win.focus();
                }
                
                helper.hideSpinner(cmp);
                //helper.alertaErro(cmp, event, helper, "DOCUMENTO CANCELADO!", "SUCESSO", "success", "Operação concluída!", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE O CANCELAMENTO", "CANCELAMENTO INCOMPLETO", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CANCELAR DOCUMENTO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    cancelaDocumento: function(cmp, event, helper){
        if (confirm("Deseja mesmo cancelar a assinatura deste documento?")) {
            
            //Exibe Spinner de carregamento
            helper.showSpinner(cmp);
            
            //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
            var action = cmp.get("c.cancelarTermo");
            var recordId = cmp.get("v.recordId")
            
            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                idContrato: recordId
            });
            //----------------------------------------------------
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.hideSpinner(cmp);
                    helper.alertaErro(cmp, event, helper, "DOCUMENTO CANCELADO!", "SUCESSO", "success", "Operação concluída!", "dismissable")
                	window.location.reload()
                }
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE O CANCELAMENTO", "CANCELAMENTO INCOMPLETO", "error", "Erro: ", "sticky")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CANCELAR DOCUMENTO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
        } 
        
    },
    
    alertaErro: function (cmp, event, helper, title, tipoMensagem, type) {
        //console.log("exibindo erro")
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": tipoMensagem,
            "type": type,
            "mode": 'sticky'
        });
        toastEvent.fire();
    },
    
})