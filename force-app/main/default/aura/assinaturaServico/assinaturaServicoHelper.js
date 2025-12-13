({
    objetoConsulta: 'WorkOrder',
    campoConsulta: 'Assinante2__r.MobilePhone, Assinante2__r.Name, Assinante2__r.CPF__c, Assinante2__r.Email, Validador2__r.MobilePhone, Validador2__r.Name, Validador2__r.CPF__c, Validador2__r.Email, Validador__r.MobilePhone, Validador__r.Name, Validador__r.CPF__c, Validador__r.Email, Account.Billingcountry, Account.BillingCity, Account.Billingstate, Account.Billingpostalcode, Account.BillingStreet, A_Clausula2__c, idDocAutentique__c, Fase__c, StatusAssinatura__c, Faturamento_Feito2__c, AccountId, Data_de_validade__c, Data_de_emissao__c, Prazo_de_garantia__c, Prazo_de_Entrega__c, Condicao_de_pagamento__c, Frete2__c, Forma_de_pagamento2__c, Testemunha__r.CPF__c, Testemunha__r.Email, Testemunha__r.LastName, Testemunha__c, Testemunha__r.FirstName, Signatario__r.CPF__c, Signatario__r.FirstName, Signatario__r.LastName, Signatario__r.Email, Signatario__c',
    
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
        
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#modalConfirma').click()
        helper.showSpinner(cmp)
        
        this.soql(cmp, query)

        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (idsAutentique) {
            //helper.alertaErro(cmp, event, helper, "", "Carregando...", "info", "", "")
            
            idsAutentique.forEach(function(resultado){
                
                //OCULTA O CONTAINER COM OS STATUS DA ASSINATURA
                $(".containerPrincipalAssinatura").hide()
                
                //console.log(resultado)
                
                //VARIAVEIS DOS SIGNATARIOS
                var nomeCliente = resultado.Signatario__r.FirstName + " " + resultado.Signatario__r.LastName
                var emailCliente = resultado.Signatario__r.Email
                var cpfCliente = resultado.Signatario__r.CPF__c
                
                //VERIFICA SE EXISTE FIADOR
                if(resultado.hasOwnProperty('Testemunha__r')){
                    var nomeTestemunha = resultado.Testemunha__r.FirstName + " " + resultado.Testemunha__r.LastName;
                    var emailTestemunha = resultado.Testemunha__r.Email;
                    var cpfTestemunha = resultado.Testemunha__r.CPF__c;
                }else{
                    var nomeTestemunha = "";
                    var emailTestemunha = "";
                    var cpfTestemunha = "";
                }
                
                //VERIFICA SE EXISTE CONTA
                if(resultado.hasOwnProperty('Account')){
                    var contaCidade = resultado.Account.BillingCity;
                    var contaPais = resultado.Account.BillingCountry;
                    var contaCEP = resultado.Account.BillingPostalCode;
                    var contaRua = resultado.Account.BillingStreet;
                    var contaEstado = resultado.Account.BillingState;
                }else{
                    var contaCidade = "";
                    var contaPais = "";
                    var contaCEP = "";
                    var contaRua = "";
                    var contaEstado  = "";
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
                
                var condicaoPagamento = resultado.Condicao_de_pagamento__c
                var FormaDePagamento = resultado.Forma_de_pagamento2__c
                var Frete = resultado.Frete2__c
                var Prazo = resultado.Prazo_de_entrega__c
                var PrazoGarantia = resultado.Prazo_de_garantia__c
                var DataEmissao = resultado.Data_de_emissao__c
                var DataValidade = resultado.Data_de_validade__c
                var idConta = resultado.AccountId
                var faturamentoFeito = resultado.Faturamento_Feito2__c
                var clausula2 = resultado.A_Clausula2__c
                
                helper.confirmaEnvio(cmp, event, helper, recordId, idAssinante2, nomeAssinante2, cpfAssinante2, emailAssinante2, celularAssinante2, idValidador2, nomeValidador2, cpfValidador2, emailValidador2, celularValidador2, idValidador, nomeValidador, cpfValidador, emailValidador, celularValidador, contaCidade, contaPais, contaCEP, contaRua, contaEstado, clausula2, Frete, faturamentoFeito, idConta, DataValidade, DataEmissao, Prazo, PrazoGarantia, condicaoPagamento, FormaDePagamento, cpfCliente, cpfTestemunha, nomeCliente,emailCliente,nomeTestemunha,emailTestemunha)
                
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
            alert("Erro: " + error)
        })
    },
    
    confirmaEnvio: function(cmp, event, helper, recordId, idAssinante2, nomeAssinante2, cpfAssinante2, emailAssinante2, celularAssinante2, idValidador2, nomeValidador2, cpfValidador2, emailValidador2, celularValidador2, idValidador, nomeValidador, cpfValidador, emailValidador, celularValidador, contaCidade, contaPais, contaCEP, contaRua, contaEstado, clausula2, Frete, faturamentoFeito, idConta, DataValidade, DataEmissao, Prazo, PrazoGarantia, condicaoPagamento, FormaDePagamento, cpfCliente, cpfTestemunha, nomeCliente, emailCliente,nomeTestemunha,emailTestemunha){
        
        var cliente = nomeCliente
        //var emailCliente = emailCliente
        
        var testemunha = nomeTestemunha
        //var emailTestemunha = emailTestemunha

        var textoConfirma = "Cliente <br>"+cliente+" - "+emailCliente+"<br><br>Testemunha <br>"+testemunha+" - "+emailTestemunha+" ";
        var textoConfirmaConcat = ""
        
        /*console.log("confirmando envio")
      	console.log("cliente", cliente + emailCliente + cpfCliente)
        console.log("testemunha", testemunha + emailTestemunha + cpfTestemunha)
        console.log("condicao de pagamento", condicaoPagamento)
        console.log("Frete", Frete)
        console.log("Prazo", Prazo)
        console.log("PrazoGarantiao", PrazoGarantia)
        console.log("DataEmissao", DataEmissao)
        console.log("DataValidade", DataValidade)
        console.log("idConta", idConta)
        console.log("clausula2", clausula2)
        console.log("faturamentoFeito", faturamentoFeito) */
        
        //VALIDA ENDEREÇO DA CONTA DO CLIENTE
        if(contaCidade == "" || contaPais == "" || contaCEP == "" || contaRua == "" || contaEstado == "" || contaCidade == undefined || contaPais == undefined || contaCEP == undefined || contaRua == undefined || contaEstado == undefined){
            alert("Dados incorretos, o endereço da conta do cliente está incompleto");
            return
        }
        
        //VALIDA VALIDADOR 1
        if(idValidador){
            if(nomeValidador == "" || cpfValidador == "" || emailValidador == "" || nomeValidador == undefined || emailValidador == undefined || cpfValidador == undefined){
                alert("Dados incorretos, o nome, cpf, email e celular do Validador devem estar preenchidos");
                return
            }else{
                textoConfirma = textoConfirma.concat("<br><br>Validador: <br>"+nomeValidador+" - "+emailValidador+" - "+celularValidador);
            }
        }
        
        //VALIDA VALIDADOR 2
        if(idValidador2){
            if(nomeValidador2 == "" || cpfValidador2 == "" || emailValidador2 == "" || nomeValidador2 == undefined || emailValidador2 == undefined || cpfValidador2 == undefined){
                alert("Dados incorretos, o nome, cpf, email e celular do Validador 2 devem estar preenchidos");
                return
            }else{
                textoConfirma = textoConfirma.concat("<br><br>Validador 2: <br>"+nomeValidador2+" - "+emailValidador2+" - "+celularValidador2);
            }
        }
        
        //VALIDA ASSINANTE 2
        if(idAssinante2){
            if(nomeAssinante2 == "" || cpfAssinante2 == "" || emailAssinante2 == "" || nomeAssinante2 == undefined || cpfAssinante2 == undefined || emailAssinante2 == undefined){
                alert("Dados incorretos, o nome, cpf, email e celular do Assinante 2 devem estar preenchidos");
                return
            }else{
                textoConfirma = textoConfirma.concat("<br><br>Assinante 2: <br>"+nomeAssinante2+" - "+emailAssinante2+" - "+celularAssinante2);
            }
        }
        
        if(clausula2){
            if(testemunha == "" || emailTestemunha == "" || cpfTestemunha == "" || testemunha == undefined || emailTestemunha == undefined || cpfTestemunha == undefined){
                alert("Dados da testemunha incorretos");
            }else if(cliente == "" || emailCliente == "" || cpfCliente == "" || cliente == undefined || emailCliente == undefined || cpfCliente == undefined){
                console.log("cliente", cliente);
                console.log("emailCliente", emailCliente);
                console.log("cpfCliente", cpfCliente);
                alert("Dados do cliente incorretos");
            }else{
                if(condicaoPagamento == undefined || FormaDePagamento == undefined || Frete == undefined || Prazo == undefined || PrazoGarantia == undefined || DataEmissao == undefined || DataValidade == undefined || idConta == undefined){
                    alert("Dados da OT incorretos\n\nOs campos Condição de pagamento, Forma de pagamento, Tipo de envio, Prazo de entrega, Prazo de garantia, Data de emissão, Data de validade, Conta, Contato e Faturamento feito devem ser preenchidos.");
                }else{
                    $("#destinatarios").empty().append(textoConfirma)
                    $("#modalConfirma").css("display", "flex");
                    $("#closeModal").click(function(){
                        $("#modalConfirma").css("display", "none");
                    });
                    
                    $("#contratoAssistencia").off().one("click", function(){
                        $("#modalConfirma").css("display", "none");
                        helper.enviaAssinatura(cmp, event, helper, recordId, 1);
                    });
                    
                    
                    $("#contratoVenda").off().one("click", function(){
                        $("#modalConfirma").css("display", "none");
                        helper.enviaAssinatura(cmp, event, helper, recordId, 2);
                    });
                }
            }
            
        }else{
            alert("Dados da OT incorretos\n");
        }
        
        helper.hideSpinner(cmp)
        
    },
    
    enviaAssinatura: function(cmp, event, helper, recordId, tipoOt){
        
        console.log("enviando assinatura")
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.enviarOT");
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idContrato: recordId,
            numero: tipoOt
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
            console.log("clique current")
            var fase = $(this).html()
            console.log("fase", fase)
            helper.consultaSignatarios(cmp, event, helper, fase);
        });
    },
    
    consultaSignatarios: function(cmp, event, helper, fase){
        console.log("consulta signatarios")
        
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO
        var action = cmp.get("c.consultarOT");
        var recordId = cmp.get("v.recordId")
        
        helper.alertaErro(cmp, event, helper, "", "Carregando assinaturas", "info", "", "")
        
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
            
            
            //console.log(agrupadoPorGrupo);
            //console.log(agrupadoPorGrupo[faseNum]);
            
            //LIMPA OS DADOS DO MODAL E ADICIONA NOVAMENTE
            $("#bodyModalFase").empty()
            
            //console.log("aqui 1")

            
            for (let item of agrupadoPorGrupo[faseNum]) {
                let status = item.hasOwnProperty("signature") ? " -> ASSINADO" : " -> NÃO ASSINADO";
                $("#bodyModalFase").append(item.name + status + "<br>");
            }

            
            //EXIBE O MODAL
            $("#modalStatusFase").css("display", "flex");
            
            //console.log("aqui")
            
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
        var action = cmp.get("c.consultarOT");
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
            var action = cmp.get("c.cancelarOT");
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