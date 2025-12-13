({
    appointments : [],
    arquivoAnexado: null,
    latitudeCompromissoAtual: '0', 
    longitudeCompromissoAtual: '0',
    idCompromisso: '',
    idsCalendariosAtivos: [],
    proximoDaLocalizacao: false,
    eventoAtualAtrasado: false,
    
    mainHelper : function(cmp, event, helper) {
  		helper.consultaCalendarios(cmp, event, helper)
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    showSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "flex");
    },
    //-------------------------------------------
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    hideSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "none");
    },
    //-------------------------------------------
    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO-------------------------------------------------------------
    alertaErro: function (cmp, event, helper, error, title, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    //----------------------------------------------------------------------------------------------
    
    consultaCalendarios:function(cmp, event, helper){
        helper.showSpinner(cmp);
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var query = "SELECT IdsCalendarios__c, id, Name from User where IsActive = true and lastLoginDate > 2023-01-01T10:10:59.000+0000 ORDER BY Name"
        
        console.log("QUERY consultaCalendarios", query)
        console.log(userId)
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (contas) {
            
            //acessa os dados do usuário atual
            var contaUsuarioAtual = contas.find((element) => element.Id == userId);
            
            //console.log("CONTA USUARIO ATUAL", contaUsuarioAtual)
            if(contaUsuarioAtual.hasOwnProperty("IdsCalendarios__c")){
                //acessa os ids de calendarios selecionados para o usuario atual, e define globalmente
                helper.idsCalendariosAtivos = contaUsuarioAtual.IdsCalendarios__c.split(",")
            }
            
            $("#checkboxes").empty()
            
            //loop para preenchimento de usuários no dropbox de calendários            
            contas.forEach(function(contaAtual) {
                var checked = ""
               	if(helper.idsCalendariosAtivos.includes(contaAtual.Id)){
                    checked = "checked"
                }
                
                var html = "<label for='"+contaAtual.Id+"'>\
				<input class='usersCalendar' type='checkbox' "+checked+" id='"+contaAtual.Id+"' value='"+contaAtual.Id+"'/>"+contaAtual.Name+"</label>"

				$("#checkboxes").append(html)
            });
            
            helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Success", "dismissable")
            
            //EVENTO DISPARADO AO ALTERAR O INPUT COM CALENDARIOS DISPONIVEIS
            $(".usersCalendar").change(function() {
                //VERIFICA SE FOI CHECADO UM VALOR
                if (this.checked) {
                    const val = $(this).val();
                    if (!helper.idsCalendariosAtivos.includes(val)) {
                        helper.idsCalendariosAtivos.push(val);
                    }
                } else {
                    const val = $(this).val();
                    const index = helper.idsCalendariosAtivos.indexOf(val);
                    if (index !== -1) {
                        helper.idsCalendariosAtivos.splice(index, 1);
                    }
                }
                
                var StringIdCalendarios = helper.idsCalendariosAtivos.toString()
                var userId = $A.get("$SObjectType.CurrentUser.Id");
                
                //CHAMA A FUNÇÃO DO APEX
                var action =  cmp.get("c.addCalendar");
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    idUsuario: userId,
                    idsCalendario: StringIdCalendarios
                });
                
                //CALLBACK DA REQUISIÇÃO---------------------------
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    var result = response.getReturnValue();
                    
                    //TESTANDO O SUCESSO
                    if (state === "SUCCESS") {
                        //helper.alertaErro(cmp, event, helper, "Seu check-out foi concluído com sucesso", "TUDO OK!", "Success", "dismissable")
                        location.reload();
                    }else if (state === "INCOMPLETE") {
                        console.log("incompleto")
                        console.log(response)                
                    } else if (state === "ERROR") {
                        console.log("erro")
                        console.log("erro: ", response.getError())
                    }
                });
                $A.enqueueAction(action);
                helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
            });
            helper.hideSpinner(cmp);
            helper.getAppointments(cmp, event, helper, '2023-09-01')
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    getAppointments: function(cmp, event, helper, dataInicio){
        
        //Padroniza a data de inicio
        dataInicio = dataInicio + 'T12:30:00.000+0000'
        
        //obtem o id do usuário atual
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        //adiciona o id do usuario junto aos ids de calendarios selecionados
        //helper.idsCalendariosAtivos.push(userId)
        
        //formata string de ids para consulta
        var idsFormatados = helper.idsCalendariosAtivos.map(id => `'${id}'`).join(',');
        
        //CONSULTA AS VARIAÇÕES DO USUARIO
        var query = "SELECT checkInRealizado__c, Owner.Name, id, Description, WhatId, What.Name, Subject, StartDateTime, EndDateTime from Event WHERE OwnerId IN ("+idsFormatados+") AND StartDateTime >= "+dataInicio+""
        
        console.log("QUERY APPOINTMENTS", query)
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (compromissos) {
            console.log("COMPROMISSOS", compromissos)
            
            //Obtém a data e hora atual
            const currentDate = new Date();
            
            //Mapeia os eventos originais para a nova estrutura
            const formattedEvents = compromissos.map(event => {
                //Converte as datas e horas para o formato desejado
                const startDateTime = new Date(event.StartDateTime);
                const endDateTime = new Date(event.EndDateTime);
                
                // Subtrai 2 horas do startDateTime
                startDateTime.setHours(startDateTime.getHours() - 3);
                
                //Define a cor com base na comparação entre as datas
                const color = helper.getColorForEvent(event);
                const textColor = color == '#ffff00' ? '#222222' : 'white'
                var checkInRealizado =  event.checkInRealizado__c ? event.checkInRealizado__c : false
                var relativo = event.What ? event.What.Name : 'Relativo nao atribuído';

                
                //Cria o objeto formatado
                return {
                title:  relativo + " (" + event.Subject + ") (" + event.Owner.Name.split(" ")[0] +  ")",
                assunto: event.Subject,
                start: startDateTime.toISOString(),
                end: endDateTime.toISOString(),
                relativo: relativo,
                usuario: event.Owner.Name,
                checkinRealizado: checkInRealizado,
                cidade: '',
                estado: '',
                rua: '',
                cep: '0',
                latitude: '0',
                longitude: '0',
                color: color,
                descricao: event.Description,
                textColor: textColor,
                WhatId: event.WhatId,
                Id: event.Id
            };
                                                     });
            
            helper.appointments = formattedEvents
            
            //Filtra os itens com o título "Visita" e obtém os IDs
            var idsVisita = helper.appointments.filter(item => item.assunto == "Visita").map(item => item.WhatId).toString();
            var idsArray = idsVisita.split(',');
            
            console.log("ids Visita", idsVisita)
            
            // Separando os IDs por prefixo
            var idsAccount = idsArray.filter(id => id.startsWith('001'));
            var idsOpportunity = idsArray.filter(id => id.startsWith('006'));
            
            // Formatando para uso na query
            var idsAccountFormatados = idsAccount.map(id => `'${id}'`).join(', ');
            var idsOpportunityFormatados = idsOpportunity.map(id => `'${id}'`).join(', ');
            
            // Construindo as queries
            var queryOpportunity = idsOpportunity.length > 0 
            ? `SELECT id, Account.billingCity, Account.BillingPostalCode, Account.BillingState, Account.BillingCountry, Account.BillingStreet, Account.BillingLatitude, Account.BillingLongitude FROM Opportunity WHERE id IN (${idsOpportunityFormatados})`
            : null;
            
            var queryAccount = idsAccount.length > 0 
            ? `SELECT id, BillingCity, BillingPostalCode, BillingState, BillingCountry, BillingStreet, BillingLatitude, BillingLongitude, (SELECT Id, Name FROM Contacts) FROM Account WHERE id IN (${idsAccountFormatados})`
            : null;
            
            
            console.log("QUERY queryOpportunity", queryOpportunity)
            
            //REALIZA A CONSULTA
            helper.soql(cmp, queryOpportunity)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (contas) {
                
                console.log("CONTAS DETALHES", contas)
                
                helper.appointments.filter(item => item.assunto == "Visita").forEach(function(compromissoAtual){
                    
                    console.log("compromissoAtual", compromissoAtual)
                    var idConta = compromissoAtual.WhatId
                    var indiceEncontrado = contas.findIndex((conta) => conta.Id == idConta)
                    
                    if(indiceEncontrado != -1){
                        console.log("INDICE ENCONTRADO", compromissoAtual)
                        compromissoAtual.cidade = contas[indiceEncontrado].Account.BillingCity ? contas[indiceEncontrado].Account.BillingCity : ' ';
                        compromissoAtual.estado = contas[indiceEncontrado].Account.BillingState ? contas[indiceEncontrado].Account.BillingState : ' ';
                        compromissoAtual.rua = contas[indiceEncontrado].Account.BillingStreet ? contas[indiceEncontrado].Account.BillingStreet.replace(/[\s,]+/g, '+') : ' ';
                        compromissoAtual.latitude = contas[indiceEncontrado].Account.BillingLatitude ? contas[indiceEncontrado].Account.BillingLatitude : ' ' 
                        compromissoAtual.longitude = contas[indiceEncontrado].Account.BillingLongitude ? contas[indiceEncontrado].Account.BillingLongitude : ' ' 
                        compromissoAtual.cep = contas[indiceEncontrado].Account.BillingPostalCode ? contas[indiceEncontrado].Account.BillingPostalCode : ' ' 
                        compromissoAtual.contatos = contas[indiceEncontrado].Contacts ? contas[indiceEncontrado].Contacts : ' ' 
                    }
                })
                
                helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
                
                helper.soql(cmp, queryAccount)
                //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
                .then(function (contas) {
                    
                    console.log("CONTAS DETALHES QUERY ACCOUNT", contas)
                    helper.appointments.filter(item => item.assunto == "Visita").forEach(function(compromissoAtual){
                        
                        console.log("compromissoAtual", compromissoAtual)
                        var idConta = compromissoAtual.WhatId
                        var indiceEncontrado = contas.findIndex((conta) => conta.Id == idConta)
                        
                        if(indiceEncontrado != -1){
                            console.log("INDICE ENCONTRADO", compromissoAtual)
                            compromissoAtual.cidade = contas[indiceEncontrado].BillingCity ? contas[indiceEncontrado].BillingCity : ' ';
                            compromissoAtual.estado = contas[indiceEncontrado].BillingState ? contas[indiceEncontrado].BillingState : ' ';
                            compromissoAtual.rua = contas[indiceEncontrado].BillingStreet ? contas[indiceEncontrado].BillingStreet.replace(/[\s,]+/g, '+') : ' ';
                            compromissoAtual.latitude = contas[indiceEncontrado].BillingLatitude ? contas[indiceEncontrado].BillingLatitude : ' ' 
                            compromissoAtual.longitude = contas[indiceEncontrado].BillingLongitude ? contas[indiceEncontrado].BillingLongitude : ' ' 
                            compromissoAtual.cep = contas[indiceEncontrado].BillingPostalCode ? contas[indiceEncontrado].BillingPostalCode : ' ' 
                            compromissoAtual.contatos = contas[indiceEncontrado].Contacts ? contas[indiceEncontrado].Contacts : ' ' 
                        }
                    })
                    
                    //console.log("NAO ORDENADO", helper.appointments)
                    // Ordena o array pelo campo "start" em ordem crescente
                    helper.appointments.sort(function(a, b) {
                        return new Date(a.start) - new Date(b.start);
                    });
                    
                    //console.log("ORDENADO", helper.appointments)
                    helper.criaCalendario(cmp, event, helper)
                    helper.addFutureAppointments(cmp, event, helper)
                })
                
                //trata excessão de erro
                .catch(function (error) {
                    console.log(error)
                })
                
                
                /*console.log("NAO ORDENADO", helper.appointments)
                // Ordena o array pelo campo "start" em ordem crescente
                helper.appointments.sort(function(a, b) {
                    return new Date(a.start) - new Date(b.start);
                });
                
                //console.log("ORDENADO", helper.appointments)
                helper.criaCalendario(cmp, event, helper)
                helper.addFutureAppointments(cmp, event, helper) */
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log("query account", queryAccount)
                console.log("erro11221", error, queryAccount)
                
                helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
                
                helper.soql(cmp, queryAccount)
                //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
                .then(function (contas) {
                    
                    console.log("CONTAS DETALHES QUERY ACCOUNT", contas)
                    helper.appointments.filter(item => item.assunto == "Visita").forEach(function(compromissoAtual){
                        
                        console.log("compromissoAtual", compromissoAtual)
                        var idConta = compromissoAtual.WhatId
                        var indiceEncontrado = contas.findIndex((conta) => conta.Id == idConta)
                        
                        if(indiceEncontrado != -1){
                            console.log("INDICE ENCONTRADO", compromissoAtual)
                            compromissoAtual.cidade = contas[indiceEncontrado].BillingCity ? contas[indiceEncontrado].BillingCity : ' ';
                            compromissoAtual.estado = contas[indiceEncontrado].BillingState ? contas[indiceEncontrado].BillingState : ' ';
                            compromissoAtual.rua = contas[indiceEncontrado].BillingStreet ? contas[indiceEncontrado].BillingStreet.replace(/[\s,]+/g, '+') : ' ';
                            compromissoAtual.latitude = contas[indiceEncontrado].BillingLatitude ? contas[indiceEncontrado].BillingLatitude : ' ' 
                            compromissoAtual.longitude = contas[indiceEncontrado].BillingLongitude ? contas[indiceEncontrado].BillingLongitude : ' ' 
                            compromissoAtual.cep = contas[indiceEncontrado].BillingPostalCode ? contas[indiceEncontrado].BillingPostalCode : ' ' 
                            compromissoAtual.contatos = contas[indiceEncontrado].Contacts ? contas[indiceEncontrado].Contacts : ' ' 
                        }
                        
                    })
                    
                    //console.log("NAO ORDENADO", helper.appointments)
                    // Ordena o array pelo campo "start" em ordem crescente
                    helper.appointments.sort(function(a, b) {
                        return new Date(a.start) - new Date(b.start);
                    });
                    
                    //console.log("ORDENADO", helper.appointments)
                    helper.criaCalendario(cmp, event, helper)
                    helper.addFutureAppointments(cmp, event, helper)
                })
                
                //trata excessão de erro
                .catch(function (error) {
                    console.log(error)
                })
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log("ERRO", error)
        })
    },
    
    //CLASSIFICA OS EVENTOS COM CORES
    getColorForEvent: function(event) {
        console.log("EVENTOOOO", event)
        const startDateTime = new Date(event.StartDateTime);
        const checkInRealizado = event.checkInRealizado__c;
        
        // Obtém a data atual
        const currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0); // Define o tempo para 00:00:00.000
        
        // Compara apenas as datas (sem a hora, minuto, segundo e milissegundo)
        if (startDateTime.toDateString() === currentDate.toDateString()) {
            // Evento no mesmo dia (cor amarela)
            return '#ffff00';
        } else if (startDateTime > currentDate) {
            // Evento no futuro (cor verde)
            return '#229A00';
        } else if (!checkInRealizado) {
            // Check-in não realizado (cor vermelha)
            return '#ff0000';
        } else {
            // Evento no passado (ou check-in realizado, se preferir uma cor diferente)
            return '#229A00'; // Cor padrão, você pode alterá-la conforme necessário
        } 
    },
    
    //Adiciona na visualizaçao os eventos futuros
    addFutureAppointments: function(cmp, event, helper){
        
        // Obtém a data atual
        var dataAtual = new Date();
        //obtem apenas os compromissos futuros
        var compromissosFiltrados = helper.appointments.filter(function(compromisso) {
            return new Date(compromisso.start) >= dataAtual;
        });
        
        compromissosFiltrados.forEach(function(compromissoAtual) {
            var idCompromisso = compromissoAtual.Id
            var tipoCompromisso = compromissoAtual.title
            var dataCompromisso = helper.verificaData(compromissoAtual.start)
            var siglaMes = new Date(compromissoAtual.start).toLocaleDateString('pt-BR', { month: 'short' }).replace('.', '').toUpperCase();
            var dia = String(new Date(compromissoAtual.start).getDate()).padStart(2, '0');
            var relativoCompromisso = compromissoAtual.relativo
            var cidade = compromissoAtual.cidade
            var estado = compromissoAtual.estado
            var latitude = compromissoAtual.latitude
            var longitude = compromissoAtual.longitude
            var corCompromisso = 'background-color:' + compromissoAtual.color
            var corTexto = 'color:' + compromissoAtual.textColor
            
            var html = "<!-- BLOCO COMPROMISSO -->\
<div class='divMestreCompromisso' data-idCompromisso='"+idCompromisso+"'>\
<div class='divAuxiliarData' style='"+corCompromisso+";"+corTexto+"'>\
"+dia+"<br></br>"+siglaMes+"\
</div>\
<div class='divDadosCompromisso'>\
<div class='dataCompromisso'>"+dataCompromisso+"</div>\
<div class='tipoCompromisso'>"+tipoCompromisso+"</div>\
<div class='relativoCompromisso'>"+relativoCompromisso+"</div>\
<div class='locationCompromisso'>\
<a href='https://www.google.com/maps?q="+latitude+","+longitude+"' style='text-transform: uppercase' target='_blank'>"+cidade+"-"+estado+"</a>\
</div>\
</div>\
</div>\
<!-- FIM BLOCO COMPROMISSO -->";
            
            $("#divProximosCompromissos").append(html)
        })
        
        $( ".divMestreCompromisso" ).on( "click", function() {
            //EXIBE POPUP
            $("#divPaiPopup").css("display", "flex")
            var idCompromisso = $(this).attr('data-idcompromisso')
            helper.configuraPopupCompromisso(cmp, event, helper, idCompromisso)
        });
    },
    
    configuraPopupCompromisso:function(cmp, event, helper, idCompromisso){        
        var compromissoAtual = helper.appointments.find((compromisso) => compromisso.Id == idCompromisso);
        var tipoCompromisso = compromissoAtual.title
        var assuntoCompromisso = compromissoAtual.assunto
        var dataCompromisso = helper.verificaData(compromissoAtual.start)
        var siglaMes = new Date(compromissoAtual.start).toLocaleDateString('pt-BR', { month: 'short' }).replace('.', '').toUpperCase();
        var dia = String(new Date(compromissoAtual.start).getDate()).padStart(2, '0');
        var relativoCompromisso = compromissoAtual.relativo
        var descricao = compromissoAtual.descricao
        var cidade = compromissoAtual.cidade
        var estado = compromissoAtual.estado
        var latitude = compromissoAtual.latitude
        var longitude = compromissoAtual.longitude
        var rua = compromissoAtual.rua
        var cep = compromissoAtual.cep
        var linkCompromisso = "https://hospcom.my.site.com/Sales/s/event/" + idCompromisso
        var iframeMaps = "<iframe style='border-radius: 10px' width='100%' height='100%' frameborder='0' scrolling='no' marginheight='0' marginwidth='0' src='https://maps.google.com/maps?q="+rua+"+"+cidade+"+"+estado+"&amp;z=13&amp;output=embed'></iframe>"
        var currentDate = new Date(); currentDate.setHours(0, 0, 0, 0);
        var startDateTime = new Date(compromissoAtual.start);
        
        //seta nas variaveis globais os valores para latitude e longitude do compromisso atual
        helper.longitudeCompromissoAtual = latitude
        helper.latitudeCompromissoAtual = longitude
        helper.idCompromisso = idCompromisso
        
        console.log("ID COMPROMISSO", idCompromisso)
        cmp.set("v.recordId",idCompromisso);
        
        if(cidade != ""){
            var linkMaps = "<a href='https://www.google.com/maps?q="+latitude+","+longitude+"' style='text-transform: uppercase' target='_blank'>"+cidade+", "+estado+"</a>";
        }else{
            var linkMaps = "<span style='color: red'>Endereço não cadastrado ao compromisso</span>"
            }
        
        $( "#divPaiPopup" ).find('.meioHeaderPopup').html(dataCompromisso)
        $( "#divPaiPopup" ).find('.tipoCompromissoBody').html(tipoCompromisso)
        $( "#divPaiPopup" ).find('.relativoCompromisso').html(relativoCompromisso)
        $( "#divPaiPopup" ).find('.descricaoCompromissoPopup').html(descricao)
        $( "#divPaiPopup" ).find('#locationCompromisso').empty().append(linkMaps)
        $( "#divPaiPopup" ).find('.mapaLocalizacaoCompromisso').empty().append(iframeMaps)
        $( "#divPaiPopup" ).find('#linkCompromisso').attr("href", linkCompromisso)
        
        if(assuntoCompromisso != "Visita"){
            $( "#divPaiPopup" ).find('.checkOutButton').hide()
        }else{
            $( "#divPaiPopup" ).find('.checkOutButton').show()
        }
        
        //VERIFICA SE O EVENTO ESTÁ ATRASADO
        if(startDateTime < currentDate){
            $("#divPaiPopupCheckout").find("#justificativa").css("display", "flex")
            helper.eventoAtualAtrasado = true
        }else{
            $("#divPaiPopupCheckout").find("#justificativa").css("display", "none")
            helper.eventoAtualAtrasado = false
        } 
        
        //EVENTOS DO POPUP APOS EXIBICAO
        $( "#closeButtonPopup" ).on( "click", function() {
            $("#divPaiPopup").css("display", "none")
        });
        
        //EVENTOS DO BOTAO CHECKOUT
        $( ".checkOutButton" ).on( "click", function() {
            
            helper.checkout(cmp, event, helper);
            
            /*
            
            var query = ""
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (contatos) {                
                console.log("contatos", contatos)
                helper.checkout(cmp, event, helper)
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })*/
            
        });
    },
    
    //UTILIZA A TEORIA DE Haversine PARA CALCULAR A DISTANCIA ENTRE DUAS LATITUDES E LONGITUDES
    calcularDistancia:function (latitude1, longitude1, latitude2, longitude2) {
        // Raio da Terra em quilômetros
        const raioTerra = 6371;
        
        // Converter graus para radianos
        const lat1Rad = (latitude1 * Math.PI) / 180;
        const lon1Rad = (longitude1 * Math.PI) / 180;
        const lat2Rad = (latitude2 * Math.PI) / 180;
        const lon2Rad = (longitude2 * Math.PI) / 180;
        
        // Diferença de latitude e longitude
        const latDiff = lat2Rad - lat1Rad;
        const lonDiff = lon2Rad - lon1Rad;
        
        // Fórmula de Haversine
        const a = Math.sin(latDiff / 2) ** 2 + Math.cos(lat1Rad) * Math.cos(lat2Rad) * Math.sin(lonDiff / 2) ** 2;
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        // Distância em quilômetros
        const distancia = raioTerra * c;
        
        return distancia;
    },
    
    checkout: function(cmp, event, helper){
        console.log("clique checkout", helper.idCompromisso)
        
        var compromissoAtual = helper.appointments.find((compromisso) => compromisso.Id == helper.idCompromisso);
        
        if(compromissoAtual.contatos != " "){
            var contatosConta = compromissoAtual.contatos;
        }else{
            alert("A conta da visita deve possuir contatos, cadastre-os antes de seguir.")
            return 0
        }
        
        
        console.log(compromissoAtual)
        console.log("contatos conta", contatosConta)
        
        $("#feedbackCompromisso").val(" ")
        $("#contatoTratado").empty().append("<option value='default' selected='selected' disabled='disabled'>Selecione o contato atendido</option>")
        
        if(contatosConta != undefined){
            contatosConta.forEach(function(contaAtual) {
                console.log(contaAtual)
                var idDaContato = contaAtual.Id
                var nomeContato = contaAtual.Name
                var html = "<option value='"+idDaContato+"'>"+nomeContato+"</option>"
                $("#contatoTratado").append(html)
            });
        }
        
        
        if ("geolocation" in navigator) {
            // O navegador suporta geolocalização
            navigator.geolocation.getCurrentPosition(function(position) {
                // `position` contém as informações de geolocalização
                const latitude = position.coords.latitude;
                const longitude = position.coords.longitude;
                
                console.log("Latitude: " + latitude);
                console.log("Longitude: " + longitude);
                
                var distancia = helper.calcularDistancia(helper.longitudeCompromissoAtual, helper.latitudeCompromissoAtual, latitude, longitude)
                console.log("distancia: " + distancia);
                
                if (distancia <= 5) {
                    console.log("distancia até o compromisso é aceitavel")
                    
                    //EXIBE POPUP NA TELA
                    $("#divPaiPopupCheckout").css("display","flex")
                    helper.proximoDaLocalizacao = true;
                    //OCULTA O POPUP AO CLICAR NO X
                    $( "#closeButtonPopupCheckout" ).on( "click", function() {
                        $("#divPaiPopupCheckout").css("display", "none")
                    });

                } else {
                    console.log("distancia até o compromisso nao é aceitavel")
                    helper.alertaErro(cmp, event, helper, "VOCÊ NÃO ESTÁ PRÓXIMO SUFICIENTE DO LOCAL DO COMPROMISSO", "ATENÇÃO!", "Warning", "dismissable")
                    
                    //EXIBE POPUP NA TELA
                    $("#divPaiPopupCheckout").css("display","flex")
                    //EXIBE DIV DA JUSTIFICATIVA
                    $("#divPaiPopupCheckout").find("#justificativa").css("display", "flex")
                    helper.proximoDaLocalizacao = false;
                    
                    //OCULTA O POPUP AO CLICAR NO X
                    $( "#closeButtonPopupCheckout" ).on( "click", function() {
                        $("#divPaiPopupCheckout").css("display", "none")
                    });
                }
                
                /* Adicione um manipulador de eventos para o elemento input do arquivo
                $("#cameraFileInput").change(function() {
                    console.log("anexado arquivo1")
                    var file = this.files[0]; // Assume que apenas um arquivo será anexado
                    var reader = new FileReader();
                    
                    reader.onload = function (evento) {
                        var imgString = evento.target.result; // Aqui está a string Blob
                        
                        //console.log("IMG Blob (string)", imgString);
                        helper.arquivoAnexado = imgString
                        console.log("Um arquivo foi anexado!");
                        
                    }; 
                    // Leia o Blob como uma string
                    reader.readAsDataURL(file);
                }); */
                
                // Agora você pode usar `latitude` e `longitude` como desejado
            }, function(error) {
                // Caso ocorra um erro ao obter a localização
                switch(error.code) {
                    case error.PERMISSION_DENIED:
                        alert("Permissão de geolocalização negada pelo usuário.");
                        break;
                    case error.POSITION_UNAVAILABLE:
                        alert("Informações de localização indisponíveis.");
                        break;
                    case error.TIMEOUT:
                        alert("Tempo limite expirado ao tentar obter a localização.");
                        break;
                    case error.UNKNOWN_ERROR:
                        alert("Erro desconhecido ao obter a localização.");
                        break;
                }
            });
        } else {
            console.error("Geolocalização não é suportada neste navegador.");
        }
    },
    
    compareAppointments:function (a, b) {
        const dataA = new Date(a.start);
        const dataB = new Date(b.start);
        
        if (dataA < dataB) {
            return 1;
        }
        if (dataA > dataB) {
            return -1;
        }
        return 0;
    },
    
    verificaData:function (dataEvento) {
        const data = new Date(dataEvento);
        data.setHours(data.getHours() + 3); // Adiciona 3 horas
        
        const dataAtual = new Date();
        const dataAmanhã = new Date();
        dataAmanhã.setDate(dataAmanhã.getDate() + 1);
        
        if (data.toDateString() === dataAtual.toDateString()) {
            const horario = data.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
            return `Hoje, ${horario}`;
        } else if (data.toDateString() === dataAmanhã.toDateString()) {
            const horario = data.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
            return `Amanhã, ${horario}`;
        } else {
            return data.toLocaleDateString('pt-BR');
        }
    },
    
    criaCalendario: function(cmp, event, helper){
        
        //INSTANCIA CALENDARIO FULL
        $('#calendar').fullCalendar('destroy');
        $('#calendar').fullCalendar({
            locale: 'pt-br',
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,basicWeek,basicDay'
            },
            eventLimit: true, // for all non-agenda views
            views: {
                agenda: {
                    eventLimit: 2 // adjust to 6 only for agendaWeek/agendaDay
                }
            },
            defaultView: 'month',
            /*dayClick: function(date, jsEvent, view) {
                $(this).css('background-color', 'red');
                console.log('Clicked on: ' + date.format());
                console.log('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);
                console.log('Current view: ' + view.name);
            },*/
            eventClick: function(calEvent, jsEvent, view) {
                //EXIBE POPUP
                $("#divPaiPopup").css("display", "flex")
                var idCompromisso = calEvent.Id
                helper.configuraPopupCompromisso(cmp, event, helper, idCompromisso)
                console.log('Event clicked:', calEvent); // Exemplo: exibe o objeto do evento no console.
            },
            events: helper.appointments,
        });
        
        //INSTANCIA MINI CALENDARIO
        $('#smallCalendar').fullCalendar('destroy');
        $('#smallCalendar').fullCalendar({
            locale: 'pt-br',
            header: {
                left: 'prev',
                center: 'title',
                right: 'next'
            },
            defaultView: 'month',
            /*dayClick: function(date, jsEvent, view) {
                $(this).css('background-color', 'red');
                console.log('Clicked on: ' + date.format());
                console.log('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);
                console.log('Current view: ' + view.name);
            },*/
            eventClick: function(calEvent, jsEvent, view) {
                //EXIBE POPUP
                $("#divPaiPopup").css("display", "flex")
                var idCompromisso = calEvent.Id
                helper.configuraPopupCompromisso(cmp, event, helper, idCompromisso)
                console.log('Event clicked:', calEvent); // Exemplo: exibe o objeto do evento no console.
            },
            views: {
                agenda: {
                    eventLimit: 2 // adjust to 6 only for agendaWeek/agendaDay
                }
            },
            events: helper.appointments,
            
        });
        
        
    },
})