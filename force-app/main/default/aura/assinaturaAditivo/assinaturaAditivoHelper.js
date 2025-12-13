({
    objetoConsulta: 'Aditivos_Contratuais__c',
    campoConsulta: 'Contrato_de_Servi_o_Relacionado__r.Assinante2__r.MobilePhone, Contrato_de_Servi_o_Relacionado__r.Assinante2__r.Name, Contrato_de_Servi_o_Relacionado__r.Assinante2__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Assinante2__r.Email, Contrato_de_Servi_o_Relacionado__r.Validador2__r.MobilePhone, Contrato_de_Servi_o_Relacionado__r.Validador2__r.Name, Contrato_de_Servi_o_Relacionado__r.Validador2__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Validador2__r.Email, Contrato_de_Servi_o_Relacionado__r.Validador__r.MobilePhone, Contrato_de_Servi_o_Relacionado__r.Validador__r.Name, Contrato_de_Servi_o_Relacionado__r.Validador__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Validador__r.Email, Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.Billingcountry, Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.BillingCity, Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.Billingstate, Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.Billingpostalcode, Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.BillingStreet, Contrato_de_Servi_o_Relacionado__r.Fiador__c, Contrato_de_Servi_o_Relacionado__r.Fiador__r.Name, Fase__c, Contrato_de_Servi_o_Relacionado__r.Fiador__r.PersonEmail, Contrato_de_Servi_o_Relacionado__r.Fiador__r.CPF__pc, Contrato_de_Servi_o_Relacionado__r.Conjuge_do_Fiador__c, Contrato_de_Servi_o_Relacionado__r.Conjuge_do_Fiador__r.Name, Contrato_de_Servi_o_Relacionado__r.Conjuge_do_Fiador__r.PersonEmail, Contrato_de_Servi_o_Relacionado__r.Conjuge_do_Fiador__r.CPF__pc, Contrato_de_Servi_o_Relacionado__r.Testemunha__c, Contrato_de_Servi_o_Relacionado__r.Testemunha__r.FirstName, Contrato_de_Servi_o_Relacionado__r.Testemunha__r.LastName, Contrato_de_Servi_o_Relacionado__r.Testemunha__r.Email, Contrato_de_Servi_o_Relacionado__r.Testemunha__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Email, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.CPF__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__c, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.FirstName, Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.LastName, idDocAutentique__c, StatusAssinatura__c',
    
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
            console.log(idsAutentique)
            
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
                    
                    //VARIAVEIS DOS SIGNATARIOS
                    var nomeCliente = resultado.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.FirstName + " " + resultado.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.LastName
                    var emailCliente = resultado.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.Email
                    var cpfCliente = resultado.Contrato_de_Servi_o_Relacionado__r.Contato_do_Locat_rio__r.CPF__c
                    
                    //VERIFICA SE EXISTE FIADOR
                    if(resultado.Contrato_de_Servi_o_Relacionado__r.hasOwnProperty('Testemunha__r')){
                        var nomeTestemunha = resultado.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.FirstName + " " + resultado.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.LastName;
                        var emailTestemunha = resultado.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.Email;
                        var cpfTestemunha = resultado.Contrato_de_Servi_o_Relacionado__r.Testemunha__r.CPF__c;
                        var idTestemunha = resultado.Contrato_de_Servi_o_Relacionado__r.Testemunha__c
                        }else{
                            var nomeTestemunha = "";
                            var emailTestemunha = "";
                            var cpfTestemunha = "";
                            var idTestemunha = "";
                        }
                    
                    //VERIFICA SE EXISTE FIADOR
                    if(resultado.Contrato_de_Servi_o_Relacionado__r.hasOwnProperty('Fiador__r')){
                        var idFiador = resultado.Contrato_de_Servi_o_Relacionado__r.Fiador__c;
                        var nomeFiador = resultado.Contrato_de_Servi_o_Relacionado__r.Fiador__r.Name;
                        var emailFiador = resultado.Contrato_de_Servi_o_Relacionado__r.Fiador__r.PersonEmail;
                        var cpfFiador =  resultado.Contrato_de_Servi_o_Relacionado__r.Fiador__r.CPF__pc;
                    }else{
                        var idFiador = undefined;
                        var nomeFiador = "";
                        var emailFiador = "";
                        var cpfFiador = ""
                        }
                    
                    //VERIFICA SE EXISTE CONJUGUE
                    if(resultado.Contrato_de_Servi_o_Relacionado__r.hasOwnProperty('Conjuge_do_fiador__c')){
                        var idConjugue = resultado.Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__c
                        var nomeConjugue = resultado.Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.Name;
                        var emailConjugue = resultado.Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.PersonEmail;
                        var cpfConjugue = resultado.Contrato_de_Servi_o_Relacionado__r.Conjuge_do_fiador__r.CPF__pc;
                    }else{
                        var idConjugue = undefined;
                        var nomeConjugue = "";
                        var emailConjugue = "";
                        var cpfConjugue = "";
                    }
                    
                    //VERIFICA SE EXISTE CONTA
                    if(resultado.Contrato_de_Servi_o_Relacionado__r.hasOwnProperty('Locat_rio_a__c')){
                        var contaCidade = resultado.Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.BillingCity;
                        var contaPais = resultado.Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.BillingCountry;
                        var contaCEP = resultado.Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.BillingPostalCode;
                        var contaRua = resultado.Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.BillingStreet;
                        var contaEstado = resultado.Contrato_de_Servi_o_Relacionado__r.Locat_rio_a__r.BillingState;
                    }else{
                        var contaCidade = "";
                        var contaPais = "";
                        var contaCEP = "";
                        var contaRua = "";
                        var contaEstado  = "";
                    }
                    
                    //VERIFICA SE EXISTE VALIDADOR
                    if(resultado.Contrato_de_Servi_o_Relacionado__r.hasOwnProperty('Validador__c')){
                        var idValidador = resultado.Contrato_de_Servi_o_Relacionado__r.Validador__c
                        var nomeValidador = resultado.Contrato_de_Servi_o_Relacionado__r.Validador__r.Name;
                        var cpfValidador = resultado.Contrato_de_Servi_o_Relacionado__r.Validador__r.CPF__c;
                        var emailValidador = resultado.Contrato_de_Servi_o_Relacionado__r.Validador__r.Email;
                        var celularValidador = resultado.Contrato_de_Servi_o_Relacionado__r.Validador__r.MobilePhone;
                    }else{
                        var idValidador = ""
                        var nomeValidador = "";
                        var cpfValidador = "";
                        var emailValidador = "";
                        var celularValidador = "";
                    }
                    
                    //VERIFICA SE EXISTE VALIDADOR 2
                    if(resultado.Contrato_de_Servi_o_Relacionado__r.hasOwnProperty('Validador2__c')){
                        var idValidador2 = resultado.Contrato_de_Servi_o_Relacionado__r.Validador2__c
                        var nomeValidador2 = resultado.Contrato_de_Servi_o_Relacionado__r.Validador2__r.Name;
                        var cpfValidador2 = resultado.Contrato_de_Servi_o_Relacionado__r.Validador2__r.CPF__c;
                        var emailValidador2 = resultado.Contrato_de_Servi_o_Relacionado__r.Validador2__r.Email;
                        var celularValidador2 = resultado.Contrato_de_Servi_o_Relacionado__r.Validador2__r.MobilePhone;
                    }else{
                        var idValidador2 = ""
                        var nomeValidador2 = "";
                        var cpfValidador2 = "";
                        var emailValidador2 = "";
                        var celularValidador2 = "";
                    }
                    
                    //VERIFICA SE EXISTE ASSINANTE 2
                    if(resultado.Contrato_de_Servi_o_Relacionado__r.hasOwnProperty('Assinante2__c')){
                        var idAssinante2 = resultado.Contrato_de_Servi_o_Relacionado__r.Assinante2__c
                        var nomeAssinante2 = resultado.Contrato_de_Servi_o_Relacionado__r.Assinante2__r.Name;
                        var cpfAssinante2 = resultado.Contrato_de_Servi_o_Relacionado__r.Assinante2__r.CPF__c;
                        var emailAssinante2 = resultado.Contrato_de_Servi_o_Relacionado__r.Assinante2__r.Email;
                        var celularAssinante2 = resultado.Contrato_de_Servi_o_Relacionado__r.Assinante2__r.MobilePhone;
                    }else{
                        var idAssinante2 = ""
                        var nomeAssinante2 = "";
                        var cpfAssinante2 = "";
                        var emailAssinante2 = "";
                        var celularAssinante2 = "";
                    }
                    
                    //OUVINTE DO CLICK NO BOTAO
                    $("#enviaAssinatura").off().on( "click", function() {
                        helper.confirmaEnvio(cmp, event, helper, recordId, idTestemunha, idAssinante2, nomeAssinante2, cpfAssinante2, emailAssinante2, celularAssinante2, idValidador2, nomeValidador2, cpfValidador2, emailValidador2, celularValidador2, idValidador, nomeValidador, cpfValidador, emailValidador, celularValidador, contaCidade, contaPais, contaCEP, contaRua, contaEstado, idFiador, idConjugue, cpfCliente, cpfConjugue, cpfFiador, cpfTestemunha, nomeCliente,emailCliente,nomeTestemunha,emailTestemunha,nomeFiador,emailFiador,nomeConjugue,emailConjugue)
                    });
                    
                }
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    confirmaEnvio: function(cmp, event, helper, recordId, idTestemunha, idAssinante2, nomeAssinante2, cpfAssinante2, emailAssinante2, celularAssinante2, idValidador2, nomeValidador2, cpfValidador2, emailValidador2, celularValidador2, idValidador, nomeValidador, cpfValidador, emailValidador, celularValidador, contaCidade, contaPais, contaCEP, contaRua, contaEstado, idFiador, idConjugue, cpfCliente, cpfConjugue, cpfFiador, cpfTestemunha, nomeCliente, emailCliente,nomeTestemunha,emailTestemunha,nomeFiador,emailFiador,nomeConjugue,emailConjugue){
        
        var cliente = nomeCliente
        //var emailCliente = emailCliente
        
        var testemunha = nomeTestemunha
        //var emailTestemunha = emailTestemunha
        
        var fiador = nomeFiador
        //var emailFiador = emailFiador
        
        var conjugue = nomeConjugue
        //var emailConjugue = emailConjugue
        
        var textoConfirma = "<h5>Destinatários</h5>Cliente: <br>"+cliente+" - "+emailCliente+"<br><br>Testemunha: <br>"+testemunha+" - "+emailTestemunha+" ";
        
        console.log("confirmando envio")
        console.log("cliente", cliente + emailCliente + cpfCliente)
        console.log("fiador", fiador + emailFiador + cpfFiador + idFiador)
        console.log("conjuge", conjugue + emailConjugue + cpfConjugue)
        console.log("testemunha", testemunha + emailTestemunha + cpfTestemunha)
        
        if(!cpfTestemunha){
            var query = "select cpf__c from dados_colaborador__c where Contato__c = '"+idTestemunha+"'"
            
            console.log(query)
            
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (dadosColaborador) {
                
                cpfTestemunha = dadosColaborador[0].CPF__c
                
                //VALIDA DADOS DA TESTEMUNHA
                if(testemunha == "" || emailTestemunha == "" || cpfTestemunha == "" || testemunha == undefined || emailTestemunha == undefined || cpfTestemunha == undefined){
                    alert("Dados da testemunha incorretos");
                    return;
                }
                
                //VALIDA DADOS DA CONTA DO CLIENTE
                if(cliente == "" || emailCliente == "" || cpfCliente == "" || cliente == undefined || emailCliente == undefined || cpfCliente == undefined){
                    alert("Dados do cliente incorretos, verifique o CPF e email do contato do cliente");
                    return; 
                }
                
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
                
                //VERIFICA SE EXISTE FIADOR
                if(idFiador){
                    
                    //SE EXISTE, VERIFICA O PREENCHIMENTO DOS CAMPOS
                    if(fiador == "" || emailFiador == "" || cpfFiador == "" || fiador == undefined || emailFiador == undefined || cpfFiador == undefined){
                        alert("Dados do Fiador incorreto");
                    }else{
                        textoConfirma = textoConfirma.concat("<br><br>Fiador: <br>"+fiador+" - "+emailFiador+"");
                        
                        //VERIFICA SE EXISTE CONJUGE
                        if(idConjugue){
                            
                            //SE EXISTE, VERIFICA O PREENCHIMENTO DOS CAMPOS
                            if(conjugue == "" || emailConjugue == "" || cpfConjugue == "" || conjugue == undefined || emailConjugue == undefined || cpfConjugue == undefined){
                                alert("Dados do fiador incorretos");
                            }else{
                                
                                textoConfirma = textoConfirma.concat("<br><br>Conjugue: <br>"+conjugue+" "+emailConjugue+" ");
                                
                                $("#destinatarios").empty().append(textoConfirma)
                                $("#modalConfirma").css("display", "flex");
                                $("#closeModal").click(function(){
                                    $("#modalConfirma").css("display", "none");
                                });
                                
                                $("#enviarContrato").click(function(){
                                    $("#modalConfirma").css("display", "none");
                                    helper.enviaAssinatura(cmp, event, helper, recordId);
                                });
                            }
                        }else{
                            $("#destinatarios").empty().append(textoConfirma)
                            $("#modalConfirma").css("display", "flex");
                            $("#closeModal").click(function(){
                                $("#modalConfirma").css("display", "none");
                            });
                            
                            $("#enviarContrato").click(function(){
                                $("#modalConfirma").css("display", "none");
                                helper.enviaAssinatura(cmp, event, helper, recordId);
                            });
                        }
                    }
                }else{
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
                
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        }else{
            //VALIDA DADOS DA TESTEMUNHA
            if(testemunha == "" || emailTestemunha == "" || cpfTestemunha == "" || testemunha == undefined || emailTestemunha == undefined || cpfTestemunha == undefined){
                alert("Dados da testemunha incorretos");
                return;
            }
            
            //VALIDA DADOS DA CONTA DO CLIENTE
            if(cliente == "" || emailCliente == "" || cpfCliente == "" || cliente == undefined || emailCliente == undefined || cpfCliente == undefined){
                alert("Dados do cliente incorretos, verifique o CPF e email do contato do cliente");
                return; 
            }
            
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
            
            //VERIFICA SE EXISTE FIADOR
            if(idFiador){
                
                //SE EXISTE, VERIFICA O PREENCHIMENTO DOS CAMPOS
                if(fiador == "" || emailFiador == "" || cpfFiador == "" || fiador == undefined || emailFiador == undefined || cpfFiador == undefined){
                    alert("Dados do Fiador incorreto");
                }else{
                    textoConfirma = textoConfirma.concat("<br><br>Fiador: <br>"+fiador+" - "+emailFiador+"");
                    
                    //VERIFICA SE EXISTE CONJUGE
                    if(idConjugue){
                        
                        //SE EXISTE, VERIFICA O PREENCHIMENTO DOS CAMPOS
                        if(conjugue == "" || emailConjugue == "" || cpfConjugue == "" || conjugue == undefined || emailConjugue == undefined || cpfConjugue == undefined){
                            alert("Dados do fiador incorretos");
                        }else{
                            
                            textoConfirma = textoConfirma.concat("<br><br>Conjugue: <br>"+conjugue+" "+emailConjugue+" ");
                            
                            $("#destinatarios").empty().append(textoConfirma)
                            $("#modalConfirma").css("display", "flex");
                            $("#closeModal").click(function(){
                                $("#modalConfirma").css("display", "none");
                            });
                            
                            $("#enviarContrato").click(function(){
                                $("#modalConfirma").css("display", "none");
                                helper.enviaAssinatura(cmp, event, helper, recordId);
                            });
                        }
                    }else{
                        $("#destinatarios").empty().append(textoConfirma)
                        $("#modalConfirma").css("display", "flex");
                        $("#closeModal").click(function(){
                            $("#modalConfirma").css("display", "none");
                        });
                        
                        $("#enviarContrato").click(function(){
                            $("#modalConfirma").css("display", "none");
                            helper.enviaAssinatura(cmp, event, helper, recordId);
                        });
                    }
                }
            }else{
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
        }
        
        
    },
    
    enviaAssinatura: function(cmp, event, helper, recordId){
        
        console.log("enviando assinatura")
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.enviarAditivo");
        
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
        var action = cmp.get("c.consultarAditivo");
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
                
                console.log("SIGNATARIOS AQUI", signatarios);
                
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
            
            var grupo = agrupadoPorGrupo[faseNum];
            
            for (var key of Object.keys(grupo)) {
                
                var elemento = grupo[key];
                if (elemento.hasOwnProperty("signature")) {
                    var status = " -> ASSINADO";
                } else {
                    var status = " -> NÃO ASSINADO";
                }
                
                $("#bodyModalFase").append(elemento.name + status + "<br>");
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
    var action = cmp.get("c.consultarAditivo");
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
            var action = cmp.get("c.cancelarAditivo");
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