({
    objetoConsulta: 'Aditivo_do_Contrato_de_Compra__c	',
    campoConsulta: 'Contrato_de_Compra__r.Aprovado__c, Contrato_de_Compra__r.Assinante__r.MobilePhone, Contrato_de_Compra__r.Assinante__r.Name, Contrato_de_Compra__r.Assinante__r.CPF__c, Contrato_de_Compra__r.Assinante__r.Email, idDocAutentique__c, Fase__c, StatusAssinatura__c, Contrato_de_Compra__r.Testemunha__r.CPF__c, Contrato_de_Compra__r.Testemunha__r.Email, Contrato_de_Compra__r.Testemunha__r.LastName, Contrato_de_Compra__r.Testemunha__c, Contrato_de_Compra__r.Testemunha__r.FirstName',
    
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
        console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (idsAutentique) {
            
            idsAutentique.forEach(function(resultado){
                
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
                    if(resultado.Contrato_de_Compra__r.Aprovado__c == false){
                        $("#enviaAssinatura").attr("disabled", "disabled")
                    }
                    
                    //OCULTA O CONTAINER COM OS STATUS DA ASSINATURA
                    $(".containerPrincipalAssinatura").hide()
                    
                    //OUVINTE DO CLICK NO BOTAO
                    $("#enviaAssinatura").off().on( "click", function() {
                        helper.consultaInfos(cmp, event, helper)
                    });
                    
                }
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    consultaInfos: function(cmp, event, helper){
        
        var recordId = cmp.get("v.recordId")
        var query = "SELECT " + helper.campoConsulta + " FROM "+ helper.objetoConsulta +" WHERE id = '"+recordId+"'"
        
        console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (idsAutentique) {
            
            idsAutentique.forEach(function(resultado){
                                
                //OCULTA O CONTAINER COM OS STATUS DA ASSINATURA
                $(".containerPrincipalAssinatura").hide()
                
                console.log(resultado)
                
                //VERIFICA SE EXISTE FIADOR
                if(resultado.Contrato_de_Compra__r.hasOwnProperty('Testemunha__r')){
                    var idTestemunha = resultado.Contrato_de_Compra__r.Testemunha__c;
                    var nomeTestemunha = resultado.Contrato_de_Compra__r.Testemunha__r.FirstName + " " + resultado.Contrato_de_Compra__r.Testemunha__r.LastName;
                    var emailTestemunha = resultado.Contrato_de_Compra__r.Testemunha__r.Email;
                    var cpfTestemunha = resultado.Contrato_de_Compra__r.Testemunha__r.CPF__c;
                }else{
                    var idTestemunha = "";
                    var nomeTestemunha = "";
                    var emailTestemunha = "";
                    var cpfTestemunha = "";
                }
                
                //VERIFICA SE EXISTE ASSINANTE 2
                if(resultado.Contrato_de_Compra__r.hasOwnProperty('Assinante__c')){
                    var idAssinante2 = resultado.Contrato_de_Compra__r.Assinante__c
                    var nomeAssinante2 = resultado.Contrato_de_Compra__r.Assinante__r.Name;
                    var cpfAssinante2 = resultado.Contrato_de_Compra__r.Assinante__r.CPF__c;
                    var emailAssinante2 = resultado.Contrato_de_Compra__r.Assinante__r.Email;
                    var celularAssinante2 = resultado.Contrato_de_Compra__r.Assinante__r.MobilePhone;
                }else{
                    var idAssinante2 = ""
                    var nomeAssinante2 = "";
                    var cpfAssinante2 = "";
                    var emailAssinante2 = "";
                    var celularAssinante2 = "";
                }
                
                helper.confirmaEnvio(cmp, event, helper, recordId, idAssinante2, nomeAssinante2, cpfAssinante2, emailAssinante2, celularAssinante2, idTestemunha, nomeTestemunha, emailTestemunha, cpfTestemunha)
                
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    confirmaEnvio: function(cmp, event, helper, recordId, idAssinante2, nomeAssinante2, cpfAssinante2, emailAssinante2, celularAssinante2, idTestemunha, nomeTestemunha, emailTestemunha, cpfTestemunha){
        

        
        console.log("confirmando envio")
        console.log("assinante", nomeAssinante2 + cpfAssinante2 + emailAssinante2)
        console.log("testemunha", nomeTestemunha + emailTestemunha + cpfTestemunha)
        
        var textoConfirma = "<h5>Destinatários</h5>";
        //var textoConfirmaConcat = ""
        
        if(!cpfTestemunha){
            var query = "select cpf__c from dados_colaborador__c where Contato__c = '"+idTestemunha+"'"
            
            console.log(query)
            
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (dadosColaborador) {
                
                cpfTestemunha = dadosColaborador[0].CPF__c
                //VALIDA ASSINANTE 2
                if(idAssinante2){
                    if(nomeAssinante2 == "" || cpfAssinante2 == "" || emailAssinante2 == "" || nomeAssinante2 == undefined || cpfAssinante2 == undefined || emailAssinante2 == undefined){
                        alert("Dados incorretos, o nome, cpf, email e celular do Assinante 2 devem estar preenchidos");
                        return
                    }else{
                        textoConfirma = textoConfirma.concat("<br><br>Assinante: <br>"+nomeAssinante2+" - "+emailAssinante2+" - "+celularAssinante2);
                    }
                }
                
                //VALIDA ASSINANTE 2
                if(idTestemunha){
                    if(nomeTestemunha == "" || emailTestemunha == "" || cpfTestemunha == "" || nomeTestemunha == undefined || emailTestemunha == undefined || cpfTestemunha == undefined){
                        alert("Dados incorretos, o nome, cpf, email e celular da Testemunha devem estar preenchidos");
                        return
                    }else{
                        textoConfirma = textoConfirma.concat("<br><br>Testemunha: <br>"+nomeTestemunha+" - "+emailTestemunha+" - "+cpfTestemunha);
                    }
                }
                
                $("#destinatarios").empty().append(textoConfirma)
                $("#modalConfirma").css("display", "flex");
                
                $("#closeModal").click(function(){
                    $("#modalConfirma").css("display", "none");
                });
                
                $("#enviarButtonClick").off().one("click", function(){
                    console.log("CLICADO")
                    $("#modalConfirma").css("display", "none");
                    helper.enviaAssinatura(cmp, event, helper, recordId);
                });
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        }else{
            //VALIDA ASSINANTE 2
            if(idAssinante2){
                if(nomeAssinante2 == "" || cpfAssinante2 == "" || emailAssinante2 == "" || nomeAssinante2 == undefined || cpfAssinante2 == undefined || emailAssinante2 == undefined){
                    alert("Dados incorretos, o nome, cpf, email e celular do Assinante 2 devem estar preenchidos");
                    return
                }else{
                    textoConfirma = textoConfirma.concat("<br><br>Assinante: <br>"+nomeAssinante2+" - "+emailAssinante2+" - "+celularAssinante2);
                }
            }
            
            //VALIDA ASSINANTE 2
            if(idTestemunha){
                if(nomeTestemunha == "" || emailTestemunha == "" || cpfTestemunha == "" || nomeTestemunha == undefined || emailTestemunha == undefined || cpfTestemunha == undefined){
                    alert("Dados incorretos, o nome, cpf, email e celular da Testemunha devem estar preenchidos");
                    return
                }else{
                    textoConfirma = textoConfirma.concat("<br><br>Testemunha: <br>"+nomeTestemunha+" - "+emailTestemunha+" - "+cpfTestemunha);
                }
            }
            
            $("#destinatarios").empty().append(textoConfirma)
            $("#modalConfirma").css("display", "flex");
            
            $("#closeModal").click(function(){
                $("#modalConfirma").css("display", "none");
            });
            
            $("#enviarButtonClick").off().one("click", function(){
                console.log("CLICADO")
                $("#modalConfirma").css("display", "none");
                helper.enviaAssinatura(cmp, event, helper, recordId);
            });
        }
    },
    
    enviaAssinatura: function(cmp, event, helper, recordId){
        
        console.log("enviando assinatura")
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.enviarAditivoCompra");
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idContrato: recordId,
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
        var steps = ['Assinatura do prestador', 'Aprovação jurídica', 'Assinatura do administrador', 'Assinaturas finalizadas']     
        var indiceEdicaoSteps = steps.findIndex(v => v == statusAtual)
        
        steps[indiceEdicaoSteps] = '@' + steps[indiceEdicaoSteps]
        
        //INSTANCIA A BARRA DE PROGRESSO
        $('#steps').progressbar({
            steps: steps
        });
        
        if(statusAtual == "Assinaturas finalizadas"){
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
            console.log(fase)
            helper.consultaSignatarios(cmp, event, helper, fase);
        });
    },
    
    consultaSignatarios: function(cmp, event, helper, fase){
        
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO
        var action = cmp.get("c.consultarAditivoCompra");
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
                
                switch(fase) {
                    case "Assinatura do prestador":
                        var faseNum = 1;
                        break;
                    case "Aprovação jurídica":
                        var faseNum = 2;
                        break;
                    case "Assinatura do administrador":
                        var faseNum = 3;
                        break;
                    default:
                        var faseNum = 0;
                        console.log("ERROR SWITCH CASE")
                        break;
                };
                
                const agrupadoPorGrupo = signatarios.reduce((agrupado, elemento) => {
                    if (!agrupado[elemento.group]) {
                    agrupado[elemento.group] = [];
                };
                                                            agrupado[elemento.group].push(elemento);
                return agrupado;
            }, {});
            
            
            console.log(agrupadoPorGrupo);
            console.log(agrupadoPorGrupo[faseNum]);
            
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
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A CONSULTA", "CONSULTA INCOMPLETO", "error", "Erro: ", "sticky")
        		helper.hideSpinner(cmp);    
        	} else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CONSULTAR", "error", "Erro: ", "sticky")
                    helper.hideSpinner(cmp);
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                    helper.hideSpinner(cmp);
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
        var action = cmp.get("c.consultarAditivoCompra");
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
            var action = cmp.get("c.cancelarAditivoCompra");
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
        console.log("exibindo erro")
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