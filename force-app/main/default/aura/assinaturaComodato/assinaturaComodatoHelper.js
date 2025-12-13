({
    objetoConsulta: 'Demonstracao__c',
    campoConsulta: 'Quantidade_de_ativos__c, Conta__c, Conta__r.BillingState, Conta__r.BillingCity, Conta__r.BillingCountry, Conta__r.BillingPostalCode, Conta__r.BillingStreet, Contato__c, Contato__r.Email, Contato__r.CPF__c, Contato__r.FirstName, Contato__r.LastName, Assinante2__r.MobilePhone, Assinante2__r.Name, Assinante2__r.CPF__c, Assinante2__r.Email, Validador2__r.MobilePhone, Validador2__r.Name, Validador2__r.CPF__c, Validador2__r.Email, Validador__r.MobilePhone, Validador__r.Name, Validador__r.CPF__c, Validador__r.Email, Fase__c, Testemunha__c, Testemunha__r.FirstName, Testemunha__r.LastName, Testemunha__r.Email, Testemunha__r.CPF__c, idDocAutentique__c, StatusAssinatura__c',
    
    mainFunction: function(cmp, event, helper){
        console.log("main function")
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
        console.log("QUERY VERIFICA ENVIO: ", query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (idsAutentique) {
            console.log("IDS CLICKSIGN", idsAutentique)
            
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
                    //OCULTA O CONTAINER COM OS STATUS DA ASSINATURA
                    $(".containerPrincipalAssinatura").hide()
                    
                    console.log(resultado)
                    
                    if(resultado.Quantidade_de_ativos__c == false){
                        $("#enviaAssinatura").attr("disabled", "disabled")
                    }
                    
                    //VERIFICA SE EXISTE FIADOR
                    if(resultado.hasOwnProperty('Testemunha__r')){
                        var nomeTestemunha = resultado.Testemunha__r.FirstName + " " + resultado.Testemunha__r.LastName;
                        var emailTestemunha = resultado.Testemunha__r.Email;
                        var cpfTestemunha = resultado.Testemunha__r.CPF__c;
                        var idTestemunha = resultado.Testemunha__c
                        }else{
                            var nomeTestemunha = "";
                            var emailTestemunha = "";
                            var cpfTestemunha = "";
                            var idTestemunha = "";
                        }
                    
                    //VERIFICA ENDEREÇO CONTA
                    if(resultado.hasOwnProperty('Conta__c')){
                        var contaCidade = resultado.Conta__r.BillingCity;
                        var contaPais = resultado.Conta__r.BillingCountry;
                        var contaCEP = resultado.Conta__r.BillingPostalCode;
                        var contaRua = resultado.Conta__r.BillingStreet;
                        var contaEstado = resultado.Conta__r.BillingState;
                    }else{
                        var contaCidade = "";
                        var contaPais = "";
                        var contaCEP = "";
                        var contaRua = "";
                        var contaEstado  = "";
                    }
                    
                    //VERIFICA CONTATO
                    if(resultado.hasOwnProperty('Contato__c')){
                        var contatoCPF = resultado.Contato__r.CPF__c;
                        var contatoEmail = resultado.Contato__r.Email;
                        var contatoSobrenome = resultado.Contato__r.LastName;
                        var contatoNome = resultado.Contato__r.FirstName;
                    }else{
                        var contatoCPF = "";
                        var contatoEmail = "";
                        var contatoSobrenome = "";
                        var contatoNome = "";
                    }
                    
                    //VERIFICA SE EXISTE VALIDADOR
                    if(resultado.hasOwnProperty('Validador__c')){
                        var idValidador = resultado.Validador__c
                        var nomeValidador = resultado.Validador__r.Name;
                        var cpfValidador = resultado.Validador__r.CPF__c;
                        var emailValidador = resultado.Validador__r.Email;
                        var celularValidador = resultado.Validador__r.MobilePhone;
                    }else{
                        var idValidador = ""
                        var nomeValidador = "";
                        var cpfValidador = "";
                        var emailValidador = "";
                        var celularValidador = "";
                    }
                    
                    //VERIFICA SE EXISTE VALIDADOR 2
                    if(resultado.hasOwnProperty('Validador2__c')){
                        var idValidador2 = resultado.Validador2__c
                        var nomeValidador2 = resultado.Validador2__r.Name;
                        var cpfValidador2 = resultado.Validador2__r.CPF__c;
                        var emailValidador2 = resultado.Validador2__r.Email;
                        var celularValidador2 = resultado.Validador2__r.MobilePhone;
                    }else{
                        var idValidador2 = ""
                        var nomeValidador2 = "";
                        var cpfValidador2 = "";
                        var emailValidador2 = "";
                        var celularValidador2 = "";
                    }
                    
                    //VERIFICA SE EXISTE ASSINANTE 2
                    if(resultado.hasOwnProperty('Assinante2__c')){
                        var idAssinante2 = resultado.Assinante2__c
                        var nomeAssinante2 = resultado.Assinante2__r.Name;
                        var cpfAssinante2 = resultado.Assinante2__r.CPF__c;
                        var emailAssinante2 = resultado.Assinante2__r.Email;
                        var celularAssinante2 = resultado.Assinante2__r.MobilePhone;
                    }else{
                        var idAssinante2 = ""
                        var nomeAssinante2 = "";
                        var cpfAssinante2 = "";
                        var emailAssinante2 = "";
                        var celularAssinante2 = "";
                    }
                    
                    
                    //OUVINTE DO CLICK NO BOTAO
                    $("#enviaAssinatura").off().on( "click", function() {
                        helper.confirmaEnvio(
                            cmp, 
                            event, 
                            helper, 
                            recordId, 
                            idTestemunha,
                            idAssinante2, 
                            nomeAssinante2, 
                            cpfAssinante2, 
                            emailAssinante2, 
                            celularAssinante2, 
                            idValidador2, 
                            nomeValidador2, 
                            cpfValidador2, 
                            emailValidador2, 
                            celularValidador2, 
                            idValidador, 
                            nomeValidador, 
                            cpfValidador, 
                            emailValidador, 
                            celularValidador, 
                            contaCidade, 
                            contaPais, 
                            contaCEP, 
                            contaRua, 
                            contaEstado, 
                            cpfTestemunha, 
                            nomeTestemunha,
                            emailTestemunha,
                            contatoCPF,
                            contatoEmail,
                            contatoSobrenome,
                            contatoNome
                        )
                    });
                    
                }
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    confirmaEnvio: function(cmp, event, helper, recordId, idTestemunha, idAssinante2, nomeAssinante2, cpfAssinante2, emailAssinante2, celularAssinante2, idValidador2, nomeValidador2, cpfValidador2, emailValidador2, celularValidador2, idValidador, nomeValidador, cpfValidador, emailValidador, celularValidador, contaCidade, contaPais, contaCEP, contaRua, contaEstado, cpfTestemunha, nomeTestemunha, emailTestemunha, contatoCPF, contatoEmail, contatoSobrenome, contatoNome){
        
        var textoConfirma = "<h5>Destinatários</h5>";
        
        console.log("confirmando envio")
        console.log("CONTATO", contatoCPF + contatoEmail + contatoSobrenome + contatoNome)
        //console.log("fiador", fiador + emailFiador + cpfFiador + idFiador)
        //console.log("conjuge", conjugue + emailConjugue + cpfConjugue)
        console.log("testemunha", nomeTestemunha + emailTestemunha + cpfTestemunha)
        
        if(!cpfTestemunha){
            var query = "select cpf__c from dados_colaborador__c where Contato__c = '"+idTestemunha+"'"
            
            console.log(query)
            
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (dadosColaborador) {
                
                cpfTestemunha = dadosColaborador[0].CPF__c
                
                //VALIDA DADOS DA TESTEMUNHA
                if(nomeTestemunha == "" || emailTestemunha == "" || cpfTestemunha == "" || nomeTestemunha == undefined || emailTestemunha == undefined || cpfTestemunha == undefined){
                    alert("Dados da testemunha incorretos");
                    return;
                }else{
                    textoConfirma = textoConfirma.concat("<br>Testemunha: <br>"+nomeTestemunha+" - "+emailTestemunha);
                }
                
                //VALIDA ENDEREÇO DA CONTA DO CLIENTE
                if(contaCidade == "" || contaPais == "" || contaCEP == "" || contaRua == "" || contaEstado == "" || contaCidade == undefined || contaPais == undefined || contaCEP == undefined || contaRua == undefined || contaEstado == undefined){
                    alert("Dados incorretos, o endereço da conta do cliente está incompleto");
                    return
                }
                
                //VALIDA CONTATO ASSINANTE
                if(contatoCPF == "" || contatoEmail == "" || contatoSobrenome == "" || contatoNome == "" || contatoSobrenome == undefined || contatoEmail == undefined || contatoCPF == undefined || contatoNome == undefined){
                    alert("Dados incorretos, os dados do contato assinante estão incompletos");
                    return
                }else{
                    textoConfirma = textoConfirma.concat("<br><br>Contato: <br>"+contatoNome+" - "+contatoEmail);
                }
                
                //VALIDA VALIDADOR 1
                if(idValidador){
                    if(nomeValidador == "" || cpfValidador == "" || emailValidador == "" || nomeValidador == undefined || emailValidador == undefined || cpfValidador == undefined){
                        alert("Dados incorretos, o nome, cpf, email e celular do Validador devem estar preenchidos");
                        return
                    }else{
                        textoConfirma = textoConfirma.concat("<br><br>Validador: <br>"+nomeValidador+" - "+emailValidador);
                    }
                }
                
                //VALIDA VALIDADOR 2
                if(idValidador2){
                    if(nomeValidador2 == "" || cpfValidador2 == "" || emailValidador2 == "" || nomeValidador2 == undefined || emailValidador2 == undefined || cpfValidador2 == undefined){
                        alert("Dados incorretos, o nome, cpf, email e celular do Validador 2 devem estar preenchidos");
                        return
                    }else{
                        textoConfirma = textoConfirma.concat("<br><br>Validador 2: <br>"+nomeValidador2+" - "+emailValidador2);
                    }
                }
                
                //VALIDA ASSINANTE 2
                if(idAssinante2){
                    if(nomeAssinante2 == "" || cpfAssinante2 == "" || emailAssinante2 == "" || nomeAssinante2 == undefined || cpfAssinante2 == undefined || emailAssinante2 == undefined){
                        alert("Dados incorretos, o nome, cpf, email e celular do Assinante 2 devem estar preenchidos");
                        return
                    }else{
                        textoConfirma = textoConfirma.concat("<br><br>Assinante 2: <br>"+nomeAssinante2+" - "+emailAssinante2);
                    }
                }
                
                $("#destinatarios").empty().append(textoConfirma)
                $("#modalConfirma").css("display", "flex");
                
                $("#closeModal").click(function(){
                    $("#modalConfirma").css("display", "none");
                });
                
                $("#enviarContrato").off().one("click", function(){
                    $("#modalConfirma").css("display", "none");
                    helper.enviaAssinatura(cmp, event, helper, recordId);
                });
                
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        }else{
            //VALIDA DADOS DA TESTEMUNHA
            if(nomeTestemunha == "" || emailTestemunha == "" || cpfTestemunha == "" || nomeTestemunha == undefined || emailTestemunha == undefined || cpfTestemunha == undefined){
                alert("Dados da testemunha incorretos");
                return;
            }else{
                textoConfirma = textoConfirma.concat("<br>Testemunha: <br>"+nomeTestemunha+" - "+emailTestemunha);
            }
            
            //VALIDA ENDEREÇO DA CONTA DO CLIENTE
            if(contaCidade == "" || contaPais == "" || contaCEP == "" || contaRua == "" || contaEstado == "" || contaCidade == undefined || contaPais == undefined || contaCEP == undefined || contaRua == undefined || contaEstado == undefined){
                alert("Dados incorretos, o endereço da conta do cliente está incompleto");
                return
            }
            
            //VALIDA CONTATO ASSINANTE
            if(contatoCPF == "" || contatoEmail == "" || contatoSobrenome == "" || contatoNome == "" || contatoSobrenome == undefined || contatoEmail == undefined || contatoCPF == undefined || contatoNome == undefined){
                alert("Dados incorretos, os dados do contato assinante estão incompletos");
                return
            }else{
                textoConfirma = textoConfirma.concat("<br><br>Contato: <br>"+contatoNome+" - "+contatoEmail);
            }
            
            //VALIDA VALIDADOR 1
            if(idValidador){
                if(nomeValidador == "" || cpfValidador == "" || emailValidador == "" || nomeValidador == undefined || emailValidador == undefined || cpfValidador == undefined){
                    alert("Dados incorretos, o nome, cpf, email e celular do Validador devem estar preenchidos");
                    return
                }else{
                    textoConfirma = textoConfirma.concat("<br><br>Validador: <br>"+nomeValidador+" - "+emailValidador);
                }
            }
            
            //VALIDA VALIDADOR 2
            if(idValidador2){
                if(nomeValidador2 == "" || cpfValidador2 == "" || emailValidador2 == "" || nomeValidador2 == undefined || emailValidador2 == undefined || cpfValidador2 == undefined){
                    alert("Dados incorretos, o nome, cpf, email e celular do Validador 2 devem estar preenchidos");
                    return
                }else{
                    textoConfirma = textoConfirma.concat("<br><br>Validador 2: <br>"+nomeValidador2+" - "+emailValidador2);
                }
            }
            
            //VALIDA ASSINANTE 2
            if(idAssinante2){
                if(nomeAssinante2 == "" || cpfAssinante2 == "" || emailAssinante2 == "" || nomeAssinante2 == undefined || cpfAssinante2 == undefined || emailAssinante2 == undefined){
                    alert("Dados incorretos, o nome, cpf, email e celular do Assinante 2 devem estar preenchidos");
                    return
                }else{
                    textoConfirma = textoConfirma.concat("<br><br>Assinante 2: <br>"+nomeAssinante2+" - "+emailAssinante2);
                }
            }
            
            $("#destinatarios").empty().append(textoConfirma)
            $("#modalConfirma").css("display", "flex");
            
            $("#closeModal").click(function(){
                $("#modalConfirma").css("display", "none");
            });
            
            $("#enviarContrato").off().one("click", function(){
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
        var action = cmp.get("c.enviarComodato");
        
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
        var steps = ['Assinatura do cliente', 'Aprovação financeira', 'Assinatura do administrador', 'Assinaturas finalizadas']
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
            helper.consultaSignatarios(cmp, event, helper, fase);
        });
    },
    
    consultaSignatarios: function(cmp, event, helper, fase){
        
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO
        var action = cmp.get("c.consultarComodato");
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
                
                console.log(signatarios);
                
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
    var action = cmp.get("c.consultarComodato");
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
            var action = cmp.get("c.cancelarComodato");
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