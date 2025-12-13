({
    dataItensPC: [],
    condicoesPagamento: [],
    idPedido1: "",
    idPedido2: "",
    idPedido3: "",
    statusTomadaPreco: "",
    statusButtonGerarPDF: "disabled",
    statusDecisaoCompra: "",
    statusCotacao: "",
    usuariosDecisaoCompra: ["005i0000005d2fFAAQ", "0055A000008lqdW", "005i0000000ImCl", "0056e00000DhKVOAA3", "005i0000000JFXu", "005i0000000J08e", "005i0000000J08eAAC"],
    
    retornaRecorId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        return recordId
    },
    
    valorTotalItensSelecionados:[0, 0, 0],
    
    mainFunction : function(cmp, event, helper) {
        console.log("mainFunction")
        helper.consultaDados(cmp, event, helper)
    },
    
    salvaDecisaoCompra : function(cmp, event, helper){
        
        $('#spinnerDiv').css("display", "flex");
        
        console.log("SALVA DECISAO COMPRA")
        var idsItemPC = [];
        var id = helper.retornaRecorId(cmp, event, helper)
        
        // Iterando sobre cada linha da tabela com a classe 'linhaClass'
        $('.linhaClass').each(function() {
            // Encontrando todos os inputs checkbox marcados dentro da linha atual
            $(this).find('.checkboxItemFornecedor:enabled:checked').each(function() {
                // Obtendo o valor do atributo data-iditempc e adicionando ao array
                var idItemPC = $(this).data('iditempc');
                idsItemPC.push(idItemPC);
            });
        });
        
                var stringDeIds = idsItemPC.join(';');
        console.log(stringDeIds);
        console.log("idsItemPC", idsItemPC);
        
        
        if (!stringDeIds) {
            alert("Você deve escolher ao menos 1 fornecedor para salvar a decisão de compra. Marque o checkbox na linha do item")
            $('#spinnerDiv').css("display", "none");
            return;
        }
        
        
        var action = cmp.get("c.decisaoCompra");
        action.setParams({
            idCotacao: id,
            comprados: stringDeIds
        });
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                helper.alertaErro(cmp, event, helper, "Decisao de compra salva com sucesso", "Tudo Ok,", "Success", "dismissable")
                $('#spinnerDiv').css("display", "none");
                location.reload(true);
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("ERRO", errors[0].message)
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    salvaTomadaPreco : function(cmp, event, helper){
        
        $('.classeControleIf:not([disabled])').each(function() {
            if ($(this).val() == '') {
                alert('Erro: Preencha todos os campos.');
                campoVazioEncontrado = true;
                return false;
            }
        });
        
        $('#spinnerDiv').css("display", "flex");
        
        var jsonInfos = [];
        var justificativaDecisaoCompra = $("#justificativaDeCompra").val();
        var id = helper.retornaRecorId(cmp, event, helper)

        helper.dataItensPC[0].forEach(function(fornecedor, index) {            
            var tipoFrete = $("#tipoFreteF" + (index + 1) + ":enabled").val();
            var formaPagamento = $("#formaPagamentoF" + (index + 1) + ":enabled").val();
            var condicaoPagamento = $("#condicaoPagamentoF" + (index + 1) + ":enabled").val();
            var transportadora = $("#transportadoraF" + (index + 1) + ":enabled").val();
            var prazoRecebimento = $("#prazoRecebimentoF" + (index + 1) + ":enabled").val();
            var descricaoPagamento = $("#descricaoPagamentoF" + (index + 1) + ":enabled").val();
            var transportadoraData = $("#transportadoraF" + (index + 1) + ":enabled").attr('data-contaSelecionada');
            var moedaFrete = $("#moedaFreteF" + (index + 1) + ":enabled").val();
            var valorFrete = $("#valorFreteF" + (index + 1) + ":enabled").val().replaceAll('.', '').replace(',', '.');
            var tipoFrete = $("#tipoFreteF" + (index + 1) + ":enabled").val();
            console.log("JUSTIFICATIVA DECI COMPRA", justificativaDecisaoCompra)

            if (condicaoPagamento) {
                jsonInfos.push({
                    "idFornecedor": fornecedor.Fornecedor__r.Id,
                    "CondicaoPagamento": condicaoPagamento,
                    "DescricaoPagamento": descricaoPagamento,
                    "FormaPagamento": formaPagamento,
                    "Frete": tipoFrete,
                    "Prazo": prazoRecebimento,
                    "Transportadora": transportadoraData,
                    "MoedaFrete": moedaFrete,
                    "ValorFrete": valorFrete,
                    "TipoFrete": tipoFrete
                });
            }
        });
        
        let jsonInfosString = JSON.stringify(jsonInfos);
        console.log("JSON INFOS", jsonInfosString);
        
        let jsons = [];
        // Seleciona todos os inputs com a classe 'inputValueFornecedor'
        $('.inputValueFornecedor:enabled').each(function() {
            // Obtém o valor do atributo 'data-iditempc'
            let idProduto = $(this).data('iditempc');
            // Obtém o valor do atributo 'value'
            //let valorProduto = $(this).val().replace(',', '.');;
            let valorProduto = $(this).val().replaceAll('.', '');
            valorProduto = valorProduto.replace(',', '.');            
            
            //console.log("VALOR PRODUTO ANTES REPLACE", $(this).val())
            console.log("VALOR PRODUTO", valorProduto)
            
            // Cria um objeto JSON com os valores obtidos
            let json = {
                idProduto: idProduto,
                valorProduto: valorProduto
            };
            
            // Adiciona o objeto JSON ao array
            jsons.push(json);
        });
        let jsonString = JSON.stringify(jsons);
        console.log(jsonString);
        
        var jsonReconfig1 = jsonString.replaceAll('},', '};');
        var jsonReconfig2 = jsonInfosString.replaceAll('},', '};');
                    
        var action = cmp.get("c.tomadaDePreco");
        action.setParams({
            valores: jsonReconfig1,
            informacoes: jsonReconfig2,
            justificativa: justificativaDecisaoCompra,
            cotacao: id
        });
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                location.reload(true);
                helper.alertaErro(cmp, event, helper, "Tomada de preço salva com sucesso", "Tudo Ok,", "Success", "dismissable")
            }
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("ERRO", errors[0].message)
                    helper.alertaErro(cmp, event, helper, errors[0].message, "Algo saiu errado", "Error", "dismissable")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    helper.alertaErro(cmp, event, helper, "Erro desconhecido", "Algo saiu errado", "Error", "dismissable")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
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
    
    calcularTotal:function(cmp, event, helper){
        console.log("CALCULANDO TOTAIS DOS ITENS SELECIONADOS")
        
        // Inicializa o total para cada fornecedor
        const totalPorFornecedor = {};
        
        // Seleciona todas as linhas da tabela com a classe "linhaClass"
        $('tr.linhaClass').each(function() {
            const $linha = $(this);
            const $checkbox = $linha.find('.checkboxItemFornecedor:checked');
            
            if ($checkbox.length > 0) {
                // Corrige o valor total substituindo vírgulas por pontos
                const valorTotal = parseFloat($checkbox.data('valortotal').replaceAll('.', '').replace(',', '.'));
                const indiceFornecedor = $checkbox.data('indicefornecedor');
                
                if (!totalPorFornecedor[indiceFornecedor]) {
                    totalPorFornecedor[indiceFornecedor] = 0;
                }
                totalPorFornecedor[indiceFornecedor] += valorTotal;
            }
        });
        
        // Exibe o total calculado (por exemplo, no console ou atualizando o DOM)
        //console.log('Total por fornecedor:', totalPorFornecedor);
        
        $(".TotalItensSelecionados").text("0,00");
        for (const indiceFornecedor in totalPorFornecedor) {
            if (totalPorFornecedor.hasOwnProperty(indiceFornecedor)) {
                const total = totalPorFornecedor[indiceFornecedor];

                $("#TotalItensSelecionados"+indiceFornecedor).text(total.toFixed(2));
            }
        }
    
    },
    
    eventsAfterPreenche:function(cmp, event, helper){
        
        $("#salvarTomadaPreco").click(function() {
            helper.salvaTomadaPreco(cmp, event, helper)
        });
        
        $("#salvarDecisaoCompra").click(function() {
            helper.salvaDecisaoCompra(cmp, event, helper)
        });
        
        $(".gerarPdf").click(function() {
            console.log("CLIQUE GERAR PDF")
            
            if(helper.statusCotacao == '1 - Rascunho'){
                var url = "https://hospcom.my.site.com/Sales/s/sfdcpage/%2Fapex%2FAssistenteCotacaoPDF%3F%26id%3D"+this.id+""
                window.open(url, '_blank', 'width=1000,height=600');
            }else{
                var url = "https://hospcom.my.site.com/Sales/s/sfdcpage/%2Fapex%2FAssistentePedidoCompraPDF%3F%26id%3D"+this.id+""
                
                window.open(url, '_blank', 'width=1000,height=600');
            }
        });
        
        //REMOVE OBRIGATORIEDADE DO FRETE AO SELECIONAR O TIPO FOB
        $(".tipoFreteClass").change(function() {
			if($(this).val() == "CIF"){
				var indicePC = $(this).attr("data-indicePC")
				$("#transportadoraF"+indicePC+"").removeClass("classeControleIf");
			}
        });
        
        $(".wppButton").click(function() {
            $('#spinnerDiv').css("display", "flex");
            
            var idPC = $(this).attr("data-idpc") 
            var randomFileName = Math.random().toString(36).substring(2, 15); 
            var numeroBruto = this.id;
            
            if(numeroBruto == 'undefined'){
                helper.alertaErro(cmp, event, helper, "Ops, algo ocorreu!", "Este fornecedor não possuí número cadastrado. Revise a conta", "Error", "dismissable")
                $('#spinnerDiv').css("display", "none");
                return
            }
            
            console.log(idPC, randomFileName, numeroBruto)
            
            // REALIZA A CONSULTA
            helper.uploadPDF(cmp, randomFileName, "AssistenteCotacaoPDF", idPC)
            // QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (urlPdfPagina) {
                
                var numero = '55' + numeroBruto.replace(/\D/g, '');
                var mensagem = 'Olá! Tudo bem? Poderia me enviar uma cotação para os itens listados no PDF neste link: ' + urlPdfPagina + ' agradeço desde já pela atenção e fico no aguardo.';
                var url = 'https://wa.me/' + numero + '?text=' + encodeURIComponent(mensagem);
                $('#spinnerDiv').css("display", "none");
                window.open(url, '_blank');
                
            })
            // Trata excessão de erro
            .catch(function (error) {
                console.log(error);
                helper.alertaErro(cmp, event, helper, "Ops, algo ocorreu!", error, "Error", "sticky")
            });
            
        });
        
        //EVENTO DE CHANGE DOS CHECKBOX 
        $('.checkboxItemFornecedor').change(function() {
            //Verifica se o checkbox foi marcado ou desmarcado
            if ($(this).is(':checked')) {
                // Checkbox marcado
                $(this).parents('.linhaClass').find('.checkboxItemFornecedor:not(:checked)').each(function() {
                    // Desabilita o input do tipo checkbox
                    $(this).prop('disabled', true);
                });
            } else {
                $(this).parents('.linhaClass').find('.checkboxItemFornecedor:not(:checked)').each(function() {
                    // Desabilita o input do tipo checkbox
                    $(this).prop('disabled', false);
                });
            }
        });
        
        $('.checkboxItemFornecedor').on('change', helper.calcularTotal);
        
        $('.classInputValorFrete, .inputValueFornecedor').on('input', function() {
            console.log("INPUT VALUE FORNECEDOR")
            var value = $(this).val().replace(/\D/g, ""); // Remove qualquer caractere que não seja dígito
            value = (value / 100).toFixed(2) + ""; // Divide por 100 para considerar as casas decimais e converte para string
            value = value.replace(".", ","); // Substitui o ponto pela vírgula
            value = value.replace(/\B(?=(\d{3})+(?!\d))/g, "."); // Insere o ponto como separador de milhar
            $(this).val(value); // Atualiza o valor do campo
        });
        
        $("#buttonMenorPreco").click(function() {
            $(".linhaClass td").removeClass("highlight");
            $(".linhaClass").each(function() {
                var minVal = Number.MAX_VALUE;
                var minCell;
                
                $(this).find("td[data-valortotal]").each(function() {
                    var val = parseFloat($(this).attr('data-valortotal').replace(',', '.'));
                    if (val < minVal) {
                        minVal = val;
                        minCell = $(this);
                    }
                });
                
                $(this).find(".highlight").removeClass("highlight");
                minCell.addClass("highlight");
            });
        });
        
        $("#selecionarTodos").click(function() {
            $('input.checkboxItemFornecedor').prop('checked', false);
            
            $('.highlight').each(function() {
                // Seleciona o checkbox dentro do elemento atual e marca como checked
                $(this).find('input[type="checkbox"]').prop('checked', true).prop('disabled', false);
            });
            
            $('input.checkboxItemFornecedor:not(:checked)').prop('disabled', true);
            helper.calcularTotal(cmp, event, helper)

        });
        
        $(".selecionaTodosFornecedor").click(function() {
      
            var indicefornecedor = $(this).attr("data-indicefornecedor") 
            $('input.checkboxItemFornecedor').prop('checked', false);
            
            $('input[data-indicefornecedor="'+indicefornecedor+'"]').each(function() {
                $(this).prop('checked', true).prop('disabled', false);                
            });
            
            $('input.checkboxItemFornecedor:not(:checked)').prop('disabled', true);
            helper.calcularTotal(cmp, event, helper)
            
        });
        
        $("#buttonMenorPrazo").click(function() {
            $(".linhaClass td").removeClass("highlight");
            $(".linhaClass").each(function() {
                var minPrazo = Number.MAX_VALUE;
                var minCell;
                
                $(this).find("td[data-prazoentrega]").each(function() {
                    var prazo = parseInt($(this).attr('data-prazoentrega'));
                    if (prazo < minPrazo) {
                        minPrazo = prazo;
                        minCell = $(this);
                    }
                });
                
                $(this).find(".highlight").removeClass("highlight");
                minCell.addClass("highlight");
            });
        });
        
        //BOTAO LIMPAR TUDO
        $("#limparTudo").click(function() {
            $(".linhaClass td").removeClass("highlight");
            $('input.checkboxItemFornecedor').prop('disabled', false).prop('checked', false);
            helper.calcularTotal(cmp, event, helper)
            
        });
        
        $(document).click(function(event) {
            // Verifica se o clique foi fora da div divSearchResults
            if (!$(event.target).closest('.divSearchResults').length) {
                // Oculta a div divSearchResults se o clique foi fora dela
                $('.divSearchResults').hide();
            }
        });
        
        // Previne o clique dentro da divSearchResults de propagar para o documento
        $('.divSearchResults').click(function(event) {
            event.stopPropagation();
        });
        
        // Adicione um event listener para o evento 'keypress' no campo de entrada
        $('.inputPesquisaTransportadora').keypress(function(event) {
            
            var elemento = this
            
            if (event.which === 13) {
                var queryTerm = $(this).val();
                helper.alertaErro(cmp, event, helper, "Carregando contas...", "Aguarde,", "Info", "dismissable")
                
                var query = "SELECT id, Name from account WHERE Name LIKE '%"+queryTerm+"%' ORDER BY Name"
                //REALIZA A CONSULTA
                helper.soql(cmp, query)
                
                //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
                .then(function (contas) {
                    console.log("CONTAS", contas)
                    $(elemento).parent().find(".divSearchResults").empty().css("display", "block")
                    
                    contas.forEach(function(usuarioAtual){
                        var nomeUsuario = usuarioAtual.Name
                        var idUsuario = usuarioAtual.Id
                        var html = "<div class='userResultSearchShare' data-id='"+idUsuario  +"'>"+nomeUsuario+"</div>"
                        $(elemento).parent().find(".divSearchResults").append(html)
                    })
                    
                    //$(elemento).parent().find(".divSearchResults").css("display", "block")
                    
                    $(".userResultSearchShare").off().on("click", function() {
                        var idUsuarioClicado = $(this).attr('data-id')
                        var nomeClicado = $(this).html()
                        $(this).parents(".tg-0pky").find(".inputPesquisaTransportadora").attr('data-contaSelecionada', idUsuarioClicado)
                        $(this).parents(".tg-0pky").find(".inputPesquisaTransportadora").val(nomeClicado)
                        $(this).parent().hide()
                    });
                })
                
                //trata excessão de erro
                .catch(function (error) {
                    console.log(error)
                })
            }
        });
    },
    
    preencheTabela:function(cmp, event, helper){
        
        console.log("HELPER DATA ITENS PC", helper.dataItensPC)
        

        if(helper.statusCotacao == '1 - Rascunho'){
            var statusButtonWpp = '';
        }else{
            var statusButtonWpp = 'disabled';
        }
      
        //Adiciona cabeçalhos para os fornecedores
        helper.dataItensPC[0].forEach(function(fornecedor, index) {
            console.log("FORNECEDOR NO EACH", fornecedor)
            $('#prodTable thead tr').find('th').last().before('\
              <th class="tg-fymr" id="fornecedor' + (index + 1) + '">\
                ' + fornecedor.Fornecedor__r.Fornecedor__r.Name + '\
                <br><button class="customButton3 gerarPdf" id="'+fornecedor.Fornecedor__r.Id+'" title="Gera o PDF do Pedido de compra para o fornecedor atual">GERAR PDF</button>\
				<br><button '+statusButtonWpp+' class="customButton3 wppButton" data-idPC="'+fornecedor.Fornecedor__r.Id+'" id="'+fornecedor.Fornecedor__r.Fornecedor__r.Phone+'" title="Enviar PDF pelo Whatsapp (HABILITADO SOMENTE QUANDO A COTAÇÃO ESTIVER EM RASCUNHO)">ENVIAR P/ WHATSAPP</button>\
          		<br><button data-indiceFornecedor="'+(index + 1)+'" '+helper.statusDecisaoCompra+' class="customButton3 selecionaTodosFornecedor" id="'+fornecedor.Fornecedor__r.Id+'" title="Seleciona todos os itens para este fornecedor">SELECIONAR TODOS</button>\
			</th>');
        });
        
        //ITERA SOB CADA ITEM
        //UTILIZA A POSICAO 0 PARA PEGAR INFORMACOES GENÉRICAS
        helper.dataItensPC.forEach(function(itemPCAtual, index){
            
            console.log("ITEM PC ATUAL", itemPCAtual[0])
            
            var codigoProduto = itemPCAtual[0].Produto2__r.ProductCode
            var imagemProduto = ""
            var nomeProduto = itemPCAtual[0].Produto2__r.Name
            var comprar = itemPCAtual[0].Comprar__c
            var marcaProduto = itemPCAtual[0].Marca__c
            var ValorTotalUltimaCompra = itemPCAtual[0].ValorTotalUltimaCompra
            var ValorUnitarioUltimaCompra = itemPCAtual[0].ValorUnitarioUltimaCompra
            var DataDaUltimaCompra = itemPCAtual[0].DataDaUltimaCompra
            var parts = DataDaUltimaCompra.split('-');
            var year = parts[0];
            var month = parts[1];
            var day = parts[2];
            var formattedDate = DataDaUltimaCompra ? `${day}/${month}/${year}` : "N/D";
            var MoedaUltimaCompra = itemPCAtual[0].MoedaUltimaCompra
            var modeloProduto = itemPCAtual[0].Modelo__c ? itemPCAtual[0].Modelo__c : "Modelo N/D"
            var quantidade = itemPCAtual[0].Item_de_pedido_de_compra__r.Quantidade_total__c
            var valorUltimaCompra = itemPCAtual[0].Valor_unit_da_ultima_compra__c ? itemPCAtual[0].Valor_unit_da_ultima_compra__c : "Valor N/D"
            var unidadeMedida = itemPCAtual[0].Unidade_de_medida__c ? itemPCAtual[0].Unidade_de_medida__c : "UND N/D"
            var estadoInput = helper.statusTomadaPreco
            var estadoDecisaoCompra = helper.statusDecisaoCompra
            
            var html = "<tr class='linhaClass'>\
            <td class='tg-0pky'>"+index+"</td>\
            <td class='tg-0pky'>"+codigoProduto+"</td>\
            <td class='tg-0pky'>"+nomeProduto+"</td>\
            <td class='tg-0pky'>"+quantidade+"</td>\
            <td class='tg-0pky'>"+unidadeMedida+"</td>\
            <td class='tg-0pky'>"+ValorUnitarioUltimaCompra+"</td>\
            <td class='tg-0pky'>"+MoedaUltimaCompra+"</td>\
            <td class='tg-0pky'>"+ValorTotalUltimaCompra+"</td>\
            <td class='tg-0pky'>"+formattedDate+"</td>"
            
            itemPCAtual.forEach(function(itemPC, index) {
                console.log("ITEM NO INDEX", itemPC)
                
                var idItemPCF1 = itemPCAtual[index] ? itemPCAtual[index].Id : ""
                var prazoRecebimentoF1 = itemPCAtual[index] ? itemPCAtual[index].Fornecedor__r.Prazo_de_recebimento__c : ""
                var statusComprarF1 = itemPCAtual[index] ? itemPCAtual[index].Comprar__c : ""
                var statusExistenteF1 = itemPCAtual[index] ? "" : "disabled"
                var statusHTMLComprarF1 = statusComprarF1 == true ? "checked" : ""
                var valorUnitarioFornecedor1 = itemPCAtual[index] ? itemPCAtual[index].Valor_unitario__c ? parseFloat(itemPCAtual[index].Valor_unitario__c).toLocaleString('pt-BR', {style: 'decimal', minimumFractionDigits: 2}) : "0" : "";
                var valorTotalFornecedor1 = itemPCAtual[index] ? itemPCAtual[index].Valor_total__c ? parseFloat(itemPCAtual[index].Valor_total__c).toLocaleString('pt-BR', {style: 'decimal', minimumFractionDigits: 2}) : "0" : "";
                var unidadeMedida = itemPCAtual[index].CurrencyIsoCode
                var quantidadeItem = itemPCAtual[index].Quantidade__c
                
                var html2 = "\
                <td class='tg-0pky ValorFornecedor' data-valorTotal='"+valorTotalFornecedor1+"' data-prazoEntrega='"+prazoRecebimentoF1+"'>\
                <div class='valorFornecedorItem'>\
                <input type='checkbox' id='' class='checkboxItemFornecedor' "+statusExistenteF1+" "+statusHTMLComprarF1+" data-idItemPC='"+idItemPCF1+"' data-valorTotal='"+valorTotalFornecedor1+"' "+estadoDecisaoCompra+" data-indiceFornecedor='"+(index+1)+"'/>\
                <div class='innerBlockValueFornecedor'>\
                    <div>\
                        "+unidadeMedida+"&nbsp;<input type='text' data-indiceFornecedor='"+(index+1)+"' value='"+valorUnitarioFornecedor1+"' "+statusExistenteF1+" data-idItemPC='"+idItemPCF1+"' "+estadoInput+" class='inputValueFornecedor'\
                    </div>\
                    <div>\
                        ("+quantidadeItem+" x "+unidadeMedida+" "+valorUnitarioFornecedor1+")\
                    </div>\
                </div>\
                </div>\
                </td>";

            	html = html + html2
            });
            
            html = html + "<td class='tg-0pky'></td></tr>";
            
            
            $("#bodyTableCot").append(html)
        })
        
        helper.preencheFinalTabela(cmp, event, helper)
    },
    
    preencheFinalTabela:function(cmp, event, helper){
        var options = ""
        helper.condicoesPagamento.forEach(function(condicaoPagamentoAtual){
            options += "<option value='"+condicaoPagamentoAtual+"'>"+condicaoPagamentoAtual+"</option>";
        })
        var estadoInput = helper.statusTomadaPreco
        
        var html = "\
        <tr>\
        <td class='tg-fymr' colspan='9'>VALOR TOTAL DOS ITENS SELECIONADOS:</td>";
        
        
        //PREENCHE CELULAS VALOR TOTAL DOS ITENS SELECIONADOS
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var salvarDecisaoCompra =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Prazo_de_recebimento__c : "";
            var tipoFreteF1 = helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Tipo_de_Frete__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            var formaPagamentoF1 = helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Forma_de_pagamento__c : "";
            var descricaoPagamentoF1 = helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Descricao_do_pagamento__c : "";
            var descricaoPagamentoF1 = helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Descricao_do_pagamento__c : "";
            var transportadoraF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Transportadora__r ? helper.dataItensPC[0][index].Fornecedor__r.Transportadora__r.Name : "" : "";
            var transportadoraIDF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Transportadora__r ? helper.dataItensPC[0][index].Fornecedor__r.Transportadora__r.Id : "" : "";
            
            html += "<td class='tg-0pky TotalItensSelecionados' id='TotalItensSelecionados" + (index + 1) + "'>0,00</td>";
        });
        
        html += "<td class='tg-0pky'></td>\
        </tr>\
        <tr>\
<td class='tg-fymr' colspan='9'>VALOR TOTAL COTADO:</td>";
        
        //PREENCHE CELULAS VALOR TOTAL COTADO
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var valorTotalCotado = helper.dataItensPC[0][index].Fornecedor__r.Valor_total_cotado__c
            var valorFormatadoComSimbolo = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valorTotalCotado);
            var valorFormatado = valorFormatadoComSimbolo.replace('R$', '').trim();
            
            html += "<td class='tg-0pky'>"+valorFormatado+"</td>"
        });
        
        html += "<td class='tg-0pky'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>PRAZO DE RECEBIMENTO (DIAS):</td>";
        
        //PREENCHE CELULAS PRAZO DE RECEBIMENTO
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var prazoRecebimentoF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Prazo_em_dias__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            
            //html += "<td class='tg-0pky'><input "+estadoInput+" "+statusExistenteF1+" class='classeControleIf' type='date' style='width: 200px' id='prazoRecebimentoF" + (index + 1) + "' value='"+prazoRecebimentoF1+"'></td>";
            html += "<td class='tg-0pky'><input "+estadoInput+" "+statusExistenteF1+" type='number' class='classeControleIf' style='width: 200px' id='prazoRecebimentoF" + (index + 1) + "' value='"+prazoRecebimentoF1+"' min='1'></td>";

        });
        
        html += "<td class='tg-0pky'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>TIPO DE FRETE:</td>";
        
        //PREENCHE CELULAS TIPO DE FRETE
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var prazoRecebimentoF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Prazo_de_recebimento__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            
            html += "<td class='tg-0lax'>\
            <select style='width: 200px' data-indicePC='"+ (index + 1) +"' id='tipoFreteF" + (index + 1) + "' "+estadoInput+" "+statusExistenteF1+" class='classeControleIf tipoFreteClass'>\
            <option selected disabled>SELECIONE</option>\
            <option value='CIF'>CIF</option>\
            <option value='FOB'>FOB</option>\
            </select>\
            </td>";
        });
        
        html += "<td class='tg-0pky'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>VALOR DO FRETE:</td>";
        
        //PREENCHE CELULAS TIPO DE FRETE
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var valorFrete =  helper.dataItensPC[0][index].Fornecedor__r.Valor_do_frete__c ? helper.dataItensPC[0][index].Fornecedor__r.Valor_do_frete__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            var valorFormatadoComSimbolo = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valorFrete);
			var valorFormatado = valorFormatadoComSimbolo.replace('R$', '').trim();

            html += "<td class='tg-0lax'>\
            <input type='text' id='valorFreteF" + (index + 1) + "' value='"+valorFormatado+"' "+estadoInput+" class='classeControleIf classInputValorFrete'\
            </select>\
            </td>";
        });
        
        html += "<td class='tg-0pky'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>MOEDA DO FRETE:</td>";
        
        //PREENCHE CELULAS TIPO DE FRETE
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var moedaFrete = helper.dataItensPC[0][index].Fornecedor__r.Moeda_do_Frete__c ? helper.dataItensPC[0][index].Fornecedor__r.Moeda_do_Frete__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            
            html += "<td class='tg-0lax'>\
            <select style='width: 200px' value='"+moedaFrete+"' id='moedaFreteF" + (index + 1) + "' "+estadoInput+" "+statusExistenteF1+" class='classeControleIf'>\
            <option selected disabled>SELECIONE</option>\
            <option value='BRL'>BRL</option>\
            <option value='USD'>USD</option>\
            <option value='EUR'>EUR</option>\
            </select>\
            </td>";
        });
        
        html += "<td class='tg-0lax'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>FORMA DE PAGAMENTO:</td>";
        
        //PREENCHE CELULAS FORMA DE PAGAMENTO
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var prazoRecebimentoF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Prazo_de_recebimento__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            
            html += "<td class='tg-0lax'>\
            <select style='width: 200px' id='formaPagamentoF" + (index + 1) + "' "+estadoInput+" "+statusExistenteF1+" class='classeControleIf'>\
            <option selected disabled>SELECIONE</option>\
            <option value='Dinheiro'>Dinheiro</option>\
            <option value='Depósito Bancário'>Depósito Bancário</option>\
            <option value='Depósito Antecipado'>Depósito Antecipado</option>\
            <option value='Boleto'>Boleto</option>\
            <option value='Dinheiro'>Dinheiro</option>\
            <option value='Cheque'>Cheque</option>\
            <option value='Cheque'>Permuta</option>\
            <option value='Cartão de Crédito'>Cartão de Crédito</option>\
            <option value='Cartão de Débito'>Cartão de Débito</option>\
            </select>\
            </td>";
        });
        
        html += "<td class='tg-0lax'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>CONDIÇÕES DE PAGAMENTO:</td>";
        
        //PREENCHE CELULAS CONDICOES DE PAGAMENTO
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var prazoRecebimentoF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Prazo_de_recebimento__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            
            html += "<td class='tg-0lax'><select style='max-width: 200px' "+estadoInput+" "+statusExistenteF1+" id='condicaoPagamentoF" + (index + 1) + "' class='classeControleIf'>"+options+"</select></td>";
        });
        
        html += "<td class='tg-0lax'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>DESCRIÇÃO DO PAGAMENTO:</td>";
        
        //PREENCHE CELULAS DA DESCRICAO DO PAGAMENTO
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var prazoRecebimentoF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Prazo_de_recebimento__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            var descricaoPagamentoF1 = helper.dataItensPC[0][index].Fornecedor__r.Descricao_do_pagamento__c ? helper.dataItensPC[0][index].Fornecedor__r.Descricao_do_pagamento__c : "";
            
            html += "<td class='tg-0lax'><input id='descricaoPagamentoF" + (index + 1) + "' "+estadoInput+" "+statusExistenteF1+" class='classeControleIf' value='"+descricaoPagamentoF1+"' placeholder='Digite aqui a descrição' type='text' style='width: 200px'></input></td>";
        	
        });
        
        html += "<td class='tg-0lax'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>TRANSPORTADORA:</td>";
        
        //PREENCHE CELULAS TRANSPORTADORA
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var prazoRecebimentoF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Prazo_de_recebimento__c : "";
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            var descricaoPagamentoF1 = helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Descricao_do_pagamento__c : "";
            
            html += "<td class='tg-0pky'>\
            <input type='text' id='transportadoraF" + (index + 1) + "' "+estadoInput+" "+statusExistenteF1+" class='inputPesquisaTransportadora classeControleIf' placeholder='Digite uma conta e tecle enter para pesquisar'></input>\
            <div class='divSearchResults'>\
            </td>";

        });
        
        html += "<td class='tg-0lax'></td>\
        </tr>\
        <tr>\
        <td class='tg-fymr' colspan='9'>JUSTIFICATIVA DA DECISÃO DE COMPRA:</td>";
        
        /*PREENCHE CELULAS DA DESCRICAO DO PAGAMENTO
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var statusExistenteF1 = helper.dataItensPC[0][index] ? "" : "disabled";
            var justificativaDecisao = helper.dataItensPC[0][index].Fornecedor__r.Justificativa_da_decisao_de_compra__c ? helper.dataItensPC[0][index].Fornecedor__r.Justificativa_da_decisao_de_compra__c : "";
            
            html += "<td class='tg-0lax'><input id='justificativaDecisaoCompraF" + (index + 1) + "' "+estadoInput+" "+statusExistenteF1+" class='' value='"+justificativaDecisao+"' placeholder='Digite aqui a justificativa' type='text' style='width: 200px'></input></td>";
            
        }); */
        
        var justificativa = helper.dataItensPC[0][0].Item_de_pedido_de_compra__r.Pedido_de_compra__r.Justificativa_de_compra__c ? helper.dataItensPC[0][0].Item_de_pedido_de_compra__r.Pedido_de_compra__r.Justificativa_de_compra__c : "" 
        html += "<td class='tg-0lax' colspan='3'><input id='justificativaDeCompra' class='classeControleIf' "+estadoInput+" value='"+justificativa+"' placeholder='Digite aqui a justificativa' type='text' style='width: 100%'></input></td>";
        html += "<td class='tg-0pky'></td></tr>";
        
        //ADICIONA CONTEUDO NA TABELA
        $("#bodyTableCot").append(html);
        
        helper.dataItensPC[0].forEach(function(itemPC, index) {
            var tipoFreteF1 = helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Tipo_de_Frete__c : "";
            var formaPagamentoF1 = helper.dataItensPC[0][index].Fornecedor__r.Forma_de_pagamento__c ? helper.dataItensPC[0][index].Fornecedor__r.Forma_de_pagamento__c : "";
            var transportadoraF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Transportadora__r ? helper.dataItensPC[0][index].Fornecedor__r.Transportadora__r.Name : "" : "";
            var transportadoraIDF1 =  helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Transportadora__r ? helper.dataItensPC[0][index].Fornecedor__r.Transportadora__r.Id : "" : "";
            var condicaoPagamentoF1 = helper.dataItensPC[0][index] ? helper.dataItensPC[0][index].Fornecedor__r.Condicao_de_Pagamento__c ? helper.dataItensPC[0][index].Fornecedor__r.Condicao_de_Pagamento__c : "" : ""
            var moedaFrete = helper.dataItensPC[0][index].Fornecedor__r.Moeda_do_Frete__c ? helper.dataItensPC[0][index].Fornecedor__r.Moeda_do_Frete__c : "";
            
            $("#tipoFreteF"+(index+1)).val(tipoFreteF1)
            $("#condicaoPagamentoF"+(index+1)).val(condicaoPagamentoF1)
            $("#transportadoraF"+(index+1)).val(transportadoraF1)
            $("#transportadoraF"+(index+1)).attr('data-contaSelecionada', transportadoraIDF1)
            $("#formaPagamentoF"+(index+1)).val(formaPagamentoF1)
            $("#moedaFreteF"+(index+1)).val(moedaFrete)
        });
        
        helper.eventsAfterPreenche(cmp, event, helper)
    },
    
    consultaDados: function(cmp, event, helper) {
    
        var id = helper.retornaRecorId(cmp, event, helper);
        
        var query = "SELECT ID, Item_de_pedido_de_compra__r.Quantidade_total__c, Fornecedor__r.Prazo_em_dias__c, Item_de_pedido_de_compra__r.Pedido_de_compra__r.Justificativa_de_compra__c, CurrencyIsoCode, Fornecedor__r.Fornecedor__r.Phone, Fornecedor__r.Justificativa_da_decisao_de_compra__c, Fornecedor__r.Valor_do_frete__c, Fornecedor__r.Moeda_do_Frete__c, Comprar__c, Fornecedor__r.Valor_total_cotado__c, Fornecedor__r.Pedido_de_compra__r.OwnerId, Fornecedor__r.Pedido_de_compra__r.Status__c, Fornecedor__r.Prazo_de_recebimento__c, Fornecedor__r.Descricao_do_pagamento__c, Fornecedor__r.Forma_de_pagamento__c, Fornecedor__r.Tipo_de_Frete__c, Fornecedor__r.Condicao_de_Pagamento__c, Fornecedor__r.Transportadora__r.Name, Fornecedor__c, Fornecedor__r.Fornecedor__r.Name, PRODUTO2__R.NAME, PRODUTO2__R.PRODUCTCODE, Linha__c, Marca__c, Modelo__c, Valor_unitario__c, Quantidade__c, Unidade_de_medida__c, Valor_total__c, Valor_unit_da_ultima_compra__c, (SELECT Item_de_pedido_de_venda__r.UnitPRICE FROM Destinacoes__r) FROM Item_de_fornecedor__c WHERE Item_de_pedido_de_compra__r.Pedido_de_compra__c = '" + id + "' ORDER BY Item_de_pedido_de_compra__r.CreatedDate ASC";
        
        // REALIZA A CONSULTA
        this.soql(cmp, query)
            // QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itensPC) {
                console.log("ITENS PC", itensPC);
                
                //CRIA STRINGS COM OS CÓDIGOS DOS ITENS
                const uniqueProductCodes = new Set();
                itensPC.forEach(item => {
                    uniqueProductCodes.add(item.Produto2__r.ProductCode);
                });
                const productCodeString = `(${Array.from(uniqueProductCodes).map(code => `'${code}'`).join(', ')})`;
                var idUsuarioAtual = $A.get("$SObjectType.CurrentUser.Id");
                console.log("iduser", idUsuarioAtual)
                var proprietarioCotacao = itensPC[0].Fornecedor__r.Pedido_de_compra__r.OwnerId;
                    
                    const hasNonZeroUnitValue = itensPC.some(item => item.Valor_unitario__c !== undefined && item.Valor_unitario__c !== 0);
                    console.log("hasNonZeroUnitValue", hasNonZeroUnitValue);
                    
                    
                //HABILITA APENAS SE TIVER VALOR    
                // HABILITA DECISAO DE COMPRA
                if (hasNonZeroUnitValue && (idUsuarioAtual == proprietarioCotacao || idUsuarioAtual == "005i0000000J08eAAC") && (itensPC[0].Fornecedor__r.Pedido_de_compra__r.Status__c == "1 - Rascunho")) {
                    helper.statusDecisaoCompra = "";                    
                } else {
                    helper.alertaErro(cmp, event, helper, "Somente o proprietário da cotação de compra pode fazer a decisão de compra!", "Atenção", "warning", "sticky")
                    helper.statusDecisaoCompra = "disabled";
                    $("#salvarDecisaoCompra, #selecionarTodos, #buttonMenorPrazo, #buttonMenorPreco").prop("disabled", true);                    
                    $("#limparTudo").prop("disabled", true);
                }
                    
                
                // HABILITA TOMADA DE PREÇO
                if (itensPC[0].Fornecedor__r.Pedido_de_compra__r.Status__c == "1 - Rascunho" && itensPC[0].Fornecedor__r.Pedido_de_compra__r.Status__c != "5 - Concluído") {
                    helper.statusTomadaPreco = "";
                } else {
                    helper.statusTomadaPreco = "disabled";
                    $("#salvarTomadaPreco").prop("disabled", true);
                }
                    
                helper.statusCotacao = itensPC[0].Fornecedor__r.Pedido_de_compra__r.Status__c
                    
                // AGRUPA OS ITENS PELO CÓDIGO DO ITEM
                const groupedItems = {};
                itensPC.forEach(item => {
                    const produto2 = item.Item_de_pedido_de_compra__c;
                    if (!groupedItems[produto2]) {
                        groupedItems[produto2] = [];
                    }
                    groupedItems[produto2].push(item);
                });
                const groupedItemsArray = Object.values(groupedItems);
                    
                console.log("GROUPED ITENS", groupedItemsArray);
                    
                helper.dataItensPC = groupedItemsArray;
                helper.dataItensPC.forEach(sublist => sublist.sort((a, b) => {
                    const idA = a.Fornecedor__r.Fornecedor__r.Id;
                    const idB = b.Fornecedor__r.Fornecedor__r.Id;
                    return idA.localeCompare(idB);
                }));

                
                // REALIZA A CONSULTA
                helper.getPicklist(cmp, "Fornecedor__c", "Condicao_de_Pagamento__c")
                // QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
                .then(function (condicoesPagamento) {
                    helper.condicoesPagamento = condicoesPagamento;
                    
                    //CONSULTA AS VARIAÇÕES DO USUARIO
                    var query = "SELECT ID, Item_de_pedido_de_compra__r.Quantidade_total__c, Fornecedor__c, Data_da_compra__c, Produto__c, Codigo_do_produto__c, Fornecedor__r.Status_do_PC__c, Valor_unitario__c, Valor_total__c, CurrencyIsoCode FROM Item_de_fornecedor__c WHERE Codigo_do_produto__c IN "+productCodeString+" AND Fornecedor__r.Status_do_PC__c NOT IN ('Rascunho', 'Em cotação', 'Cancelado') ORDER BY Data_da_compra__c"
                    
                    console.log("QUERY SEGUNDA", query)
                    //REALIZA A CONSULTA
                    helper.soql(cmp, query)
                    
                    //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
                    .then(function (oldPcs) {
                        
                    	helper.dataItensPC.forEach(function(itemPC, index) {
                    
                            // Filtra apenas os elementos que possuem a chave 'Data_da_compra__c'
                            const filteredData = oldPcs.filter(item => item.Data_da_compra__c && item.Codigo_do_produto__c == itemPC[0].Produto2__r.ProductCode);
                            
                            // Converte a string de data em um objeto Date e encontra o elemento com a data mais recente
                            const mostRecentItem = filteredData.reduce((max, item) => {
                                return new Date(item.Data_da_compra__c) > new Date(max.Data_da_compra__c) ? item : max;
                            }, filteredData[0]);
                           
                            console.log("MOST RECENT ITEM", mostRecentItem);
                
                    		var itemPcOld = mostRecentItem
                    		
                            if(itemPcOld){
                                itemPC[0].DataDaUltimaCompra = itemPcOld.Data_da_compra__c ? itemPcOld.Data_da_compra__c : ""
                                itemPC[0].ValorUnitarioUltimaCompra = itemPcOld.Valor_unitario__c ? itemPcOld.Valor_unitario__c : ""
                                itemPC[0].ValorTotalUltimaCompra = itemPcOld.Valor_total__c ? itemPcOld.Valor_total__c : "" 
                                itemPC[0].MoedaUltimaCompra = itemPcOld.CurrencyIsoCode ? itemPcOld.CurrencyIsoCode : "" 
                            }else{
                                itemPC[0].DataDaUltimaCompra = ""
                                itemPC[0].ValorUnitarioUltimaCompra = ""
                                itemPC[0].ValorTotalUltimaCompra = ""
                                itemPC[0].MoedaUltimaCompra = ""
                            }

                        });
                    
                    	console.log("HELPER DATA ITENS 2", helper.dataItensPC)
                        
                        helper.preencheTabela(cmp, event, helper);

                        
                    })
                    
                    //trata excessão de erro
                    .catch(function (error) {
                        console.log(error)
                    })
                    
                })
                // Trata excessão de erro
                .catch(function (error) {
                    console.log(error);
                });
        
        
            })
        // Trata excessão de erro
        .catch(function (error) {
            console.log(error);
        });
    },

})