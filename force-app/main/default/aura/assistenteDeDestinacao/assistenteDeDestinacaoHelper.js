({

    //VARIAVEIS GLOBAIS RECEBIMENTO
    codigoProdutoRecebimentoAtual: '',
    idItemPCRecebimentoAtual: '',
    quantidadeRecebidaRecebimentoAtual: '',
    qtdTotalRecebimentoAtual: '',

    //VARIAVEIS GLOBAIS DESTINACAO
    codigoProdutoDestinacaoAtual: '',
    idItemPCDestinacaoAtual: '',
    quantidadeRecebidaDestinacaoAtual: '',

    helperMain: function (cmp, event, helper) {

        //Obj1 = assistenteDeDestinacao
        //Obj2 = assistenteDeDestinacaoNaoDestinado  
        //Obj2 é uma copia de Obj1.
        // A variavel controlador chama o id de uma div dentro do outro obj  
        var controlador = $("#recarregarPaginaObj2").text();

        //Se a div existe quer dizer que o obj foi criado
        if (controlador.trim() !== "") {
            location.reload();//Entao recarregue a pagina
        } else {
            helper.preencheTabela(cmp, event, helper);
        }

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

        helper.hideSpinner(cmp);
    },
    //----------------------------------------------------------------------------------------------

    //ABRE OU FECHA O DROPDOWN COM OS PEDIDOS RELACIONADOS A UM PRODUTO----
    openClosePedidos: function (cmp, event, helper, elemento) {
        var tamanhoAberto = '220px';
        var tamanhoFechado = '90px';
        var tamanhoMarginAberto = '150px';
        var tamanhoMarginFechado = '10px';
        var tamanhoAtual = $(elemento).parents('#itemTabela').find('#itemTabelaSecundaria').css('height');
        var tamanhoSetado = tamanhoAtual == tamanhoAberto ? tamanhoFechado : tamanhoAberto;
        var tamanhoMargin = tamanhoAtual == tamanhoAberto ? tamanhoMarginFechado : tamanhoMarginAberto;
        $(elemento).parents('#itemTabela').find('#itemTabelaSecundaria').css("height", tamanhoSetado);
        $(elemento).parents('#itemTabela').css("padding-bottom", tamanhoMargin);
    },

    criaLogs: function (cmp, event, helper, conteudo, titulo, tipo, contentType, pasta) {
        //REALIZA A CONSULTA
        this.criaLog(cmp, conteudo, titulo, tipo, contentType, pasta)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (result) {
                console.log(result)
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
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

    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecorId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");

        return recordId
    },
    //---------------------------------------------------

    //PREENCHE TABELA INICIAL----------------------------
    preencheTabela: function (cmp, event, helper) {
        //EXIBE SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        var IdPedidoDeCompra = helper.retornaRecorId(cmp, event, helper);
        var query = "select id, name, Descricao__c, Valor_total__c, Fornecedor__r.Tipo__c, Valor_unitario__c, Status__c, Quantidade_recebida2__c, Quantidade_disponivel__c, Item_de_pedido_de_compra__c, Item_de_pedido_de_compra__r.Produto__r.Valor_Total__c, Item_de_pedido_de_compra__r.Produto__r.URL_da_Imagem__c, Fornecedor__c, Codigo_do_produto__c, Produto__c, Modelo__c, Marca__c, Quantidade__c,  (SELECT id, Quantidade_Disponivel__c, Quantidade_requisitada__c, Item_de_pedido_de_venda__r.Quantidade_a_requisitar_novo__c, Item_de_pedido_de_venda__r.order.OrderNumber,  Item_de_pedido_de_venda__r.order.Account.name, Item_de_pedido_de_venda__r.OrderItemNumber from Destinacoes__r) from Item_de_fornecedor__c WHERE comprar__c = true AND Fornecedor__c = '" + IdPedidoDeCompra + "' AND Quantidade_destinada__c > 0"

        console.log("QUERY", query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itensPedidoDeVenda) {
                //LIMPA TABELA ANTES DE INSERIR
                $("#listaCotacao").empty()
                itensPedidoDeVenda.forEach(function (itemPedidoDeVenda) {
                    //console.log("ITEM DO PEDIDO DE VENDA")
                    //console.log(itemPedidoDeVenda);

                    var tipoPc = itemPedidoDeVenda.Fornecedor__r.Tipo__c
                    var valorTotalPc = itemPedidoDeVenda.Valor_total__c.toLocaleString('pt-br', { style: 'currency', currency: 'BRL' });
                    var valorUnitario = itemPedidoDeVenda.Valor_unitario__c.toLocaleString('pt-br', { style: 'currency', currency: 'BRL' });
                    var idItemPC = itemPedidoDeVenda.Id
                    var codigo = itemPedidoDeVenda.Codigo_do_produto__c
                    var produto = itemPedidoDeVenda.Produto__c
                    var modelo = itemPedidoDeVenda.Modelo__c
                    var marca = itemPedidoDeVenda.Marca__c
                    var qtdTotal = itemPedidoDeVenda.Quantidade__c
                    var idProduto = itemPedidoDeVenda.Item_de_pedido_de_compra__r.Produto__c
                    var urlImagem = itemPedidoDeVenda.Item_de_pedido_de_compra__r.Produto__r.URL_da_Imagem__c
                    var valorTotal = itemPedidoDeVenda.Item_de_pedido_de_compra__r.Produto__r.Valor_Total__c
                    var destinacoes = itemPedidoDeVenda.Destinacoes__r
                    var quantidadeDisponivel = itemPedidoDeVenda.Quantidade_disponivel__c
                    var quantidadeRecebida = itemPedidoDeVenda.Quantidade_recebida2__c
                    var Status = itemPedidoDeVenda.Status__c
                    var statusAcoes = (Status != 'Novo' && Status != 'Recebido Total' && Status != 'undefined') ? "" : "disabled='true'"

                    if (tipoPc == 'Compra para consumo') {
                        console.log("item consumo")
                        var descricao = itemPedidoDeVenda.Descricao__c
                        produto = descricao
                    }

                    var inputHtml = ("\
<div title='Clique para expandir' data-status='"+ Status + "' data-idProduto='" + idProduto + "' data-idItemPC='" + idItemPC + "' data-quantidadeDisponivel='" + quantidadeDisponivel + "' data-quantidade = '" + qtdTotal + "' data-quantidadeRecebida = '" + quantidadeRecebida + "' data-valorTotal = '" + valorTotal + "' data-urlImagem = '" + urlImagem + "' data-codigo='" + codigo + "' data-marca='" + marca + "' data-nomeProduto='" + produto + "' data-codigo='" + codigo + "' data-modelo='" + modelo + "' id='itemTabela' class='containerMestreBlocos itemTabela' draggable='false' style='padding-bottom: 10px;' >\
   <div style='z-index: 1; cursor: pointer' class='blocoItemPedidoVenda blocoItemPedidoVendaEvento'>\
      <div style='height: 100%;' class='row'>\
         <div style='display: flex; height: 100%;' class='col-md-6'>\
            <div class='containerImageItem'><a class='imageItemProd' target='_blank' title='Clique para abrir o produto' href='https://hospcom.my.site.com/Sales/s/product2/"+ idProduto + "' draggable='false'><img src='" + urlImagem + "' style='height: 90%' class='imgItemPedido' draggable='false'></a></div>\
            <div class='containerDadosIniciaisItem'>\
               <div style='width: 100%; height: auto; font-size: 14px; color: #00345c; font-weight: bold;'>"+ produto + "</div>\
               <div style='width: 100%; height: auto; font-size: 12px; color: #A0BB31;'>"+ codigo + ' - ' + modelo + ' - ' + marca + "</div>\
            </div>\
         </div>\
         <div style='display: flex; height: 100%;' class='col-md-6'>\
            <div class='containerDetalhesItem'>\
				<div class='textoSecundario'>Qtd. Total:&nbsp<span style='font-weight: 400;'>"+ qtdTotal + "</span></div>\
               <div class='textoSecundario'>Qtd. Disponível:&nbsp<span style='font-weight: 400;'>"+ quantidadeDisponivel + "</span></div>\
            </div>\
			<div class='containerDetalhesItem'>\
				<div class='textoSecundario'>Valor unitário:&nbsp<span style='font-weight: 400;'>"+ valorUnitario + "</span></div>\
               <div class='textoSecundario'>Valor total:&nbsp<span style='font-weight: 400;'>"+ valorTotalPc + "</span></div>\
            </div>\
           <div class='containerQuantItens'>\
    <div class='containerButtonsActions'>\
        <button type='button' id='acao' title='Destinar Itens' "+ statusAcoes + " class='btn btn-primary destinaItens buttonActionsPrincipal'><i class='fa fa-paper-plane '></i>&nbsp;Destinar</button>\
        <button type='button' id='acao' title='Receber Itens' "+ statusAcoes + " class='btn btn-primary recebeItens buttonActionsPrincipal'><i class='fa fa-cubes '></i>&nbsp;Receber</button>\
    </div>\
    <div class='containerInputActions'>\
         <select class='selectpicker' id='selectStatus'>\
    <option disabled='true'>Status do item</option>\
    <option value='NOVO' title='NOVO'>NOVO</option>\
    <option value='RECEBIDO PARCIAL' title='RECEBIDO PARCIAL'>RECEBIDO PARCIAL</option>\
    <option value='RECEBIDO TOTAL' title='RECEBIDO TOTAL'>RECEBIDO TOTAL</option>\
    <option value='CMP - EM PRODUÇÃO FORN.' title='CMP - EM PRODUÇÃO FORN.'>CMP - EM PRODUÇÃO FORN.</option>\
    <option value='CMP - EM COLETA PORTO/FORNECEDOR' title='CMP - EM COLETA PORTO/FORNECEDOR'>CMP - EM COLETA PORTO/FORNECEDOR</option>\
    <option value='EM TRANSITO' title='EM TRANSITO'>EM TRANSITO</option>\
    <option value='CMP - EM DESEMBARAÇO' title='CMP - EM DESEMBARAÇO'>CMP - EM DESEMBARAÇO</option>\
    <option value='CMP - EM TRANSITO NACIONAL' title='CMP - EM TRANSITO NACIONAL'>CMP - EM TRANSITO NACIONAL</option>\
    <option value='CMP - EM TRANSITO INTERNACIONAL' title='CMP - EM TRANSITO INTERNACIONAL'>CMP - EM TRANSITO INTERNACIONAL</option>\
    <option value='CMP - PRE-EMBARQUE IMPORTAÇÃO' title='CMP - PRE-EMBARQUE IMPORTAÇÃO'>CMP - PRE-EMBARQUE IMPORTAÇÃO</option>\
    <option value='CMP - AG. PAGAMENTO FORN' title='CMP - AG. PAGAMENTO FORN'>CMP - AG. PAGAMENTO FORN</option>\
    <option value='CMP - AG. CONSOLIDAÇÃO DE CARGA' title='CMP - AG. CONSOLIDAÇÃO DE CARGA'>CMP - AG. CONSOLIDAÇÃO DE CARGA</option>\
    <option value='CMP - AG. DESEMBARAÇO ADUANEIRO' title='CMP - AG. DESEMBARAÇO ADUANEIRO'>CMP - AG. DESEMBARAÇO ADUANEIRO</option>\
    <option value='CMP - AG. NFE NACIONALIZAÇÃO' title='CMP - AG. NFE NACIONALIZAÇÃO'>CMP - AG. NFE NACIONALIZAÇÃO</option>\
    <option value='AG APROVAÇÃO PEDIDO' title='AG APROVAÇÃO PEDIDO'>AG APROVAÇÃO PEDIDO</option>\
    <option value='CMP -AG. DADOS TECNICOS' title='CMP -AG. DADOS TECNICOS'>CMP -AG. DADOS TECNICOS</option>\
    <option value='AG. RECEBIMENTO LOGISTICA' title='AG. RECEBIMENTO LOGISTICA'>AG. RECEBIMENTO LOGISTICA</option>\
    <option value='CMP - AG. AUTORIZAÇÃO DESEMBARAÇO' title='CMP - AG. AUTORIZAÇÃO DESEMBARAÇO'>CMP - AG. AUTORIZAÇÃO DESEMBARAÇO</option>\
    <option value='CMP - AG. REMOÇAO DE CARGA' title='CMP - AG. REMOÇAO DE CARGA'>CMP - AG. REMOÇAO DE CARGA</option>\
    <option value='CMP - AG. LIBERAÇAO CANAL VERMELHO' title='CMP - AG. LIBERAÇAO CANAL VERMELHO'>CMP - AG. LIBERAÇAO CANAL VERMELHO</option>\
    <option value='CMP - AG. LIBERAÇAO CANAL AMARELO' title='CMP - AG. LIBERAÇAO CANAL AMARELO'>CMP - AG. LIBERAÇAO CANAL AMARELO</option>\
    <option value='CMP - AG. LIBERAÇAO CANAL CINZA' title='CMP - AG. LIBERAÇAO CANAL CINZA'>CMP - AG. LIBERAÇAO CANAL CINZA</option>\
    <option value='CMP - AG. ACEITE DE CARGA DG/BATERIA' title='CMP - AG. ACEITE DE CARGA DG/BATERIA'>CMP - AG. ACEITE DE CARGA DG/BATERIA</option>\
    <option value='AG. PRONTIDÃO' title='AG. PRONTIDÃO'>AG. PRONTIDÃO</option>\
    <option value='CMP -AG. ENTREGA FORNECEDOR' title='CMP -AG. ENTREGA FORNECEDOR'>CMP -AG. ENTREGA FORNECEDOR</option>\
    <option value='CANCELADO' title='CANCELADO'>CANCELADO</option>\
    <option value='CMP - COTAÇÃO DE COMPRA' title='CMP - COTAÇÃO DE COMPRA'>CMP - COTAÇÃO DE COMPRA</option>\
</select>\
    </div>\
</div>\
         </div>\
      </div>\
   </div>\
   <div id='itemTabelaSecundaria' style='background-color: rgb(245, 246, 248); box-shadow: 0 2px 8px rgb(14 19 24 / 7%); height: 90px;' class='blocoItemPedidoVenda blocoItemPedidoVendaExpand'>\
      \
         \
         \
      </div>\
   </div>\
</div>")

                    $('#listaCotacao').append(inputHtml)

                    //SETA O STATUS ATUAL NO SELECT OPTIONS
                    $(".selectpicker:last option").each(function () {
                        var valorAtualOption = $(this).val()
                        if (valorAtualOption == Status) {

                            $(this).attr('selected', 'true')
                        }
                    })

                    //PREENCHE O DROPDOWN DE DESTINACOES
                    if (itemPedidoDeVenda.Destinacoes__r != undefined) {
                        itemPedidoDeVenda.Destinacoes__r.forEach(function (destinacao) {
                            //console.log("destinacao: ")
                            //console.log(destinacao)

                            try {
                                var idPedido = destinacao.Item_de_pedido_de_venda__r.OrderId
                                var IditemPedido = destinacao.Item_de_pedido_de_venda__c
                                var idRequisicao = destinacao.Id
                                var quantidadeRequisitada = destinacao.Quantidade_requisitada__c
                                //var quantidadeDisponivel = destinacao.Quantidade_Disponivel__c
                                var pedidoDeVenda = destinacao.Item_de_pedido_de_venda__r.Order.OrderNumber;
                                var nomeConta = destinacao.Item_de_pedido_de_venda__r.Order.Account.Name;
                                var quantidadeARequisitar = destinacao.Item_de_pedido_de_venda__r.Quantidade_a_requisitar_novo__c
                                var produtoDoPedido = destinacao.Item_de_pedido_de_venda__r.OrderItemNumber
                                var buttonAction = quantidadeRequisitada == 0 ? "<button type='button' id='acao' title='Confirmar' " + statusAcoes + " class='btn btn-primary buttonAcaoRequisicao'>Confirmar&nbsp;<i class='fa fa-check-circle iconRotate'></i></button>" : "<button type='button' id='acao' title='Excluir Confirmação' " + statusAcoes + " class='btn btn-primary buttonAcaoRequisicaoDelete'><i class='fa fa-trash iconRotate'></i></button>"
                                var colorAditional = ''
                                var linkPedido = "https://hospcom.my.site.com/Sales/s/order/" + idPedido
                                var produtoDoPedidoId = destinacao.Item_de_pedido_de_venda__c
                                var linkProdutoPedido = "https://hospcom.my.site.com/Sales/s/orderitem/" + produtoDoPedidoId
                                var target = "target='_blank'"
                            } catch (err) {
                                var IditemPedido = destinacao.Item_de_pedido_de_venda__c
                                var idRequisicao = destinacao.Id
                                var quantidadeRequisitada = destinacao.Quantidade_requisitada__c
                                //var quantidadeDisponivel = destinacao.Quantidade_Disponivel__c
                                var pedidoDeVenda = 'Item do Pv Removido';
                                var nomeConta = 'Item do Pv Removido';
                                var quantidadeARequisitar = ''
                                var produtoDoPedido = 'Item do Pv Removido'
                                var buttonAction = ''
                                var colorAditional = 'background-color: yellow;'
                                var linkPedido = "#"
                                var linkProdutoPedido = "#"
                                var target = ""
                            }
                            var inputTabelaSecundaria2 = "\
                        <div data-idRequisicao='"+ idRequisicao + "'  data-IditemPedido='" + IditemPedido + "' data-quantidadeDisponivel='" + quantidadeDisponivel + "' data-quantidadeARequisitar='" + quantidadeARequisitar + "' data-nomeConta='" + nomeConta + "' data-pedidoDeVenda='" + pedidoDeVenda + "' id='itemTabelaRequisicao' style='" + colorAditional + " z-index: 1; margin-bottom: 10px; display: flex; padding: 10px; flex-direction: column; justify-content: center;' data-produtodopedido='8026e00000ELqZmAAL' data-item-pv='0000048076' class='blocoItemPedidoVenda blocoItemPedidoVendaFilho'>\
                             <div style='display: flex; width: 100%; height: 40%; margin-bottom: 10px;'>\
                                <div class='textBlocoItens'>Pedido de Venda:&nbsp<span style='font-weight: 400;'><a href='"+ linkPedido + "' " + target + ">" + pedidoDeVenda + "</a></span></div>\
                                <div class='textBlocoItens'>Prod. do PV:&nbsp<span style='font-weight: 400;'><a href='"+ linkProdutoPedido + "' " + target + ">" + produtoDoPedido + "</a></span></div>\
								<div style='' class='textBlocoItens'>Quantidade:&nbsp<span style='font-weight: 400;'>"+ quantidadeRequisitada + "</div>\
								<div style='' class='textBlocoItens'>Cliente:&nbsp<span style='font-weight: 400;'>"+ nomeConta + "</div>\
                                <div style='justify-content: flex-end' class='textBlocoItens'>"+ buttonAction + "</div>\
                             </div>\
                          </div>\
                        "

                            $(".itemTabela:last").find("#itemTabelaSecundaria").append(inputTabelaSecundaria2);
                        })
                    }

                })
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.eventsAfterPreencheTabela(cmp, event, helper);
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },
    //---------------------------------------------------

    //EVENTOS AFTER PREENCHE TABELA----------------------------------
    eventsAfterPreencheTabela: function (cmp, event, helper) {


        //APLICA ESTILO EM TODAS OS SELECTS
        $('.selectpicker').selectpicker({
            dropupAuto: false
        });

        $('.datepicker').datepicker({
            format: 'dd/mm/yyyy',
            language: 'pt-BR',
            endDate: '+0d',
        });

        //ABRE POPUP COM DETALHES
        $(".destinaItens").off().on("click", function () {
            var elemento = $(this).parents('#itemTabela');
            helper.exibePopupPrincipal(cmp, event, helper, elemento);
        });

        //ABRE POPUP COM RECEBIMENTO
        $(".buttonAtualiza").off().on("click", function () {
            helper.preencheTabela(cmp, event, helper)
        });

        //ABRE POPUP COM RECEBIMENTO
        $(".recebeItens").off().on("click", function () {
            var elemento = $(this).parents('#itemTabela');
            helper.exibePopupRecebimento(cmp, event, helper, elemento);
        });

        //FECHA POPUP COM DETALHES
        $(".closeButtonProdutoDetails").off().on("click", function () {
            $("#containerDetalhes").css("display", "none");
            $("#containerRecebimento").css("display", "none");
            helper.preencheTabela(cmp, event, helper);
        });

        //CLIQUE AÇÃO DA DESTINACAO
        $(".buttonAcaoRequisicao").off("click").on("click", function () {
            var elemento = $(this).parents('#itemTabelaRequisicao');
            helper.confirmaDestinacao(cmp, event, helper, elemento);
        });

        //CLIQUE AÇÃO DA EXCLUSÃO DA DESTINACAO
        $(".buttonAcaoRequisicaoDelete").off("click").on("click", function () {
            var elemento = $(this).parents('#itemTabelaRequisicao');
            helper.excluiDestinacao(cmp, event, helper, elemento);
        });

        //CHANGE DO STATUS DO ITEM
        $('.selectpicker').off('changed.bs.select').on('changed.bs.select', function (e, clickedIndex, newValue, oldValue) {
            var status = $(e.currentTarget).val();
            var elemento = $(this).parents('#itemTabela');
            helper.validaAtualizaStatusItem(cmp, event, helper, elemento, status, oldValue);
        });

        //APLICA Z-INDEX 1 QUANDO EXIBE O OPTIONS E APLICA Z-INDEX 0 QUANDO OCULTA        
        $(".selectpicker").off('show.bs.select').on('show.bs.select', function () {
            $(this).parents('#itemTabela').css('z-index', '1')
        });

        $(".containerInputActions").off().on('hide.bs.dropdown', function () {
            $(this).parents('#itemTabela').css('z-index', '0')
        });

        $(".selectpicker option:selected").css('backgroundColor', '#FFFFFF');
        //----------------------------------------------------------------------

        //EVENTO PARA ABERTURA OU FECHAMENTO DO DROPDOWN COM PEDIDOS
        $('.containerImageItem, .containerDadosIniciaisItem, .containerDetalhesItem').off().on('click', function (e) {
            helper.openClosePedidos(cmp, event, helper, this);
        });



        /*    // Abrir o pop-up
           $(".buttonAbrePopupStatus").off("click").on('click', function () {
               $('#popupAlterarStatusTodos').modal('show');
           });
   
           // Botão Cancelar - fecha o pop-up
           $(".btnCancelarStatusTodos").off("click").on('click', function () {
               $('#popupAlterarStatusTodos').modal('hide');
               // Resetar o select
               $('#selectStatusTodosPopup').prop('selectedIndex', 0);
           });
   
           // Botão Confirmar - executa a ação
           $(".btnConfirmarStatusTodos").off("click").on('click', function () {
               var statusSelecionado = $('#selectStatusTodosPopup').val();
   
               if (statusSelecionado && statusSelecionado !== 'Selecione o status') {
                   // Chama a função passando o status selecionado
                   helper.mudaTodosStatus(cmp, event, helper, statusSelecionado);
   
                   // Fecha o pop-up
                   $('#popupAlterarStatusTodos').modal('hide');
   
                   // Resetar o select
                   $('#selectStatusTodosPopup').prop('selectedIndex', 0);
               } else {
                   // Alerta se nenhum status foi selecionado
                   alert('Por favor, selecione um status antes de confirmar.');
               }
           }); */


        //EVENTO DO BOTAO ALTERAR PRAZO DE ENTREGA
        $(".buttonAlteraPrazoEntrega").off("click").on('click', function () {
            helper.confirmaAlterarPrazoPopup(cmp, event, helper)
        });
    },
    //---------------------------------------------------------------

    mudaTodosStatus: function (cmp, event, helper, stts) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        /*
        var idsItensPc = []
        var idsProdutos = []
        
        $('.itemTabela').each(function () {
            var status = $(this).attr('data-status')
            console.log(status)
            if (status == 'Novo') {
                var valorAtualOption = $(this).attr('data-iditempc')
                var valorAtualOptionProduto = $(this).attr('data-idproduto')
                idsItensPc.push(valorAtualOption)
                idsProdutos.push(valorAtualOptionProduto)
            }

        }) */

        var recordId = cmp.get("v.recordId");

        //var contentLog = "=====ALTERACAO EM MASSA DE ITEM=====\n" + "RECORD ID: " + recordId + "\nIDS itens pc: " + idsItensPc + "\n IDS PRODUTOS: " + idsProdutos + "\n"
        var contentLog = "=====ALTERACAO EM MASSA DE ITEM=====\n" + "RECORD ID: " + recordId

        var pastaLog = "COMPRAS - LOGS"
        var dataLog = new Date();
        var tituloLog = dataLog + "ALTERADO ITENS EM MASSA: " + recordId

        console.log("entrou altera em massa")

        //VERIFICA SE EXISTEM ITENS VALIDOS PARA O ENVIO
        if (true) {
            //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
            var action = cmp.get("c.aguardandoEntrega");

            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                pc: recordId,
                stts: stts
            });
            //----------------------------------------------------

            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.preencheTabela(cmp, event, helper)
                    helper.criaLogs(cmp, event, helper, contentLog, tituloLog, 'txt', 'text/plain', pastaLog)
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, "ALTERAÇÃO DE STATUS EM MASSA CONCLUÍDO", "TUDO OK!", "success", "", "dismissable")
                }
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ALTERAÇÃO DE STATUS EM MASSA", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE A ALTERAÇÃO DE STATUS EM MASSA", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DURANTE A ALTERAÇÃO EM MASSA", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });

            $A.enqueueAction(action);
        } else {
            helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
            helper.alertaErro(cmp, event, helper, "NENHUM ITEM COM O STATUS NOVO FOI ENCONTRADO NA LISTA!", "Erro!", "error", "Erro: ", "sticky")
        }

    },

    confirmaDestinacao: function (cmp, event, helper, elemento) {
        $("#containerChildDestinacao").css("display", "flex");

        var idRequisicao = $(elemento).attr('data-idrequisicao')
        var nomeConta = $(elemento).attr('data-nomeconta')
        var pedidoVenda = $(elemento).attr('data-pedidodevenda')
        var quantidadeARequisitar = $(elemento).attr('data-quantidadeARequisitar')
        var quantidadeDisponivel = $(elemento).attr('data-quantidadeDisponivel')

        $('#numeroPedidoPopup').html(pedidoVenda)
        $('#nomeContaPopup').html(nomeConta)
        $('#quantidadeARequisitar').html(quantidadeARequisitar)

        $("#containerChildDestinacao").attr('data-tipo', 'confirmaDestinacao')
        $("#containerChildDestinacao").attr('data-idrequisicao', idRequisicao)
        $("#containerChildDestinacao").attr('data-nomeconta', nomeConta)
        $("#containerChildDestinacao").attr('data-pedidodevenda', pedidoVenda)
        $("#containerChildDestinacao").attr('data-quantidadeARequisitar', quantidadeARequisitar)
        $("#containerChildDestinacao").attr('data-quantidadeDisponivel', quantidadeDisponivel)

        helper.eventsAfterModalDestinacao(cmp, event, helper);
    },

    excluiDestinacao: function (cmp, event, helper, elemento) {
        var idDestinacao = $(elemento).attr('data-idrequisicao')

        helper.validaConfirmaExclusao(cmp, event, helper, idDestinacao)
        /* $("#containerChildDestinacao").css("display", "flex");
        
        var idRequisicao = $(elemento).attr('data-idrequisicao')
        var nomeConta = $(elemento).attr('data-nomeconta')
        var pedidoVenda = $(elemento).attr('data-pedidodevenda')
        var quantidadeARequisitar = $(elemento).attr('data-quantidadeARequisitar')
        var quantidadeDisponivel = $(elemento).attr('data-quantidadeDisponivel')
        
        $('#numeroPedidoPopup').html(pedidoVenda)
        $('#nomeContaPopup').html(nomeConta)
        $('#quantidadeARequisitar').html(quantidadeARequisitar)
        
        $("#containerChildDestinacao").attr('data-tipo', 'excluiDestinacao')
        $("#containerChildDestinacao").attr('data-idrequisicao', idRequisicao)
        $("#containerChildDestinacao").attr('data-nomeconta', nomeConta)
        $("#containerChildDestinacao").attr('data-pedidodevenda', pedidoVenda)
        $("#containerChildDestinacao").attr('data-quantidadeARequisitar', quantidadeARequisitar)
        $("#containerChildDestinacao").attr('data-quantidadeDisponivel', quantidadeDisponivel)
        
        helper.eventsAfterModalDestinacao(cmp, event, helper);  */
    },

    validaAtualizaStatusItem: function (cmp, event, helper, elemento, status, oldValue) {


        console.table([
            { nome: 'elemento selecionado', valor: elemento },
            { nome: 'status', valor: status },
            { nome: 'status antigo', valor: oldValue }
        ]);


        const statusCompras = status.startsWith("CMP");

        //var statusTransitorios = ["NOVO", "Aguardando Nfe de nacionalização", "Aguardando consolidação de carga", "Em produção", "Em trânsito", "Em coleta", "Aguardando desembaraço aduaneiro"];

        console.log("OLD VALUE", oldValue)
        console.log("new value", status)
        if (status == "RECEBIDO TOTAL" || status == "RECEBIDO PARCIAL" || status == "NOVO") {
            helper.alertaErro(cmp, event, helper, "Não é permitido alterar para status: " + status, "Alteração bloqueada!", "error", "Erro: ", "dismissible")
            helper.preencheTabela(cmp, event, helper);
            console.error("Tentativa de alteração para status bloqueado:", status)
            return;
        }

        if (oldValue == "CANCELADO") {
            helper.alertaErro(cmp, event, helper, "Pedidos cancelados não podem ter status alterado", "Status atual: Cancelado", "error", "Erro: ", "dismissible")
            helper.preencheTabela(cmp, event, helper);
            console.error("Tentativa de alteração de pedido cancelado. Status atual:", oldValue, "-> Novo status:", status)
            return;
        }

        if (oldValue == "RECEBIDO TOTAL") {
            helper.alertaErro(cmp, event, helper, "Pedidos já recebidos não podem ter status alterado", "Status atual: Recebido Total", "error", "Erro: ", "dismissible")
            helper.preencheTabela(cmp, event, helper);
            console.error("Tentativa de alteração de pedido recebido. Status atual:", oldValue, "-> Novo status:", status)
            return;
        }

        if (oldValue == "CMP - COTAÇÃO DE COMPRA" && statusCompras) {
            helper.alertaErro(cmp, event, helper, "De 'COTAÇÃO DE COMPRA' só é permitido mudar para status transitórios", "Transição inválida", "error", "Erro: ", "dismissible")
            helper.preencheTabela(cmp, event, helper);
            console.error("Transição bloqueada:", oldValue, "->");
            return;
        }

        /*    if (oldValue == "Novo" && !(status == "Aguardando Entrega Fornecedor")) {
               if (status != "Cancelado") {
                   helper.alertaErro(cmp, event, helper, "Status 'Novo' só pode mudar para 'Aguardando Entrega Fornecedor' ou 'Cancelado'", "Transição inválida", "error", "Erro: ", "dismissible")
                   helper.preencheTabela(cmp, event, helper);
                   console.error("Transição bloqueada de 'Novo':", oldValue, "->", status, "| Status permitidos: 'Aguardando Entrega Fornecedor' ou 'Cancelado'")
                   return;
               }
           } */

        /*   if (status == "Aguardando Entrega Fornecedor") {
              if (oldValue != "Novo") {
                  helper.alertaErro(cmp, event, helper, "Só é permitido 'Aguardando Entrega Fornecedor' vindo de status 'Novo'", "Transição inválida", "error", "Erro: ", "dismissible")
                  helper.preencheTabela(cmp, event, helper);
                  console.error("Transição bloqueada para 'Aguardando Entrega Fornecedor':", oldValue, "->", status, "| Origem permitida: 'Novo'")
                  return;
              }
          } */

        helper.atualizaStatusItem(cmp, event, helper, elemento, status);
    },

    cancelaItem: function (cmp, event, helper, iDItemPc) {
        //EXIBE SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.cancelaItem");

        console.log("ID ITEM PC cancela", iDItemPc)

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            itemPC: iDItemPc
        });
        //----------------------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                console.log("cancelou item")
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "ITEM CANCELADO", "TUDO OK!", "success", "", "dismissable")
                helper.preencheTabela(cmp, event, helper);
                //helper.preencheTabelaSecundariaRecebimento(cmp, event, helper, helper.codigoProdutoRecebimentoAtual, helper.idItemPCRecebimentoAtual, helper.quantidadeRecebidaRecebimentoAtual, helper.qtdTotalRecebimentoAtual )
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO AO CANCELAR O ITEM", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors)
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CANCELAR O ITEM", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO AO CANCELAR O ITEM", "error", "Erro: ", "sticky")
                    console.log(errors)
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },

    atualizaStatusItem: function (cmp, event, helper, elemento, status) {
        var iDItemPc = $(elemento).attr('data-iditempc');

        if (status == "Cancelado") {
            helper.cancelaItem(cmp, event, helper, iDItemPc);
            return;
        }

        //EXIBE SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.statusItemPC");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idItemPC: iDItemPc,
            stts: status,
        });
        //----------------------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                console.log("alterou status")
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "STATUS ALTERADO", "TUDO OK!", "success", "", "dismissable")
                //helper.preencheTabela(cmp, event, helper);
                //helper.preencheTabelaSecundariaRecebimento(cmp, event, helper, helper.codigoProdutoRecebimentoAtual, helper.idItemPCRecebimentoAtual, helper.quantidadeRecebidaRecebimentoAtual, helper.qtdTotalRecebimentoAtual )
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ALTERAÇÃO DO STATUS", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors)
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE A ALTERAÇÃO DO STATUS", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A ALTERAÇÃO DO STATUS", "error", "Erro: ", "sticky")
                    console.log(errors)
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },

    //CONFIRMA A ALTERAÇÃO DE PRAZO (PREPARA O POPUP COM AS INFORMAÇÕES)
    confirmaAlterarPrazoPopup: function (cmp, event, helper, elemento) {
        $("#containerChildDestinacao").css("display", "flex");
        $("#linhaRecebimento").show()
        $("#linhaQuantidade").hide()
        $("#linhaQuantidade2").hide()
        $("#linhaConta").hide()
        $("#atenderPedido").hide()
        $(".popup").css("height", "170px")

        $("#containerChildDestinacao").attr('data-tipo', 'confirmaAlteraPrazo')

        $(".datepicker").datepicker("destroy");

        $('.datepicker').datepicker({
            format: 'dd/mm/yyyy',
            language: 'pt-BR',
            startDate: '+0d'
        });

        $(".datepicker").datepicker("refresh");

        helper.eventsAfterModalDestinacao(cmp, event, helper);

    },

    //VALIDA E ENVIA A ALTERAÇÃO DE PRAZO--------------------------------------------------------
    validaConfirmaAlteraPrazo: function (cmp, event, helper, elemento) {

        var dataRecebimento = $('.datepicker').data('datepicker').getFormattedDate('yyyy-mm-dd');
        var dataFormatada = new Date(String(dataRecebimento)).toISOString().split('T')[0]
        helper.enviaConfirmaAlteraPrazo(cmp, event, helper, elemento, dataFormatada);

    },

    enviaConfirmaAlteraPrazo: function (cmp, event, helper, elemento, dataFormatada) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var idPC = helper.retornaRecorId(cmp, event, helper)
        var idItensPV = []

        $('.blocoItemPedidoVendaFilho').each(function () {
            var idItemPV = $(this).attr('data-iditempedido')
            idItensPV.push(idItemPV)
        })

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.prazoRecebimento");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idItensPV: idItensPV.toString(),
            prazo: dataFormatada,
            idPC: idPC,
        });
        //----------------------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#containerChildDestinacao').css({ "display": "none" }); //OCULTA POPUP

                //OCULTA SPINNER DE CARREGAMENTO
                helper.hideSpinner(cmp);

                //RETORNA O POPUP PARA O ESTADO PADRÃO INICIAL
                helper.setaEstadoPadraoPopup(cmp, event, helper)
                helper.alertaErro(cmp, event, helper, "PRAZO ALTERADO", "TUDO OK!", "success", "", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A MUDANÇA DO PRAZO", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE A MUDANÇA DO PRAZO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "ERRO DESCONHECIDO DURANTE A MUDANÇA DO PRAZO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },
    //------------------------------------------------------------------------------------------

    setaEstadoPadraoPopup: function (cmp, event, helper) {

        $(".datepicker").datepicker("destroy");
        $(".popup").css("height", "300px")

        $('.datepicker').datepicker({
            format: 'dd/mm/yyyy',
            language: 'pt-BR',
            endDate: '+0d',
        });
        $(".datepicker").datepicker("refresh");

        $('#textoQuantidade').html("Quantidade a destinar:")

        $("#linhaQuantidade").show()
        $("#linhaQuantidade2").show()
        $("#linhaConta").show()
        $("#atenderPedido").show()
    },

    //=======================================DESTINACAO===========================================
    //============================================================================================

    //EXIBE POPUP PRINCIPAL (DESTINACAO)
    exibePopupPrincipal: function (cmp, event, helper, elemento) {

        $("#containerDetalhes").css("display", "flex");

        var nomeProduto = $(elemento).attr('data-nomeproduto');
        var modeloProduto = $(elemento).attr('data-modelo');
        var marcaProduto = $(elemento).attr('data-marca');
        var codigo = $(elemento).attr('data-codigo');
        var urlImagem = $(elemento).attr('data-urlImagem');
        var valorTotal = $(elemento).attr('data-valorTotal');
        var idItemPC = $(elemento).attr('data-idItemPC');
        var quantidadeDisponivel = $(elemento).attr('data-quantidadeDisponivel');


        //SETA OS VALORES NA VISUALIZAÇÃO
        $("#containerDetalhes").attr("data-idItemPC", idItemPC);
        $(".nomeProdutoDetails").html(nomeProduto);
        $(".marcaProdutosDetails").html(marcaProduto);
        $(".modeloProdutoDetails").html(modeloProduto);
        $(".produtoProdutosDetails").html(codigo);
        $(".codigosPrecosDetails").html(quantidadeDisponivel);
        $(".imagemPopup").attr("src", urlImagem);


        //preenche tabela do popup principal
        helper.preencheTabelaSecundaria(cmp, event, helper, codigo, idItemPC, quantidadeDisponivel);

    },

    //PREENCHE TABELA SECUNDÁRIA (DESTINACAO)
    preencheTabelaSecundaria: function (cmp, event, helper, codigoProduto, idItemPC, quantidadeDisponivel) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        helper.codigoProdutoDestinacaoAtual = codigoProduto;
        helper.idItemPCDestinacaoAtual = idItemPC;
        helper.quantidadeRecebidaDestinacaoAtual = quantidadeDisponivel;

        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT Id, OrderItemNumber, Order.Status, Quantity, Descricao_da_linha__c, Order.Prazo_de_entrega__c, Order.OrderNumber, Quantidade_a_requisitar_novo__c, Order.Account.Name, Order.Account.Raz_o_Social__c, Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c, PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.StockKeepingUnit, PriceBookEntry.Product2.ProductCode, PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c FROM OrderItem WHERE PriceBookEntry.Product2.ProductCode = '" + codigoProduto + "' AND (Order.Status NOT IN ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Cancelado') AND Quantidade_a_requisitar_novo__c > 0  AND Status__c IN ('OPR - ANALISE DE COMPRA', 'OPR - AG. DESTINAÇÃO')) ")

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itensPedidos) {
                $("#corpoTabelaPedidosCompra").empty()
                itensPedidos.forEach(function (itemPedido) {

                    var idPedido = itemPedido.OrderId
                    var idItemPV = itemPedido.Id
                    var numeroPedido = itemPedido.Order.OrderNumber
                    var nomeDaConta = itemPedido.Order.Account.Name
                    var prazoDeEntrega = itemPedido.Order.Prazo_de_entrega__c
                    var modelo = itemPedido.PricebookEntry.Product2.Modelo__c
                    var marca = itemPedido.PricebookEntry.Product2.Marca__c
                    var quantidadeFaltaRequisitar = itemPedido.Quantidade_a_requisitar_novo__c
                    var statusPedido = itemPedido.Order.Status
                    var quantidadePedido = itemPedido.Quantity
                    var linkPedido = "https://hospcom.my.site.com/Sales/s/order/" + idPedido


                    var inputHtml = "\
<tr id='itemTabelaSecundariaDestinacao' data-quantidadeDisponivel='"+ quantidadeDisponivel + "' data-quantidadeFaltaRequisitar='" + quantidadeFaltaRequisitar + "' data-pedidodevenda='" + numeroPedido + "' data-idItemPC='" + idItemPC + "' data-nomeconta='" + nomeDaConta + "' data-idItemPV='" + idItemPV + "'>\
<td id=''><a href='"+ linkPedido + "' target='_blank'>" + numeroPedido + "</a></td>\
<td id=''>"+ prazoDeEntrega + "</td>\
<td id=''>"+ nomeDaConta + "</td>\
<td id=''>"+ codigoProduto + "</td>\
<td id=''>"+ modelo + "</td>\
<td id=''>"+ marca + "</td>\
<td id=''>"+ quantidadePedido + "</td>\
<td id=''>"+ quantidadeFaltaRequisitar + "</td>\
<td id=''>"+ statusPedido + "</td>\
<td> <button type='button' id='acao' class='btn btn-primary buttonItemTabelaSecundariaDestinacao' style='background-color: #a0bb31; border: 0px'><i class='fa fa-paper-plane'></i></button>\
</td>\
</tr>\
"
                    $("#corpoTabelaPedidosCompra").append(inputHtml)

                });

                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.eventsAfterTabelaSecundaria(cmp, event, helper);

            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    //EVENTOS AFTER PREENCHE TABELA (DESTINACAO)
    eventsAfterTabelaSecundaria: function (cmp, event, helper) {

        //ABRE POPUP DE DESTINACAO
        $(".buttonItemTabelaSecundariaDestinacao").off("click");
        $(".buttonItemTabelaSecundariaDestinacao").on("click", function () {
            console.log("evento de click")
            var elemento = $(this).parents('#itemTabelaSecundariaDestinacao');
            helper.confirmaDestinacaoPopup(cmp, event, helper, elemento);
        });

    },

    confirmaDestinacaoPopup: function (cmp, event, helper, elemento) {
        $("#containerChildDestinacao").css("display", "flex");

        //DEFINE AS VARIÁVEIS
        var nomeConta = $(elemento).attr('data-nomeconta')
        var pedidoVenda = $(elemento).attr('data-pedidodevenda')
        var idItemPv = $(elemento).attr('data-iditempv')
        var idItemPc = $(elemento).attr('data-iditempc')
        var quantidadeFaltaRequisitar = $(elemento).attr('data-quantidadeFaltaRequisitar')
        var quantidadeDisponivel = $(elemento).attr('data-quantidadeDisponivel')

        //INSERE OS DADOS NA VISUALIZAÇÃO DO POPUP
        $('#numeroPedidoPopup').html(pedidoVenda)
        $('#nomeContaPopup').html(nomeConta)
        $('#quantidadeARequisitar').html(quantidadeFaltaRequisitar)

        //INSERE OS ATRIBUTOS COM DADOS NO POPUP
        $("#containerChildDestinacao").attr('data-tipo', 'confirmaDestinacaoPopup')
        $("#containerChildDestinacao").attr('data-iditempv', idItemPv)
        $("#containerChildDestinacao").attr('data-iditempc', idItemPc)
        $("#containerChildDestinacao").attr('data-nomeconta', nomeConta)
        $("#containerChildDestinacao").attr('data-pedidodevenda', pedidoVenda)
        $("#containerChildDestinacao").attr('data-quantidadeDisponivel', quantidadeDisponivel)
        $("#containerChildDestinacao").attr('data-quantidadeFaltaRequisitarPedido', quantidadeFaltaRequisitar)

        //EVENTOS ACIONADOS APÓS A EXIBIÇÃO DO POPUP
        helper.eventsAfterModalDestinacao(cmp, event, helper);
    },

    //EXIBE MODAL DE DESTINACAO (DESTINACAO)
    modalDestinacao: function (cmp, event, helper, elemento) {
        $("#containerChildDestinacao").css("display", "flex");
        helper.eventsAfterModalDestinacao(cmp, event, helper);
    },

    //EVENTOS AFTER MODAL (DESTINACAO)
    eventsAfterModalDestinacao: function (cmp, event, helper) {
        console.log("events after modal destinacao")
        //FECHA MODAL DESTINACAO
        $(".closeButtonPopupAtende").off("click");
        $(".closeButtonPopupAtender").on("click", function () {
            $("#containerChildDestinacao").css("display", "none");
            helper.setaEstadoPadraoPopup(cmp, event, helper)
        });


        //CHAMA A FUNCAO PRA CONFIRMAR A DESTINACAO
        $("#confirmarDestinacaoPopup").off("click");
        $("#confirmarDestinacaoPopup").on("click", function () {

            var elemento = $(this).parents('#containerChildDestinacao');
            var tipo = $(elemento).attr('data-tipo')

            if (tipo == 'confirmaDestinacao') {
                helper.validaConfirmaDestinacao(cmp, event, helper, elemento)
            } else if (tipo == 'excluiDestinacao') {
                helper.validaConfirmaExclusao(cmp, event, helper, elemento)
            } else if (tipo == 'confirmaDestinacaoPopup') {
                helper.validaConfirmaDestinacaoPopup(cmp, event, helper, elemento)
            } else if (tipo == 'confirmaRecebimentoPopup') {
                console.log("click do botao confirmando o recebimento no popup")
                helper.validaConfirmaRecebimentoPopup(cmp, event, helper, elemento)
            } else if (tipo == 'confirmaRecebimentoPopupEstoque') {
                helper.validaConfirmaRecebimentoPopupEstoque(cmp, event, helper, elemento)
            } else if (tipo == 'confirmaAlteraPrazo') {
                helper.validaConfirmaAlteraPrazo(cmp, event, helper, elemento)
            }

        });

    },

    //VALIDA E ENVIA DESTINACAO POPUP ----------------------------------------
    validaConfirmaDestinacaoPopup: function (cmp, event, helper, elemento) {
        var quantidadeADestinar = parseInt($(elemento).find('#inputQantidadeADestinar').val())
        var quantidadeDisponivel = parseInt($(elemento).attr('data-quantidadedisponivel'))
        var quantidadeFaltaRequisitarPedido = parseInt($(elemento).attr('data-quantidadefaltarequisitarpedido'))

        console.log("QUANTIDADE DISPONIVEL" + quantidadeDisponivel)
        console.log("QUANTIDADE A DESTINAR" + quantidadeADestinar)
        console.log("QUANTIDADE FALTA REQUISITAR PEDIDO" + quantidadeFaltaRequisitarPedido)

        console.log(quantidadeADestinar > quantidadeDisponivel)
        console.log(quantidadeADestinar == 0)
        console.log(quantidadeADestinar > quantidadeFaltaRequisitarPedido)

        if ((quantidadeADestinar > quantidadeDisponivel) || (quantidadeADestinar == 0) || (quantidadeADestinar > quantidadeFaltaRequisitarPedido)) {
            helper.alertaErro(cmp, event, helper, "A quantidade destinada não pode ser maior que a disponível ou igual a 0", "Dados inválidos!", "error", "Erro: ", "dismissible")
        } else {
            helper.enviaConfirmaDestinacaoPopup(cmp, event, helper, elemento);
        }
    },

    enviaConfirmaDestinacaoPopup: function (cmp, event, helper, elemento) {
        console.log("envia confirma destinacao")

        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);



        var quantidadeDisponivelAtual = parseInt($("#containerDetalhes").find('.codigosPrecosDetails').html())
        var quantidadeADestinar = parseInt($(elemento).find('#inputQantidadeADestinar').val())
        var quantidadeSetada = parseInt(quantidadeDisponivelAtual - quantidadeADestinar)

        var idItemPv = $(elemento).attr('data-iditempv')
        var idItemPc = $(elemento).attr('data-iditempc')

        console.log("enviado destinacao=====")
        console.log(idItemPv)
        console.log(idItemPc)
        console.log(quantidadeADestinar)

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.destina");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idItemPC: idItemPc,
            idItemPV: idItemPv,
            quantidade: quantidadeADestinar,
        });
        //----------------------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#containerChildDestinacao').css({ "display": "none" }); //OCULTA POPUP
                $("#containerDetalhes").find('.codigosPrecosDetails').html(quantidadeSetada)

                helper.setaEstadoPadraoPopup(cmp, event, helper); //RESETA O POPUP DE CONFIRMAÇÃO
                helper.preencheTabelaSecundaria(cmp, event, helper, helper.codigoProdutoDestinacaoAtual, helper.idItemPCDestinacaoAtual, helper.quantidadeRecebidaDestinacaoAtual)
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "DESTINAÇÃO CONFIRMADA", "TUDO OK!", "success", "", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A CONFIRMAÇÃO DA DESTINAÇÃO", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE A CONFIRMAÇÃO DA DESTINAÇÃO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A CONFIRMAÇÃO DA DESTINAÇÃO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },
    //------------------------------------------------------------------------

    //VALIDA E ENVIA A DESTINACAO FORA DO POPUP (TABELA DE DESTINACAO)---
    validaConfirmaDestinacao: function (cmp, event, helper, elemento) {
        var quantidadeADestinar = parseInt($(elemento).find('#inputQantidadeADestinar').val())
        var quantidadeDisponivel = parseInt($(elemento).attr('data-quantidadedisponivel'))
        //var quantidadeFaltaRequisitarPedido = $(elemento).attr('data-quantidadeFaltaRequisitarPedido')

        //alert(quantidadeFaltaRequisitarPedido)

        if (quantidadeADestinar > quantidadeDisponivel || quantidadeADestinar == 0) {
            helper.alertaErro(cmp, event, helper, "A quantidade destinada não pode ser maior que a disponível ou igual a 0", "Dados inválidos!", "error", "Erro: ", "dismissible")
        } else {
            helper.EnviaConfirmaDestinacao(cmp, event, helper, elemento);
        }

    },

    EnviaConfirmaDestinacao: function (cmp, event, helper, elemento) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var idRequisicao = $(elemento).attr('data-idrequisicao')
        var quantidadeADestinar = $(elemento).find('#inputQantidadeADestinar').val()

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.confirmaDestinacao");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idRequisicao: idRequisicao,
            quantidade: quantidadeADestinar,
        });
        //----------------------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#containerChildDestinacao').css({ "display": "none" }); //OCULTA POPUP
                helper.preencheTabela(cmp, event, helper)
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "DESTINAÇÃO CONFIRMADA", "TUDO OK!", "success", "", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A CONFIRMAÇÃO DA DESTINAÇÃO", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                console.log("erro")
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE A CONFIRMAÇÃO DA DESTINAÇÃO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A CONFIRMAÇÃO DA DESTINAÇÃO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },
    //-------------------------------------------------------------------

    //VALIDA E ENVIA A EXCLUSAO DA DESTINACAO DE FORA DO POPUP (TABELA DE DESTINACAO)
    validaConfirmaExclusao: function (cmp, event, helper, idDestinacao) {
        if (confirm('Deseja mesmo excluir essa destinação?')) {
            helper.EnviaConfirmaExclusao(cmp, event, helper, idDestinacao)
        }
    },

    EnviaConfirmaExclusao: function (cmp, event, helper, idDestinacao) {

        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.deletaDestinacao");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idDestinacao: idDestinacao
        });
        //----------------------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#containerChildDestinacao').css({ "display": "none" }); //OCULTA POPUP
                helper.preencheTabela(cmp, event, helper)
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "EXCLUSÃO CONFIRMADA", "TUDO OK!", "success", "", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A EXCLUSÃO DA DESTINAÇÃO", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                console.log("erro")
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE A EXCLUSÃO DA DESTINAÇÃO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A EXCLUSÃO DA DESTINAÇÃO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },
    //-------------------------------------------------------------------------------

    //======================================RECEBIMENTO===========================================
    //============================================================================================

    //VALIDA E ENVIA RECEBIMENTO POPUP ESTOQUE---------------------------------------
    validaConfirmaRecebimentoPopupEstoque: function (cmp, event, helper, elemento) {
        var quantidadeADestinar = $(elemento).find('#inputQantidadeADestinar').val()
        var dataRecebimento = $(elemento).find('#inputDataRecebimento').val()
        var quantidadeAReceber = $(elemento).attr('data-quantidadeareceber')

        console.log("quantidade a destinar", quantidadeADestinar)
        console.log("quantidade a receber", quantidadeAReceber)

        if (!quantidadeADestinar || !dataRecebimento) {
            helper.alertaErro(cmp, event, helper, "Você deve inserir uma quantidade e uma data válida!", "Dados inválidos!", "error", "Erro: ", "dismissible")
        } else {
            if (parseInt(quantidadeADestinar) > parseInt(quantidadeAReceber)) {
                helper.alertaErro(cmp, event, helper, "A quantidade a destinar não pode ser maior que a quantidade a receber.", "Dados inválidos!", "error", "Erro: ", "dismissible")
            } else {
                var dataRecebimento = $('#inputDataRecebimento').data('datepicker').getFormattedDate('yyyy-mm-dd');
                helper.enviaConfirmaRecebimentoPopupEstoque(cmp, event, helper, elemento, dataRecebimento);
            }
        }

    },

    enviaConfirmaRecebimentoPopupEstoque: function (cmp, event, helper, elemento, data) {
        //EXIBE SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        var quantidade = $(elemento).find('#inputQantidadeADestinar').val()
        var idItemPc = $(elemento).attr('data-iditempc')

        var quantidadeRecebidaAtual = $("#containerRecebimento").find('.quantidadeRecebida').html()
        var quantidadeAReceberAtual = $("#containerRecebimento").find('.quantidadeAReceber').html()
        var quantidadeRecebidaFutura = parseInt(quantidadeRecebidaAtual) + parseInt(quantidade)
        var quantidadeAReceberFutura = parseInt(quantidadeAReceberAtual) - parseInt(quantidade)

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.recebeEstoque");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idItemPC: idItemPc,
            quantidade: quantidade,
            dataRecebimento: data,
        });
        //----------------------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#containerChildDestinacao').css({ "display": "none" }); //OCULTA POPUP
                $("#linhaRecebimento").css({ "display": "none" }); //OCULTA LINHA COM DATEPICKER
                $("#containerRecebimento").find('.quantidadeRecebida').html(quantidadeRecebidaFutura)
                $("#containerRecebimento").find('.quantidadeAReceber').html(quantidadeAReceberFutura)
                $("#containerRecebimento").attr('data-quantidadeareceber', quantidadeAReceberFutura)

                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "RECEBIMENTO CONFIRMADO", "TUDO OK!", "success", "", "dismissable")
                helper.preencheTabelaSecundariaRecebimento(cmp, event, helper, helper.codigoProdutoRecebimentoAtual, helper.idItemPCRecebimentoAtual, helper.quantidadeRecebidaRecebimentoAtual, helper.qtdTotalRecebimentoAtual)
            }
            else if (state === "INCOMPLETE") {
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE O RECEBIMENTO", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE O RECEBIMENTO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE O RECEBIMENTO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);

    },

    //VALIDA E ENVIA RECEBIMENTO POPUP------------------------------------------------
    validaConfirmaRecebimentoPopup: function (cmp, event, helper, elemento) {
        var quantidadeADestinar = $(elemento).find('#inputQantidadeADestinar').val()
        var dataRecebimento = $(elemento).find('#inputDataRecebimento').val()


        if (!quantidadeADestinar || !dataRecebimento) {
            helper.alertaErro(cmp, event, helper, "Você deve inserir uma quantidade e uma data válida!", "Dados inválidos!", "error", "Erro: ", "dismissible")
        } else {
            var dataRecebimento = $('#inputDataRecebimento').data('datepicker').getFormattedDate('yyyy-mm-dd');
            //var dataFormatada = new Date(String(dataRecebimento)).toISOString().split('T')[0]
            helper.enviaConfirmaRecebimentoPopup(cmp, event, helper, elemento, dataRecebimento);
        }


    },

    enviaConfirmaRecebimentoPopup: function (cmp, event, helper, elemento, data) {
        //EXIBE SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        var quantidade = $(elemento).find('#inputQantidadeADestinar').val()
        var idDestinacao = $(elemento).attr('data-iddestinacao')
        var idItemPv = $(elemento).attr('data-iditempv')
        var idItemPc = $(elemento).attr('data-iditempc')

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.recebeItemDestinado");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idItemPC: idItemPc,
            idDestinacao: idDestinacao,
            quantidade: quantidade,
            dataRecebimento: data,
        });
        //----------------------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#containerChildDestinacao').css({ "display": "none" }); //OCULTA POPUP
                $("#linhaRecebimento").css({ "display": "none" }); //OCULTA LINHA COM DATEPICKER
                var quantidadeRecebidaAtual = $("#containerRecebimento").find('.quantidadeRecebida').html()
                var quantidadeAReceberAtual = $("#containerRecebimento").find('.quantidadeAReceber').html()

                $(elemento).find('.quantidadeRecebida').html(quantidadeRecebidaAtual + quantidade)
                $(elemento).find('.quantidadeAReceber').html(quantidadeAReceberAtual - quantidade)

                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.alertaErro(cmp, event, helper, "RECEBIMENTO CONFIRMADO", "TUDO OK!", "success", "", "dismissable")
                helper.preencheTabelaSecundariaRecebimento(cmp, event, helper, helper.codigoProdutoRecebimentoAtual, helper.idItemPCRecebimentoAtual, helper.quantidadeRecebidaRecebimentoAtual, helper.qtdTotalRecebimentoAtual)
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE O RECEBIMENTO", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE O RECEBIMENTO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE O RECEBIMENTO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);

    },
    //--------------------------------------------------------------------------------

    //EXIBE POPUP SECUNDARIO (RECEBIMENTO)
    exibePopupRecebimento: function (cmp, event, helper, elemento) {
        $("#containerRecebimento").css("display", "flex");

        var nomeProduto = $(elemento).attr('data-nomeproduto');
        var modeloProduto = $(elemento).attr('data-modelo');
        var marcaProduto = $(elemento).attr('data-marca');
        var codigo = $(elemento).attr('data-codigo');
        var urlImagem = $(elemento).attr('data-urlImagem');
        var valorTotal = $(elemento).attr('data-valorTotal');
        var quantidadeRecebida = $(elemento).attr('data-quantidaderecebida');
        var qtdTotal = $(elemento).attr('data-quantidade');
        var idItemPC = $(elemento).attr('data-idItemPC');
        var quantidadeAReceber = qtdTotal - quantidadeRecebida

        //SETA OS VALORES COMO ATRIBUTOS DA DIV
        $("#containerRecebimento").attr('data-quantidadeAReceber', quantidadeAReceber)
        $("#containerRecebimento").attr('data-idItemPC', idItemPC)

        //SETA OS VALORES NA VISUALIZAÇÃO
        $(".nomeProdutoDetails").html(nomeProduto);
        $(".marcaProdutosDetails").html(marcaProduto);
        $(".modeloProdutoDetails").html(modeloProduto);
        $(".quantidadeRecebida").html(quantidadeRecebida);
        $(".produtoProdutosDetails").html(codigo);
        $(".quantidadeRequisitadaRecebimento").html(qtdTotal);
        $(".quantidadeAReceber").html(quantidadeAReceber);
        $(".codigosPrecosDetails").html("R$ " + valorTotal);
        $(".imagemPopup").attr("src", urlImagem);

        helper.preencheTabelaSecundariaRecebimento(cmp, event, helper, codigo, idItemPC, quantidadeRecebida, qtdTotal)

    },

    //PREENCHE TABELA SECUNDÁRIA (RECEBIMENTO)
    preencheTabelaSecundariaRecebimento: function (cmp, event, helper, codigoProduto, idItemPC, quantidadeRecebida, qtdTotal) {
        //EXIBE SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        //ATUALIZA VARIÁVEIS GLOBAIS (UTILIZADAS NA ATUALIZAÇÃO DA TABELA)
        helper.codigoProdutoRecebimentoAtual = codigoProduto;
        helper.idItemPCRecebimentoAtual = idItemPC;
        helper.quantidadeRecebidaRecebimentoAtual = quantidadeRecebida;
        helper.qtdTotalRecebimentoAtual = qtdTotal;
        //----------------------------------------------------------------

        var IdPedidoDeCompra = helper.retornaRecorId(cmp, event, helper);

        var query = "select id, name, Quantidade_Recebida__c, Item_de_pedido_de_compra__c, Item_de_pedido_de_compra__r.Produto__r.Valor_Total__c, Item_de_pedido_de_compra__r.Produto__r.URL_da_Imagem__c, Fornecedor__c, Codigo_do_produto__c, Produto__c, Modelo__c, Marca__c, Quantidade__c,  (SELECT id, Quantidade_recebida_novo__c, Quantidade_Disponivel__c, Quantidade_requisitada__c, Item_de_pedido_de_venda__r.order.Prazo_de_entrega__c, Item_de_pedido_de_venda__r.order.Account.Name, Item_de_pedido_de_venda__r.order.OrderNumber,Item_de_pedido_de_venda__r.OrderItemNumber from Destinacoes__r) from Item_de_fornecedor__c WHERE id = '" + idItemPC + "' AND Fornecedor__c = '" + IdPedidoDeCompra + "' AND Quantidade_destinada__c >  0"
        //REALIZA A CONSULTA
        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itensPedidos) {
                $("#corpoTabelaSecundariaRecebimento").empty()
                //var destinacoes = itensPedidos
                console.log("QUERY DESTINACOES", query)
                console.log(itensPedidos)
                console.log(query)
                console.log(idItemPC)

                try {

                    $("#receberEstoque").removeAttr("disabled")

                    itensPedidos[0].Destinacoes__r.forEach(function (itemPedido) {

                        if (itemPedido.hasOwnProperty("Item_de_pedido_de_venda__c")) {
                            var idPV = itemPedido.Item_de_pedido_de_venda__r.OrderId
                            var quantidadeRecebida = itemPedido.Quantidade_recebida_novo__c == undefined ? "NÃO DEFINIDO" : itemPedido.Quantidade_recebida_novo__c
                            var idDestinacao = itemPedido.Id
                            var numeroPedido = itemPedido.Item_de_pedido_de_venda__r.Order.OrderNumber
                            var nomeDaConta = itemPedido.Item_de_pedido_de_venda__r.Order.Account.Name
                            var itemPv = itemPedido.Item_de_pedido_de_venda__r.OrderItemNumber
                            var idItemPv = itemPedido.Item_de_pedido_de_venda__r.Id
                            var quantidadeRequisitada = itemPedido.Quantidade_requisitada__c
                            var statusButton = (quantidadeRequisitada == quantidadeRecebida || quantidadeRecebida == "NÃO DEFINIDO") ? "disabled = 'true'" : ""
                            var linkPedido = "https://hospcom.my.site.com/Sales/s/order/" + idPV

                            console.log("STATUS BUTTON", statusButton)
                            if (statusButton != "disabled = 'true'") {
                                console.log("diferente")
                                $("#receberEstoque").attr("disabled", "disabled")
                            }

                            var inputHtml = "\
                            <tr id='itemTabelaSecundaria' data-iddestinacao='"+ idDestinacao + "' data-quantidadeTotal='" + qtdTotal + "' data-quantidadeRecebida='" + quantidadeRecebida + "' data-nomeDaConta='" + nomeDaConta + "' data-pedidoVenda='" + numeroPedido + "' data-idItemPC='" + idItemPC + "' data-idItemPv='" + idItemPv + "' data-quantidadeRequisitada='" + quantidadeRequisitada + "'>\
                            <td id=''><a href='"+ linkPedido + "' target='_blank'>" + numeroPedido + "</a></td>\
                            <td id=''>"+ itemPv + "</td>\
                            <td id=''>"+ nomeDaConta + "</td>\
                            <td id=''>"+ quantidadeRequisitada + "</td>\
                            <td id=''>"+ quantidadeRecebida + "</td>\
                            <td> <button type='button' id='acao' "+ statusButton + " class='btn btn-primary buttonItemTabelaSecundaria' style='background-color: #a0bb31; border: 0px'><i class='fa fa-paper-plane iconRotate'></i></button></td>\
                            </tr>\
                            "
                            $("#corpoTabelaSecundariaRecebimento").append(inputHtml)
                        }
                    });
                } catch (err) {
                    console.log("sem destinações!")
                    console.log(err)
                }
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.eventsAfterTabelaSecundariaRecebimento(cmp, event, helper);

            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    //EVENTOS AFTER PREENCHE TABELA SECUNDÁRIA (RECEBIMENTO)
    eventsAfterTabelaSecundariaRecebimento: function (cmp, event, helper) {

        //ABRE POPUP DE DESTINACAO
        $(".buttonItemTabelaSecundaria").off("click");
        $(".buttonItemTabelaSecundaria").on("click", function () {
            var elemento = $(this).parents('#itemTabelaSecundaria');
            helper.confirmaRecebimentoPopup(cmp, event, helper, elemento);
        });

        //CLIQUE NO BOTAO DE RECEBER PARA ESTOQUE
        $(".buttonRecebeEstoque").off("click");
        $(".buttonRecebeEstoque").on("click", function () {
            var elemento = $(this).parents('#containerRecebimento');
            helper.confirmaRecebimentoPopupEstoque(cmp, event, helper, elemento);
        });
    },

    //EXIBE O POPUP PRA CONFIRMAR O RECEBIMENTO E SETA AS INFORMAÇÕES NO POPUP
    confirmaRecebimentoPopup: function (cmp, event, helper, elemento) {
        $("#containerChildDestinacao").css("display", "flex");
        $("#linhaRecebimento").show()

        //DEFINE AS VARIÁVEIS
        var nomeConta = $(elemento).attr('data-nomedaconta')
        var pedidoVenda = $(elemento).attr('data-pedidovenda')
        var idItemPv = $(elemento).attr('data-iditempv')
        var idItemPc = $(elemento).attr('data-iditempc')
        var quantidadeRequisitada = $(elemento).attr('data-quantidaderequisitada')
        var quantidadeDisponivel = $(elemento).attr('data-quantidadeDisponivel')
        var quantidadeRecebida = $(elemento).attr('data-quantidaderecebida')
        var quantidadeTotal = $(elemento).attr('data-quantidadetotal')
        var idDestinacao = $(elemento).attr('data-iddestinacao')

        //INSERE OS DADOS NA VISUALIZAÇÃO DO POPUP
        $('#numeroPedidoPopup').html(pedidoVenda)
        $('#nomeContaPopup').html(nomeConta)
        $('#quantidadeARequisitar').html(quantidadeRequisitada)
        $('#textoQuantidade').html("Quantidade recebida:")

        //INSERE OS ATRIBUTOS COM DADOS NO POPUP
        $("#containerChildDestinacao").attr('data-tipo', 'confirmaRecebimentoPopup')
        $("#containerChildDestinacao").attr('data-iditempv', idItemPv)
        $("#containerChildDestinacao").attr('data-iditempc', idItemPc)
        $("#containerChildDestinacao").attr('data-nomeconta', nomeConta)
        $("#containerChildDestinacao").attr('data-pedidodevenda', pedidoVenda)
        $("#containerChildDestinacao").attr('data-quantidadetotal', quantidadeTotal)
        $("#containerChildDestinacao").attr('data-quantidaderecebida', quantidadeRecebida)
        $("#containerChildDestinacao").attr('data-quantidadeDisponivel', quantidadeRequisitada)
        $("#containerChildDestinacao").attr('data-iddestinacao', idDestinacao)

        //EVENTOS ACIONADOS APÓS A EXIBIÇÃO DO POPUP
        helper.eventsAfterModalDestinacao(cmp, event, helper);
    },

    confirmaRecebimentoPopupEstoque: function (cmp, event, helper, elemento) {
        $("#containerChildDestinacao").css("display", "flex");
        $("#linhaRecebimento").show()

        //DEFINE AS VARIÁVEIS
        var nomeConta = "RECEBENDO PARA ESTOQUE"
        var pedidoVenda = "RECEBENDO PARA ESTOQUE"
        var idItemPc = $(elemento).attr('data-iditempc')
        var quantidadeAReceber = $(elemento).attr('data-quantidadeareceber')

        //INSERE OS DADOS NA VISUALIZAÇÃO DO POPUP
        $('#numeroPedidoPopup').html(pedidoVenda)
        $('#nomeContaPopup').html(nomeConta)
        $('#textoPopupQuantidade').html("Quantidade a receber:")
        $('#textoQuantidade').html("Quantidade recebida:")
        $('#quantidadeARequisitar').html(quantidadeAReceber)

        //INSERE OS ATRIBUTOS COM DADOS NO POPUP
        $("#containerChildDestinacao").attr('data-tipo', 'confirmaRecebimentoPopupEstoque')
        $("#containerChildDestinacao").attr('data-iditempc', idItemPc)
        $("#containerChildDestinacao").attr('data-quantidadeAReceber', quantidadeAReceber)

        //EVENTOS ACIONADOS APÓS A EXIBIÇÃO DO POPUP
        helper.eventsAfterModalDestinacao(cmp, event, helper)

    }

})