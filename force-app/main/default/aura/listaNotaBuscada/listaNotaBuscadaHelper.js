({
    notasBuscadas : [],
    
	mainFunction : function(cmp, event, helper) {
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
    
    lancaNota : function(cmp, event, helper, idNota, idPedido){
        console.log("LANÇA NOTA", idNota, idPedido)
        var action = cmp.get("c.lancaNota");
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idNota: idNota,
            idPedido: idPedido
        });
        //----------------------------------------------------
        
        helper.alertaErro(cmp, event, helper, "", "Lançando Nota...", "info", "", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCESSO")
                helper.alertaErro(cmp, event, helper, "", "Nota lançada", "success", "", "dismissable")
                location.reload();
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
    },
    
    lancaNotaContrato : function(cmp, event, helper, idNota, idContrato){
        console.log("LANÇA NOTA CONTRATO", idNota, idContrato)
        var action = cmp.get("c.lancaNotaContrato");
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idNota: idNota,
            idContrato: idContrato
        });
        //----------------------------------------------------
        
        helper.alertaErro(cmp, event, helper, "", "Lançando Nota...", "info", "", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCESSO")
                helper.alertaErro(cmp, event, helper, "", "Nota lançada", "success", "", "dismissable")
                location.reload();
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
    },
    
    consultaPCs : function(cmp, event, helper, CNPJ, valorNota, lancada, idNota){
        var query = "SELECT ID, CurrencyIsoCode, NAME, VALOR_TOTAL_COMPRADO__C, Data_de_aprova_o_da_cota_o__c, Status_do_PC__c, Valor_faturado__c FROM FORNECEDOR__C WHERE FORNECEDOR__R.CNPJ__C = '"+CNPJ+"' AND VALOR_TOTAL_COMPRADO__C >= "+valorNota+" AND Falta_lancar__c >= "+valorNota+" AND Data_de_aprova_o_da_cota_o__c != null AND Data_de_aprova_o_da_cota_o__c > 2024-05-01 ORDER BY Data_de_aprova_o_da_cota_o__c ASC"
        console.log(query)
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (pedidosDeCompra) {
            console.log("PCS RELACIONADOS", pedidosDeCompra)
            
            if(pedidosDeCompra.length == 0){
                $("#bodyPcs4353").append("<div style='display: flex; align-items: center; justify-content: center; width: 100%; height: 200px'>Nenhum PC relacionado encontrado</div>")
            	return
            }
            
            var html = ''
            pedidosDeCompra.forEach(function(pedidoDeCompra){
                
                var numeroPC = pedidoDeCompra.Name
                var dataCompra = pedidoDeCompra.Data_de_aprova_o_da_cota_o__c
                var valorComprado = pedidoDeCompra.Valor_total_comprado__c
                var moeda = pedidoDeCompra.CurrencyIsoCode
                var id = pedidoDeCompra.Id
                var estado = lancada ? "disabled" : ""
                let dataObj = new Date(dataCompra);
                
                const valorFormatado = new Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL',
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2,
                }).format(valorComprado).replace('R$', '').trim();
                
                let dataFormatada = dataObj.toLocaleDateString('pt-BR', {
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric'
                });
                
                html = html + "<div class='itemPcs'>\
                <div class='itemHeaderTop438443'><a target='_blank' href='https://hospcom.my.site.com/Sales/s/fornecedor/"+id+"'>(PC)&nbsp;"+numeroPC+"</a></div>\
                <div class='itemHeaderTop438443'>"+dataFormatada+"</div>\
                <div class='itemHeaderTop438443'>"+moeda+" "+valorFormatado+"</div>\
                <div class='itemHeaderTop438443'>\
                <button  id='"+id+"' "+estado+" class='buttonLancar'>Esboçar</button>\
                </div>\
                </div>"
            })
            $("#bodyPcs4353").append(html)
            
            $(".buttonLancar").on( "click", function() {
                var idPedido = $(this).attr('id');
                helper.lancaNota(cmp, event, helper, idNota, idPedido)
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    consultaContratos : function(cmp, event, helper, CNPJ, valorNota, lancada, idNota, dataEmissao){
        var query = "SELECT ID, NAME, Valor_Global__c, createddate, Status__c, Total_de_notas_fiscais__c, CurrencyIsoCode, Valor_do_contrato2__c FROM Contrato_de_compra__c WHERE FORNECEDOR__R.CNPJ__C = '"+CNPJ+"'  AND Inicio_do_contrato__c != null AND Inicio_do_contrato__c <= "+dataEmissao+""
       	//var query = "SELECT ID, CurrencyIsoCode, NAME, VALOR_TOTAL_COMPRADO__C, Data_de_aprova_o_da_cota_o__c, Status_do_PC__c, Valor_faturado__c FROM FORNECEDOR__C WHERE FORNECEDOR__R.CNPJ__C = '"+CNPJ+"' AND VALOR_TOTAL_COMPRADO__C >= "+valorNota+" AND Falta_lancar__c >= "+valorNota+" AND Data_de_aprova_o_da_cota_o__c != null AND Data_de_aprova_o_da_cota_o__c > 2024-05-01 ORDER BY Data_de_aprova_o_da_cota_o__c ASC"
        console.log("query contratos", query)
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (Contratos) {
            console.log("CONTRATOS RELACIONADOS", Contratos)
            
            if(Contratos.length == 0){
                $("#bodyPcs4353").append("<div style='display: flex; align-items: center; justify-content: center; width: 100%; height: 200px'>Nenhum contrato relacionado encontrado</div>")
            	retur
            }
            
            var html = ''
            Contratos.forEach(function(contrato){
                
                var numeroPC = contrato.Name
                var dataCompra = contrato.CreatedDate
                var valorComprado = contrato.Valor_do_contrato2__c ? contrato.Valor_do_contrato2__c : 0
                var moeda = contrato.CurrencyIsoCode
                var id = contrato.Id
                var estado = lancada ? "disabled" : ""
                let dataObj = new Date(dataCompra);
                
                const valorFormatado = new Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL',
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2,
                }).format(valorComprado).replace('R$', '').trim();
                
                let dataFormatada = "-"
                
                html = html + "<div class='itemPcs'>\
                <div class='itemHeaderTop438443'><a target='_blank' href='https://hospcom.my.site.com/Sales/s/fornecedor/"+id+"'>(CTR)&nbsp;"+numeroPC+"</a></div>\
                <div class='itemHeaderTop438443'>"+dataFormatada+"</div>\
                <div class='itemHeaderTop438443'>"+moeda+" "+valorFormatado+"</div>\
                <div class='itemHeaderTop438443'>\
                <button  id='"+id+"' "+estado+" class='buttonLancarContrato'>Esboçar</button>\
                </div>\
                </div>"
            })
            $("#bodyPcs4353").append(html)
            
            $(".buttonLancarContrato").on( "click", function() {
                var idContrato = $(this).attr('id');
                helper.lancaNotaContrato(cmp, event, helper, idNota, idContrato)
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },

    
    geraDANFE : function(cmp, event, helper, recordId){
        console.log("GERAR DANFE")
        var action = cmp.get("c.salvaDANFE");
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idNota: recordId,
        });
        //----------------------------------------------------
        
        helper.alertaErro(cmp, event, helper, "", "Gerando DANFE...", "info", "", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCESSO")
                var linkDANFE = response.getReturnValue()
                $("#iframePDF").attr('src', linkDANFE)
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
    },
    
    consultaDados: function(cmp, event, helper){
        
        var recordId = cmp.get("v.recordId")
        
        var query = "select Id, Natureza_de_Operacao__c, CurrencyIsoCode, Data_de_Emissao__c, Nome_do_Fornecedor__c, UF__c, Chave_de_Acesso__c, Lancada__c, Link_PDF__c, XML__c, CNPJ_Fornecedor_Formatado__c, Valor_da_nota__c FROM Nota_buscada__c WHERE Id = '"+recordId+"'"
        console.log(query)
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (notasBuscadas) {
            console.log(notasBuscadas)
            
            helper.notasBuscadas = notasBuscadas
            var nomeFornecedor = notasBuscadas[0].Nome_do_Fornecedor__c
            var CNPJ = notasBuscadas[0].CNPJ_Fornecedor_Formatado__c
            var chaveAcesso = notasBuscadas[0].Chave_de_Acesso__c
            var valorNota = notasBuscadas[0].Valor_da_nota__c
            var XML = notasBuscadas[0].XML__c
            var lancada = notasBuscadas[0].Lancada__c
            var naturezaOperacao = notasBuscadas[0].Natureza_de_Operacao__c
            var dataEmissao = notasBuscadas[0].Data_de_emissao__c
            var moeda = notasBuscadas[0].CurrencyIsoCode
            
            const valorFormatado = new Intl.NumberFormat('pt-BR', {
                style: 'currency',
                currency: 'BRL',
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
            }).format(valorNota).replace('R$', '').trim();
            
            $("#fornecedor").html(nomeFornecedor) 
            $("#chaveAcesso").html(chaveAcesso)
            $("#cnpj").html(CNPJ)
            $("#valorDaNota").html(moeda + "&nbsp;" + valorFormatado)
            
            //VERIFICA SE NAO EXISTE UM LINK DO DANFE
            if(!notasBuscadas[0].hasOwnProperty("Link_PDF__c")){
                helper.geraDANFE(cmp, event, helper, recordId)
            }else{
                var linkDANFE = notasBuscadas[0].Link_PDF__c
                $("#iframePDF").attr('src', linkDANFE)
            }
            
            if(naturezaOperacao == 'Serviço'){
                helper.consultaContratos(cmp, event, helper, CNPJ, valorNota, lancada, recordId, dataEmissao)
            }
            
            helper.consultaPCs(cmp, event, helper, CNPJ, valorNota, lancada, recordId)
            
            $('#buttonDownloadXML').click(function() {
                // Verifique se o navegador suporta a API Clipboard
                if (navigator.clipboard) {
                    navigator.clipboard.writeText(XML)
                        .then(() => {
                            alert("XML copiado para a área de transferência!");
                        })
                        .catch(err => {
                            console.error("Erro ao copiar para a área de transferência: ", err);
                        });
                } else {
                    // Se o navegador não suportar a API Clipboard, tente um método alternativo
                    let tempInput = $("<textarea>");
                    $("body").append(tempInput);
                    tempInput.val(XML).select();
                    document.execCommand("copy");
                    tempInput.remove();
                    alert("XML copiado para a área de transferência!");
                }
            });
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
})