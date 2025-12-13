({
    taskClicada: "",
    cartaoClicado: "",
    idQuadroAtual: "",
    nomeQuadroAtual: "",
    newUsuarioCompartilhado: "",
    imageUsers: [],
    cartoes: [],
    quadros: [],
    gestorTaskAtual: '',
    anoSelecionado : '',
    mesSelecionado : '',
    membrosTarefaAtual : [],
    colaboradorSelecionado : '',
    
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO
    showSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "flex");
    },
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO
    hideSpinner: function (cmp) {
        $('#spinnerDiv').css("display", "none");
    },
    
    mainMethod : function(cmp, event, helper) {
        var query = "SELECT id, MediumPhotoUrl from User where IsActive = true";
        //helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (usuarios) {
            helper.imageUsers = usuarios
            console.log("usuarios", usuarios)
            helper.consultaQuadros(cmp, event, helper);
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    consultaUsuarios: function(cmp, event, helper) {
    helper.showSpinner(cmp);

    var userId = $A.get("$SObjectType.CurrentUser.Id");
    var query = "select id, Name from user where isactive = true ORDER BY Name";

    console.log("QUERY", query);
    console.log("USER ID ATUAL", userId);

    this.soql(cmp, query)
        .then(function(usuarios) {
            var contaUsuarioAtual = usuarios.find((element) => element.Id == userId);

            console.log("CARTOES", helper.cartoes);
            console.log("CONTA USUARIO ATUAL", contaUsuarioAtual);

            $("#checkboxes").empty();

            usuarios.forEach(function(contaAtual) {
                var checked = "";

                if(helper.membrosTarefaAtual && helper.membrosTarefaAtual.includes(contaAtual.Id)) {
                    checked = "checked";
                }

                var html = `<label class='label-option' for='${contaAtual.Id}'>
                                <input class='usersCalendar' type='checkbox' ${checked} id='${contaAtual.Id}' value='${contaAtual.Id}'/>
                                ${contaAtual.Name}
                            </label>`;
                $("#checkboxes").append(html);
            });

            // Toggle da exibição de checkboxes
            $("#selectBox").off().on("click", function() {
                $("#checkboxes").toggle();
            });
            
           // Registro do evento de pesquisa dinâmica
$("#searchInput").off().on("keyup", function() {
    var value = $(this).val().toLowerCase();
    var found = false;

    console.log("Valor de pesquisa:", value); // Verifica o valor digitado
    
    $("#checkboxes label").each(function() {
        var labelText = $(this).text().toLowerCase();
        var match = labelText.indexOf(value) > -1;

        console.log("Verificando label:", labelText, " - Match:", match); // Log de depuração para cada label

        $(this).toggle(match);

        // Se houver uma correspondência, rola até o item
        if (match && !found) {
            // Forçar o scroll no contêiner pai
            $("#checkboxes").scrollTop($(this).position().top + $("#checkboxes").scrollTop());
            found = true;
            console.log("Item encontrado e rolado para a visualização:", labelText); // Log quando o item é encontrado e rolado
        }
    });

    if (!found) {
        console.log("Nenhum item encontrado para o valor de pesquisa:", value); // Log se nenhum item for encontrado
    }
});

            // Registro do evento de mudança dos checkboxes
            $('.usersCalendar').off().change(function() {
                var idUsuario = $(this).val();

                if ($(this).is(':checked')) {
                    console.log('Checkbox marcado. ID:', $(this).attr('id'));
                    helper.adicionaMembroTarefa(cmp, event, helper, idUsuario);
                } else {
                    console.log('Checkbox desmarcado. ID:', $(this).attr('id'));
                    helper.removeMembroTarefa(cmp, event, helper, idUsuario);
                }
            });
        })
        .catch(function(error) {
            console.log(error);
        });
}

    ,
    consultaQuadros: function(cmp, event, helper){
        helper.showSpinner(cmp)
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Info", "dismissable")
        
        var query = "SELECT Id, Name FROM Quadro_Trello__c";
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (quadros) {
            helper.hideSpinner(cmp)
            helper.quadros = quadros
            helper.preencheQuadros(cmp, event, helper)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    preencheQuadros: function(cmp, event, helper){
        $("#linhasQuadros").empty()
        
        helper.quadros.forEach(function(quadroAtual){
            var nomeQuadro = quadroAtual.Name;
            var limite = 20
            if (nomeQuadro.length > limite) {
                nomeQuadro = nomeQuadro.slice(0, limite - 3) + '...'; 
            } else {
                nomeQuadro = nomeQuadro;
            }
            
            
            var idQuadro = quadroAtual.Id
            
            var html = "<div class='quadroTrelloMiniatura' data-idQuadro='"+idQuadro+"' data-nomeQuadro='"+nomeQuadro+"'><i class='fa fa-columns' aria-hidden='true'></i>"+nomeQuadro+"</div>"
            $("#linhasQuadros").append(html)
        });
        helper.eventsAfterPreencheQuadros(cmp, event, helper)
    },
    
    eventsAfterPreencheQuadros: function(cmp, event, helper){
        //EVENTO CLIQUE NO QUADRO DO TRELLO
        $(".quadroTrelloMiniatura").off().on( "click", function() {
            var idQuadro = $(this).attr("data-idquadro")
            var nomeQuadro = $(this).attr("data-nomeQuadro")
            
            helper.idQuadroAtual = idQuadro
            helper.nomeQuadroAtual = nomeQuadro
            helper.consultaDados(cmp, event, helper);
            $("#screenFrames").hide()
            
            console.log("clicado quadro", idQuadro)
        });
        
        //EVENTO DE CLIQUE EM ADICIONAR NOVO QUADRO
        $("#divNewQuadro").off().on( "click", function() {
            var windowHash = window.location.hash;
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Quadro_Trello__c",
                "panelOnDestroyCallback": function(event) {
                    helper.consultaQuadros(cmp, event, helper)
                    window.location.hash = windowHash;
                },
                "navigationLocation":"LOOKUP"
            });
            createRecordEvent.fire();
        });
        
        //EVENTO DE CLIQUE EM ADICIONAR NOVO QUADRO
        $("#divTarefasEquipe").off().on( "click", function() {
            helper.popupTarefasEquipe(cmp, event, helper)
        });
    },
    
    adicionaMembroTarefa: function(cmp, event, helper, idMembro){
        var action = cmp.get("c.adicionarMembroAtividade");
        
        action.setParams({
            taskId: helper.taskClicada,
            novoMembroId: idMembro
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso confirma item check")
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo, membro adicionado.", "Success", "dismissable")
                //helper.configuraPopupCompartilhamento(cmp, event, helper, 'Quadro')
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR membro", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    removeMembroTarefa: function(cmp, event, helper, idMembro){
        
        console.log("--------------");
        console.log(helper.membrosTarefaAtual + ", " + idMembro);
        console.log("--------------");
        var action = cmp.get("c.removerMembroAtividade");
        
        action.setParams({
            taskId: helper.taskClicada,
            membroIdParaRemover: idMembro
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //- - - - - - - -CALLBACK DA REQUISIÇÃO- - - - - - - -
        action.setCallback(this, function (response) {
            var state = response.getState(); 
           
            if (state === "SUCCESS") {
                helper.userimagefunction(cmp, event, helper);
                console.log("sucesso confirma item check")
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo, membro removido.", "Success", "dismissable")
                //helper.configuraPopupCompartilhamento(cmp, event, helper, 'Quadro')
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR membro", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    confirmaItemChecklist: function(cmp, event, helper, idChecklist){
        var action = cmp.get("c.completaChecklist");
        
        action.setParams({
            idChecklist: idChecklist
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso confirma item check")
                
                var checkboxesMarcados = $('.checkBoxChecklist').filter(':checked');
                var totalCheckboxes = $('.checkBoxChecklist').length;
                var concluidoTrueCount = checkboxesMarcados.length;
                var percentConcluido = ((concluidoTrueCount / totalCheckboxes) * 100).toFixed(1);
                
                $('#porcentagemConcluida').html(percentConcluido + "%")
                $('#progressBarChecklist').attr('value', concluidoTrueCount);
                $('#progressBarChecklist').attr('max', totalCheckboxes);
                
                //helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo, compartilhamento atualizado.", "Success", "dismissable")
                //helper.configuraPopupCompartilhamento(cmp, event, helper, 'Quadro')
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    removeConfirmaChecklist:function(cmp, event, helper, idChecklist){
        var action = cmp.get("c.unableChecklist");
        
        action.setParams({
            idChecklist: idChecklist
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso confirma item check")
                
                var checkboxesMarcados = $('.checkBoxChecklist').filter(':checked');
                var totalCheckboxes = $('.checkBoxChecklist').length;
                var concluidoTrueCount = checkboxesMarcados.length;
                var percentConcluido = ((concluidoTrueCount / totalCheckboxes) * 100).toFixed(1);
                
                $('#porcentagemConcluida').html(percentConcluido + "%")
                $('#progressBarChecklist').attr('value', concluidoTrueCount);
                $('#progressBarChecklist').attr('max', totalCheckboxes);
                
                
                //helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo, compartilhamento atualizado.", "Success", "dismissable")
                //helper.configuraPopupCompartilhamento(cmp, event, helper, 'Quadro')
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    excluiItemChecklist:function(cmp, event, helper, idChecklist, elemento){
        var action = cmp.get("c.deleteChecklistTarefa");
        
        action.setParams({
            idChecklist: idChecklist
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso exclui item check")
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo, item de checklist Excluído", "Success", "dismissable")
                $(elemento).parents('.itemChecklist').remove()
                
                var checkboxesMarcados = $('.checkBoxChecklist').filter(':checked');
                var totalCheckboxes = $('.checkBoxChecklist').length;
                var concluidoTrueCount = checkboxesMarcados.length;
                var percentConcluido = ((concluidoTrueCount / totalCheckboxes) * 100).toFixed(1);
                
                $('#porcentagemConcluida').html(percentConcluido + "%")
                $('#progressBarChecklist').attr('value', concluidoTrueCount);
                $('#progressBarChecklist').attr('max', totalCheckboxes);
                
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    popupTarefasEquipe: function(cmp, event, helper){
        helper.showSpinner(cmp)
        
        var userId = $A.get("$SObjectType.CurrentUser.Id").slice(0, -3);
        console.log("ID USUARIO", userId)
        $("#tabelaEquipe").css('display', 'flex')
        
        if(!(helper.anoSelecionado || helper.mesSelecionado)){
            // Obtém a data atual
            var dataAtual = new Date();
            
            // Obtém o mês (vale de 0 a 11, onde 0 é janeiro e 11 é dezembro)
            var mesAtual = dataAtual.getMonth() + 1; // Adicionamos 1 para obter o número do mês correto
            var anoAtual = dataAtual.getFullYear();
            
            var mesFormatado = mesAtual < 10 ? '0' + mesAtual : mesAtual;
            
            $("#mes").val(mesFormatado)
            $("#anos").val(anoAtual)
            helper.mesSelecionado = mesFormatado
            helper.anoSelecionado = anoAtual
        }
        
        $("#mes").off().on('change', function() {
            var mesSetado = $(this).val()
            helper.mesSelecionado = mesSetado
            console.log("change ano", mesSetado)
            helper.popupTarefasEquipe(cmp, event, helper)
        });
        
        $("#anos").off().on('change', function() {
            var anoSetado = $(this).val()
            helper.anoSelecionado = anoSetado
            console.log("change ano", anoSetado)
            helper.popupTarefasEquipe(cmp, event, helper)
        });
        
        $("#colaborador").off().on('change', function() {
            var colaboradorSelecionado = $(this).val()
            helper.colaboradorSelecionado = colaboradorSelecionado
            console.log("change colaborador", colaboradorSelecionado)
            helper.popupTarefasEquipe(cmp, event, helper)
        });
        
        var ultimoDiaDoMes = new Date(helper.anoSelecionado, helper.mesSelecionado, 0).getDate();
        var dataInicial = ""+helper.anoSelecionado+"-"+helper.mesSelecionado+"-01"
        var dataFinal = ""+helper.anoSelecionado+"-"+helper.mesSelecionado+"-"+ultimoDiaDoMes+""
        
        if(helper.colaboradorSelecionado){
            var query = "SELECT id, Subject, ActivityDate, Status_do_gestor__c, CompletedDateTime, Description, Meta__c, Peso_Meta__c, Owner.Name from Task WHERE ActivityDate > "+dataInicial+" AND ActivityDate < "+dataFinal+" AND Meta__c = true AND ID_do_Gestor__c = '"+userId+"' AND OwnerId = '"+helper.colaboradorSelecionado+"'"
        }else{
            var query = "SELECT id, Subject, ActivityDate, Status_do_gestor__c, CompletedDateTime, Description, Meta__c, Peso_Meta__c, Owner.Name from Task WHERE ActivityDate > "+dataInicial+" AND ActivityDate < "+dataFinal+" AND Meta__c = true AND ID_do_Gestor__c = '"+userId+"'"
        }
        
        console.log("QUERY", query)
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Info", "dismissable")

        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (tarefas) {
            console.log(tarefas)
	
            // Objeto para armazenar as metas por colaborador
            const metasPorColaborador = {};
            
            // Iterar sobre as tarefas
            tarefas.forEach(tarefa => {
                const ownerId = tarefa.OwnerId;
                const ownerName = tarefa.Owner.Name;
                
                // Verificar se o valor já existe no select
                var alreadyExists = $("#colaborador option").filter(function() {
                    return $(this).val() == ownerId;
                }).length > 0;
                
                // Se o valor não existir, adicione-o
                if (!alreadyExists) {
                    $("#colaborador").append("<option value='" + ownerId + "'>" + ownerName + "</option>");
                }            
            
                // Se o colaborador ainda não estiver no objeto, criar uma entrada para ele
                if (!metasPorColaborador[ownerId]) {
                    metasPorColaborador[ownerId] = {
                        Nome: ownerName,
                        Metas: []
                    };
                }
            
                // Adicionar a meta à entrada do colaborador
                const metaKey = `Meta_${Object.keys(metasPorColaborador[ownerId].Metas).length + 1}`;
                const pesoMetaKey = `Peso_${metaKey}`;
            	const linkTarefa = "https://hospcom.my.site.com/Sales/s/task/" + tarefa.Id
                
                const meta = {
                    Nome: metaKey,
                    Status: tarefa.Status_do_gestor__c,
                    Peso: tarefa.Peso_Meta__c,
                    Descricao: tarefa.Description,
                    Link: linkTarefa
                };
            
                metasPorColaborador[ownerId].Metas.push(meta);
            });
        
        	console.log("METAS POR COLABORADOR", metasPorColaborador)
            
            // Converter o objeto de metas por colaborador de volta para um array
            const resultadoFinal = Object.values(metasPorColaborador).map(function(colaborador) {
                var resultado = { 
                    Nome: colaborador.Nome,
                };
                
                colaborador.Metas.reduce(function(result, meta) {
                    result[meta.Nome] = meta.Status;
                    result[`Peso_${meta.Nome}`] = meta.Peso;
                    result[`Descricao_${meta.Nome}`] = meta.Descricao;
                    result[`Link_${meta.Nome}`] = meta.Link;
                    return result;
                }, resultado);
                
                return resultado;
            });
        
        	console.log("RESULTADO FINAL", resultadoFinal)


            //-------------------------------------------------------------------
            //Função para calcular a porcentagem de SIM em comparação com NÃO
            var calcularPorcentagem = (colaborador) => {
              let totalSim = 0;
              let totalNao = 0;
              let totalGeral = 0;
            
              // Iterar sobre as chaves do colaborador
              Object.keys(colaborador).forEach(chave => {
                if (chave.startsWith("Meta_")) {
                  const valorMeta = colaborador[chave];
                  const pesoKey = `Peso_${chave}`;
                  const peso = colaborador[pesoKey] || 0;
            
                  if (valorMeta === "OK") {
                    totalSim += peso;
                  } else if (valorMeta === "NÃO") {
                    totalNao += peso;
                  }
                  totalGeral += peso;
                }
              });
            
              const porcentagemSim = (totalSim / totalGeral) * 100 || 0;
              const porcentagemNao = (totalNao / totalGeral) * 100 || 0;
            
              return {
                TotalSim: totalSim,
                TotalNao: totalNao,
                PorcentagemSim: porcentagemSim,
                PorcentagemNao: porcentagemNao
              };
            };
            
            // Calcular a porcentagem para cada colaborador
           	const resultadoFinal2 = resultadoFinal.map(colaborador => {
              const resultado = { Nome: colaborador.Nome, TotalFinal: 0 };
            
              // Adicionar cada chave ao resultado
              Object.keys(colaborador).forEach(chave => {
                resultado[chave] = colaborador[chave];
              });
            
              // Calcular e adicionar as porcentagens ao resultado
              const porcentagens = calcularPorcentagem(colaborador);
              Object.assign(resultado, porcentagens);
            
              return resultado;
            });
            console.log("RESULTADO FINAL DEPOIS DO TOTAL", resultadoFinal2)
			//------------------------------------------------------------------
            
			//CRIA OS CAMPOS NO MAPA DA TABELA----------------------------------
            // Obter todas as chaves de metas de todas as entradas
            const metaKeys = resultadoFinal.reduce((keys, tarefa) => {
                return keys.concat(Object.keys(tarefa).filter(key => key !== 'Nome'));
            }, []).filter((value, index, self) => self.indexOf(value) === index); // Remover duplicatas
            

            // Criar o mapa de campos
            const mapaDeCampos = [
                { label: 'Nome', fieldName: 'Nome', type: 'text', sortable: true, initialWidth: 160, }
            ];
            	
            metaKeys.forEach((metaKey, index) => {
                if(metaKey.includes("Link")){
                	var type = "url"
                }else{
                    var type = "text"
                }

                mapaDeCampos.push({
                    label: metaKey.replaceAll("_", " "),
                    fieldName: metaKey,
                    type: type,
                    initialWidth: 120,
                    sortable: false
                });
            });
			
            mapaDeCampos.push({
                label: "% Total",
                fieldName: "PorcentagemSim",
                type: 'text',
                sortable: false
            });

			console.log("metaKeys", metaKeys)
			console.log("MAPA DE CAMPOS", mapaDeCampos)
            console.log("RESULTADO F", resultadoFinal2)
    		
    		$("#closePopupTarefasEquipe").off().on( "click", function() {
                console.log("clicado close metas equipe")
                $("#tabelaEquipe").css("display","none")
            });
    		
    		cmp.set('v.columns', mapaDeCampos);
            cmp.set("v.data", resultadoFinal2);

			helper.hideSpinner(cmp)
        })
        
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO
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
    
    consultaDados: function(cmp, event, helper){
        var query = "SELECT id, name, (SELECT id, Subject, ActivityDate, Description, Meta__c, OwnerId, Owner.Name, ID_do_Gestor__c, Membros_da_Atividade__c from Tasks WHERE Status != 'Concluído') from cartaoTrello__c Where Quadro_Trello__c='"+helper.idQuadroAtual+"'";
        helper.showSpinner(cmp)
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (cartoes) {
            console.log("CARTOES", cartoes)
            helper.cartoes = cartoes
            helper.preencheView(cmp, event, helper)
            helper.hideSpinner(cmp)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //PREENCHE VIEW COM OS CARTOES E TASKS
    preencheView:function(cmp, event, helper){
        //console.log("PREENCHE VIEW")
        //LIMPA OS CARTOES NA VIEW
        $("#screenCards").empty()
        //SETA O NOME DO QUADRO ATUAL
        $("#inputTituloQuadro").val(helper.nomeQuadroAtual)
        
        if(helper.cartoes.length == 0){
            helper.alertaErro(cmp, event, helper, "Este quadro não possuí nenhum cartão disponível. Se desejar, utilize o botão '+' para adicionar um novo.", "Atenção", "Warning", "dismissable")
        }
        
        helper.cartoes.forEach(function(cartaoAtual){
            var tituloCartao = cartaoAtual.Name
            var idCartao = cartaoAtual.Id
            var tasks = cartaoAtual.Tasks
            
            var html = "<div class='cartaoTrello' data-idCartao='"+idCartao+"'>\
               <div class='divSuperiorCartao'>\
                  <!-- HEADER CARTAO -->\
                  <div class='headerCartao'>\
                     <input class='inputTituloCartao' value='"+tituloCartao+"'></input>\
					<div class='actionCartao'>\
						<i class='fa fa-share-alt-square compartilhaCartao' aria-hidden='true' title='Compartilhar cartão'></i>\
						<i class='fa fa-times removeCartao' aria-hidden='true' title='Remover cartão'></i>\
					</div>\
                  </div>\
                  <!-- BODY CARTAO -->\
                  <div class='bodyCartao' id='bodyCartao'>\
                  </div>\
               </div>\
               <!-- FOOTER CARTAO -->\
               <div class='footerCartao'>\
                  <div class='addTaskIcon'>\
                     <i class='fa fa-plus' aria-hidden='true'></i>\
                  </div>\
                  <div class='addTaskText'>\
                     Adicionar uma tarefa\
                  </div>\
               </div>\
            </div>"
            
            $("#screenCards").append(html)
            
            //VERIFICA SE EXISTE TASKS PARA O CARTAO ATUAL
            if (tasks) {
                tasks.forEach(function (taskAtual) {
                    var idTask = taskAtual.Id;
                    var userId = $A.get("$SObjectType.CurrentUser.Id").slice(0, -3);
                    
                    var idGestor = taskAtual.ID_do_Gestor__c;
                    var assuntoTask = taskAtual.Subject;
                    var dataVencimento = new Date(taskAtual.ActivityDate + 'T00:00:00');
                    var idOwner = taskAtual.Owner.Id;
                    var idOwnerShort = taskAtual.Owner.Id.slice(0, -3);
                    var OwnerName = taskAtual.Owner.Name;
                    
                    var consulta = "SELECT Membros_da_Atividade__c FROM Task WHERE Id = '" + idTask + "'";
                    
                    // REALIZA A CONSULTA
                    helper.soql(cmp, consulta)
                    
                    // QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
                    .then(function (tarefas) {
                        console.log(tarefas);
                    });
                    
                    console.log('consulta ^');
                    
                    if (taskAtual.hasOwnProperty('Membros_da_Atividade__c')) {
                        var membrosTarefa = taskAtual.Membros_da_Atividade__c.split(',');
                        console.log("MEMBROS TAREFA", membrosTarefa);
                        
                        // Consulta para buscar informações dos usuários
                        var consultaUsuarios = "SELECT Id, MediumPhotoUrl FROM User WHERE Id IN ('" + membrosTarefa.join("','") + "')";
                        helper.soql(cmp, consultaUsuarios)
                        .then(function (usuarios) {
                            usuarios.forEach(function (usuario) {
                                // Adiciona cada imagem de usuário ao array imageUsers
                                helper.imageUsers.push({
                                    Id: usuario.Id,
                                    MediumPhotoUrl: usuario.MediumPhotoUrl
                                });
                            });
                            
                        });
                        
                    } else {
                        var membrosTarefa = [];
                    }
                    
                    // Adiciona o id do Daniel em toda tarefa atual, assim, ele visualizará todas
                    membrosTarefa.push("2F005i0000000JFXuAAO");
                    membrosTarefa.push("005i0000000JFXu");
                    
                    console.log("USER ID ATUAL", userId);
                    console.log("ID OWNER SHORT", idOwnerShort);
                    console.log("ID OWNER", idOwner);
                    console.log("ID GESTOR TAREFA", idGestor);
                    console.log("MEMBROS TAREFA", membrosTarefa);
                    
                    if ((userId != idOwner) && (userId != idOwnerShort)) {
                        if (userId != idGestor) {
                            if (!membrosTarefa.includes(userId)) {
                                return;
                            }
                        }
                    }
                    
                    var membrosHtml = "";
                    var count = 0;
                    membrosTarefa.forEach(function (membroId) {
                        if (count < 4) { // Limita a 5 repetições
                            var imageUser = helper.imageUsers.find((element) => element.Id == membroId);
                            if (imageUser) {
                                membrosHtml += "<div class='imageTask' title='Membro' style='background-image: url(" + imageUser.MediumPhotoUrl + ")'></div>";
                                count++; // Incrementa o contador
                            }
                        }
                    });
                    

                    var opcoes = { day: 'numeric', month: 'short', year: 'numeric' };
                    var dataFormatada = dataVencimento.toLocaleDateString('pt-BR', opcoes);
                    
                    // Corpo da Task
                    var htmlTask = "<div class='cardTask' data-id='" + idTask + "'>\
                    <div class='editIcon'><i class='fa fa-pencil' aria-hidden='true'></i></div>\
                    <div class='tituloTask'>" + assuntoTask + "</div>\
                    <div class='footerTask'>\
                    <div>\
                    <i class='fa fa-clock-o' aria-hidden='true'></i>\
                    <span>" + dataFormatada + "</span>\
                    </div>\
					<div style='display: flex; gap: 2px;'>\
                    " + membrosHtml+"\
                    </div>\
					</div>\
                    </div>";
                    
                    
                    $(".bodyCartao:last").append(htmlTask);
                });
            }
        })
        helper.eventsAfterPreenche(cmp, event, helper);
    },
    
    eventsAfterPreenche:function(cmp, event, helper){
        //EVENTO ARRASTÁVEL DOS CARTOES
        var el = document.getElementById('screenCards');
        // Verifica se já existe uma instância Sortable no elemento
        if (Sortable.get(el)) {
            // Se existir, destrói a instância Sortable existente
            Sortable.get(el).destroy();
        }
        var sortable = Sortable.create(el, {
            group: {
                name: 'shared', //seta o nome do grupo de compartilhamento de itens
                pull: 'clone', // To clone: set pull to 'clone'
                put: false,
            },
            animation: 150,
            forceFallback: true,
            sort: true //DESATIVA A REORDENAÇÃO
        });
        
        //EVENTO ARRASTÁVEL DE TASK
        var elementos = $('.bodyCartao');
        $(elementos).each(function (i,e) {
            // Verifica se já existe uma instância Sortable no elemento
            if (Sortable.get(e)) {
                // Se existir, destrói a instância Sortable existente
                Sortable.get(e).destroy();
            }
            var sortable2 = Sortable.create(e, {
                group: {
                    name: 'tasks', //seta o nome do grupo de compartilhamento de itens
                },
                onAdd: function (evt) {
                    var idTask = $(evt.item).attr("data-id")
                    var newWhatId = $(evt.item).parents(".cartaoTrello").attr("data-idcartao")
                    helper.atualizaWhatId(cmp, event, helper, idTask, newWhatId)
                },
                animation: 150,
                forceFallback: true,
                sort: true //DESATIVA A REORDENAÇÃO
            });
        })
        
        $("#closePopup").on( "click", function() {
            console.log("clicado close")
            $("#popupTask").css("display","none")
        });
        
        //EVENTO CLIQUE TASK
        $(".cardTask").on( "click", function() {
            var idTask = $(this).attr("data-id")
            var idCartao = $(this).parents(".cartaoTrello").attr("data-idcartao")
            helper.configuraPopupTask(cmp, event, helper, idCartao, idTask)
        });
        
        //EVENTO FECHA POPUP COMPARTILHAMENTO
        $("#closeSharePopup").on( "click", function() {
            console.log("clicado closeSharePopup")
            $("#popupCompartilhaQuadro").css("display","none")
        });
        
        //EVENTO FECHA POPUP COMPARTILHAMENTO
        $("#returnIcon").off().on( "click", function() {
            console.log("clicado return icon")
            helper.consultaQuadros(cmp, event, helper);
            $("#screenFrames").css("display","flex")
        });
        
        //EVENTO FECHA POPUP COMPARTILHAMENTO
        $("#buttonActionRemoveAtividade").on( "click", function() {
            console.log("clicado apagar atividade")
            helper.removeAtividade(cmp, event, helper)
        });
        
        //EVENTO FECHA POPUP COMPARTILHAMENTO
        $("#buttonActionSalvaEdicao").off().on( "click", function() {
            console.log("clicado salvar atividade")
            helper.salvaAtividade(cmp, event, helper)
        });
        
        //EVENTO POPUP NOVO CHECKLIST
        $("#buttonNewChecklist").off().on( "click", function() {
            console.log("clicado novo checklist")
            
            //var idCartao = $(this).parents(".cartaoTrello").attr("data-idcartao")
            var createRecordEvent = $A.get("e.force:createRecord");
            var windowHash = window.location.hash;
            createRecordEvent.setParams({
                "entityApiName": "Checklist_Tarefa__c",
                'defaultFieldValues': {
                    'Id_Tarefa__c' : helper.taskClicada,
                    'Cartao_Trello__c' : helper.cartaoClicado
                },
                "panelOnDestroyCallback": function(event) {
                    helper.configuraPopupTask(cmp, event, helper, helper.cartaoClicado, helper.taskClicada)
                    window.location.hash = windowHash;
                },
                "navigationLocation":"LOOKUP"
            });
            createRecordEvent.fire();
        });
        
        //EVENTO POPUP NOVA ATIVIDADE
        $("#buttonNovaAtividade").off().on( "click", function() {
            console.log("clicado nova atividade")
            
            //var idCartao = $(this).parents(".cartaoTrello").attr("data-idcartao")
            var createRecordEvent = $A.get("e.force:createRecord");
            var windowHash = window.location.hash;
            createRecordEvent.setParams({
                "entityApiName": "Atividade__c",
                'defaultFieldValues': {
                    'Id_Tarefa__c' : helper.taskClicada,
                    'Cartao_Trello__c' : helper.cartaoClicado
                },
                "panelOnDestroyCallback": function(event) {
                    helper.configuraPopupTask(cmp, event, helper, helper.cartaoClicado, helper.taskClicada)
                    window.location.hash = windowHash;
                },
                "navigationLocation":"LOOKUP"
            });
            createRecordEvent.fire();
        });
        
        $("#inputTituloQuadro").change(function(){
            var newNameQuadro = $(this).val()
            var idQuadro = helper.idQuadroAtual
            var action = cmp.get("c.updateQuadroTrello");
            
            helper.showSpinner(cmp)

            action.setParams({
                quadroId: idQuadro,
                name: newNameQuadro,
                tituloQuadro: "",
            });
            
            helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Info", "dismissable")
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                
                //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                if (state === "SUCCESS") {
                    console.log("sucesso")
                    helper.hideSpinner(cmp)
                    helper.nomeQuadroAtual = newNameQuadro
                    helper.consultaDados(cmp, event, helper)
                }
                //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                else if (state === "INCOMPLETE") {
                    console.log("INCOMPLETO")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
        });
        
        //EVENTO COMPARTILHA QUADRO
        $("#buttonCompartilharQuadro").off().on( "click", function() {
            console.log("Compartilha quadro")
            helper.configuraPopupCompartilhamento(cmp, event, helper, 'Quadro')
        });
        
        //EVENTO COMPARTILHA QUADRO
        $("#buttonApagarQuadro").off().on( "click", function() {
            console.log("clique apagar quadro")
            helper.deleteQuadro(cmp, event, helper)
        });
        
        //EVENTO FINALIZA TAREFA
        $("#buttonFinaliza").off().on( "click", function() {
            console.log("clique finalizar tarefa")
            helper.showSpinner(cmp)

            var action = cmp.get("c.updateStatus");
            action.setParams({
                taskId: helper.taskClicada,
                status: "Concluído"
            });
            
            helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Info", "dismissable")
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                
                //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                if (state === "SUCCESS") {
                    console.log("sucesso")
                    $("#popupTask").css('display', 'none')
                    helper.hideSpinner(cmp)
                    helper.consultaDados(cmp, event, helper)
                }
                //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                else if (state === "INCOMPLETE") {
                    console.log("INCOMPLETO")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
        });
        
        //EVENTO REMOVE CARTAO
        $(".removeCartao").off().on("click", function() {
            var idCartao = $(this).parents(".cartaoTrello").attr("data-idcartao")            
            var action = cmp.get("c.deletaCartao");
            action.setParams({
                recordId: idCartao,
            });
            
            helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Info", "dismissable")
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                
                //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                if (state === "SUCCESS") {
                    console.log("sucesso")
                    helper.consultaDados(cmp, event, helper)
                }
                //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                else if (state === "INCOMPLETE") {
                    console.log("INCOMPLETO")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
        });
        
        //EVENTO REMOVE CARTAO
        $(".compartilhaCartao").off().on("click", function() {
            var idCartao = $(this).parents(".cartaoTrello").attr("data-idcartao")
            helper.cartaoClicado = idCartao
            console.log("CLIQUE COMPARTILHA CARTAO", idCartao)
            helper.configuraPopupCompartilhamento(cmp, event, helper, 'Cartao')
        });
        
        //EVENTO DO CLIQUE EM UMA NOVA TAREFA DO CARTAO
        $(".footerCartao").off().on( "click", function() {
            var idCartao = $(this).parents(".cartaoTrello").attr("data-idcartao")
            var createRecordEvent = $A.get("e.force:createRecord");
            var windowHash = window.location.hash;
            createRecordEvent.setParams({
                "entityApiName": "Task",
                'defaultFieldValues': {
                    'WhatId' : idCartao
                },
                "panelOnDestroyCallback": function(event) {
                    helper.consultaDados(cmp, event, helper)
                    window.location.hash = windowHash;
                },
                "navigationLocation":"LOOKUP"
                
            });
            createRecordEvent.fire();
        });
        
        // META TAREFA
        $("#buttonMarcaMeta").off().on( "click", function() {
            
            //obtem o usuario atual
            var userId = $A.get("$SObjectType.CurrentUser.Id").slice(0, -3);
            
            console.log("USUARIO ID", userId)
            console.log("ID GESTOR TASK", helper.gestorTaskAtual)
            
            if(helper.gestorTaskAtual != userId){
                helper.alertaErro(cmp, event, helper, "Apenas o gestor do usuário pode defini-la ou excluí-la das metas", "Atenção", "Error", "dismissable")
            	return
            }
            
            var valorAtual = $(this).attr('data-marcado')
            var valorSetado = valorAtual == 'true' ? false : true
            
            var action = cmp.get("c.updateTaskMeta");
            helper.showSpinner(cmp)
            
            action.setParams({
                taskId: helper.taskClicada,
                meta: valorSetado,
                pesoMeta: "1.0",
            });
            
            helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Info", "dismissable")
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                
                //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                if (state === "SUCCESS") {
                    console.log("sucesso")
                    
                    if(valorSetado == true){
                        var htmlCartao = "<i class='fa fa-check-square' aria-hidden='true'></i><div>Remover das metas</div>"
                        $("#buttonMarcaMeta").attr('data-marcado', 'true')
                        $("#buttonMarcaMeta").empty().append(htmlCartao)
                    }else{
                        var htmlCartao = "<i class='fa fa-square-o' aria-hidden='true'></i><div>Marcar como meta</div>"
                        $("#buttonMarcaMeta").attr('data-marcado', 'false')
                        $("#buttonMarcaMeta").empty().append(htmlCartao)
                    }
                    helper.hideSpinner(cmp)
                }
                //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                else if (state === "INCOMPLETE") {
                    console.log("INCOMPLETO")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
        });
        
        //EVENTO DO CLICK EM NOVO CARTAO
        $("#divNewCartao").off().on( "click", function() {
            var windowHash = window.location.hash;
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "cartaoTrello__c",
                'defaultFieldValues': {
                    'Quadro_Trello__c' : helper.idQuadroAtual
                },
                "panelOnDestroyCallback": function(event) {
                    helper.consultaDados(cmp, event, helper)
                    window.location.hash = windowHash;
                },
                "navigationLocation":"LOOKUP"
            });
            createRecordEvent.fire();
        });
    },
        
    deleteQuadro:function(cmp, event, helper){
        
        var action = cmp.get("c.deletaQuadro");
        var idQuadro = helper.idQuadroAtual;
        
        helper.showSpinner(cmp)
        action.setParams({
            recordId: idQuadro
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso")
                helper.hideSpinner(cmp)
                
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo", "Success", "dismissable")
                $("#screenFrames").css("display","flex")                
                helper.consultaQuadros(cmp, event, helper)
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);  
    },
    
    removeAtividade:function(cmp, event, helper){
        var action = cmp.get("c.deletaTask");
        var idTask = helper.taskClicada;
        action.setParams({
            recordId: idTask
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso")
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo", "Success", "dismissable")
                $("#popupTask").css("display","none")
                
                helper.consultaDados(cmp, event, helper)
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    salvaAtividade:function(cmp, event, helper){
        console.log("SALVANDO ATIVIDADE ID: ", helper.taskClicada)
        var newDescricao = cmp.get('v.valDescricao');
        var newTitulo = $("#inputTituloCartao").val()
        var taskId = helper.taskClicada
        var idCartao = helper.cartaoClicado
        var dataEntrega = new Date(cmp.get('v.valDataEntrega'));
        var opcoes = { day: 'numeric', month: 'numeric', year: 'numeric' };
        var dataFormatada = dataEntrega.toLocaleDateString('pt-BR', opcoes);
        
        console.log("taskId: ", taskId)
        console.log("name: ", newTitulo)
        console.log("description: ", newDescricao)
        console.log("entrega: ", dataFormatada)
        console.log("whatId: ", idCartao)
        
        var action = cmp.get("c.updateTask");
        action.setParams({
            taskId: taskId,
            subject: newTitulo,
            description: newDescricao,
            entregad: dataFormatada,
            whatId: idCartao
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso")
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo", "Success", "dismissable")
                helper.consultaDados(cmp, event, helper)
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    atualizaWhatId:function(cmp, event, helper, idTask, newWhatId){
        
        var action = cmp.get("c.updateTaskWhatId");
        action.setParams({
            whatId: newWhatId,
            taskId: idTask
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso")
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo", "Success", "dismissable")
                helper.consultaDados(cmp, event, helper)
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    compartilhaQuadro: function(cmp, event, helper){
        var action = cmp.get("c.compartilhaQuadro");
        var tipoCompartilhamento = "Edit"
        var idNovoUsuarioCompartilhado = helper.newUsuarioCompartilhado
        var idQuadroAtual = helper.idQuadroAtual
        
        action.setParams({
            recordId: idQuadroAtual,
            userId: idNovoUsuarioCompartilhado,
            tipoCompartilhamento: tipoCompartilhamento
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                //console.log("sucesso")
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo, compartilhamento atualizado.", "Success", "dismissable")
                helper.configuraPopupCompartilhamento(cmp, event, helper, 'Quadro')
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    compartilhaCartao: function(cmp, event, helper){
        var action = cmp.get("c.compartilhaCartao");
        var tipoCompartilhamento = "Edit"
        var idNovoUsuarioCompartilhado = helper.newUsuarioCompartilhado
        var idCartao = helper.cartaoClicado

        action.setParams({
            recordId: idCartao,
            userId: idNovoUsuarioCompartilhado,
            tipoCompartilhamento: tipoCompartilhamento
        });
        
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                console.log("sucesso")
                helper.alertaErro(cmp, event, helper, "Ok", "Tudo certo, compartilhamento atualizado.", "Success", "dismissable")
                helper.configuraPopupCompartilhamento(cmp, event, helper, 'Cartao')
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETO")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    //helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    //helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO, VERIFIQUE OS DADOS DA CONTA DO CLIENTE", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
         
    configuraPopupTask:function(cmp, event, helper, idCartao, idTask){
        helper.showSpinner(cmp)
        $("#popupTask").css("display","flex")
        $("#divDescAtividade").empty()
        
        var cartaoAtual = helper.cartoes.find((element) => element.Id == idCartao)
        var nomeCartao = cartaoAtual.Name
        var taskAtual = cartaoAtual.Tasks.find((element) => element.Id == idTask)
        var idGestorTaskAtual = taskAtual.ID_do_Gestor__c
        var tituloTask = taskAtual.Subject
        var descricaoTask = taskAtual.Description
        var checkMeta = taskAtual.Meta__c
        var nomeAtribuido = taskAtual.Owner.Name
        var idTarefa = taskAtual.Id
        var linkTarefa = "https://hospcom.my.site.com/Sales/s/task/" + idTarefa
        
        helper.cartaoClicado = idCartao
        helper.taskClicada = idTask;
        helper.membrosTarefaAtual = cartaoAtual.Tasks.find((element) => element.Id == idTask).Membros_da_Atividade__c
        helper.gestorTaskAtual = idGestorTaskAtual;
        helper.consultaUsuarios(cmp, event, helper)
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "info", "dismissable")
        
        cmp.set('v.valDescricao', descricaoTask);
        cmp.set('v.valDataEntrega', taskAtual.ActivityDate);
        $("#inputTituloCartao").val(tituloTask)
        $("#nomeListaPopup").html(nomeAtribuido)
        $("#nomeTarefa").attr('href', linkTarefa)
       
        
        helper.userimagefunction(cmp, event, helper);
        
        
        if(checkMeta == true){
            var htmlCartao = "<i class='fa fa-check-square' aria-hidden='true'></i><div>Remover das metas</div>"
            $("#buttonMarcaMeta").attr('data-marcado', 'true')
            $("#buttonMarcaMeta").empty().append(htmlCartao)
        }else{
            var htmlCartao = "<i class='fa fa-square-o' aria-hidden='true'></i><div>Marcar como meta</div>"
            $("#buttonMarcaMeta").attr('data-marcado', 'false')
            $("#buttonMarcaMeta").empty().append(htmlCartao)
        }
        
        //PREENCHE ATIVIDADES TASK
        //QUERY CONSULTA
        var query = "SELECT Id, Name, Descricao__c, Owner.Name from Atividade__c where Id_Tarefa__c = '"+helper.taskClicada+"'"
        console.log("QUERY", query)
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (atividadesTarefa) {
            $("#divDescAtividade").empty()
            
            atividadesTarefa.forEach(function(atividadeAtual){
                console.log("ATIVIDADES TAREFA", atividadesTarefa)
                var nomeAtividade = atividadeAtual.Name
                var idAtividade = atividadeAtual.Id
                var descricaoAtividade = atividadeAtual.Descricao__c ? atividadeAtual.Descricao__c : "Sem descrição" 
                var proprietarioAtividade = atividadeAtual.Owner.Name
                var html = "<div class='blocoAtividadePopup'>Criado por: "+proprietarioAtividade+"<br>"+descricaoAtividade+"</div>"
                $("#divDescAtividade").append(html)
            })
            
            var query = "SELECT Id, concluido__c, Name from Checklist_Tarefa__c where Id_Tarefa__c = '"+helper.taskClicada+"'"
            console.log("QUERY", query)
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (checkLists) {
                $("#itensChecklist").empty()
                
                console.log("ATIVIDADES TAREFA", checkLists)
                
                var totalItems = checkLists.length;
                var concluidoTrueCount = checkLists.filter(item => item.concluido__c == true).length;
                var percentConcluido = ((concluidoTrueCount / totalItems) * 100).toFixed(1);
                
                if(totalItems == 0){
                    $("#blocoChecklist").hide()
                }else{
                    $("#blocoChecklist").show()
                    checkLists.forEach(function(checklistAtual){
                        var nomeChecklist = checklistAtual.Name
                        var idChecklist = checklistAtual.Id
                        var checkListConcluido = checklistAtual.concluido__c
                        var statusCheckbox = checkListConcluido ? "checked" : ""
                        
                        var html = "\
                        <div class='itemChecklist'>\
                        <div style='display: flex'>\
                        <input data-idChecklist='"+idChecklist+"' "+statusCheckbox+" type='checkbox' class='checkBoxChecklist'></input>\
                        <div>"+nomeChecklist+"</div>\
                        </div>\
                        <div class='trashChecklistItem' data-idChecklist='"+idChecklist+"'><i class='fa fa-trash' aria-hidden='true'></i></div>\
                        </div>\
                        ";
                        
                        $("#itensChecklist").append(html);
                    })
                    
                    $('#porcentagemConcluida').html(percentConcluido + "%")
                    $('#progressBarChecklist').attr('value', concluidoTrueCount);
                    $('#progressBarChecklist').attr('max', totalItems);
                }
                                
                //QUANDO OCORRER UMA MUDANCA NO ESTADO DO CHECKBOX
                $('.checkBoxChecklist').off().on('change', function() {
                    var idChecklist = $(this).data('idchecklist');
                    // Verifique se o checkbox está marcado ou desmarcado
                    if($(this).is(':checked')) {
                        helper.confirmaItemChecklist(cmp, event, helper, idChecklist)
                    } else {
                        helper.removeConfirmaChecklist(cmp, event, helper, idChecklist)
                    }
                });
                
                //QUANDO OCORRER UMA MUDANCA NO ESTADO DO CHECKBOX
                $('.trashChecklistItem').off().on('click', function() {
                    var idChecklist = $(this).data('idchecklist');
                    helper.excluiItemChecklist(cmp, event, helper, idChecklist, this)
                    
                });
                
                helper.hideSpinner(cmp)
                
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
            
            //helper.hideSpinner(cmp)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
        
        
        userimagefunction:function(cmp, event, helper){
            $("#container-users").empty();
            var membrosHtml = "";
            
            console.log("-----------------------------------------------------------");
            console.log("          imagens:  ", helper.imageUsers);
            console.log("-----------------------------------------------------------");
            
            // Verifica se `Membros_da_Atividade__c` existe e popula `membrosHtml` com as imagens
            if (helper.membrosTarefaAtual) {
                var membrosTarefa = helper.membrosTarefaAtual.split(',');  // Certifique-se de que está separando os IDs por vírgula
                
                membrosTarefa.forEach(function (membroId) {
                    var imageUser = helper.imageUsers.find((element) => element.Id == membroId.trim());
                    
                    console.log("-----------------------------------------------------------");
                    console.log("          membros:  ", imageUser);
                    console.log("-----------------------------------------------------------");
                    
                    if (imageUser) {
                        var userProfileUrl = "https://hospcom.my.site.com/Sales/s/profile/" + imageUser.Id;
                        membrosHtml += "<a href='" + userProfileUrl + "' target='_blank'>" +
                            "<div class='imageMembroPopup' title='Membro' style='background-image: url(" + imageUser.MediumPhotoUrl + ")'></div>" +
                            "</a>";
                    }
                });
            }
            
            // Agora, insira `membrosHtml` como um irmão de `#nomeListaPopup`
            $("#container-users").append( membrosHtml );
            
        },
            configuraPopupCompartilhamento: function(cmp, event, helper, option){
        //EXIBE POPUP
        $("#popupCompartilhaQuadro").css("display","flex")
        
        cmp.set('v.valInputShare', '');
        helper.showSpinner(cmp)
        helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Info", "dismissable")
        
        if(option == 'Quadro'){
            var query = "SELECT ID, ParentID, RowCause, UserOrGroup.Name, UserOrGroup.Title, UserOrGroupId, AccessLevel FROM Quadro_Trello__Share WHERE ParentID = '"+helper.idQuadroAtual+"'";
            $("#compartilhaQuadroText").html("Compartilhar Quadro")
        }else{
            var query = "SELECT ID, ParentID, RowCause, UserOrGroup.Name, UserOrGroup.Title, UserOrGroupId, AccessLevel FROM cartaoTrello__Share WHERE ParentID = '"+helper.cartaoClicado+"'";
            $("#compartilhaQuadroText").html("Compartilhar Cartão")
        }
        
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (usuariosQuadro) {
            //console.log("usuarios", usuarios)
            $("#divUsersCompartilhados").empty()
            
            usuariosQuadro.forEach(function(usuarioQuadroAtual){
                var nomeUsuario = usuarioQuadroAtual.UserOrGroup.Name
                var idUsuario = usuarioQuadroAtual.UserOrGroupId
                var cargoUsuario = usuarioQuadroAtual.UserOrGroup.Title ? usuarioQuadroAtual.UserOrGroup.Title : "Cargo não cadastrado"
                var html = "<div class='userSharedLine' data-id='"+idUsuario  +"'>"+nomeUsuario+" - "+cargoUsuario+"</div>"
                $("#divUsersCompartilhados").append(html)
            })
            helper.eventsAfterPopupCompartilha(cmp, event, helper, option)
            helper.hideSpinner(cmp)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    eventsAfterPopupCompartilha: function(cmp, event, helper, option){
        //OCULTA DIV USUARIOS CASO CLIQUE FORA
        $(document).off().on("click",function() {
            $("#divSearchResults").hide()
        });
        
        //FUTURAMENTE ADICIONAR A OPCAO PARA REMOVER O COMPARTILHAMENTO
        $(".userSharedLine").off().on("click", function(){
            console.log("clicado usuario shared")
        })
        
        $(".buttonCompartilhaUser").off().on("click", function(){
            if(option == 'Quadro'){
                helper.compartilhaQuadro(cmp, event, helper);
            }else{
                helper.compartilhaCartao(cmp, event, helper);
            }
        })
    }
})