({
    //VARIÁVEIS GLOBAIS DO SELECT DE FILTRO DE BUSCA
    selectLinha: null,
    selectFamilia: null,
    selectTipo: null,
    selectMarca: null,
    selectNPedido: null,
    //----------------------------------------------

    //VARIÁVEIS GLOBAIS GERAIS------------------
    oldColorInput: '',
    oldColorTextInput: '',
    indiceRemocao: '',
    ultimaCategoriaInserida: '',
    imagemUltimaCategoriaInserida: '',
    posicaoDivCotacao: 0,
    posicaoDivProdutoFilho: 0,
    numeroDivEmEdicao: 0,
    iDsPedidoDeCompra : [],
    itensPedidosPadronizados : null,
    tipoPedido : '',
    //------------------------------------------


    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecorId: function (cmp, event, helper) {
        var recordId = 'a1e6e000020FI5nAAG'
        return recordId
    },
    //---------------------------------------------------
    
    criaLogs: function (cmp, event, helper, conteudo, titulo, tipo, contentType, pasta){
        //REALIZA A CONSULTA
        this.criaLog(cmp, conteudo, titulo, tipo, contentType, pasta)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (result) {
            console.log("ID DO LOG CRIADO: ", result)
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

    eventsAfterAppend: function (cmp, event, helper) {

        //EVENTO QUE FORMATA O TAMANHO DOS TEXTOS COM BASE NO TAMANHO DA DIV PAI
        var divProdutosHeight = parseInt($(".divListaProdutosMaster").height()) + "px";
        $("#listaProdutos").css('height', divProdutosHeight);
        //----------------------------------------------------------------------

        //EVENTO QUE FORMATA O TAMANHO DOS TEXTOS COM BASE NO TAMANHO DA DIV PAI
        var divCotacaoHeight = parseInt($(".divListaProdutosCotacao").height()) + "px";
        $("#listaCotacao").css('height', divCotacaoHeight);
        //----------------------------------------------------------------------

        //EVENTO QUE FORMATA O TAMANHO DOS TEXTOS COM BASE NO TAMANHO DA DIV PAI
        var divColunaScrollParent = parseInt($("#divColunaScrollParent").height() - 10) + "px";
        $("#colunaPlataformaMkt").css('height', divColunaScrollParent);
        //----------------------------------------------------------------------

    },

    //FUNÇÃO QUE PREENCHE OS FILTROS DISPONÍVEIS PARA PESQUISA-------
    preencheFiltros: function (cmp, event, helper, inputPesquisa, filtro) {

        if (filtro === 'linha' || filtro === 'null') {
            helper.preencheLinhas(cmp, event, helper, inputPesquisa, filtro)
        } else if (filtro === 'familia') {
            helper.preencheFamilias(cmp, event, helper, inputPesquisa, filtro)
        } else if (filtro === 'tipo') {
            helper.preencheTipos(cmp, event, helper, inputPesquisa, filtro)
        } else if (filtro === 'marca') {
            helper.preencheMarcas(cmp, event, helper, inputPesquisa, filtro)
        }

    },
    //---------------------------------------------------------------

    //ESSA FUNÇÃO PREENCHE O SELECT COM AS LINHAS DISPONÍVEIS
    preencheLinhas: function (cmp, event, helper, inputPesquisa, filtro) {
        //Oculta os demais selects
        $("#selectFamilia").hide()
        $("#selectTipo").hide()
        $("#selectMarca").hide()

        //cria um array vazio de linhas
        const linhas = [];

        if (inputPesquisa === 'all') {
            var query = "SELECT Linha__c FROM Product2 WHERE IsActive = true"
        } else {
            var query = "SELECT Linha__c FROM Product2 WHERE IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%')"
        }

        //realiza a consulta
        helper.soql(cmp, query)

            //quando a solicitação for concluída, faça:
            .then(function (produtos) {
                //percorre o json de produtos adicionando as linhas no array de linhas
                produtos.forEach(function (atual) {
                    //só adiciona a linha no array se ela não já tiver sido adicionada
                    if (linhas.indexOf(atual.Linha__c) == -1 && atual.Linha__c !== undefined) {
                        linhas.push(atual.Linha__c);
                    }
                })

                //limpa todos as opções do select
                $("#listaItens1").empty();
                $("#listaItens2").empty();

                //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
                $("#listaItens1").append("<input type='radio' name='item1' id='default' title='Linha' checked='true'/>")

                linhas.forEach(function (atualLinha) {
                    if (String(atualLinha).length >= 8) {
                        var titleLinha = String(atualLinha).substring(0, 8) + "..."
                    } else {
                        var titleLinha = atualLinha
                    }

                    $("#listaItens1").append("<input type='radio' name='item1' id='" + atualLinha + "' title='" + titleLinha + "'/>")
                    $("#listaItens2").append("<li id='" + atualLinha + "' class='itemLinha' onclick=''><label class='labelLinha' for='" + atualLinha + "'>" + atualLinha + "</label></li>")

                })

                $('.itemLinha').click(function () {
                    helper.selectLinha = $(this).text();
                    $('#selectLinhas').removeAttr("open");
                    helper.buscaProdutos(cmp, event, helper, helper.inputPesquisa, "familia")
                });

            })
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })

    },

    //ESSA FUNÇÃO PREENCHE O SELECT COM AS FAMÍLIAS DISPONÍVEIS
    preencheFamilias: function (cmp, event, helper, inputPesquisa, filtro) {

        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        //Oculta os demais selects
        $("#selectTipo").hide()
        $("#selectMarca").hide()

        $("#selectFamilia").show()

        //cria um array vazio de linhas
        const familias = [];

        //recupera linha selecionada
        const linhaSelecionada = helper.selectLinha;

        if (inputPesquisa === 'all') {
            var query = "SELECT Linha__c, Family FROM Product2 WHERE IsActive = true AND Linha__c ='" + linhaSelecionada + "' ORDER BY Family"
        } else {
            var query = "SELECT Family, Linha__c FROM Product2 WHERE IsActive = true AND Linha__c = '" + linhaSelecionada + "' AND (Name like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY Family"
        }

        //realiza a consulta
        helper.soql(cmp, query)

            //quando a solicitação for concluída, faça:
            .then(function (produtos) {
                //percorre o json de produtos adicionando as linhas no array de linhas
                produtos.forEach(function (atual) {
                    //só adiciona a linha no array se ela não já tiver sido adicionada
                    if (familias.indexOf(atual.Family) == -1 && atual.Linha__c !== undefined) {
                        familias.push(atual.Family);
                    }
                })

                //limpa todos as opções do select
                $("#listaFamilia1").empty();
                $("#listaFamilia2").empty();


                //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
                $("#listaFamilia1").append("<input type='radio' name='item2' id='default' title='Familia' checked='true'/>")

                familias.forEach(function (atualFamilia) {
                    console.log(atualFamilia)
                    if (atualFamilia !== undefined) {
                        if (String(atualFamilia).length >= 8) {
                            var titleFamilia = String(atualFamilia).substring(0, 8) + "..."
                        } else {
                            var titleFamilia = atualFamilia
                        }
                        $("#listaFamilia1").append("<input type='radio' name='item2' id='" + atualFamilia + "' title='" + titleFamilia + "'/>")
                        $("#listaFamilia2").append("<li id='" + atualFamilia + "' class='itemFamilia'><label class='labelLinha' for='" + atualFamilia + "'>" + atualFamilia + "</label></li>")
                    }
                })

                //Ouvinte de clique em um item do select
                $('.itemFamilia').click(function () {
                    helper.selectFamilia = $(this).text();
                    $('#selectFamilia').removeAttr("open");
                    helper.buscaProdutos(cmp, event, helper, helper.inputPesquisa, "tipo")
                });

                //Oculta Spinner de carregamento
                helper.hideSpinner(cmp);
            })
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    //ESSA FUNÇÃO PREENCHE O SELECT COM OS TIPOS DISPONÍVEIS
    preencheTipos: function (cmp, event, helper, inputPesquisa, filtro) {

        //Exibe spinner de carregamento
        helper.showSpinner(cmp);

        //Oculta os demais selects
        $("#selectMarca").hide()

        //cria um array vazio de linhas
        const tipos = [];

        //recupera familia selecionada
        const familiaSelecionada = helper.selectFamilia;

        //recupera linha selecionado
        const linhaSelecionada = helper.selectLinha;

        if (inputPesquisa === 'all') {
            var query = "SELECT Linha__c, Family, Tipo_do_Produto__c FROM Product2 WHERE IsActive = true AND Linha__c ='" + linhaSelecionada + "' AND Family = '" + familiaSelecionada + "' ORDER BY Tipo_do_Produto__c"
        } else {
            var query = "SELECT Family, Linha__c, Tipo_do_Produto__c FROM Product2 WHERE IsActive = true AND Linha__c = '" + linhaSelecionada + "' AND Family = '" + familiaSelecionada + "' AND (Name like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY Tipo_do_Produto__c"
        }

        //realiza a consulta 
        helper.soql(cmp, query)
            //quando a solicitação for concluída, faça:
            .then(function (produtos) {
                //percorre o json de produtos adicionando as linhas no array de linhas
                produtos.forEach(function (atual) {
                    //só adiciona a linha no array se ela não já tiver sido adicionada
                    if (tipos.indexOf(atual.Tipo_do_Produto__c) == -1) {
                        tipos.push(atual.Tipo_do_Produto__c);
                    }
                })

                $("#selectTipo").show()

                //limpa todos as opções do select
                $("#listaTipo1").empty();
                $("#listaTipo2").empty();

                //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
                $("#listaTipo1").append("<input type='radio' name='item3' id='default' title='Tipo' checked='true'/>")

                tipos.forEach(function (atualTipo) {
                    if (atualTipo !== undefined) {
                        if (String(atualTipo).length >= 8) {
                            var titleFamilia = String(atualTipo).substring(0, 8) + "..."
                        } else {
                            var titleFamilia = atualTipo
                        }
                        $("#listaTipo1").append("<input type='radio' name='item3' id='" + atualTipo + "' title='" + titleFamilia + "'/>")
                        $("#listaTipo2").append("<li id='" + atualTipo + "' class='itemTipo'><label class='labelLinha' for='" + atualTipo + "'>" + atualTipo + "</label></li>")
                    }
                })

                //EVENTO DE OUVINTE
                $('.itemTipo').click(function () {
                    helper.selectTipo = $(this).text();
                    $('#selectTipo').removeAttr("open");
                    helper.buscaProdutos(cmp, event, helper, helper.inputPesquisa, "marca")
                });

                //Oculta Spinner de carregamento
                helper.hideSpinner(cmp);
            })
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    //ESSA FUNÇÃO PREENCHE O SELECT COM OS TIPOS DISPONÍVEIS
    preencheMarcas: function (cmp, event, helper, inputPesquisa, filtro) {
        console.log("preenchendo Marcas...");

        //Exibe spinner de carregamento
        helper.showSpinner(cmp);

        //cria um array vazio de linhas
        const marcas = [];

        //recupera familia selecionada
        const familiaSelecionada = helper.selectFamilia;

        //recupera linha selecionado
        const linhaSelecionada = helper.selectLinha;

        //recupera tipo selecionada
        const tipoSelecionado = helper.selectTipo;

        if (inputPesquisa === 'all') {
            var query = "SELECT Linha__c, Family, Tipo_do_Produto__c, Marca__c FROM Product2 WHERE IsActive = true AND Tipo_do_Produto__c = '" + tipoSelecionado + "' AND Linha__c ='" + linhaSelecionada + "' AND Family = '" + familiaSelecionada + "' ORDER BY Marca__c"
        } else {
            var query = "SELECT Family, Linha__c, Tipo_do_Produto__c, Marca__c FROM Product2 WHERE IsActive = true AND Tipo_do_Produto__c = '" + tipoSelecionado + "' AND Linha__c = '" + linhaSelecionada + "' AND Family = '" + familiaSelecionada + "' AND (Name like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY Marca__c"
        }

        //realiza a consulta 
        helper.soql(cmp, query)
            //quando a solicitação for concluída, faça:
            .then(function (produtos) {
                //percorre o json de produtos adicionando as linhas no array de linhas
                produtos.forEach(function (atual) {
                    //só adiciona a linha no array se ela não já tiver sido adicionada
                    if (marcas.indexOf(atual.Marca__c) == -1) {
                        marcas.push(atual.Marca__c);
                    }
                })

                $("#selectMarca").show()

                //limpa todos as opções do select
                $("#listaMarca1").empty();
                $("#listaMarca2").empty();

                //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
                $("#listaMarca1").append("<input type='radio' name='item4' id='default' title='Marca' checked='true'/>")

                marcas.forEach(function (atualMarca) {
                    if (atualMarca !== undefined) {
                        if (String(atualMarca).length >= 8) {
                            var titleMarca = String(atualMarca).substring(0, 8) + "..."
                        } else {
                            var titleMarca = atualMarca
                        }
                        $("#listaMarca1").append("<input type='radio' name='item4' id='" + atualMarca + "' title='" + titleMarca + "'/>")
                        $("#listaMarca2").append("<li id='" + atualMarca + "' class='itemMarca'><label class='labelLinha' for='" + atualMarca + "'>" + atualMarca + "</label></li>")
                    }
                })

                //EVENTO DE OUVINTE
                $('.itemMarca').click(function () {
                    helper.selectMarca = $(this).text();
                    $('#selectMarca').removeAttr("open");
                    helper.buscaProdutos(cmp, event, helper, helper.inputPesquisa, "end")
                });

                //Oculta Spinner de carregamento
                helper.hideSpinner(cmp);
            })
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
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

    exibeDetalhesItem: function (cmp, helper, item) {
        //DEFINE A VISUALIZAÇÃO DO NOME DO PRODUTO-------------------------
        var nomeItem = item.attr("data-name")//.length >= 20 ? (item.attr("data-name").substring(0,20) + "...") : item.attr("data-name");
        var urlImage = item.attr("data-image")
        var marca = item.attr("data-marca")
        var modelo = item.attr("data-modelo")
        var codigoFabricante = marca + ": " + item.attr("data-codigoFabricante")
        var codigoHospcom = "HOSPCOM: " + item.attr("data-codigoHospcom")
        var descricao = item.find("#textAreaDesc").val()

        var inputHtml = $("<!-- CONTAINER DE DETALHES --> <div class='containerDetalhes' id='containerDetalhes' style='display: flex'> <div class='containerDetalhesInterno'> <div style='width: 48%; height: 100%; display: flex;'> <div style='width: 100%; display: flex; justify-content: center; align-items: center;'> <img style='height: auto; border-bottom-left-radius: 10px; border-top-left-radius: 10px;' src='" + urlImage + "'/> </div> </div> <!-- DIVISOR --> <div style='display: flex; height: 100%; width: 4%; align-items: center; justify-content: center;'> <hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/> </div> <div style='width: 48%; height: auto;'> <div style='width: 100%; height: auto; display: flex'> <div class='nomeProdutoDetails'>" + nomeItem + "</div> <div id='closeButtonProdutoDetails' style='color: red; font-size: 25px; display: flex; justify-content: center; align-items: center; width: 10%; height: 100%;'> <a class='closeButtonProdutoDetails'><i class='fa fa-times-circle' aria-hidden='true'></i></a> </div> </div> <div class='modeloProdutoDetails'>" + modelo + "</div> <div class='codigosProdutosDetails'>" + codigoFabricante + "</div> <div class='codigosProdutosDetails'>" + codigoHospcom + "</div> <div class='descricaoProdutosDetails'>" + descricao + "</divv> </div> </div> </div> </div> </div> <!-- FIM CONTAINER DETALHES -->")
        $("#containerPrincipal").append(inputHtml)

        inputHtml.find("#closeButtonProdutoDetails").click(function () {
            console.log("clicou remover")
            $("#containerDetalhes").remove()
        })
    },

    //EXIBE DIV DA PLATAFORMA DE MKT----------------------------
    exibePlataformaMkt: function (cmp, event, helper) {
        //ALTERA ESTILO DOS BOTÕES APÓS CLIQUE
        $("#buttonPlataformaMarketing").css("opacity", "100%")
        $("#buttonPesquiseProdutos").css("opacity", "40%")

        //OCULTA DIV DO PESQUISE PRODUTOS
        $("#divPesquiseProdutos").hide()

        //EXIBE DIV DO MKT
        $("#divPlataformaMkt").show()

        //CHAMA FUNÇÃO GENÉRICA QUE ADICIONA EVENTOS APÓS A ATUALIZAÇÃO--
        helper.eventsAfterAppend(cmp, event, helper)
        //---------------------------------------------------------------
    },
    //----------------------------------------------------------

    //EXIBE DIV DA PESQUISA DE PRODUTOS------------------------
    exibePesquisaProdutos: function (cmp, event, helper) {
        helper.buscaProdutos(cmp, event, helper, "all", "null")
        
        //ALTERA ESTILO DOS BOTÕES APÓS CLIQUE
        $("#buttonPlataformaMarketing").css("opacity", "40%")
        $("#buttonPesquiseProdutos").css("opacity", "100%")

        //OCULTA DIV DO PESQUISE
        $("#divPlataformaMkt").hide()

        //EXIBE DIV DO MKT
        $("#divPesquiseProdutos").show()

        //CHAMA FUNÇÃO GENÉRICA QUE ADICIONA EVENTOS APÓS A ATUALIZAÇÃO--
        helper.eventsAfterAppend(cmp, event, helper)
        //---------------------------------------------------------------
    },
    //---------------------------------------------------------
    
    //EVENTOS VINCULADOS APÓS O PREENCHIMENTOD A COLUNA DA DIREITA
    eventsAfterConsultaCotacao: function(cmp, event, helper){
        
        //helper.ativaDragAndDrop(cmp, event, helper) //ATIVA O ARRASTA E SOLTA NA COLUNA DA DIREITA
        
        //EXPANDE OU RECOLHE O TEXTAREA------------------------------------
        $(".customTextArea").on("click", function () {
            console.log("click em textarea expand")
            $(this).css({ "height": "200px" });
        })
        $(".customTextArea").on("focusout", function () {
            $(this).css({ "height": "20px" });
        })
        //------------------------------------------------------------------
        
        //EXPANDE E RECOLHE O MENU DE OPÇÕES DO ITEM------------------------
        $(".buttonOptions").on("click", function () {
            console.log('clique')
            if ($(this).parent().find("#menuOptionsId").css('display') == 'none') {
                $(this).parent().find("#menuOptionsId").css({ "display": "flex" });
            } else {
                $(this).parent().find("#menuOptionsId").css({ "display": "none" });
            }
        })
        //------------------------------------------------------------------
        
        //RECOLHE O MENU CASO CLICK EM FECHAR-------------------------------
        $(".optionCloseOptions").on("click", function () {
            $(this).parent().css({ "display": "none" });
        })
        //------------------------------------------------------------------
        
        //ATUALIZA OS DADOS DO ITEM------------------------------------------
        $(".inputQtd, .textAreaDesc, .selectUm").on('change', function() {
            helper.atualizaItemCompra(cmp, event, helper, this)
        })
        //------------------------------------------------------------------
        
        //REMOVE ITEM DA COTAÇÃO--------------------------------------------
        $(".optionClose").on("click",function () {
            helper.removeItemCotacaoCompra(cmp, event, helper, this)
        })
        //------------------------------------------------------------------
    },
    
    //FUNCAO AUXILIAR CHAMADA ANTES DE PREENCHER A COLUNA DA ESQUERDA COM OS PEDIDOS DE VENDA E ITENS PARA COMPRA
    //A FUNCAO AUXILIAR FAZ A CONSULTA APLICANDO OS FILTROS NECESSÁRIOS
    auxiliarPreenchePedidos: function(cmp, event, helper){
        helper.auxiliarPreenchePedidosRevenda(cmp, event, helper) 
    },
    
    auxiliarPreenchePedidosRevenda: function(cmp, event, helper){
        
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        var itensPedidosPadronizados = [];
        var numeroDoPedido = [];
        var numeroDoPedidoJson = [];
        
        //REALIZA A CONSULTA PARA
        var query = "SELECT Id, OrderId, OrderItemNumber, Descricao_da_linha__c,PriceBookEntry.Product2.Tipo_do_Produto__c, Order.OrderNumber, Quantidade_a_requisitar_novo__c, Order.Account.Name, Order.Account.Raz_o_Social__c, Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c, PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.StockKeepingUnit, PriceBookEntry.Product2.ProductCode, PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c FROM OrderItem WHERE Quantidade_requisitada__c = 0 AND Product2id IN (SELECT Produto2__c FROM Item_de_fornecedor__c WHERE Quantidade_disponivel__c > 0 AND Status__c IN ('CMP - AG. ENTREGA FORNECEDOR','CMP - AG. CONSOLIDAÇÃO DE CARGA','CMP - EM PRODUÇÃO FORN.','	CMP - AG. DESEMBARAÇO ADUANEIRO','EM TRANSITO','CMP - EM COLETA PORTO/FORNECEDOR','CMP - AG. NFE NACIONALIZAÇÃO')) AND (Order.Status NOT IN ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Cancelado') AND Quantidade_falta_requisitar__c > 0 AND Status__c IN ('OPR - ANALISE DE COMPRA', 'CMP - AG. COMPRA NACIONAL', 'CMP - AG. COMPRA IMPORTAÇÃO', 'OPR - AG. DESTINAÇÃO'))"
        
        query += (helper.selectMarca != null && helper.selectMarca != 'NENHUM') ? " AND PriceBookEntry.Product2.Marca__c = '" + helper.selectMarca + "' " : '';
        query += (helper.selectTipo != null && helper.selectTipo != 'NENHUM')? " AND PriceBookEntry.Product2.Tipo_do_Produto__c = '" + helper.selectTipo + "' " : '';
        query += (helper.selectNPedido != null && helper.selectNPedido != 'NENHUM') ? " AND Order.OrderNumber = '" + helper.selectNPedido + "' " : '';
        query += " ORDER BY Order.OrderNumber ";
        
        console.log("query Preenche pedido de venda: ", query);
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (itensPedidos) {
            
            itensPedidos.forEach(function (itemPedido) {
                var itemPedidoPadronizado = {"IdProduto":itemPedido.PricebookEntry.Product2.Id, "tipoProduto":itemPedido.PricebookEntry.Product2.Tipo_do_Produto__c, "codigoHospcom":itemPedido.PricebookEntry.Product2.StockKeepingUnit, "modelo":itemPedido.PricebookEntry.Product2.Modelo__c,"quantidadeFaltaRequisitar":itemPedido.Quantidade_a_requisitar_novo__c , "numeroPedido":itemPedido.Order.OrderNumber, "pedido": {"iDPedido":itemPedido.OrderId, "numeroPedido":itemPedido.Order.OrderNumber, "nomeDaConta":itemPedido.Order.Account.Name, "idDaConta":itemPedido.Order.Account.Id, "contaCompradora":itemPedido.Order.Faturamento_Feito__r.Raz_o_Social__c, "idContaCompradora":itemPedido.Order.Faturamento_Feito__r.Id} ,"Id": itemPedido.Id, "OrderItemNumber":itemPedido.OrderItemNumber, "Descricao":itemPedido.Descricao_da_linha__c, "iDPedido":itemPedido.OrderId, "urlImagem":itemPedido.PricebookEntry.Product2.URL_da_Imagem__c, "nomeProduto":itemPedido.PricebookEntry.Product2.Name, "codigoFabricante":itemPedido.PricebookEntry.Product2.ProductCode, "marca":itemPedido.PricebookEntry.Product2.Marca__c};
                itensPedidosPadronizados.push(itemPedidoPadronizado)
            });
            
            //console.log("ITENS PEDIDOS PADRONIZADOS: ", itensPedidosPadronizados)
                        
            /*itensPedidosPadronizados = itensPedidosPadronizados.reduce(function(result, current) {
                result[current.IdProduto] = result[current.IdProduto] || [];
                result[current.IdProduto].push(current);
                return result;
            }, {}); */
            
            //console.log("ITENS PEDIDOS PADRONIZADOS AFTER: ", itensPedidosPadronizados)
            
            helper.itensPedidosPadronizados = itensPedidosPadronizados
            helper.preenchePedidos(cmp, event, helper, 0);
            
            //Exibe Spinner de carregamento
        	helper.hideSpinner(cmp);
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
    },
    
    //PREENCHE A COLUNA DA ESQUERDA COM OS PEDIDOS DE VENDA COM ITENS DISPONÍVEIS PARA COMPRA
    preenchePedidos: function (cmp, event, helper) {
        
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        var itensPedidosPadronizados = helper.itensPedidosPadronizados
        $('#colunaPlataformaMkt').empty()
        
        console.log("ITENS PEDIDOS PADRONIZADOS: ", itensPedidosPadronizados)
        
        itensPedidosPadronizados.forEach(function (itemPedidoAtual) {
            
            var quantidadeTotalAux = 0
            var nomeProduto = itemPedidoAtual.nomeProduto;
            var modeloProduto = itemPedidoAtual.modelo;
            var codigoFabricante = itemPedidoAtual.codigoFabricante;
            var codigoHospcom = itemPedidoAtual.codigoHospcom;
            var marca = itemPedidoAtual.marca;
            var numeroPedido = itemPedidoAtual.numeroPedido;
            var idPedido = itemPedidoAtual.pedido.iDPedido;
            var urlImagem = itemPedidoAtual.urlImagem;
            var quantidadeFaltaRequisitar = itemPedidoAtual.quantidadeFaltaRequisitar;
            var idProduto = itemPedidoAtual.IdProduto;
            var tipoProduto = itemPedidoAtual.tipoProduto;
            var idItemPv = itemPedidoAtual.Id
            var urlProduto = 'https://hospcom.my.site.com/Sales/s/item-de-fornecedor/'+idItemPv+'';

            
            if ( $("#selectMarcaPv option[value='"+marca+"']").length == 0 ){
                $('#selectMarcaPv').append("<option value='"+marca+"'>"+marca+"</option>")
            }
            
            if ( $("#selectTipoPv option[value='"+tipoProduto+"']").length == 0 ){
                $('#selectTipoPv').append("<option value='"+tipoProduto+"'>"+tipoProduto+"</option>")
            }
            
            if ( $("#selectNumeroPedidoPv option[value='"+numeroPedido+"']").length == 0 ){
                $('#selectNumeroPedidoPv').append("<option value='"+numeroPedido+"'>"+numeroPedido+"</option>")
            }
            
            //INSERE BLOCO DO PRODUTO
            $('#colunaPlataformaMkt').append("\
			<!-- APPEND DOS ITENS -->\
            <div class='containerMestreBlocos' data-quantidadeFaltaRequisitar='"+quantidadeFaltaRequisitar+"' data-idItemPv='"+idItemPv+"' data-codigoFabricante='"+codigoFabricante+"' data-type='itemPedido' data-quantidade='"+quantidadeFaltaRequisitar+"' data-idProduto='"+idProduto+"' id='containerMestreBlocos' title='Clique para expandir'>\
            <div class='blocoItemPedidoVenda' style='z-index: 1; cursor: pointer'>\
            <div class='row' style='height: 100%;'>\
            <!-- PRIMEIRA COLUNA COM IMAGEM E NOMES -->\
            <div class='col-md-6' style='display: flex; height: 100%;'>\
            <div class='containerImageItem'>\
            <a href='"+urlProduto+"' title='Clique para abrir o produto' target='_blank' class='imageItemProd'>\
            <img class='imgItemPedido' style='height: 90%' src='"+urlImagem+"'/>\
            </a>\
            </div>\
            <div class='containerDadosIniciaisItem'>\
            <div style='width: 100%; height: auto; font-size: 14px; color: #00345c; font-weight: bold;'>"+nomeProduto+"</div>\
            <div style='width: 100%; height: auto; font-size: 12px; color: #A0BB31;'>"+modeloProduto+"</div>\
            </div>\
            </div>\
            <!-- SEGUNDA COLUNA COM CODIGOS E CONTADOR -->\
            <div class='col-md-6' style='display: flex; height: 100%;'>\
            <div class='containerDetalhesItem'>\
            <div class='textoSecundario'>"+marca+": "+codigoFabricante+"</div>\
            <div class='textoSecundario'>QUANTIDADE FALTA REQUISITAR: "+quantidadeFaltaRequisitar+"</div>\
            </div>\
            <div class='containerQuantItens'>\
			<div class='contadorItens' id='contadorItem'>PV.:&nbsp;<a target='_blank' title='Clique para abrir' href='https://hospcom.my.site.com/Sales/s/order/"+idPedido+"'>"+numeroPedido+"</a></div>\
            </div>\
            </div>\
            </div>\
            </div>\
            <div class='blocoItemPedidoVenda blocoItemPedidoVendaExpand' style='background-color: #F5F6F8;' id='blocoItemPedidoVenda'>\
            </div>\
            </div>")
            
            //OCULTA SPINNER DE CARREGAMENTO---
            helper.hideSpinner(cmp);
            //---------------------------------
        });
        
        //FUNÇÕES ADICIONAIS APÓS CARREGAR OS ITENS DE PEDIDO DE VENDA
        helper.eventsAfterAddItemPedidoVenda(cmp, event, helper);
    },
    
    //PREENCHE OS SELECT OPTIONS DO MODAL DE FORNECEDORES
    preencheModalFornecedores: function (cmp, event, helper){
        
        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT id, type, name from account WHERE type = 'fornecedor' ORDER BY Name")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (fornecedores) {
            $('#fornecedor1, #fornecedor2, #fornecedor3').append("<option value='' selected='true' disabled='true'>CLIQUE PARA PROCURAR</option>")
            fornecedores.forEach(function (fornecedor) {
                $('#fornecedor1, #fornecedor2, #fornecedor3').append("<option name='"+fornecedor.Name+"' value='"+fornecedor.Id+"'>"+fornecedor.Name+"</option>")
            });
            
            $('.selectpickerFornecedor').selectpicker({
                dropupAuto: false  
            });

            helper.eventsAfterModalFornecedores(cmp,event,helper)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //EVENTOS EXECUTADOS APÓS O CARREGAMENTO DO MODAL DE FORNECEDORES
    eventsAfterModalFornecedores: function (cmp, event, helper){

        //EVENTO DO BOTAO CONTINUAR--------------------------
        $("#buttonContinuar").on( "click", function() {
            console.log("chamou valida")
            helper.validaFornecedores(cmp, event, helper);
        });
        
    },
    
    //EVENTOS EXECUTADOS APÓS A ADIÇÃO DOS ITENS EM PEDIDOS DE VENDAS---
    eventsAfterAddItemPedidoVenda: function(cmp, event, helper){
                
        //EVENTO PARA ABERTURA OU FECHAMENTO DO DROPDOWN COM PEDIDOS
        $('.blocoItemPedidoVenda').not(".blocoItemPedidoVendaExpand").on('click', function() {
            helper.preenchePedidosItem(cmp, event, helper, this)
            helper.openClosePedidos(cmp, event, helper, this);
        });
        
        //APLICA ESTILO EM TODAS OS SELECTS
        $('#selectMarcaPv, #selectTipoPv, #selectNumeroPedidoPv').selectpicker({
            dropupAuto: false             
        });
        
        //EVENTO DO CHANGE DOS FILTROS
        $('.selectpicker').on('changed.bs.select', function (e) { 
            helper.selectMarca = $('#selectMarcaPv').val();
            helper.selectTipo = $('#selectTipoPv').val();
            helper.selectNPedido = $('#selectNumeroPedidoPv').val();
            //$('#selectTipoPv').selectpicker('val', 'default');
            helper.auxiliarPreenchePedidos(cmp, event, helper);
        });
        
        $('.buttonInserirPv').on('click', function() {
            var elemento = $(this).parents('#containerMestreBlocos')
            var iDProdutoPedido = $(this).parents('.blocoItemPedidoVendaFilho').attr('data-produtoDoPedido')
            
            $(elemento).attr('data-type', 'pedidoItem');
            $(elemento).attr('data-idPvClicado', iDProdutoPedido);
            
            helper.adicionaItemCotacao(cmp, event, helper, elemento, this)
            //helper.openClosePedidos(cmp, event, helper, elemento);
        });
    },
    
    itemPvAtual: '',
    
    preenchePedidosItem: function(cmp, event, helper, elemento){
        
        //LIMPA A DIV
        $(elemento).parents('.containerMestreBlocos').children("#blocoItemPedidoVenda").empty()
        
        //EXIBE SPINNER INTERNO NA DIV
        $(elemento).parents('.containerMestreBlocos').children("#blocoItemPedidoVenda").append("\
		<div class='innerSpin'><div class='spinner-border' role='status'>\
        <span class='sr-only'>Loading...</span>\
		</div></div>")
        
        var codigoFabricante = $(elemento).parents('.containerMestreBlocos').attr('data-codigofabricante')
        const formatDate = {day: 'numeric', month: 'numeric', year: 'numeric'};
        helper.itemPvAtual = elemento;
        
        var query = "SELECT ID, Marca__c, Fornecedor__r.Fornecedor__r.Name, Fornecedor__r.Name, Fornecedor__r.Prazo_de_recebimento__c, Fornecedor__r.Comprador__r.Name, Quantidade_disponivel__c FROM Item_de_fornecedor__c WHERE Codigo_do_produto__c = '"+codigoFabricante+"' AND Quantidade_disponivel__c > 0 AND Status__c IN ('CMP - EM PRODUÇÃO FORN.','CMP - AG. ENTREGA FORNECEDOR','Aguardando desembaraço aduaneiro','EM TRANSITO','CMP - EM COLETA PORTO/FORNECEDOR','CMP - AG. NFE NACIONALIZAÇÃO','CMP - AG. CONSOLIDAÇÃO DE CARGA')";
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (itensPedidoDeCompra) {
            
            //LIMPA A DIV
            $(elemento).parents('.containerMestreBlocos').children("#blocoItemPedidoVenda").empty()
            
            //VERIFICA SE NAO HOUVE NENHUM RESULTADO E EXIBER O TEXTO NA DIV
            if (itensPedidoDeCompra.length == 0) {
                $(elemento).parents('.containerMestreBlocos').children("#blocoItemPedidoVenda").append("<div style='display: flex; justify-content: center'>Nenhum item de pedido de compra disponível para esse produto</div>");
            }
            
            //PREENCHE OS RESULTADOS NA DIV
            itensPedidoDeCompra.forEach(function (itemPedidoDeCompraAtual){                
                var linkPedido = "https://hospcomhospitalar.force.com/Sales/s/order/"+itemPedidoDeCompraAtual.Fornecedor__c+""
                var numeroPedido = itemPedidoDeCompraAtual.Fornecedor__r.Name;
                var nomeDaConta = itemPedidoDeCompraAtual.Fornecedor__r.Comprador__r.Name;
                var prazoDeEntrega = new Date(itemPedidoDeCompraAtual.Fornecedor__r.Prazo_de_recebimento__c).toLocaleDateString("pt-BR", formatDate)
                var empresa = 'HOSPCOM EQUIPAMENTOS HOSPITALARES EIRELI' //itemPedidoPadronizado.pedido.contaCompradora;
                var urlLogoHospcom = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000BlZVy&oid=00Di0000000JVhH&lastMod=1666210877000'
                var urlLogoGDB = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbdf&oid=00Di0000000JVhH&lastMod=1666362135000'
                var urlLogoHealth = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbex&oid=00Di0000000JVhH&lastMod=1666363177000'
                var urlLogoABC = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbdu&oid=00Di0000000JVhH&lastMod=1666362299000'
                var imageEmpresa = empresa == 'HOSPCOM EQUIPAMENTOS HOSPITALARES EIRELI' ? urlLogoHospcom : (empresa == 'GDB COMERCIO E SERVICOS - EIRELI' ? urlLogoGDB : (empresa == 'HEALTH SOLUTIONS' ? urlLogoHealth : (empresa == 'ABC EQUIPAMENTOS HOSPITALARES LTDA' ? urlLogoABC : '')))
                var quantidadeDisponivel = itemPedidoDeCompraAtual.Quantidade_disponivel__c
                var marca = itemPedidoDeCompraAtual.Marca__c
                var fornecedor = itemPedidoDeCompraAtual.Fornecedor__r.Fornecedor__r.Name
                
                $(elemento).parents('.containerMestreBlocos').children("#blocoItemPedidoVenda").append("\
                <!-- BLOCO DO PEDIDO -->\
                <div id='blocoItemPc' data-idItemPc='"+itemPedidoDeCompraAtual.Id+"' class='blocoItemPedidoVenda blocoItemPedidoVendaFilho' data-quantidadeDisponivel='"+quantidadeDisponivel+"' data-type='pedidoItem' style='z-index: 1; margin-bottom: 10px; display: flex; padding: 10px; flex-direction: column'>\
                    <div style='display: flex; width: 100%; height: 40%'>\
                        <div class='textBlocoItens'>Pedido de compra:&nbsp;<a href='"+linkPedido+"' target='_blank'><span style='font-weight: 400;'>"+numeroPedido+"</span></a></div>\
                        <div class='textBlocoItens'>Previsão de entrega:&nbsp;<span style='font-weight: 400;'>"+prazoDeEntrega+"</span></div>\
                        <div class='textBlocoItens' style='width: 45%'>Nome da conta:&nbsp;<span style='font-weight: 400;'>"+nomeDaConta+"</span></div>\
                        <div class='textBlocoItens' style='width: 15%; display: flex; flex-direction: column'>\
                        	<img class='imageEmpresa' src='"+imageEmpresa+"'/>\
               	     	</div>\
                	</div>\
					\
					<div style='display: flex; width: 100%; height: 40%'>\
						<div class='textBlocoItens'>Marca:&nbsp;<span style='font-weight: 400;'>"+marca+"</span></div>\
                        <div class='textBlocoItens' style='width: 80%'>Fornecedor:&nbsp;<span style='font-weight: 400;'>"+fornecedor+"</span></div>\
                	</div>\
                <div style='display: flex; width: 100%; height: 30%' class='textoSecundario'></div>\
                <button type='button' class='btn btn-success buttonDestinar'>DESTINAR ("+quantidadeDisponivel+" UNIDADES DISPONÍVEIS)</button>\
                </div>\
                <!-- FIM BLOCO DO PEDIDO -->");
            })
            
            $('.buttonDestinar').off().on("click", function(){
                helper.exibeModalDestinacao(cmp, event, helper, this)
            });
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    quantidadeDisponivel: 0,
    quantidadeFaltaRequisitar: 0,
    idItemPc: '',
    idItemPv: '',
    
    exibeModalDestinacao: function(cmp, event, helper, item){
        //EXIBE POPUP
        $('#divPaiPopup').css('display', 'flex');
        
        //RECUPERA QUANTIDADE DISPONIVEL
        helper.quantidadeDisponivel =  $(item).parents('#blocoItemPc').attr('data-quantidadeDisponivel');
        //RECUPERA IDITEMPC
        helper.idItemPc = $(item).parents('#blocoItemPc').attr('data-idItemPc');
        //RECUPERA O IDITEMPV
        helper.idItemPv = $(item).parents('#containerMestreBlocos').attr('data-iditempv')
        //RECUPERA A QUANTIDADE QUE FALTA DESTINAR PARA O PV
        helper.quantidadeFaltaRequisitar = $(item).parents('#containerMestreBlocos').attr('data-quantidadeFaltaRequisitar')
        
        //DEFINE O MAX VALOR DO INPUT
        var quantidadeMax = parseInt(helper.quantidadeFaltaRequisitar) > parseInt(helper.quantidadeDisponivel) ? helper.quantidadeDisponivel : helper.quantidadeFaltaRequisitar
        
        console.log("QUANTIDADE MAX", quantidadeMax)
        
        //SETA O MAX NO INPUT
        $('#divPaiPopup').find('#inputPopupQuantidade').attr("max", quantidadeMax)
        
        //evento de cancelar (fecha o popup)
        $('#cancelarPopupButton').off().on("click", function(){
            $('#divPaiPopup').find('#inputPopupQuantidade').val(0)
            $('#divPaiPopup').hide();
        });
        
        //evento de confirma (destina)
        $('#confirmaPopupButton').off().on("click", function(){
            var quantidadeInput = $('#divPaiPopup').find('#inputPopupQuantidade').val()
            
            if(parseInt(quantidadeInput) > parseInt(quantidadeMax)){
                helper.alertaErro(cmp, event, helper, "DADOS INVÁLIDOS", "O VALOR DESTINADO NÃO PODE SER MAIOR QUE O PERMITIDO.", "error", "Erro: ", "sticky")
            }else{
                console.log(quantidadeInput, helper.idItemPc, helper.idItemPv)
                helper.destina(cmp, event, helper, helper.idItemPc, helper.idItemPv, quantidadeInput)
            }
            
        });
        
    },
    
    //CHAMA A FUNCAO PARA DESTINAR O ITEM
    destina: function(cmp, event, helper, idItemPc, idItemPv, quantidade){
        
        var contentLog = "=====DESTINANDO ITEM (PAINEL DE DESTINACAO) =====\n" + "idItemPc: " + idItemPc + "\n idItemPv: " + idItemPv + "\n idItemPc: " + idItemPc+ "\n quantidade: " + quantidade
        var pastaLog = "COMPRAS - LOGS"
        var dataLog = new Date(); 
        var tituloLog = dataLog + "LOG DESTINACAO DE ITEM (PAINEL DE DESTINAÇÃO)"
        
        helper.criaLogs(cmp, event, helper, contentLog, tituloLog, 'txt', 'text/plain', pastaLog)

        
        var action = cmp.get("c.destina"); 
        
        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idItemPC: idItemPc,
            idItemPV: idItemPv,
            quantidade: quantidade
        });
        //--------------------------------------------------
        
        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
            
            //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
            if (state === "SUCCESS") {
                helper.alertaErro(cmp, event, helper, "Destinado com sucesso!", "SUCESSO", "success", "Operação concluída!", "dismissable")
                helper.preenchePedidosItem(cmp, event, helper, helper.itemPvAtual)
                $('#divPaiPopup').hide();
            }
            
            //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A DESTINAÇÃO", "DESTINAÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO DURANTE A DESTINAÇÃO", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    //ABRE OU FECHA O DROPDOWN COM OS PEDIDOS RELACIONADOS A UM PRODUTO----
    openClosePedidos: function(cmp, event, helper, elemento){
        var tamanhoAberto = '220px';
        var tamanhoFechado = '90px';
        var tamanhoMarginAberto = '150px';
        var tamanhoMarginFechado = '10px';
        var tamanhoAtual = $(elemento).parents('.containerMestreBlocos').children('#blocoItemPedidoVenda').css('height');
        var tamanhoSetado = tamanhoAtual == tamanhoAberto ? tamanhoFechado : tamanhoAberto;
        var tamanhoMargin = tamanhoAtual == tamanhoAberto ? tamanhoMarginFechado : tamanhoMarginAberto;
		$(elemento).parents('.containerMestreBlocos').children('#blocoItemPedidoVenda').css("height", tamanhoSetado);
        $(elemento).parents('.containerMestreBlocos').css("padding-bottom", tamanhoMargin);
    },
    //---------------------------------------------------------------------

    //CHAMA FUNÇÃO DO APEX QUE ADICIONA UM ITEM NA COTAÇÃO--
    adicionaItemFilhoCotacao: function (cmp, helper, item) {
        helper.showSpinner(cmp); //EXIBE SPINNER DE CARREGAMENTO

        //SETA POSIÇÃO ATUAL DO SCROLL DA DIV DA COTAÇÃO
        helper.posicaoDivCotacao = $('#listaCotacao').scrollTop()

        var recordId = helper.retornaRecorId(cmp, event, helper) //VARIÁVEL QUE ARMAZENA O RECORDID DO REGISTRO
        var idProduto = $(item).attr('data-idproduto');	//VARIÁVEL QUE ARMAZENA O ID DO PRODUTO A SER ADICIONADO
        var descricao = $(item).attr('data-descricao');	//VARIÁVEL QUE ARMAZENA A DESCRIÇÃO DO PRODUTO A SER ADICIONADO
        var origemItem = $(item).attr('data-tipo');
        
        if (origemItem == "produtoFilho") {
        	//CHAMA A FUNÇÃO QUE ATUALIZA O ITEM PAI DO FILHO
        	
        	var action = cmp.get("c.atualizaItem"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
            var itemPai = $(item).parents(".containerCotacao").attr('data-item-c');	//VARIÁVEL QUE ARMAZENA O IDENTIFICADOR DO PRODUTO PAI O QUAL ESTE FILHO SERÁ ADICIONADO
            var idCotacao = $(item).attr('data-iditemcotacao');
            
            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                id: idCotacao,
                item: null,
                itemPai: itemPai
            });
            //--------------------------------------------------
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#listaProdutos').click()
            //-----------------------------------------
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                
                //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                if (state === "SUCCESS") {
                    helper.consultaCotacao(cmp, event, helper, 0) //CHAMA FUNÇÃO QUE IRÁ CONSULTAR A COTAÇÃO NOVAMENTE E EXIBIR OS ITENS ATUALIZADOS
                    helper.alertaErro(cmp, event, helper, "Produto atualizado com sucesso!", "SUCESSO", "success", "Operação concluída!", "dismissable")
                }
                
                //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
            
        }else if (origemItem == "produtoPai"){
            console.log("adicionando um produto pai a um filho")
            //VERIFICA SE O PRODUTO PAI NÃO TEM MAIS FILHOS
            var quantidadeItensFilhos = $(item).find('#produtosFilhosDrop').find('.containerCotacao').length
            
            if(quantidadeItensFilhos > 0){
                helper.alertaErro(cmp, event, helper, "ESTE ITEM CONTÉM ITENS FILHOS, MOVA-OS OU REMOVA-OS ANTES DE PROSSEGUIR", "ERRO DURANTE A OPERAÇÃO", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
            	helper.consultaCotacao(cmp, event, helper, 0) //CHAMA FUNÇÃO QUE IRÁ CONSULTAR A COTAÇÃO NOVAMENTE E EXIBIR OS ITENS ATUALIZADOS
            }else{
                var action = cmp.get("c.atualizaItem"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
                
                var itemPai = $(item).parents('.containerCotacao').attr('data-item-c')
                var idItemAtual = $(item).attr('data-item-c')
                var idCotacao = $(item).attr('data-iditemcotacao');
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    id: idCotacao,
                    item: null,
                    itemPai: itemPai
                });
                //--------------------------------------------------
                
                //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                $('#listaProdutos').click()
                //-----------------------------------------
                
                //CALLBACK DA REQUISIÇÃO---------------------------
                action.setCallback(this, function (response) {
                    var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                    
                    //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                    if (state === "SUCCESS") {
                        helper.consultaCotacao(cmp, event, helper, 0) //CHAMA FUNÇÃO QUE IRÁ CONSULTAR A COTAÇÃO NOVAMENTE E EXIBIR OS ITENS ATUALIZADOS
                        helper.alertaErro(cmp, event, helper, "Produto atualizado com sucesso!", "SUCESSO", "success", "Operação concluída!", "dismissable")
                    }
                    
                    //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                    else if (state === "INCOMPLETE") {
                        helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                            reject(errors[0].message);
                        } else {
                            console.log("Erro desconhecido");
                            helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                            reject("Erro desconhecido");
                        }
                    }
                });
                
                $A.enqueueAction(action);
            }
        }else{
            console.log("adicionando um produto externo a um filho")
            
            var action = cmp.get("c.inserirFilho"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
            var itemPai = $(item).closest(".containerCotacao").attr('data-item-c');	//VARIÁVEL QUE ARMAZENA O IDENTIFICADOR DO PRODUTO PAI O QUAL ESTE FILHO SERÁ ADICIONADO
            
            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                pedido: recordId,
                produto: idProduto,
                descricao: descricao,
                itemPai: itemPai
            });
            //--------------------------------------------------
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#listaProdutos').click()
            //-----------------------------------------
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                
                //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                if (state === "SUCCESS") {
                    console.log("sucesso")
                    //helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.consultaCotacao(cmp, event, helper, 0) //CHAMA FUNÇÃO QUE IRÁ CONSULTAR A COTAÇÃO NOVAMENTE E EXIBIR OS ITENS ATUALIZADOS
                    helper.alertaErro(cmp, event, helper, "O Produto foi inserido com sucesso ao pedido!", "SUCESSO", "success", "Operação concluída!", "dismissable") //EXIBE UM ALERTA DE SUCESSO AO USUÁRIO
                }
                
                //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR PRODUTO FILHO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
        }
        
        
        //QUANDO O DATA-ITEM-C == UNDEFINED SIGNIFICA QUE O ITEM QUE ESTÁ SENDO ADICIONADO É UM FILHO
        // if ($(item).attr('data-item-c') === undefined) {
        //SE O ITEM FOR FILHO, ELE PODE ESTAR SENDO MOVIDO PARA OUTRO PAI OU ELE PODE SE TORNAR UM PAI
        
        //  if ($(item).attr('data-tipo') === undefined) {
        //      var itemPai = $(item).parents(".containerCotacao").attr('data-item-c');	//VARIÁVEL QUE ARMAZENA O IDENTIFICADOR DO PRODUTO PAI O QUAL ESTE FILHO SERÁ ADICIONADO
        //    var option = 0
        //   } else {
        //   var itemPai = $(item).parents(".containerCotacao").attr('data-item-c');	//VARIÁVEL QUE ARMAZENA O IDENTIFICADOR DO PRODUTO PAI O QUAL ESTE FILHO SERÁ ADICIONADO
        //                var option = 1
        // }
        
        // } else {
        // var itemPai = $(item).parent().closest(".containerCotacao").attr('data-item-c')
        //var option = 1
        //}

	
    },
    //-----------------------------------------------------

    //FUNÇÃO QUE ATIVA O DRAG AND DROP NOS ITENS----------------
    ativaDragAndDrop: function (cmp, event, helper) {
        //CONFIGURAÇÕES DA COLUNA DROP "DIREITA"------------------------------------------
        var el = document.getElementById('listaCotacao');
        //INSTANCIA O OBJETO SORTABLE, DO PLUGIN DE DRAG AND DROP
        Sortable.create(el, {
            //DEFINIÇÕES DO GRUPO DE ARRASTA E SOLTA
            group: {
                name: 'shared', //DEFINE O NOME DO GRUPO DE COMPARTILHAMENTO ENTRE ITENS
            },
            // A FUNÇÃO ABAIXO É EXECUTADA QUANDO UM ITEM É ADICIONADO A DIV DA COLUNA DEFINIDA EM "EL"
            onAdd: function (evt) {
                helper.adicionaItemCotacao(cmp, event, helper, evt.item) //CHAMA FUNÇÃO QUE ADICIONA UM ITEM NA COTAÇÃO, PASSANDO O ITEM A SER ADICIONADO
            },
            animation: 150, //DEFINE O TEMPO DE ANIMAÇÃO AO ARRASTAR UM ITEM
            scroll: true, //HABILITA O PLUGIN DE SCROLL
            forceAutoscrollFallback: true, //FORÇA O PLUGIN DE SCROOL
            scrollSensitivity: 100, //DEFINE A SENSIBILIDADE DO SCROLL DA LISTA AO ARRASTAR UM ITEM
            forceFallback: true,	//FORÇA O USO DO PLUGIN, SOBRESCREVENDO O MÉTODO NATIVO DE DRAG AND DROP
            sort: false
        });
        //--------------------------------------------------------------------------
    },
    //----------------------------------------------------------

    preencheResultados: function (cmp, inputPesquisa) {
        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT Name FROM Product2 WHERE IsActive = true AND Name like '%" + inputPesquisa + "%'")

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (produtos) {
                //console.log(produtos)
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },
})