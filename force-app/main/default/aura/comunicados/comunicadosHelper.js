({
    idClicado : '',
    comunicados : [],
    
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
    
    helperMethod : function(cmp, event, helper) {
        console.log("HELPER COMUNICADO")
        $(".comunicadominimezeclass").on("click", function() {
            var currentDisplay = $(".bottomComunicado45343453").css("display");
            if (currentDisplay == "none") {
                $(".bottomComunicado45343453").css("display", "flex");
                $("#iconeMinimize").removeClass("fa-window-maximize").addClass("fa-minus");
            } else {
                $(".bottomComunicado45343453").css("display", "none");
                $("#iconeMinimize").removeClass("fa-minus").addClass( "fa-window-maximize");
            }
        });
        helper.consultaDados(cmp, event, helper)
    },
    
    consultaDados : function(cmp, event, helper){
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");

        var query = "select id, name, Corpo__c, Descricao_curta__c, createddate, Titulo__c, (SELECT id, CreatedById from Confirmacoes_de_Leitura__r where CreatedById = '"+currentUser+"') from comunicado__c ORDER BY CreatedDate DESC"
        //console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (comunicados) {
            //console.log(comunicados)
            helper.comunicados = comunicados
            
            comunicados.forEach(function(comunicado){
                var titulo = comunicado.Titulo__c;
                var id = comunicado.Id
                var corpo = comunicado.Corpo__c;
                var descricaoCurta = comunicado.Descricao_curta__c;
                var dataCriacao = comunicado.CreatedDate
                const date = new Date(dataCriacao);
				const formattedDate = `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}/${date.getFullYear()}`;
                var status = comunicado.Confirmacoes_de_Leitura__r ? "Lido" : "Não lido"
                var classLido = comunicado.Confirmacoes_de_Leitura__r ? "lido" : ""
                
                var html = "\
                <div title='Clique para ler' class='itemComunicado490394 "+classLido+"' data-id='"+id+"'>\
                    <div class='comunicadosTitle'>"+titulo+"</div>\
					<div class='comunicadosSubTitle'>"+descricaoCurta+"</div>\
                    <div class='comunicadosDate'>"+formattedDate+" - "+status+"</div>\
                </div>";
                
                $("#bottomComunicado45343453").append(html)
            })
            
            const existsWithoutConfirmations = comunicados.some(item => !item.Confirmacoes_de_Leitura__r || item.Confirmacoes_de_Leitura__r.length === 0);
            //console.log(existsWithoutConfirmations); // true se existir ao menos um objeto sem confirmações de leitura
            
            if(existsWithoutConfirmations == true){
                $("#iconEnvelopeComunicado").addClass( "fa-envelope envelopeIcon");
                $("#iconeMinimize").addClass( "fa-minus");
                
                // play sound
                var getSound = $A.get('$Resource.notifyComunicado');
                var playSound = new Audio(getSound);
                playSound.play();
            }else{
                $("#iconEnvelopeComunicado").addClass( "fa-envelope-open");
                $(".bottomComunicado45343453").css("display", "none");
                $("#iconeMinimize").addClass( "fa-window-maximize");
            }
            
            
            $(".popupButtonComunicado43543").on("click", function() {
                $('#popupComunicado').css("display", "none");
                 $('#overlay124567').css("display", "none");

                //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
                var action = cmp.get("c.confirma");
                //console.log("ID", helper.idClicado)
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    comunicado: helper.idClicado,
                });
                //----------------------------------------------------
                
                helper.alertaErro(cmp, event, helper, "", "Processando Leitura...", "info", "", "dismissable")
                
                //CALLBACK DA REQUISIÇÃO---------------------------
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("SUCESSO")
                        
                        var dataId = helper.idClicado
                        var info = $('[data-id="' + dataId + '"]').find('.comunicadosDate').html().split(" - ");
                        $('[data-id="' + dataId + '"]').find('.comunicadosDate').html(info[0] + " - " + "Lido")
                    	$('[data-id="' + dataId + '"]').css("background-color", "white")
                    }
                    else if (state === "INCOMPLETE") {
                        //helper.alertaErro(cmp, event, helper, "ERRO DURANTE O ENVIO", "ENVIO INCOMPLETO", "error", "Erro: ", "sticky")
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            console.log("erro", errors[0].message)
                            
                            //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO ENVIAR DOCUMENTO", "error", "Erro: ", "sticky")
                            reject(errors[0].message);
                        } else {
                            console.log("erro desconhecido")
                            //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                            reject("Erro desconhecido");
                        }
                    }
                });
                
                $A.enqueueAction(action);
            });
            
            $(".itemComunicado490394").on("click", function() {
                $('#popupComunicado').css("display", "flex");
                $('#overlay124567').css("display", "flex");
                helper.idClicado = $(this).attr("data-id")
                console.log("id clicado set", helper.idClicado)
                var comunicadoData = helper.comunicados.find((comunicado) => comunicado.Id == helper.idClicado);
                console.log("COMUNICADO DATA", comunicadoData)
                const date = new Date(comunicadoData.CreatedDate);
                const formattedDate = `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}/${date.getFullYear()}`;
                
                let descricaoCurta = comunicadoData.Descricao_curta__c;
                // Verifica se o comprimento é maior que 60
                descricaoCurta = descricaoCurta.length > 70 
                ? descricaoCurta.substring(0, 70) + '...' 
                : descricaoCurta;
                
                cmp.set('v.popupTitle', comunicadoData.Titulo__c);
                cmp.set('v.popupSubtitle', descricaoCurta);
                cmp.set('v.popupDate', formattedDate);
                cmp.set('v.myVal', comunicadoData.Corpo__c);
                
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    }
    
    
    
})