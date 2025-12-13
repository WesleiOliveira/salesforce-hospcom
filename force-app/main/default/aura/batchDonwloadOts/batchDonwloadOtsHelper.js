({
    helperMethod : function(cmp, event, helper) {
        helper.getUserInfo(cmp, event, helper)
        helper.getTecnicos(cmp, event, helper)
        helper.getRecordTypes(cmp, event, helper)
        helper.initEvents(cmp, event, helper)
        helper.getOts(cmp, event, helper)
    },
    
    numeroOt : "",
    numeroSerie: "",
    dataAbertura : "",
    tecnicoResponsavel : "",
    tipoOt : "",
    data : [],
    userEmail : "",
    
    getUserInfo : function(cmp, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");        
        var query = "select id, email from user where id = '"+userId+"'";
        
        helper.alertaErro(cmp, event, helper, "", "Carregando Dados...", "info", "", "dismissable")
        helper.soql(cmp, query)
        .then(function (usuario) {
            helper.userEmail = usuario[0].Email
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
    },
    
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
    
    getTecnicos : function(cmp, event, helper){
        
        helper.getPicklist(cmp, "WorkOrder", "T_cnico_Respons_vel__c")
        .then(function (tecnicos) {
            var html = ""
            tecnicos.forEach(function(item, index) {
                var htmlTemp = "<option value='"+item+"'>"+item+"</option>"
                html = html + htmlTemp
            });
            $("#tecnicoRespon").append(html)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    

    
    //eventos iniciais
    initEvents : function(cmp, event, helper){
        
        //entrada input numero ot
        let typingTimer;
        let doneTypingInterval = 1000; // tempo em milissegundos (1 segundo)
        $('#inputSearch').on('input', function () {
            clearTimeout(typingTimer); // limpa o timer anterior
            let input = $(this);
            typingTimer = setTimeout(function () {
                let valorDigitado = input.val();
                console.log('Valor digitado:', valorDigitado);
                helper.numeroOt = valorDigitado
                helper.getOts(cmp, event, helper)
                // aqui você pode chamar sua função ou fazer uma busca
            }, doneTypingInterval);
        });
        
        $('#inputNs').on('input', function () {
            clearTimeout(typingTimer); // limpa o timer anterior
            let input = $(this);
            typingTimer = setTimeout(function () {
                let valorDigitado = input.val();
                console.log('Valor digitado serie:', valorDigitado);
                helper.numeroSerie = valorDigitado
                helper.getOts(cmp, event, helper)
                // aqui você pode chamar sua função ou fazer uma busca
            }, doneTypingInterval);
        });
        
        //entrada input data
        $('#inputDate').on('change', function () {
            var dataSelecionada = $(this).val();
            helper.dataAbertura = dataSelecionada
            helper.getOts(cmp, event, helper)
            //console.log('Data selecionada:', dataSelecionada);
        });
        
        //entrada input tecnico
        $('#tecnicoRespon').on('change', function () {
            var tecnicoResponsavel = $(this).val();
            helper.tecnicoResponsavel = tecnicoResponsavel
            helper.getOts(cmp, event, helper)
        });
        
        //entrada input tipo de o.t
        $('#tiposOts').on('change', function () {
            var tipoOt = $(this).val();
            helper.tipoOt = tipoOt
            helper.getOts(cmp, event, helper)
        });
        
        //clique em baixar
        $(document).on('click', '.uniqueDownload', function () {
            var idDocumento = $(this).data('iddocumento');
            console.log("clicado", idDocumento);
            helper.uniqueDownload(cmp, event, helper, idDocumento)
        });
        
        $(document).on('click', '#buttonDownload3244324', function () {
            // Pergunta pro usuário se quer continuar
            if (confirm("Esse download será processado em segundo plano e enviado no seu e-mail ("+helper.userEmail+"). Deseja continuar?")) {
                let idsSelecionados = $('.checkbox-custom:checked').map(function() {
                    return this.id;
                }).get();
                
                helper.multipleDownload(cmp, event, helper, idsSelecionados)
                
                // Exemplo: imprimir os IDs dos selecionados no console
                selecionados.each(function() {
                    console.log($(this).attr('id'));
                });
                
            } else {
                console.log("Ação cancelada pelo usuário.");
            }
        });
        
    },
    
    multipleDownload : function(cmp, event, helper, idsSelecionados){
        
        console.log("selecionados", idsSelecionados)
        
        const url = 'https://workflowwebhook.hospcom.net/webhook/6363eeca-fc48-4790-959e-aa3c8ae68914';
        
        const payload = {
            selecionados: idsSelecionados,
            email : helper.userEmail
        };
        
        //helper.alertaErro(cmp, event, helper, "", "Iniciando Download...", "info", "", "dismissable")
        
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                // 'Authorization': 'Bearer seu_token' // se necessário
            },
            body: JSON.stringify(payload)
        })
        .then(response => response.json())
        .then(data => {
            console.log('Resposta da API:', data);
            //var downloadLink = data.PdfDownloadUrl;
            //window.location.href = downloadLink; // Inicia o download diretamente
            
        })
            .catch(error => {
            console.error('Erro na requisição:', error);
        });	
            
        },
            
    uniqueDownload : function(cmp, event, helper, idDocumento){
        const url = 'https://workflowwebhook.hospcom.net/webhook/8f0df25f-0177-4dc3-97d8-43f59b1fdf20';
        const payload = {
            contentId: idDocumento
        };
        
        helper.alertaErro(cmp, event, helper, "", "Iniciando Download...", "info", "", "dismissable")
        
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                // 'Authorization': 'Bearer seu_token' // se necessário
            },
            body: JSON.stringify(payload)
        })
        .then(response => response.json())
        .then(data => {
            console.log('Resposta da API:', data);
            var downloadLink = data.PdfDownloadUrl;
            window.location.href = downloadLink; // Inicia o download diretamente
            
        })
            .catch(error => {
            console.error('Erro na requisição:', error);
        });
        },
            
    //consulta ots e anexos
    getOts : function(cmp, event, helper){
        
        var { numeroOt, dataAbertura, tecnicoResponsavel, tipoOt, numeroSerie } = helper;
        var conditions = [
            numeroOt && `WorkOrderNumber LIKE '%${numeroOt}%'`,
            numeroSerie && `Numero_de_Serie__c LIKE '%${numeroSerie}%'`,
            dataAbertura && `Data_criacao__c = ${dataAbertura}`,
            tecnicoResponsavel && `T_cnico_Respons_vel__c LIKE '%${tecnicoResponsavel}%'`,
            tipoOt && `Tipo_de_registro__c = '${tipoOt}'`
        ].filter(Boolean);
        
        var query = "SELECT Id, WorkOrderNumber, Data_criacao__c, T_cnico_Respons_vel__c, Tipo_de_registro__c, Numero_de_Serie__c, Tipo_de_Servi_o__c FROM WorkOrder";
        query += conditions.length
        ? " WHERE " + conditions.join(" AND ")
        : " ORDER BY CREATEDDATE DESC LIMIT 30";

        console.log(query)
        helper.alertaErro(cmp, event, helper, "", "Carregando Ots...", "info", "", "dismissable")
        
        helper.soql(cmp, query)
        .then(function (ots) {
            //console.log("Ots", ots)
            
            if(ots.length == 0){
                alert("Nenhuma OT encontrada, tente mudar os filtros")
                return 0
            }
            
            var workOrders = ots.map(r => `'${r.WorkOrderNumber}'`).join(',');
            
            //console.log("WK", workOrders)
            
            var query = `
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, 
                ContentDocument.ContentSize, LinkedEntity.Name 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN (
                SELECT Id FROM WorkOrder 
                WHERE WorkOrderNumber IN (${workOrders})
            ) ORDER BY LinkedEntity.Name`;
            
            //console.log(query)
            helper.alertaErro(cmp, event, helper, "", "Carregando Anexos...", "info", "", "dismissable")
            
            helper.soql(cmp, query)
            .then(function (anexos) {
                
                if(anexos.length == 0){
                    alert("Nenhum anexo encontrado, tente mudar os filtros")
                    return 0
                }
                
                //console.log("Anexos", anexos)
                
                //uni o array de ots com anexos
                const resultado = anexos.map(anexo => {
                        const ot = ots.find(ot => ot.Id === anexo.LinkedEntityId);
                        return ot
                        ? Object.assign({}, anexo, ot) // junta os campos diretamente no nível do anexo
                    : anexo; // se não achar OT, mantém só o anexo
                });
            
                //console.log("misturado", resultado)
                
                helper.data = resultado
                helper.insertData(cmp, event, helper)
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
	
	//insere itens na tabela    
    insertData : function(cmp, event, helper){
        var data = helper.data
        
        console.log("data", data)
        
        //limpa elementos nao selecionados na tela
        $('.itemTable43534').each(function () {
            const checkbox = $(this).find('input[type="checkbox"]');
            if (!checkbox.is(':checked')) {
                $(this).remove();
            }
        });
        
        var html = ""
        
        // percorre o array `data`
        data.forEach(function(item, index) {
            
            var nomeDocumento = item.ContentDocument.Title.length > 30 ? item.ContentDocument.Title.slice(0, 27) + '...' : item.ContentDocument.Title;
            var numeroOt = item.LinkedEntity.Name;
            var tipoServico = item.Tipo_de_Servi_o__c
            var tipo = item.ContentDocument.FileExtension
			var tamanho = (item.ContentDocument.ContentSize / (1024 * 1024)).toFixed(2) + "MB"
			var idDocumento = item.ContentDocument.Id
            
            var htmlTemp = "<div class='itemTable43534'>\
                <div class='item43534'>\
                    <input type='checkbox' id='"+idDocumento+"' name='scales' class='checkbox-custom' />\
                </div>\
                <div class='item43534'>\
                   "+numeroOt+"\
                </div>\
                <div class='item43534'>\
                   "+tipoServico+"\
                </div>\
                <div class='item43534'>\
                    "+nomeDocumento+"\
                </div>\
                <div class='item43534'>\
                    "+tipo+"\
                </div>\
                <div class='item43534'>\
                    "+tamanho+"\
                </div>\
				<div class='item43534'>\
                    <a target='_blank' href='https://hospcom.my.site.com/Sales/s/contentdocument/"+idDocumento+"'>Visualizar</a>\
                </div>\
				<div class='item43534'>\
                    <a data-idDocumento='"+idDocumento+"' class='uniqueDownload'>Baixar</a>\
                </div>\
            </div>"
            
            html = html + htmlTemp
        });
        
        $("#bodyItens").append(html)
        
        
    },
    
        getRecordTypes : function(cmp, event, helper){
        helper.getRecordsTypes(cmp, "WorkOrder")
        .then(function (recordTypes) {
            
            const array = Object.entries(recordTypes).map(([nome, id]) => ({ nome, id }));
            var html = "";
            array.forEach(function(item, index) {
                var htmlTemp = "<option value='"+item.nome+"'>"+item.nome+"</option>";
                html = html + htmlTemp;
            });
            $("#tiposOts").append(html);
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    }
    
    
})