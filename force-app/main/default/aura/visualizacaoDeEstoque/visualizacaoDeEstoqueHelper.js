({
    //VARIÁVEIS GLOBAIS DO SELECT DE FILTRO DE BUSCA
    selectLinha: null,
    selectFamilia: null,
    selectTipo: null,
    selectMarca: null,
    //----------------------------------------------

    //VARIÁVEIS GLOBAIS GERAIS------------------
    oldColorInput: '',
    oldColorTextInput: '',
    indiceRemocao: '',
    ultimaCategoriaInserida: '',
    imagemUltimaCategoriaInserida: '',
    customEstoques: [
        {"Name":"ESTOQUE DISPONÍVEL","Id":"00000XXX1","Codigos":"'153', '305', '31', '37', '10', '401', '42', '32', '77', '38', '155', '89', 'ORT-01', '406', '11', '154', '90', '289', '156', '20', '402', '33', '30', '36'"},
        {"Name":"ESTOQUE DE CONSULTA","Id":"00000XXX2","Codigos":"'389', '77', '40', '20', '15', '109', '35', '11', '60', '33', '30', '36', '22', '289', '21', '70', '34', '38', '10', '31', '02', '1', '50', '32', '37'"}
    ],
    perfisHabilitadosPCs: ['Administrador do sistema', 'Comunidade Logística', 'Analista de Compras', 'Assistente de Compras'],
    //-------------------------------------------

    inputPesquisa: "null",

    addListeners: function (cmp) {

    },

    isEmpty: function (cmp, str) {
        return !str.trim().length;
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

        /*
        $('.class1229').unbind().removeData();
        $('.class1229').counterUp({
            delay: 10,
            time: 1000,
        });

        $('.class1222').unbind().removeData();
        $('.class1222').counterUp({
            delay: 10,
            time: 1000,
        }); */

        //$(".exampleSelect").unbind().removeData();
        //$(".exampleSelect").map(function () {
        //    $(this).dropzie();
        //})

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

    buscaEstoques: function (cmp, event, helper, inputPesquisa, filtro) {
        helper.buscaProdutos(cmp, event, helper, inputPesquisa, filtro, helper.customEstoques)
    },

    //FUNÇÃO QUE ATUALIZA A EXIBIÇÃO DA QUANTIDADE EM ESTOQUE APÓS ALTERAR O ESTOQUE
    atualizaDadosEstoqueItem: function (cmp, event, helper, item) {
        //EXIBE O SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        var idEstoqueSelecionado = $(item).attr('data-value')
        var idProduto = $(item).parents('.itemPesquisa').attr('data-idproduto')
        var estoqueSelecionado = ""

        helper.customEstoques.forEach(function(estoqueAtual){
            if(estoqueAtual.Id == idEstoqueSelecionado){
                estoqueSelecionado = String(estoqueAtual.Codigos)
            }
        })

        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT SUM(Em_estoque__c) FROM Entrada_de_Estoque__c WHERE produto__c = '"+idProduto+"' AND Estoque__r.Codigo__c IN ("+estoqueSelecionado+")")

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (entradaEstoque) {
                entradaEstoque.forEach(function(entradaAtual){
                    if (Object.keys(entradaAtual).length === 0) {
                        $(item).parents(".containerEstoques").find("#quantidadeEmEstoque").text("0")
                    } else {
                        entradaEstoque.forEach(function (entradaAtual) {
                            $(item).parents(".containerEstoques").find("#quantidadeEmEstoque").text(entradaAtual.expr0)
                        })
                    }

                })

                //OCULTA SPINNER DE CARREGAMENTO---
                helper.hideSpinner(cmp);
                //---------------------------------
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },
    //------------------------------------------------------------------------------

    //FUNÇÃO QUE BUSCA E PREECHE OS PRODUTOS ENCONTRADOS---------------------
    buscaProdutos: function (cmp, event, helper, inputPesquisa, filtro, estoques) {

        //EXIBE O SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        var optionsEstoque = "<option id='optionSelect' value='00000XXX1'>ESTOQUE DISPONÍVEL</option>"
		let usaPesquisaAvancada = inputPesquisa.includes('%');
        
        //CRIA VARIÁVEL COM OS OPTIONS DO ESTOQUE
        estoques.forEach(function (estoqueAtual) {
            var nomeEstoque = String(estoqueAtual.Name)
            optionsEstoque = optionsEstoque + "<option id='optionSelect' value='" + estoqueAtual.Id + "'>" + nomeEstoque + "</option>"
        })

        //VALIDA APLICAÇÃO DO FILTRO NA PESQUISA--------------------------------------
        //SE O INPUT DE PESQUISA NÃO FOR VAZIO----------------------------------------
        if (filtro === "null" && inputPesquisa != "all" &&  !usaPesquisaAvancada) {
            var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c FROM Product2 WHERE IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
        } else if (filtro === "familia" && inputPesquisa != "all") {
            var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c FROM Product2 WHERE IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') AND Linha__c = '"+helper.selectLinha+"' ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
        } else if (filtro === "tipo" && inputPesquisa != "all") {
            var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') AND Linha__c = '"+helper.selectLinha+"' AND Family = '" + helper.selectFamilia + "' ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
        } else if (filtro === "marca" && inputPesquisa != "all") {
            var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') AND Linha__c = '"+helper.selectLinha+"' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
        } else if (filtro === "end" && inputPesquisa != "all") {
            var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') AND Linha__c = '"+helper.selectLinha+"' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' AND Marca__c = '" + helper.selectMarca + "' ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"

        //SE O INPUT DE PESQUISA FOR ALL, ISTO É, A CAIXA DE PESQUISA É VAZIA---
        } else if (inputPesquisa === "all" && !usaPesquisaAvancada) {
            if (filtro === 'null') {
                var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
            } else if (filtro === 'familia') {
                var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
            } else if (filtro === 'tipo') {
                var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' AND Family = '" + helper.selectFamilia + "' ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
            } else if (filtro === 'marca') {
                var query = "SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
            } else if (filtro === 'end') {
                var query = "SELECT StockKeepingUnit, Name, Tipo_do_Produto__c, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Total_aguardando_entrega_transicional__c	, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE IsActive = true AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' AND Marca__c = '" + helper.selectMarca + "' ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC LIMIT 100"
            }
        } /*else {
            console.log("else geral")
            //var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c, Type  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '"+pricebook2id+"') AND IsActive = true AND (Name like '%"+inputPesquisa+"%' OR Modelo__c like '%"+inputPesquisa+"%' OR Marca__c like '%"+inputPesquisa+"%') ORDER BY Name LIMIT 200"
        }
        //-------------------------------------------------------------------------- */
        
        if (usaPesquisaAvancada) {
            //alert("usando pesquisa avançada")
            helper.alertaErro(cmp, event, helper, "Ao combinar termos com % a tela pesquisará os termos separadamente em Nome do produto, Modelo, Marca e Código", "VOCÊ ESTÁ USANDO UMA PESQUISA AVANÇADA!", "info", "", "dismissable")
            // Lista de colunas onde a pesquisa será realizada
            const searchColumns = ["Name", "Modelo__c", "Marca__c", "ProductCode"];
    
            // Divide a pesquisa do usuário pelos '%'
            const terms = inputPesquisa.split("%").map(term => term.trim()).filter(term => term.length > 0);
    
            // Constrói a cláusula WHERE dinâmicamente
            let searchConditions = terms.map(term => {
                let columnConditions = searchColumns.map(column => `${column} LIKE '%${term}%'`);
                return `(${columnConditions.join(" OR ")})`; // Agrupa com OR
            });
    
            // Junta os termos com AND para garantir que todos apareçam na pesquisa
            let whereClause = searchConditions.join(" AND ");
    
            var query = `
                SELECT StockKeepingUnit, Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, 
                       Total_aguardando_entrega_transicional__c, Valor_Total__c, Description, 
                       ProductCode, Marca__c, Estoque_disponivel__c  
                FROM Product2 
                WHERE IsActive = true 
                AND ${whereClause}
                ORDER BY Estoque_disponivel__c DESC NULLS LAST, LastModifiedDate DESC 
                LIMIT 100
            `;
        }
        
		
        //REALIZA A CONSULTA AOS PRODUTOS FILTRANDO PELO LIVRO DE PREÇO ATUAL
        helper.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (produtos) {
                //LIMPA A TELA DE EXIBIÇÃO DOS PRODUTOS
                $('#listaProdutos').empty();

                //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                $('#listaProdutos').click()
                //-----------------------------------------
                //LOOP QUE PERCORRE TODOS OS PRODUTOS ENCONTRADOS, ITERANDO SOBRE PRODUTOATUAL---------------------------------------
                produtos.forEach(function (produtoAtual) {

                    /*VERIFICA SE O PRODUTO POSSÚI DESCRIÇÃO---
                    if (String(produtoAtual.Description) === undefined || String(produtoAtual.Description) === "undefined") {
                        var produtoDescricao = "PRODUTO SEM DESCRIÇÃO"
                        var produtoDescricaoData = "PRODUTO SEM DESCRIÇÃO"
                    } else {
                        var produtoDescricao = String(produtoAtual.Description).substring(0, 200).toUpperCase() + "..."
                        var produtoDescricaoData = String(produtoAtual.Description)
                    }
                    //-----------------------------------------*/

                    //DEFINE VARIÁVEIS DE COR E QUANTIDADE DO ESTOQUE-----------------------------------------------------------------------------------------------------------------------------------------
                    //Verifica se há estoque do produto atual
                    if (produtoAtual.Estoque_disponivel__c === 0 || produtoAtual.Estoque_disponivel__c === undefined || produtoAtual.Estoque_disponivel__c === "undefined") {
                        //Se não houver estoque, verifica se está aguardando recebimento
                        if (produtoAtual.Qtd_Aguardando_Recebimento__c >= 1) {
                            //Caso esteja aguardando recebimento, mostrará a quantidade que está aguardando recebimento

                            //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO PRINCIPAL DO ITEM-------------------------------
                            var quantEstoque = produtoAtual.Qtd_Aguardando_Recebimento__c + " EM RECEBIMENTO"
                            var corEstoque = "#f40a29"; //define a cor vermelha
                            var corEtiqueta = "#FCFB20"; //define a cor amarela
                            //-------------------------------------------------------------------------------------
                            //
                            //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO EXPANDIDA DO ITEM "HOVER"------------------------
                            var quantidadeEstoque = "0"
                            var aguardandoReceber = produtoAtual.Total_aguardando_entrega_transicional__c
                            if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                                aguardandoReceber = "0"
                            }
                            //-------------------------------------------------------------------------------------
                            //
                        } else {
                            //Se não tiver aguardando recebimento, logo exibirá "Sem estoque e 0 UND"
                            //
                            //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO PRINCIPAL DO ITEM-------------------------------
                            var quantEstoque = "SEM ESTOQUE"
                            var quantidadeEstoque = "0"
                            //------------------------------------------------------------------------------------
                            //
                            //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO EXPANDIDA DO ITEM "HOVER"-----------------------
                            var corEstoque = "#f40a29";
                            var corEtiqueta = "#f40a29";
                            var quantidadeEstoque = "0"

                            var aguardandoReceber = produtoAtual.Total_aguardando_entrega_transicional__c
                            if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                                aguardandoReceber = "0"
                            }
                            //------------------------------------------------------------------------------------ 
                        }
                    } else {
                        //Se houver estoque, exibirá a quantidade em estoque na visualização principal, e na expandida a quantidade aguardando recebimento
                        var corEstoque = "#a0bb31";
                        var corEtiqueta = "#a0bb31";

                        var quantEstoque = produtoAtual.Estoque_disponivel__c + " EM ESTOQUE"
                        var quantidadeEstoque = produtoAtual.Estoque_disponivel__c

                        var aguardandoReceber = produtoAtual.Qtd_Aguardando_Recebimento__c
                        if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                            aguardandoReceber = "0"
                        }
                    }
                    //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                    var nomeProduto = produtoAtual.Name.length > 70 ? produtoAtual.Name.substring(0,70) + "..." : produtoAtual.Name
                    var idProduto = produtoAtual.ID_do_Produto__c
                    var tipoProduto = produtoAtual.Tipo_do_Produto__c
                    var quantidadeEmRecebimento = produtoAtual.Total_aguardando_entrega_transicional__c ? produtoAtual.Total_aguardando_entrega_transicional__c : 0

                    //SE NÃO HOUVER ESTOQUE DO ITEM
                    if (quantidadeEstoque == 0) {
                        //EXIBIRÁ A COR VERMELHA
                        var corEstoque = '#f40a29'
                    } else {
                        //EXIBIRÁ A COR VERDE
                        var corEstoque = '#a0bb31'
                    }

                    if(quantidadeEmRecebimento == 0){
                        //EXIBIRÁ A COR VERMELHA
                        var corRecebimento = '#f40a29'
                    }else{
                        //EXIBIRÁ A COR AMARELA
                        var corRecebimento = '#fed032'
                    }

                    //var corEstoque = produtoAtual.Estoque_disponivel__c == undefined || produtoAtual.Estoque_disponivel__c == 0 ? '#f40a29' : '#a0bb31'

                    var htmlItem = $("\
<div data-valorTotal='"+produtoAtual.Valor_Total__c+"' data-codigoHospcom='" + produtoAtual.StockKeepingUnit + "' data-codigoFabricante='" + produtoAtual.ProductCode + "' data-name='" + produtoAtual.Name + "' data-idProduto='" + idProduto + "' class='itemPesquisa' data-codigo='" + produtoAtual.ProductCode + "' data-marca='" + produtoAtual.Marca__c + "' data-modelo='" + produtoAtual.Modelo__c + "' data-image='" + produtoAtual.URL_da_Imagem__c + "' name='" + produtoAtual.Name + "'>\
<div class='class1227'>\
<a class='' target='_blank' style='height: 100%' href='https://hospcomhospitalar.force.com/Sales/s/product2/"+produtoAtual.ID_do_Produto__c+"'><img src='" + produtoAtual.URL_da_Imagem__c + "' class='class1226'/></a>\
</div>\
<div class='class1231'>\
<hr class='divisorClass'/>\
</div>\
<div style='width: 90%; display: flex'>\
<div class='col-lg-4 col-md-12'> <div class='class1232'> " + nomeProduto + "</div>\
<div class='class1233'> " + produtoAtual.Modelo__c + " </div>\
<div style='display: flex; height: 4%'>\
<hr class='divisorHorizontal'/>\
</div><div class='class1234'>" + produtoAtual.Marca__c + ": " + produtoAtual.ProductCode + " </div>\
</div>\
<div class='col-lg-3 col-md-6' style='padding: 5px;'>\
<div class='containerEstoques' style='border: 1px solid " + corEstoque + "'>\
<div style='display: flex; height: 40%; padding: 5px;'>\
<select id='selectEstoque' class='exampleSelect'>" + optionsEstoque + "</select>\
<div class='class1224' style='padding: 0px; width: 20%'>\
    <button title='Clique para exibir detalhes' type='button' id='buttonDetalhesEmCompra' class='btn btn-info btn-rounded btn-icon'>\
        <i class='fa fa-external-link class1238B'>\
        </i>\
    </button>\
</div>\
</div>\
<div class='class1230'>\
<div id='quantidadeEmEstoque' data-quantidade='145' class='class1229'>" + quantidadeEstoque + " </div>\
<div>\
</div>\
<div class='class1228'> UND</div>\
<div>\
</div>\
</div>\
</div>\
</div>\
<div class='col-lg-1 col-md-6'> </div>\
<div class='col-lg-3 col-md-6' style='padding: 5px;'>\
<div class='containerEstoques' style='border: 1px solid " + corRecebimento + "'>\
<div style='width: 100%; height: 40%; display: flex'>\
<div class='class1225'>\
<div class='class1225C'> Em Compra </div></div><div class='class1224'>\
<button title='Clique para exibir detalhes' type='button' id='buttonDetalhes' class='btn btn-info btn-rounded btn-icon'> <i class='fa fa-external-link class1238'></i> </button> </div></div><div class='class1237'>\
<div id='quantidadeEmCompra' data-quantidade='245' class='class1222'>" + quantidadeEmRecebimento + " </div><div></div><div class='class1223'> UND</div><div></div></div></div></div><div class='col-lg-1 col-md-6'> </div></div></div>")

                    //ADICIONA O ITEM À DIV
                    $('#listaProdutos').append(htmlItem)

                    htmlItem.find(".exampleSelect").dropzie();
                    htmlItem.find(".dropzieToggle").css("background-color", corEstoque)
                    htmlItem.find(".class1225C").css("background-color", corRecebimento)
                    htmlItem.find("#buttonDetalhesEmCompra").css("background-color", corEstoque)
                    htmlItem.find("#buttonDetalhes").css("background-color", corRecebimento)
                    htmlItem.find(".class1238").css("background-color", corRecebimento)
                    htmlItem.find(".class1238B").css("background-color", corEstoque)
                    
                    htmlItem.find("#buttonDetalhes").click(function () {
                        helper.exibeDetalhesItem(cmp, helper, htmlItem)
                    })

                    htmlItem.find("#buttonDetalhesEmCompra").click(function () {
                        helper.exibeDetalhesEstoque(cmp, helper, htmlItem)
                    })

                    htmlItem.find(".dropzieOption").click(function () {
                        helper.atualizaDadosEstoqueItem(cmp, event, helper, this)
                    })

                })
                //----------------------------------------------------------------------------------------------------------------

                //CHAMA FUNÇÃO QUE IRÁ PREENCHER OS FILTROS DE PESQUISA-
                helper.preencheFiltros(cmp, event, helper, inputPesquisa, filtro)
                //------------------------------------------------------

                helper.eventsAfterAppend(cmp, event, helper)

                //OCULTA SPINNER DE CARREGAMENTO---
                helper.hideSpinner(cmp);
                //---------------------------------
            })

            //TRATA EXCESSÃO DE ERRO DA CONSULTA
            .catch(function (error) {
                helper.alertaErro(cmp, event, helper, error, "ERRO AO CONSULTAR PRODUTOS", "error")
            })
    },
    //-----------------------------------------------------------------------

    //FUNÇÃO QUE PREENCHE OS FILTROS DISPONÍVEIS PARA PESQUISA-------
    preencheFiltros: function (cmp, event, helper, inputPesquisa, filtro) {


        if (filtro === 'linha' || filtro === 'null') {
            helper.preencheLinhas(cmp, event, helper, inputPesquisa, filtro)
            //helper.preencheFamilias(cmp, event, helper, inputPesquisa, filtro)
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
                    helper.buscaEstoques(cmp, event, helper, helper.inputPesquisa, "familia")
                });

            })
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })

    },

    //ESSA FUNÇÃO PREENCHE O SELECT COM AS FAMÍLIAS DISPONÍVEIS
    preencheFamilias: function (cmp, event, helper, inputPesquisa, filtro) {

        //EXIBE O SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        //OCULTA O SELECT DO TIPO E MARCA E EXIBE SOMENTE O SELECT COM A FAMILIA
        $("#divMasterSelectFamilia").show()
        $("#divMasterSelectTipo").hide()
        $("#divMasterSelectMarca").hide()

        $("#selectTipo").hide()
        $("#selectMarca").hide()
        $("#selectFamilia").show()
        //-----------------------------------------------------------------------

        //cria um array vazio de linhas
        const familias = [];

        //recupera linha selecionada
        //const linhaSelecionada = helper.selectLinha;

        if (inputPesquisa === 'all') {
            var query = "SELECT Linha__c, Family FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' ORDER BY Family"
        } else {
            var query = "SELECT Family, Linha__c FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' AND (Name like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY Family"
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

                //LIMPA TODAS AS OPÇÕES DO SELECT
                $("#listaFamilia1").empty();
                $("#listaFamilia2").empty();

                //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
                $("#listaFamilia1").append("<input type='radio' name='item2' id='default' title='Familia' checked='true'/>")

                familias.forEach(function (atualFamilia) {
                    console.log(atualFamilia)
                    if (atualFamilia !== undefined) {
                        if (String(atualFamilia).length >= 8) {
                            var titleFamilia = atualFamilia
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
                    helper.buscaEstoques(cmp, event, helper, helper.inputPesquisa, "tipo")
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

        //OCULTA O SELECT DA MARCA
        $("#divMasterSelectMarca").hide()
        $("#selectMarca").hide()
        

        //cria um array vazio de linhas
        const tipos = [];

        //recupera familia selecionada
        const familiaSelecionada = helper.selectFamilia;

        //recupera linha selecionado
        //const linhaSelecionada = helper.selectLinha;

        if (inputPesquisa === 'all') {
            var query = "SELECT Linha__c, Family, Tipo_do_Produto__c FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' AND Family = '" + familiaSelecionada + "' ORDER BY Tipo_do_Produto__c"
        } else {
            var query = "SELECT Family, Linha__c, Tipo_do_Produto__c FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' AND Family = '" + familiaSelecionada + "' AND (Name like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY Tipo_do_Produto__c"
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

                //EXIBE DIV E SELECT COM OS TIPOS
                $("#divMasterSelectTipo").show()
                $("#selectTipo").show()

                //limpa todos as opções do select
                $("#listaTipo1").empty();
                $("#listaTipo2").empty();

                //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
                $("#listaTipo1").append("<input type='radio' name='item3' id='default' title='Tipo' checked='true'/>")

                tipos.forEach(function (atualTipo) {
                    if (atualTipo !== undefined) {
                        if (String(atualTipo).length >= 8) {
                            var titleFamilia = atualTipo
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
                    helper.buscaEstoques(cmp, event, helper, helper.inputPesquisa, "marca")
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
            var query = "SELECT Linha__c, Family, Tipo_do_Produto__c, Marca__c FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' AND Tipo_do_Produto__c = '" + tipoSelecionado + "' AND Family = '" + familiaSelecionada + "' ORDER BY Marca__c"
        } else {
            var query = "SELECT Family, Linha__c, Tipo_do_Produto__c, Marca__c FROM Product2 WHERE IsActive = true AND Linha__c = '"+helper.selectLinha+"' AND Tipo_do_Produto__c = '" + tipoSelecionado + "' AND Family = '" + familiaSelecionada + "' AND (Name like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY Marca__c"
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

                $("#divMasterSelectMarca").show()
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
                    helper.buscaEstoques(cmp, event, helper, helper.inputPesquisa, "end")
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

    //EXIBE DETALHES DO ITEM (NOME, MODELO, PEDIDO DE COMPRA, VALORES ETC...)
    exibeDetalhesItem: function (cmp, helper, item) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //DEFINE A VISUALIZAÇÃO DO NOME DO PRODUTO-------------------------
        var nomeItem = item.attr("data-name")//.length >= 20 ? (item.attr("data-name").substring(0,20) + "...") : item.attr("data-name");
        var urlImage = item.attr("data-image")
        var marca = item.attr("data-marca")
        var modelo = item.attr("data-modelo")
        var codigoFabricante = marca + ": " + item.attr("data-codigoFabricante")
        var codigoHospcom = "HOSPCOM: " + item.attr("data-codigoHospcom")
        var valorTotal = new Intl.NumberFormat('id', {minimumFractionDigits: 2 }).format(item.attr("data-valorTotal"));
        var idProduto = item.attr("data-idproduto")

        var inputHtml = $("<div class='containerDetalhes' id='containerDetalhes' style='display: flex'> <div class='containerDetalhesInterno'> <div style='width: 48%; height: 100%; display: flex;'> <div style='width: 100%; display: flex; justify-content: center; align-items: center;'> <img style='height: auto; border-bottom-left-radius: 10px; border-top-left-radius: 10px;' src='" + urlImage + "'/> </div></div><div style='display: flex; height: 100%; width: 4%; align-items: center; justify-content: center;'> <hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/> </div><div style='width: 48%; height: auto;'> <div style='width: 100%; height: auto; display: flex'> <div class='nomeProdutoDetails' style='width: 90%!important;'>" + nomeItem + "</div><div id='closeButtonProdutoDetails' style='color: red; font-size: 25px; display: flex; justify-content: center; align-items: center; width: 10%; height: 100%;'> <a class='closeButtonProdutoDetails'><i class='fa fa-times-circle' aria-hidden='true'></i></a> </div></div><div class='modeloProdutoDetails'>" + modelo + "</div><div class='codigosProdutosDetails'>" + codigoFabricante + "</div><div class='codigosProdutosDetails'>" + codigoHospcom + "</div><div class='codigosProdutosDetails'>PREÇO DE LISTA: " + valorTotal + "</div><div class='descricaoProdutosDetails'> <table class='table table-striped'> <thead> <tr> <th scope='col'>Pedido de compra</th> <th scope='col'>Total requisitado</th><th scope='col'>Total reservado</th><th scope='col'>Total disponível</th><th scope='col'>Previsao da entrega</th> </tr></thead> <tbody id='corpoTabelaPedidosCompra'> </tbody> </table> </div></div></div></div>")
        $("#containerPrincipal").append(inputHtml)

        var query = "SELECT Quantidade_destinada_Exibir__c, QuantidadeExibir__c, Quantidade_destinada__c, Quantidade_disponivel__c, Item_de_pedido_de_compra__r.Quantidade_disponivel_a_receber__c, Item_de_pedido_de_compra__r.Quantidade_Destinada__c, Item_de_pedido_de_compra__r.Quantidade_requisitada__c, Name, id, Fornecedor__c, Fornecedor__r.Name, Fornecedor__r.Prazo_de_recebimento__c, Fornecedor__r.Nova_Data_de_Entrega__c, Quantidade__c, Produto__c FROM Item_de_fornecedor__c WHERE  (Fornecedor__r.Status_do_PC__c != 'Cancelado') AND (status__c NOT IN ('Novo', 'Cancelado', 'Recebido Total') OR status__c = 'CMP - AG. ENTREGA FORNECEDOR') AND Quantidade_disponivel__c > 0 AND  status__c != '' AND Item_de_pedido_de_compra__r.Produto__c = '"+idProduto+"'"
        console.log("QUERY EXIBE DETALHES ITEM: ", query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (pedidosDeCompras) {
                pedidosDeCompras.forEach(function(pedidoDeCompra){
                    
                    var perfilAtual = cmp.get('v.CurrentUser')['Profile'].Name;
                    var usuarioHabilitado = helper.perfisHabilitadosPCs.includes(perfilAtual);
                    
                    var idPedidoDeCompra = String(pedidoDeCompra.Fornecedor__c) //ID DO PEDIDO DE COMPRA
                    var numeroPedidoCompra = String(pedidoDeCompra.Fornecedor__r.Name) //NUMERO DO PEDIDO DE COMPRA
                    var totalDisponivel = String(pedidoDeCompra.Quantidade_disponivel__c) //TOTAL DISPONÍVEL
                    var quantidadeReservado = String(pedidoDeCompra.Quantidade_destinada_Exibir__c)   //TOTAL RESERVADO
                    var quantidadeRequisitada = String(pedidoDeCompra.QuantidadeExibir__c)
                    var prazoDeRecebimentoTemp = pedidoDeCompra.Fornecedor__r.Nova_Data_de_Entrega__c ? String(pedidoDeCompra.Fornecedor__r.Nova_Data_de_Entrega__c).split("-") : String(pedidoDeCompra.Fornecedor__r.Prazo_de_recebimento__c).split("-")
                    var prazoDeRecebimento = prazoDeRecebimentoTemp[2] + "-" + prazoDeRecebimentoTemp[1] + "-" + prazoDeRecebimentoTemp[0]
                    var urlPC = usuarioHabilitado ? 'https://hospcomhospitalar.force.com/Sales/s/fornecedor/'+idPedidoDeCompra : "javascript:void(0)"
                    
                    inputHtml.find("#corpoTabelaPedidosCompra").append("<tr>\
<th scope='row'>\
<a href='"+urlPC+"' target='_blank'>"+numeroPedidoCompra+"</a>\
</th>\
<td>"+quantidadeRequisitada+"</td>\
<td>"+quantidadeReservado+"</td>\
<td>"+totalDisponivel+"</td>\
<td>"+prazoDeRecebimento+"</td>\
</tr>")
                })
                
                //OCULTA SPINNER DE CARREGAMENTO---
                helper.hideSpinner(cmp);
                //---------------------------------
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })

        inputHtml.find("#closeButtonProdutoDetails").click(function () {
            console.log("clicou remover")
            $("#containerDetalhes").remove()
        })

    },

    //EXIBE DETALHES DOS ESTOQUES SENDO LISTADOS
    exibeDetalhesEstoque: function (cmp, helper, item) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        console.log(item)
        
        //DEFINE A VISUALIZAÇÃO DO NOME DO PRODUTO-------------------------
        //var nomeItem = item.attr("data-name")//.length >= 20 ? (item.attr("data-name").substring(0,20) + "...") : item.attr("data-name");
        //var urlImage = item.attr("data-image")
        //var marca = item.attr("data-marca")
        //var modelo = item.attr("data-modelo")
        //var codigoFabricante = marca + ": " + item.attr("data-codigoFabricante")
        //var codigoHospcom = "HOSPCOM: " + item.attr("data-codigoHospcom")
        //var valorTotal = new Intl.NumberFormat('id', {minimumFractionDigits: 2 }).format(item.attr("data-valorTotal"));
        var idProduto = item.attr("data-idproduto")
        var todosEstoques = helper.customEstoques[0].Codigos + "," + helper.customEstoques[1].Codigos

        var inputHtml = $("<div class='containerDetalhes' id='containerDetalhes' style='display: flex'> <div class='containerDetalhesInterno' style='height: auto!important'> <div style='width: 100%; height: auto;'> <div style='width: 100%; height: auto; display: flex'> <div class='nomeProdutoDetails' style='width: 90%!important;' >Detalhe dos estoques</div><div id='closeButtonProdutoDetails' style='color: red; font-size: 25px; display: flex; justify-content: flex-end; align-items: center; width: 10%; height: 100%;'> <a class='closeButtonProdutoDetails'><i class='fa fa-times-circle' aria-hidden='true'></i></a> </div></div><div class='descricaoProdutosDetails'> <table class='table table-striped'> <thead> <tr> <th scope='col'>Cod. Estoque</th><th scope='col'>Nome do Estoque</th> <th scope='col'>Quantidade Disponível</th> </tr></thead> <tbody id='corpoTabelaPedidosCompra'> </tbody> </table> </div></div></div></div>")
        $("#containerPrincipal").append(inputHtml)
		
        var query = "SELECT Em_estoque__c, Estoque__r.Codigo__c, Estoque__r.Name FROM Entrada_de_Estoque__c WHERE produto__c = '"+idProduto+"' AND Estoque__r.Codigo__c IN ("+todosEstoques+")"
        console.log(query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (estoques) {
                //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                $('#listaProdutos').click()
                //-----------------------------------------
                estoques.forEach(function(estoqueAtual){
                    var codigoEstoque = estoqueAtual.Estoque__r.Codigo__c
                    var quantidadeDisponivelEstoque = estoqueAtual.Em_estoque__c
                    var nomeEstoque = estoqueAtual.Estoque__r.Name
                    var idEstoque = estoqueAtual.Estoque__r.Id

                    inputHtml.find("#corpoTabelaPedidosCompra").append("<tr><th scope='row'><a href='https://hospcomhospitalar.force.com/Sales/s/estoque/"+idEstoque+"' target='_blank'>"+codigoEstoque+"</a></th><td>"+nomeEstoque+"</td> <td>"+quantidadeDisponivelEstoque+"</td></tr>")
                })
                
                //OCULTA SPINNER DE CARREGAMENTO---
                helper.hideSpinner(cmp);
                //---------------------------------
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })

        inputHtml.find("#closeButtonProdutoDetails").click(function () {
            $("#containerDetalhes").remove()
        })

    },

    //FUNÇÃO QUE RETORNA O ULTIMO ITEM DO INDICE DE PRODUTOS NA COTAÇÃO-
    retornaIndiceUltimoItem: function (cmp, event, helper) {
        return $('#listaCotacao').children().length
    },
    //------------------------------------------------------------------

    //FUNÇÃO QUE ATIVA O DRAG AND DROP NOS ITENS----------------
    ativaDragAndDrop: function (cmp, event, helper) {
        //CONFIGURAÇÕES DA COLUNA DROP "DIREITA"------------------------------------------
        var el = document.getElementById('listaCotacao');
        //INSTANCIA O OBJETO SORTABLE, DO PLUGIN DE DRAG AND DROP
        var sortable = Sortable.create(el, {
            //DEFINIÇÕES DO GRUPO DE ARRASTA E SOLTA
            group: {
                name: 'shared', //DEFINE O NOME DO GRUPO DE COMPARTILHAMENTO ENTRE ITENS
            },
            onUpdate: function (evt) {
                //ATUALIZA O NUMBERITEM DE TODOS OS ITENS JÁ ADICIONADOS----------------------------------
                helper.atualizaListaItens(cmp, evt.item, helper)
                //----------------------------------------------------------------------------------------
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
        });
        //--------------------------------------------------------------------------
    },
    //----------------------------------------------------------

    //FUNÇÃO QUE ATUALIZA OS NÚMEROS DOS ITENS DA LISTA---------
    atualizaListaItens: function (cmp, event, helper) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        //CRIA UMA LISTA COM A ORDEM DOS ITENS
        var listaItens = []

        //PERCORRE TODA A LISTA DE ITENS NA COTAÇÃO E OBTÉM SUA POSIÇÃO E ID DO PRODUTO
        $('#listaCotacao').children().each(function () {
            //VARIÁVEL QUE ARMAZENA O ID DO PRODUTO
            var idProduto = $(this).attr('data-idItemCotacao')
            //VARIÁVEL QUE ARMAZENA A POSICAO DO PRODUTO
            var posicaoProduto = $(this).index() + 1
            //ADICIONA AMBOS VALORES NA LISTA COM A ORDEM, FORMANDO UM JSON
            if (idProduto != undefined) {
                listaItens.push({ idProduto: idProduto, posicaoProduto: posicaoProduto })
            }
        });
        //EXIBE JSON PARA CONFERÊNCIA
        var stringAux = String(JSON.stringify(listaItens))

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.ordena");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            ordenacao: stringAux,
        });
        //----------------------------------------------------

        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#listaProdutos').click()
        //-----------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //OCULTA SPINNER DE CARREGAMENTO---
                helper.hideSpinner(cmp);
                //---------------------------------

                helper.consultaCotacao(cmp, event, helper, 0)
                helper.alertaErro(cmp, event, helper, "LISTA REORDENADA COM SUCESSO", "TUDO CERTO!", "success", "", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ORDENAÇÃO", "ORDENAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
                console.log("incompleto")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO ATUALIZAR A LISTA", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    console.log("Erro desconhecido");
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A ORDENAÇÃO DA LISTA", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);

    },
    //----------------------------------------------------------

    //FUNÇÃO QUE CALCULA O TOTAL DA COTAÇÃO, DO KIT E DOS ITENS FILHOS--
    calculaTotais: function (cmp, event, helper) {
        //console.log("calculando totais...")
        var totalItensFilhos = 0;
        var totalKit = 0;
        var totalCotacao = 0;

        //PERCORRE O DOM DE ITENS PAIS INSERIDOS---------------------------------------------
        $('#listaCotacao').children().each(function () {

            //PERCORRE TODOS OS ITENS FILHOS DE UM ITEM PAI, SOMANDO OS VALORES DOS MESMOS---
            $(this).find("#produtosFilhosDrop").children().each(function () {
                var totalTemp = String($(this).find("#totalItem").val()).replace('BRL ', '');
                totalTemp = parseFloat(totalTemp.replace('.', '').replace(',', '.'));
                totalItensFilhos += totalTemp;
            })
            //--------------------------------------------------------------------------------

            var totalKit = String($(this).find("#totalItemPai").val()).replace('BRL ', '');
            totalKit = parseFloat(totalKit.replace('.', '').replace(',', '.'));
            totalKit = totalKit + totalItensFilhos

            totalCotacao = totalCotacao + totalKit
            $(this).find("#totalKit").text("TOTAL DO KIT: BRL " + new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(totalKit))
            totalItensFilhos = 0;
        });

        $(document).find("#totalCotacao").text("TOTAL DA COTAÇÃO BRL " + new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(totalCotacao))
    },
    //------------------------------------------------------------------

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