({    
    
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
    
    dataItens : [],
    dataItensPedido : [],
    idItemAtual : "",
    idPedidoAtual: "",
    
    mainFunction: function(cmp, event, helper) {
        console.log("Main func")
        helper.consultaPedidos(cmp, event, helper)
        //helper.salvaSeparacaoAPI(cmp, event, helper)
        
        $('#sliderInput1').on("click", function() {
            
            let isChecked = $('#inputSlider1').prop("checked");
            $("#inputSlider1").attr("checked", !isChecked);
            
            if(!isChecked){
                //console.log('Checkbox foi ativado.');
                helper.alertaErro(cmp, event, helper, "", "Entrada de itens por Scanner ativada", "Success", "", "dismissable")
                
                var timeout;
                $('.inputNms').on('input', function() {
                    var inputAtual = $(this);
                    var $currentInput = $(this); // Seleciona o input atual
                    var $nextInput = $currentInput.closest('.itemPcs').next().find('input');
                    
                    clearTimeout(timeout);
                    timeout = setTimeout(function() {
                        // A função que será executada após 1 segundo de inatividade
                        var quantidadeInput = $(inputAtual).attr("data-quantidade");
                        LDKJFLSKDA
                        console.log("contador entrada", helper.contadorInput);
                        
                        if(quantidadeInput <= 1 || helper.contadorInput == quantidadeInput - 1) {
                            console.log("DIFERENTE ENTRA");
                            helper.contadorInput = 0;
                            
                            if ($nextInput.length) {
                                // Move o foco para o próximo input se ele existir
                                $nextInput.focus();
                                
                                var idItem = $(inputAtual).attr("data-idItem");
                                var numerosSerie = $(inputAtual).val();
                                
                                //var numerosSerie = $(inputAtual).attr("data-quantidade");
                                helper.dataItens.push({ idItem: idItem, NumerosSerie: numerosSerie });
                            } else {
                                
                                var idItem = $(inputAtual).attr("data-idItem");
                                var numerosSerie = $(inputAtual).val();
                                helper.dataItens.push({ idItem: idItem, NumerosSerie: numerosSerie });
                                
                                // Se não houver próximo input, exibe um alerta
                                helper.alertaErro(cmp, event, helper, "Todos os números de série foram coletados", "Tudo Certo!", "Success", "", "dismissable")
                            }
                        } else {
                            var textoAtualInput = $(inputAtual).val();
                            $(inputAtual).val(textoAtualInput + ",");
                            helper.contadorInput = helper.contadorInput + 1;
                        }
                    }, 1000);
                });
                
            }else{
                //console.log('Checkbox foi desativado.');
                $('.inputNms').off('input');
                helper.alertaErro(cmp, event, helper, "", "Entrada de itens por Scanner desativada", "Success", "", "dismissable")
            }
        });
    },
    
    consultaPedidos: function(cmp, event, helper) {
        
        var userId = $A.get("$SObjectType.CurrentUser.Profile.Name");
        //var currentUser = cmp.get("v.currentUser");
		//console.log("Current Profile:", currentUser.Profile.Name);
        
        //console.log("ConsultaPedidos", username)
        
        var query = "SELECT id, Separacao_urgente__c, separador_pedido__c, ordernumber, separado__c, Nome_da_conta__c, Key_Account__c from order where status IN ('Em Andamento') AND Natureza_de_Opera_o__c IN ('VENDA', 'BONIFICAÇÃO', 'SERVIÇO', 'VENDA DA CONSIGNAÇÃO', 'REMESSA DE TROCA') AND separado__c = false ORDER BY OrderNumber DESC, Separacao_urgente__c"
        console.log(query)
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (pedidosVenda) {
            
            var html = ""
            
            console.log("pedidos venda", pedidosVenda)
            
            pedidosVenda.forEach(function(pedidoAtual){
                var numeroPedido = pedidoAtual.OrderNumber;
                var nomeConta = pedidoAtual.Nome_da_conta__c
                var idPedido = pedidoAtual.Id
                var separacaoUrgente = pedidoAtual.Separacao_urgente__c ? "urgente6546456" : ""
                
                html += "<div class='blocoPedido45334 "+separacaoUrgente+"' data-id='"+idPedido+"'>\
                    	<div>Pedido: <a target='_blank' href='https://hospcom.my.site.com/Sales/s/order/"+idPedido+"'>&nbsp;"+numeroPedido+"</a></div>\
                        <div>Conta: "+nomeConta+"</div>\
                        <div>Status: AG. SEPARAÇÃO</div>\
                    </div>"
            });
            
            $("#blocoPedidos").empty().append(html)
            
            $( ".blocoPedido45334" ).on( "click", function() {
                var idPedido = $(this).attr("data-id")
                helper.idPedidoAtual = idPedido;
                helper.consultaItemsPedido(cmp, event, helper, idPedido)
            });
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    contadorInput : 0,
    
    salvaSeparacao: function(cmp, event, helper){
        console.log("SALVA NS")
        var action = cmp.get("c.salvaNS");
        
        console.log("salva ns", helper.dataItens)
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            json: JSON.stringify(helper.dataItens),
        });
        //----------------------------------------------------
        
        helper.alertaErro(cmp, event, helper, "", "Salvando Separação...", "info", "", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCESSO")
                helper.alertaErro(cmp, event, helper, "", "Tudo certo!", "success", "", "dismissable")
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
    
    insereInfosLote: function(cmp, event, helper){
        console.log("insereInfosLote", helper.idItemAtual)
        const jsonResult = helper.createJsonForInputs(helper.idItemAtual);
        $("input[data-iditem='"+helper.idItemAtual+"']").val(JSON.stringify(jsonResult, null, 2));
        helper.dataItens.push({ idItem: helper.idItemAtual, NumerosSerie: JSON.stringify(jsonResult, null, 2) });
        console.log(JSON.stringify(jsonResult, null, 2));
    },
    
    createJsonForInputs: function(id) {
        const result = {
            id: id,
            data: [],
        };
        
        $('.inputQtd').each(function(index) {
            const qtd = $(this).val();
            const lts = $('.inputLts').eq(index).val();
            
            result.data.push({
                qtd: qtd,
                lts: lts,
            });
        });
        
        return result;
    },
    
    salvaSeparacaoAPI: function(cmp, event, helper) {
        const idItem = "42342342";
        const numeroSerie = "342342342";
        
        const webhookUrl = "https://hooks.zapier.com/hooks/catch/16880640/28v5l6u/";
        
        fetch(webhookUrl, {
            method: "POST",
            mode: "no-cors", 
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                idItem: idItem,
                numeroSerie: numeroSerie
            })
        })
        .then(response => {
            if (response.ok) {
                return response.json();
            } else {
                throw new Error("Falha ao enviar o webhook: " + response.statusText);
            }
        })
        .then(data => {
            console.log("Resposta do Zapier:", data);
        })
        .catch(error => {
            console.error("Erro ao enviar o webhook:", error);
        });
    },
    
    separaLote: function(cmp, event, helper, idItem){
        //console.log("SALVA NS")
        
        //console.log("SEPARANDO LOTE", idItem)
        console.log("ITENS PEDIDO", helper.dataItensPedido)
        
        $("#popupSeparacaoLote").css("display", "flex")
        $("#bodySeparacaoLote").empty()
        
        var itemPedido = helper.dataItensPedido.find((element) => element.Id == idItem);
        var idItem = itemPedido.Id
        var modelo = itemPedido.Product2.Modelo__c ? itemPedido.Product2.Modelo__c : "-"
        var nomeProduto = itemPedido.Product2.Name.length > 15 ? itemPedido.Product2.Name.substring(0, 15)+"..." : itemPedido.Product2.Name
        var codigoFabricante = itemPedido.Codigo_fabricante__c
        var numeroSerie = itemPedido.Description ? itemPedido.Description : ""
        var quantidade = itemPedido.Quantity
        var enderecoEstoque = itemPedido.Product2.Posicao_no_Estoque_153__c ? itemPedido.Product2.Posicao_no_Estoque_153__c : "-" 
        var quantidadeFaltaSeparar = itemPedido.Quantity
        
        $("#quantidadeFaltaSeparar").html(quantidadeFaltaSeparar)
        
        var html = "\
        <div class='itemPcs'>\
        <div class='itemHeaderTop438443'><a href='https://hospcom.my.site.com/Sales/s/orderitem/"+idItem+"' target='_blank'>&nbsp;"+nomeProduto+"</a></div>\
        <div class='itemHeaderTop438443'>"+codigoFabricante+"</div>\
        <div class='itemHeaderTop438443'>"+enderecoEstoque+"</div>\
        <div class='itemHeaderTop438443'><input type='number' min='0' class='inputQtd' style='width: 100%' /></div>\
        <div class='itemHeaderTop438443'><input class='inputLts'/></div>\
        <div class='itemHeaderTop438443' style='flex-direction: column'>\
        <a class='removeItemLote' data-idItem='"+idItem+"'>Remover</a>\
        <a class='confirmaItemLote' data-idItem='"+idItem+"'>Confirmar</a>\
        </div>\
        </div>";
        
        $("#bodySeparacaoLote").append(html);
        

        
        $(document).off("click", ".confirmaItemLote").on("click", ".confirmaItemLote", function () {
            
            var idItem = $(this).attr("data-idItem");
            var quantidadeSeparada = Number($(this).parents('.itemPcs').find('.inputQtd').val());
            var numeroLote = $(this).parents('.itemPcs').find('.inputLts').val();
            var quantidadeFaltaSeparar = Number($("#quantidadeFaltaSeparar").html());
            
            console.log("QUANTIDADE SEPARADA", quantidadeSeparada);
            console.log("NUMEROS LOTE", numeroLote);
            console.log("QUANTIDADE FALTA SEPARAR", quantidadeFaltaSeparar);
            
            if (quantidadeSeparada > quantidadeFaltaSeparar) {
                alert("A quantidade separada não pode ser maior que a quantidade que falta separar");
                return;
            }
            
            if (!quantidadeSeparada) {
                alert("A quantidade separada não pode ser vazia");
                return;
            }
            
            if (!numeroLote) {
                alert("O lote deve ser preenchido");
                return;
            }
            
            var quantidadeRestante = quantidadeFaltaSeparar - quantidadeSeparada;
            $("#quantidadeFaltaSeparar").html(quantidadeRestante);
            
            var itemPedido = helper.dataItensPedido.find((element) => element.Id == idItem);
            var idItem = itemPedido.Id
            var modelo = itemPedido.Product2.Modelo__c ? itemPedido.Product2.Modelo__c : "-"
            var nomeProduto = itemPedido.Product2.Name.length > 15 ? itemPedido.Product2.Name.substring(0, 15)+"..." : itemPedido.Product2.Name
            var codigoFabricante = itemPedido.Codigo_fabricante__c
            var numeroSerie = itemPedido.Description ? itemPedido.Description : ""
            var quantidade = itemPedido.Quantity
            var enderecoEstoque = itemPedido.Product2.Posicao_no_Estoque_153__c ? itemPedido.Product2.Posicao_no_Estoque_153__c : "-" 
            
            var html = "\
            <div class='itemPcs'>\
            <div class='itemHeaderTop438443'><a href='https://hospcom.my.site.com/Sales/s/orderitem/"+idItem+"' target='_blank'>&nbsp;"+nomeProduto+"</a></div>\
            <div class='itemHeaderTop438443'>"+codigoFabricante+"</div>\
            <div class='itemHeaderTop438443'>"+enderecoEstoque+"</div>\
            <div class='itemHeaderTop438443'><input type='number' min='0' class='inputQtd' style='width: 100%' /></div>\
            <div class='itemHeaderTop438443'><input class='inputLts'/></div>\
            <div class='itemHeaderTop438443' style='flex-direction: column'>\
            <a class='removeItemLote' data-idItem='"+idItem+"'>Remover</a>\
            <a class='confirmaItemLote' data-idItem='"+idItem+"'>Confirmar</a>\
            </div>\
            </div>";
            
            if(quantidadeRestante > 0){
                $("#bodySeparacaoLote").append(html);
            }
        });

        
        $(document).off("click", ".removeItemLote").on("click", ".removeItemLote", function () {
            
            var idItem = $(this).attr("data-idItem");
            
            var quantidadeSeparada = Number($(this).parents('.itemPcs').find('.inputQtd').val());
            //var numeroLote = $(this).parents('.itemPcs').find('.inputLts').val();
            var quantidadeFaltaSeparar = Number($("#quantidadeFaltaSeparar").html());
            
            console.log("QUANTIDADE REMOVIDA", quantidadeSeparada);
            
            $(this).parents('.itemPcs').remove()
            quantidadeFaltaSeparar = quantidadeFaltaSeparar + quantidadeSeparada
            $("#quantidadeFaltaSeparar").html(quantidadeFaltaSeparar);
        });
        
        
        
    },
    
    salvaComentario:function(cmp, event, helper, comentario){
        console.log("SALVA COMENTÁRIO")
        
        var action = cmp.get("c.salvaComentario");
        var idPedido = helper.idPedidoAtual;
        
        console.log("salva COMENTÁRIO", helper.dataItens)
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            comentario : comentario,
            orderId: idPedido
        });
        //----------------------------------------------------
        
        helper.alertaErro(cmp, event, helper, "", "Salvando Comentário...", "info", "", "dismissable")
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCESSO")
                helper.alertaErro(cmp, event, helper, "", "Tudo certo!", "success", "", "dismissable")
                //location.reload();
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
    
    consultaItemsPedido : function(cmp, event, helper, idPedido){
        console.log("consulta itens pedidos")
        
        var query = "SELECT id, Order.Comentarios__c, Product2.Posicao_no_Estoque_153__c, Product2.Modelo__c, Quantity, Description, Product2.Name, Codigo_fabricante__c from OrderItem where OrderId = '"+idPedido+"'"
        console.log(query)
        
        helper.alertaErro(cmp, event, helper, "", "Carregando itens...", "info", "", "dismissable")
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (ItensPedido) {
            
            var html = ""
            
            var comentarios = ItensPedido[0].Order.Comentarios__c
            $("#textAreaComent3245").val(comentarios)
            
            helper.dataItensPedido = ItensPedido;
            
            ItensPedido.forEach(function(itemPedido){
                
                var idItem = itemPedido.Id
                var modelo = itemPedido.Product2.Modelo__c ? itemPedido.Product2.Modelo__c : "-"
                var nomeProduto = itemPedido.Product2.Name.length > 15 ? itemPedido.Product2.Name.substring(0, 15)+"..." : itemPedido.Product2.Name
                var codigoFabricante = itemPedido.Codigo_fabricante__c
                var numeroSerie = itemPedido.Description ? itemPedido.Description : ""
                var quantidade = itemPedido.Quantity
                var enderecoEstoque = itemPedido.Product2.Posicao_no_Estoque_153__c ? itemPedido.Product2.Posicao_no_Estoque_153__c : "-" 
                
                html += "<div class='itemPcs'>\
                <div class='itemHeaderTop438443'><a class='separarLote' data-idItem='"+idItem+"'>Separar lote</a></div>\
                <div class='itemHeaderTop438443'><a target='_blank' href='https://hospcom.my.site.com/Sales/s/orderitem/"+idItem+"'>&nbsp;"+nomeProduto+"</a></div>\
                <div class='itemHeaderTop438443'>"+codigoFabricante+"</div>\
                <div class='itemHeaderTop438443'>"+enderecoEstoque+"</div>\
                <div class='itemHeaderTop438443'>"+quantidade+"</div>\
                <div class='itemHeaderTop438443'><input class='inputNms' data-idItem='"+idItem+"' data-quantidade='"+quantidade+"' value='"+numeroSerie+"'></input></div>\
                </div>"
            })
            
            $("#bodyPcs4353").empty().append(html)
            
            
            $( ".separarLote" ).on( "click", function() {
                var idItem = $(this).attr("data-idItem");
                helper.idItemAtual = idItem;
                helper.separaLote(cmp, event, helper, idItem)
            });
            
            /*
            $(document).on("click", function (event) {
                // Verifica se o clique foi fora da div e fora do botão que a abre
                if (
                    !$(event.target).closest("#popupSeparacaoLote").length && 
                    !$(event.target).closest(".separarLote").length
                ) {
                    $("#popupSeparacaoLote").css("display", "none");
                }
            }); */
            
            $('#textAreaComent3245').blur(function () {
                var comentario = $("#textAreaComent3245").val()
                console.log("clicado fora")
                helper.salvaComentario(cmp, event, helper, comentario)
            });
            
            $( "#buttonClose" ).on( "click", function() {
                $("#popupSeparacaoLote").css("display", "none");
            });
            
            $( "#buttonConcluir" ).on( "click", function() {
                $("#popupSeparacaoLote").css("display", "none");
                helper.insereInfosLote(cmp, event, helper);
            });
            
            var timeout;
            $('.inputNms').on('input', function() {
                var inputAtual = $(this);
                var $currentInput = $(this); // Seleciona o input atual
                var $nextInput = $currentInput.closest('.itemPcs').next().find('input');
                
                clearTimeout(timeout);
                timeout = setTimeout(function() {
                    // A função que será executada após 1 segundo de inatividade
                    var quantidadeInput = $(inputAtual).attr("data-quantidade");
                    
                    console.log("contador entrada", helper.contadorInput);
                    
                    if(quantidadeInput <= 1 || helper.contadorInput == quantidadeInput - 1) {
                        console.log("DIFERENTE ENTRA");
                        helper.contadorInput = 0;
                        
                        if ($nextInput.length) {
                            // Move o foco para o próximo input se ele existir
                            $nextInput.focus();
                            
                            var idItem = $(inputAtual).attr("data-idItem");
                            var numerosSerie = $(inputAtual).val();
                            
                            //var numerosSerie = $(inputAtual).attr("data-quantidade");
                            helper.dataItens.push({ idItem: idItem, NumerosSerie: numerosSerie });
                        } else {
                            
                            var idItem = $(inputAtual).attr("data-idItem");
                            var numerosSerie = $(inputAtual).val();
                            helper.dataItens.push({ idItem: idItem, NumerosSerie: numerosSerie });
                            
                            // Se não houver próximo input, exibe um alerta
                            helper.alertaErro(cmp, event, helper, "Todos os números de série foram coletados", "Tudo Certo!", "Success", "", "dismissable")
                        }
                    } else {
                        var textoAtualInput = $(inputAtual).val();
                        $(inputAtual).val(textoAtualInput + ",");
                        helper.contadorInput = helper.contadorInput + 1;
                    }
                    
                    //console.log("contador saida", helper.contadorInput);
                    //console.log("quantidade input", quantidadeInput);
                    //console.log('Palavra digitada:', $(inputAtual).val());
                }, 1000);
            });

                        
           $( "#buttonSalvaSeparacao" ).on( "click", function() {
                //console.log("DATA ITENS", helper.dataItens)
                helper.salvaSeparacao(cmp, event, helper)
            });
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    }
})