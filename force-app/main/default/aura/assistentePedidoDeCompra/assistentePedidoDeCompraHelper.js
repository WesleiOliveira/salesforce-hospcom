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
    iDsPedidoDeCompra: [],
    itensPedidosPadronizados: null,
    tipoPedido: '',
    empresaCompradora: '',
    pedidoDeCompraClone: '',
    dataFornecedores: "<option value='' selected='true' disabled='true'>CLIQUE PARA PROCURAR</option>",
    iDsContas: [],
    //------------------------------------------

    inputPesquisa: "null",

    isEmpty: function (cmp, str) {
        return !str.trim().length;
    },

    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecorId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        console.log("RecordID: ", recordId);
        return recordId
    },
    //---------------------------------------------------

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

    //FUNÇÃO QUE BUSCA E PREECHE OS PRODUTOS ENCONTRADOS---------------------
    buscaProdutos: function (cmp, event, helper, inputPesquisa, filtro) {
        var recordId = helper.retornaRecorId(cmp, event, helper)

        //EXIBE O SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);

        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#listaProdutos').click()
        helper.alertaErro(cmp, event, helper, "", "Carregando Produtos...", "info", "", "dismissable")

        let campos = "Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Quantidade_em_Estoque_Oficial__c",
            where = ["IsActive = true"],
            pesquisa = inputPesquisa !== "all" ? `%${inputPesquisa}%` : null,
            ordem = inputPesquisa !== "all" ? "ORDER BY Name" : "ORDER BY LastModifiedDate DESC";

        if (pesquisa) where.push(`(Name LIKE '${pesquisa}' OR Modelo__c LIKE '${pesquisa}' OR Marca__c LIKE '${pesquisa}' OR ProductCode LIKE '${pesquisa}')`);
        if (["familia", "tipo", "marca", "end"].includes(filtro)) where.push(`Linha__c = '${helper.selectLinha}'`);
        if (["tipo", "marca", "end"].includes(filtro)) where.push(`Family = '${helper.selectFamilia}'`);
        if (["marca", "end"].includes(filtro)) where.push(`Tipo_do_Produto__c = '${helper.selectTipo}'`);
        if (filtro === "end") where.push(`Marca__c = '${helper.selectMarca}'`);

        let query = `SELECT ${campos} FROM Product2 WHERE ${where.join(" AND ")} ${ordem} LIMIT 50`;

        helper.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (produtos) {
                //VARIÁVEL CONTADORA DAS DIVS INSERIDAS
                var contId = 1;

                //LIMPA A TELA DE EXIBIÇÃO DOS PRODUTOS
                $('#listaProdutos').empty();

                //LOOP QUE PERCORRE TODOS OS PRODUTOS ENCONTRADOS, ITERANDO SOBRE PRODUTOATUAL---------------------------------------
                produtos.forEach(function (produtoAtual) {

                    //VERIFICA SE O PRODUTO POSSÚI DESCRIÇÃO
                    if (String(produtoAtual.Description) == undefined || String(produtoAtual.Description) == "undefined") {
                        var produtoDescricao = "PRODUTO SEM DESCRIÇÃO"
                        var produtoDescricaoData = "PRODUTO SEM DESCRIÇÃO"
                    } else {
                        var produtoDescricao = String(produtoAtual.Description).substring(0, 200).toUpperCase() + "..."
                        var produtoDescricaoData = String(produtoAtual.Description)
                    }
                    //-----------------------------------------

                    //DEFINE VARIÁVEIS DE COR E QUANTIDADE DO ESTOQUE-----------------------------------------------------------------------------------------------------------------------------------------
                    //Verifica se há estoque do produto atual
                    if (produtoAtual.Quantidade_em_Estoque_Oficial__c === 0 || produtoAtual.Quantidade_em_Estoque_Oficial__c === undefined || produtoAtual.Quantidade_em_Estoque_Oficial__c === "undefined") {
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
                            var quantidadeEstoque = "0 UND"
                            var aguardandoReceber = produtoAtual.Qtd_Aguardando_Recebimento__c
                            if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                                aguardandoReceber = "0 UND"
                            }
                            //-------------------------------------------------------------------------------------
                            //
                        } else {
                            //Se não tiver aguardando recebimento, logo exibirá "Sem estoque e 0 UND"
                            //
                            //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO PRINCIPAL DO ITEM-------------------------------
                            var quantEstoque = "SEM ESTOQUE"
                            var quantidadeEstoque = "0 UND"
                            //------------------------------------------------------------------------------------
                            //
                            //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO EXPANDIDA DO ITEM "HOVER"-----------------------
                            var corEstoque = "#f40a29";
                            var corEtiqueta = "#f40a29";
                            var quantidadeEstoque = "0 UND"

                            var aguardandoReceber = produtoAtual.Qtd_Aguardando_Recebimento__c
                            if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                                aguardandoReceber = "0 UND"
                            }
                            //------------------------------------------------------------------------------------ 
                        }
                    } else {
                        //Se houver estoque, exibirá a quantidade em estoque na visualização principal, e na expandida a quantidade aguardando recebimento
                        var corEstoque = "#a0bb31";
                        var corEtiqueta = "#a0bb31";

                        var quantEstoque = produtoAtual.Quantidade_em_Estoque_Oficial__c + " EM ESTOQUE"
                        var quantidadeEstoque = produtoAtual.Quantidade_em_Estoque_Oficial__c + " UND"

                        var aguardandoReceber = produtoAtual.Qtd_Aguardando_Recebimento__c
                        if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                            aguardandoReceber = "0 UND"
                        }
                    }
                    //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                    var idProduto = produtoAtual.ID_do_Produto__c
                    var tipoProduto = produtoAtual.Tipo_do_Produto__c

                    //ADICIONA O ITEM À DIV
                    $('#listaProdutos').append("<div id='" + contId + "' data-type='itemExterno' data-idProduto='" + idProduto + "' class='itemPesquisa' data-descricao='" + produtoDescricaoData + "' data-codigo='" + produtoAtual.ProductCode + "' data-marca='" + produtoAtual.Marca__c + "' data-modelo='" + produtoAtual.Modelo__c + "' data-image='" + produtoAtual.URL_da_Imagem__c + "' name='" + produtoAtual.Name + "'> <!-- IMAGEM DO ITEM --> <div style='width: 26%; display: flex; align-items:center; justify-content: center;'> <img src='" + produtoAtual.URL_da_Imagem__c + "' style=' height: 90%; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/> </div> <!-- DIVISOR --> <div style='display: flex; height: 100%; width: 4%; align-items: center;'> <hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/> </div> <!-- INFO DO ITEM --> <div style='background-color: ; width: 70%; display: flex; flex-direction: column'> <!-- NOME DO ITEM --> <div style=' width: 100%; height: 24%; font-size: 14px; color: #00345c; font-weight: bold;'>" + produtoAtual.Name.substring(0, 17) + "...</div> <!-- MODELO DO ITEM --> <div style='background-color: ; width: 100%; height: 24%; font-size: 12px; color: #00345c;'>" + String(produtoAtual.Modelo__c).substring(0, 30) + "</div> <!-- DIVISOR --> <div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div> <!-- MARCA E CÓDIGO ITEM --> <div style=' width: 100%; height: 24%; font-size: 12px; color: #A0BB31;'>" + produtoAtual.Marca__c + ": " + produtoAtual.ProductCode + "</div> <!-- STATUS STOQUE ITEM --> <div style='background-color: grown; width: 100%; height: 24%'> <div style='color: white; background-color: " + corEtiqueta + "; height: 100%; width: 70%; display: flex; justify-content: center; align-items: center; border-radius: 120px; font-size: 13px;'>" + quantEstoque + "</div> </div> </div> <!-- DESCRIÇÃO FLUTUANTE DO ITEM --> <div class='divDescricaoItem' style='display: none; flex-direction: column; padding: 10px; border: 0.01px solid " + corEstoque + ";'> <!-- NOME DO ITEM --> <div class='itemNameFlutuante'>" + produtoAtual.Name + " </div> <!-- DIVISOR --> <div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div> <!-- MODELO DO ITEM --> <div style='height: 15%; width: 100%; display: flex'> <!-- NOME DO MODELO --> <div style='width: 60%; height: 100%; font-size: 10px; color: #a0bb31'>" + produtoAtual.Marca__c + ": " + produtoAtual.ProductCode + "</div> <!-- MODELO DO ITEM --> <div style='width: 40%; height: 100%; font-size: 10px; color: #a0bb31; text-align: right;'> TIPO: " + tipoProduto + "</div> </div> <!-- DESCRIÇÃO DO ITEM --> <div class='descricaoFlutuanteItem'>" + produtoDescricao + " </div> <!-- RODAPÉ --> <div style='width: 100%; height: 26%; column-gap: 3px; display: flex'> <div class='containerRodape'> <div class='rodapeBlocos'> Preço de lista </div> <div class='rodapeBlocos' style=''>R$ " + new Intl.NumberFormat('id').format(produtoAtual.Valor_Total__c) + "</div> </div> <div class='containerRodape' style='background-color: #ffff00'> <div class='rodapeBlocos' style='color: #00345c'>Em recebimento</div> <div class='rodapeBlocos' style='color: #00345c;'>" + aguardandoReceber + "</div> </div> <div class='containerRodape' style='background-color: " + corEstoque + "'> <div class='rodapeBlocos'> Qnt. em estoque </div> <div class='rodapeBlocos' style='font-size: 11px!important;'>" + quantidadeEstoque + "</div> </div> </div>   </div>")
                    contId++;
                })
                //----------------------------------------------------------------------------------------------------------------

                //OUVINTE DE MOUSEOVER NOS ITENS INSERIDOS-----------------------------
                $(".itemPesquisa").mouseover(function () {
                    var id = $(this).attr('id');
                    if ((id % 2) === 0) {
                        $(".divDescricaoItem", this).css({ "margin-left": "-277px" });
                        $(".divDescricaoItem", this).css({ "display": "flex" });
                    } else {
                        $(".divDescricaoItem", this).css({ "display": "flex" });
                    }

                })
                //---------------------------------------------------------------------

                //OUVINTE DE MOUSEOUT NOS ITENS INSERIDOS-----------------------------
                $(".itemPesquisa").mouseout(function () {
                    $(".divDescricaoItem", this).hide();
                })
                //---------------------------------------------------------------------

                //OUVINTE DE CLICK NOS ITENS INSERIDOS---------------------------------
                $(".itemPesquisa").click(function () {
                    $(".divDescricaoItem", this).hide();
                })
                //---------------------------------------------------------------------

                //CONFIGURAÇÕES DA COLUNA DRAG "ITENS DA ESQUERDA"----------------------
                var el = document.getElementById('listaProdutos');
                var sortable = Sortable.create(el, {
                    group: {
                        name: 'shared', //seta o nome do grupo de compartilhamento de itens
                        pull: 'clone', // To clone: set pull to 'clone'
                        put: false,
                    },
                    animation: 150,
                    forceFallback: true,
                    sort: false //DESATIVA A REORDENAÇÃO
                });
                //-----------------------------------------------------------------------

                //ATIVA DRAG AND DROP NA COLUNA DA DIREITA---------
                helper.ativaDragAndDrop(cmp, event, helper)
                //-------------------------------------------------

                //CHAMA FUNÇÃO QUE IRÁ PREENCHER OS FILTROS DE PESQUISA-
                helper.preencheFiltros(cmp, event, helper, inputPesquisa, filtro)
                //------------------------------------------------------

                //OCULTA SPINNER DE CARREGAMENTO---
                helper.hideSpinner(cmp);
                //---------------------------------
            })

            //TRATA EXCESSÃO DE ERRO DA CONSULTA
            .catch(function (error) {
                helper.alertaErro(cmp, event, helper, error, "ERRO AO CONSULTAR PRODUTOS", "error")
                console.log("Erro durante a consulta" + error)
            })
    },
    //-----------------------------------------------------------------------

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

    preencheLinhas: function (cmp, event, helper, inputPesquisa, filtro) {
        $("#selectFamilia, #selectTipo, #selectMarca").hide();

        const pesquisaAtiva = inputPesquisa !== 'all';
        const filtroTexto = pesquisaAtiva ?
            `AND (Name LIKE '%${inputPesquisa}%' OR Marca__c LIKE '%${inputPesquisa}%' OR ProductCode LIKE '%${inputPesquisa}%')`
            : '';

        const query = `SELECT Linha__c FROM Product2 WHERE IsActive = true ${filtroTexto}`;

        helper.soql(cmp, query).then(produtos => {
            const linhas = new Set();
            produtos.forEach(p => p.Linha__c && linhas.add(p.Linha__c));

            let htmlItens1 = "<input type='radio' name='item1' id='default' title='Linha' checked='true'/>";
            let htmlItens2 = "";

            linhas.forEach(linha => {
                const title = linha.length > 8 ? linha.substring(0, 8) + "..." : linha;
                htmlItens1 += `<input type='radio' name='item1' id='${linha}' title='${title}'/>`;
                htmlItens2 += `<li id='${linha}' class='itemLinha'><label class='labelLinha' for='${linha}'>${linha}</label></li>`;
            });

            $("#listaItens1").html(htmlItens1);
            $("#listaItens2").html(htmlItens2);

            $('.itemLinha').off('click').on('click', function () {
                helper.selectLinha = $(this).text();
                $('#selectLinhas').removeAttr("open");
                helper.buscaProdutos(cmp, event, helper, helper.inputPesquisa, "familia");
            });
        }).catch(console.log);
    },


    //ESSA FUNÇÃO PREENCHE O SELECT COM AS FAMÍLIAS DISPONÍVEIS
    preencheFamilias: function (cmp, event, helper, inputPesquisa, filtro) {
        helper.showSpinner(cmp);

        $("#selectTipo, #selectMarca").hide();
        $("#selectFamilia").show();

        const linhaSelecionada = helper.selectLinha;
        const pesquisaAtiva = inputPesquisa !== 'all';
        const filtroTexto = pesquisaAtiva ?
            `AND (Name LIKE '%${inputPesquisa}%' OR Marca__c LIKE '%${inputPesquisa}%' OR ProductCode LIKE '%${inputPesquisa}%')`
            : '';

        const query = `SELECT Family, Linha__c FROM Product2 WHERE IsActive = true AND Linha__c = '${linhaSelecionada}' ${filtroTexto} ORDER BY Family`;

        helper.soql(cmp, query).then(produtos => {
            const familias = new Set();

            produtos.forEach(p => {
                if (p.Linha__c && p.Family) familias.add(p.Family);
            });

            // Constrói HTML em lote
            let htmlFamilia1 = "<input type='radio' name='item2' id='default' title='Familia' checked='true'/>";
            let htmlFamilia2 = "";

            familias.forEach(fam => {
                if (!fam) return;
                const title = fam.length > 8 ? fam.substring(0, 8) + "..." : fam;
                htmlFamilia1 += `<input type='radio' name='item2' id='${fam}' title='${title}'/>`;
                htmlFamilia2 += `<li id='${fam}' class='itemFamilia'><label class='labelLinha' for='${fam}'>${fam}</label></li>`;
            });

            // Atualiza DOM de uma vez
            $("#listaFamilia1").html(htmlFamilia1);
            $("#listaFamilia2").html(htmlFamilia2);

            // Reatribui listener
            $('.itemFamilia').off('click').on('click', function () {
                helper.selectFamilia = $(this).text();
                $('#selectFamilia').removeAttr("open");
                helper.buscaProdutos(cmp, event, helper, helper.inputPesquisa, "tipo");
            });

            helper.hideSpinner(cmp);
        }).catch(console.log);
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

    //FUNÇÃO QUE REMOVE UM ITEM DA COTAÇÃO----------------------
    removeItemCotacao: function (cmp, event, helper, item, option) {
        if (option === 0) {
            var textAlerta = "Deseja mesmo remover este item?"
            var textAlertaErro = "ITEM REMOVIDO"
        } else {
            var textAlerta = "Deseja mesmo transformar este item em acessório?"
            var textAlertaErro = "ITEM MOVIDO"
        }

        //EXIBE CAIXA DE DÍALOGO CONFIRMANDO A EXCLUSÃO DO ITEM
        if (confirm(textAlerta)) {
            helper.showSpinner(cmp); //EXIBE SPINNER DE CARREGAMENTO

            //SETA POSIÇÃO ATUAL DO SCROLL DA DIV DA COTAÇÃO
            helper.posicaoDivCotacao = $('#listaCotacao').scrollTop()

            var recordId = helper.retornaRecorId(cmp, event, helper) //VARIÁVEL QUE ARMAZENA O RECORDID DO REGISTRO
            var idItemCotacao = $(item).closest(".containerCotacao").attr('data-iditemcotacao');	//VARIÁVEL QUE ARMAZENA O ID DO PRODUTO A SER ADICIONADO

            var action = cmp.get("c.deleta"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO

            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                //idCotacao: recordId,
                id: idItemCotacao,
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
                    //helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.consultaCotacao(cmp, event, helper, 1) //CHAMA FUNÇÃO QUE IRÁ CONSULTAR A COTAÇÃO NOVAMENTE E EXIBIR OS ITENS ATUALIZADOS
                    helper.alertaErro(cmp, event, helper, textAlertaErro, "ÓTIMO!", "success", "", "dismissable") //EXIBE UM ALERTA DE SUCESSO AO USUÁRIO
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
        } else {
            console.log("else confirma")
        }



    },
    //----------------------------------------------------------

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
        $("#buttonItensOPP").css("opacity", "40%")

        //OCULTA DIV DO PESQUISE PRODUTOS
        $("#divPesquiseProdutos").hide()

        //OCULTA DIV DAS OPPS
        $("#divOpps").hide()

        //EXIBE DIV DO MKT
        $("#divPlataformaMkt").show()

        //CHAMA FUNÇÃO GENÉRICA QUE ADICIONA EVENTOS APÓS A ATUALIZAÇÃO--
        helper.eventsAfterAppend(cmp, event, helper)
        //---------------------------------------------------------------
    },
    //----------------------------------------------------------

    //EXIBE DIV DE OPPS----------------------------
    exibeItensOpp: function (cmp, event, helper) {

        //ALTERA ESTILO DOS BOTÕES APÓS CLIQUE
        $("#buttonItensOPP").css("opacity", "100%")
        $("#buttonPlataformaMarketing").css("opacity", "40%")
        $("#buttonPesquiseProdutos").css("opacity", "40%")

        //OCULTA DIV DO PESQUISE PRODUTOS
        $("#divPesquiseProdutos").hide()

        //OCULTA DIV DOS ITENS DO PV
        $("#divPlataformaMkt").hide()

        //EXIBE DIV DAS OPPS
        $("#divOpps").show()

        helper.clicadoOpp = true


        //CHAMA FUNÇÃO GENÉRICA QUE ADICIONA EVENTOS APÓS A ATUALIZAÇÃO--
        //helper.eventsAfterAppend(cmp, event, helper)
        //---------------------------------------------------------------
    },
    //----------------------------------------------------------

    //EXIBE DIV DA PESQUISA DE PRODUTOS------------------------
    exibePesquisaProdutos: function (cmp, event, helper) {
        helper.buscaProdutos(cmp, event, helper, "all", "null")

        //ALTERA ESTILO DOS BOTÕES APÓS CLIQUE
        $("#buttonPlataformaMarketing").css("opacity", "40%")
        $("#buttonItensOPP").css("opacity", "40%")
        $("#buttonPesquiseProdutos").css("opacity", "100%")

        //OCULTA DIV DO PESQUISE
        $("#divPlataformaMkt").hide()

        //OCULTA DIV DAS OPPS
        $("#divOpps").hide()

        //EXIBE DIV DO MKT
        $("#divPesquiseProdutos").show()

        //CHAMA FUNÇÃO GENÉRICA QUE ADICIONA EVENTOS APÓS A ATUALIZAÇÃO--
        helper.eventsAfterAppend(cmp, event, helper)
        //---------------------------------------------------------------
    },
    //---------------------------------------------------------

    modalFornecedores: function (cmp, event, helper) {
        var inputHtml = $("\
<div class='containerDetalhes' id='containerDetalhes' style='display: flex'>\
<div class='containerDetalhesInterno'>\
<div style='width: 48%; height: 100%; display: flex;'>\
<div style='width: 100%; display: flex; justify-content: center; align-items: center;'> <img style='height: auto; border-bottom-left-radius: 10px; border-top-left-radius: 10px;' src='' + urlImage + ''/> </div>\
</div>\
<div style='display: flex; height: 100%; width: 4%; align-items: center; justify-content: center;'>\
<hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
</div>\
<div style='width: 48%; height: auto;'>\
<div style='width: 100%; height: auto; display: flex'>\
<div class='nomeProdutoDetails'>' + nomeItem + '</div>\
<div id='closeButtonProdutoDetails' style='color: red; font-size: 25px; display: flex; justify-content: center; align-items: center; width: 10%; height: 100%;'> <a class='closeButtonProdutoDetails'><i class='fa fa-times-circle' aria-hidden='true'></i></a> </div>\
</div>\
<div class='modeloProdutoDetails'>' + modelo + '</div>\
<div class='codigosProdutosDetails'>' + codigoFabricante + '</div>\
<div class='codigosProdutosDetails'>' + codigoHospcom + '</div>\
<div class='codigosProdutosDetails'>PREÇO DE LISTA: ' + valorTotal + '</div>\
<div class='descricaoProdutosDetails'>\
<table class='table table-striped'>\
<thead>\
<tr>\
<th scope='col'>Pedido de compra</th>\
<th scope='col'>Total requisitado</th>\
<th scope='col'>Total reservado</th>\
<th scope='col'>Total disponível</th>\
<th scope='col'>Previsao da entrega</th>\
</tr>\
</thead>\
<tbody id='corpoTabelaPedidosCompra'> </tbody>\
</table>\
</div>\
</div>\
</div>\
</div>")

        if (false) {
            $("#containerPrincipal").append(inputHtml)
        }

    },

    addAdicionalFornecedor: function (cmp, event, helper) {

        $("#containerAditionalFornecedor").css("display", "flex")

        $("#buttonCancelarAditionalFornecedor").off().on("click", function () {
            $("#containerAditionalFornecedor").css("display", "none")
        });

        $("#buttonContinuarAditionalFornecedor").on("click", function () {
            var fornecedorAdicional = $("#fornecedor4").val()
            helper.criaFornecedorAdicional(cmp, event, helper, fornecedorAdicional)
        });

        helper.preencheModalFornecedores(cmp, event, helper)
    },

    criaFornecedorAdicional: function (cmp, event, helper, fornecedorAdicional) {

        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.cloneFornecedorWithChildren");

        console.log("PEDIDO DE COMPRA CLONE", helper.pedidoDeCompraClone)
        console.log("FORNECEDOR ADICIONAL", fornecedorAdicional)

        action.setParams({
            fornecedorId: helper.pedidoDeCompraClone,
            novoFornecedor: fornecedorAdicional
        });

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
                helper.alertaErro(cmp, event, helper, "pedido(s) foram criados, 1 para cada fornecedor informado.", "TUDO OK!", "success", "", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ATUALIZAÇÃO DO ITEM", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CRIAR OS PEDIDOS DE COMPRAS", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A CRIAÇÃO DOS PEDIDOS DE COMPRA", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });
        $A.enqueueAction(action);
    },

    //PREENCHE A COLUNA DA DIREITA, COM OS ITENS DA COTACAO
    consultaCotacaoCompra: function (cmp, event, helper) {

        var recordId = helper.retornaRecorId(cmp, event, helper)

        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT Id, Pedido_de_compra__r.Status__c, Pedido_de_compra__r.Tipo__c, Codigo_do_produto__c, Quantidade_total__c, Unidade_de_medida__c, Descri_o_da_linha__c, Nome__c, Modelo__c, Marca__c, Produto__c, Produto__r.URL_da_Imagem__c FROM Item_de_pedido_de_compra__c WHERE Pedido_de_compra__c = '" + recordId + "' ORDER BY CreatedDate DESC")

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itens) {

                $("#listaCotacao").empty(); //LIMPA DIV PARA INSERIR

                if (itens.length == 0) {
                    helper.hideSpinner(cmp);
                    return 0;
                }

                console.log("CONSULTA COTACAO COMPRA", itens)

                var statusCotacao = itens[0].Pedido_de_compra__r.Status__c
                console.log("statusCotacao", statusCotacao)

                if (statusCotacao != '5 - Concluído') {
                    $("#addOptionalFornecedor").css("display", "flex")
                    $("#addOptionalFornecedor").off().on("click", function () {
                        helper.addAdicionalFornecedor(cmp, event, helper)
                    });
                }

                itens.forEach(function (item) {

                    var unidadeDeMedida = item.Unidade_de_medida__c
                    var imageUrl = item.Produto__r.URL_da_Imagem__c;
                    var idItemCotacao = item.Id;
                    var nomeItem = item.Nome__c;
                    var ordem = '';
                    var quantidade = item.Quantidade_total__c
                    var descricao = item.Descri_o_da_linha__c;
                    var modCodMarca = item.Marca__c + ": " + item.Codigo_do_produto__c;
                    helper.tipoPedido = item.Pedido_de_compra__r.Tipo__c


                    //CRIA A VARIÁVEL COM O ITEM QUE SERÁ ADICIONADO-------------------
                    var inputHtml = $("\
<div class='containerCotacao' data-idItemCotacao='" + idItemCotacao + "' data-image='" + imageUrl + "' data-idItemCotacao='" + idItemCotacao + "'>\
<div class='itemMainCotacao'>\
<!-- IMAGEM DO ITEM -->\
<div style='width: 20%'>\
<img src='" + imageUrl + "' style='height: auto; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/>\
</div>\
<!-- DIVISOR -->\
<div style='display: flex; height: 100%; width: 4%; align-items: center; justify-content: center;'>\
<hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
</div>\
<!-- INFO DO ITEM -->\
<div style='width: 76%; display: flex; flex-direction: column'>\
<!-- NOME DO ITEM E BOTÕES DE AÇÃO -->\
<div style='position: relative; display: flex; align-items: center; width: 100%; height: 44%'>\
<div style='display: flex; align-items: center; width: 80%; height: 100%; font-size: 20px; color: #00345c; font-weight: bold;'>" + nomeItem + "</div>\
<div style='justify-content:center; align-items: center; display: flex; align-items: center; width: 10%; height: 100%; font-size: 20px; color: #00345c; font-weight: bold;'>\
<div class='buttonNumberItem' id='numberItem' style=''>#" + ordem + "</div>\
</div><a style='width: 10%; height: 100%;' id='buttonOptions' class='buttonOptions'>\
<div style='justify-content:center; align-items: center; display: flex; align-items: center; width: 100%; height: 100%; font-size: 20px; color: #00345c; font-weight: bold;'>\
<div class='buttonNumberItem' style='background-color: #f4f4f4!important; border: 0px'>\
<i class='fa fa-sort-desc' style='color: #00345c; font-size: 18px;' aria-hidden='true'></i>\
</div>\
</div>\
</a>\
<!-- MENU OPTIONS ITEM -->\
<div style='display: none; flex-direction: column' id='menuOptionsId'  class='menuOptions'>\
<div id='optionClose' class='optionClose' style='width: 100%; height:33.3%; display: flex; justify-content: right; align-items: center; cursor: pointer;'>\
<div style='width: 80%; height: 100%; color: red; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Remover</div>\
<div style='width: 20%; height: 100%; color: red; display: flex; align-items: center; justify-content: center; text-align: center'>\
<i class='fa fa-times-circle' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i>\
</div>\
</div> <div id='optionShowDetails' style='width: 100%; height:33.3%; display: flex; justify-content: right; align-items: center'>\
<div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Exibir Detalhes</div>\
<div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; justify-content: center; text-align: center'>\
<i class='fa fa-th-large' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i>\
</div> </div> <div id='optionCloseOptions' class='optionCloseOptions' style='width: 100%; cursor: pointer; height:33.3%; display: flex; justify-content: right; align-items: center'>\
<div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Fechar</div>\
<div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; justify-content: center; text-align: center'>\
<i class='fa fa-minus-circle' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i>\
</div> </div> </div> </div>\
<!-- MODELO DO ITEM -->\
<div style='width: 100%; height: auto; font-size: 12px; color: #00345c; display: flex; align-items: center'>" + modCodMarca + "</div>\
<!-- DIVISOR -->\
<div style='display: flex; height: 4%; height: 8%; align-items: center;'>\
<hr style='border-top: 1px solid #dcdcdc; margin-top: 2px; width: 95%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
</div>\
<!-- DESCRIÇÃO -->\
<div style='width: 100%; height: auto'> <div style='font-size: 11px; color: #00345e; height: auto; width: 100%; display: flex; justify-content: center; align-items: center; border-radius: 5px;'>\
<textarea id='textAreaDesc' value='Descrição' class='customTextArea textAreaDesc' id='multiliner' name='multiliner'></textarea>\
</div> </div>\
\
<!-- VALORES -->\
<div style='column-gap: 2px; padding-bottom: 1px; padding-top: 1px; width: 100%; height: 30%; font-size: 12px; color: #A0BB31; display: flex'>\
\
    <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 50%; background-color: #a0bb31'>\
        <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>QNTD</div>\
        <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'>\
        	<input class='inputQtd' style='text-align: center; background-color: rgb(0, 0, 0, 0); border: 0px solid;width: 100%; height: 100%;' type='text' id='quantidade' name='lname' value='1'/>\
        </div>\
    </div>\
\
    <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 50%; background-color: #a0bb31'>\
        <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>UM</div>\
        <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'>\
        	<select id='selectUm' class='selectUm'>\
				<option value='default' disabled>Selecione</option>\
              	<option value='AMPOLA'>AMPOLA</option>\
                <option value='BALDE'>BALDE</option>\
                <option value='BANDEJ'>BANDEJ</option>\
                <option value='BARRA'>BARRA</option>\
                <option value='BISNAG'>BISNAG</option>\
                <option value='BLOCO'>BLOCO</option>\
                <option value='BOBINA'>BOBINA</option>\
                <option value='BOMB'>BOMB</option>\
                <option value='CAPS'>CAPS</option>\
                <option value='CART'>CART</option>\
                <option value='CENTO'>CENTO</option>\
                <option value='CJ'>CJ</option>\
                <option value='CM'>CM</option>\
                <option value='CM2'>CM2</option>\
                <option value='CX'>CX</option>\
                <option value='CX2'>CX2</option>\
                <option value='CX3'>CX3</option>\
                <option value='CX5'>CX5</option>\
                <option value='CX10'>CX10</option>\
                <option value='CX15'>CX15</option>\
                <option value='CX20'>CX20</option>\
                <option value='CX25'>CX25</option>\
                <option value='CX50'>CX50</option>\
                <option value='CX100'>CX100</option>\
                <option value='DISP'>DISP</option>\
                <option value='DUZIA'>DUZIA</option>\
                <option value='EMBAL'>EMBAL</option>\
                <option value='FARDO'>FARDO</option>\
                <option value='FOLHA'>FOLHA</option>\
                <option value='FRASCO'>FRASCO</option>\
                <option value='GALAO'>GALAO</option>\
                <option value='GF'>GF</option>\
                <option value='GRAMAS'>GRAMAS</option>\
                <option value='JOGO'>JOGO</option>\
                <option value='KG'>KG</option>\
                <option value='KIT'>KIT</option>\
                <option value='LATA'>LATA</option>\
                <option value='LITRO'>LITRO</option>\
                <option value='M'>M</option>\
                <option value='M2'>M2</option>\
                <option value='M3'>M3</option>\
                <option value='MILHEI'>MILHEI</option>\
                <option value='ML'>ML</option>\
                <option value='MWH'>MWH</option>\
                <option value='PACOTE'>PACOTE</option>\
                <option value='PALETE'>PALETE</option>\
                <option value='PARES'>PARES</option>\
                <option value='PC'>PC</option>\
                <option value='POTE'>POTE</option>\
                <option value='K'>K</option>\
                <option value='RESMA'>RESMA</option>\
                <option value='ROLO'>ROLO</option>\
                <option value='SACO'>SACO</option>\
                <option value='SACOLA'>SACOLA</option>\
                <option value='TAMBOR'>TAMBOR</option>\
                <option value='TANQUE'>TANQUE</option>\
                <option value='TON'>TON</option>\
                <option value='TUBO'>TUBO</option>\
                <option value='UNID'>UNID</option>\
                <option value='VASIL'>VASIL</option>\
                <option value='VIDRO'>VIDRO</option>\
				<option value='UN' disabled>UN</option>\
				<option value='PCT' disabled>PCT</option>\
            </select>\
        </div>\
	</div>\
</div>\
\
</div>\
</div>\
 </div>")

                    $("#listaCotacao").append(inputHtml)  //ADICIONA O ITEM

                    //SETS APÓS INSERÇÃO
                    $(".textAreaDesc:last").val(descricao);

                    //SETS APÓS INSERÇÃO
                    $(".inputQtd:last").val(quantidade);

                    //SETA O STATUS ATUAL NO SELECT OPTIONS
                    $(".selectUm:last option").each(function () {
                        var valorAtualOption = $(this).val()
                        if (valorAtualOption == unidadeDeMedida) {
                            $(this).attr('selected', 'true')
                        }
                    })


                });
                helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                helper.eventsAfterConsultaCotacao(cmp, event, helper);
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })

    },

    //EVENTOS VINCULADOS APÓS O PREENCHIMENTOD A COLUNA DA DIREITA
    eventsAfterConsultaCotacao: function (cmp, event, helper) {

        //helper.ativaDragAndDrop(cmp, event, helper) //ATIVA O ARRASTA E SOLTA NA COLUNA DA DIREITA

        //EXPANDE OU RECOLHE O TEXTAREA------------------------------------
        $(".customTextArea").off().on("click", function () {
            console.log("click em textarea expand")
            $(this).css({ "height": "200px" });
        })
        $(".customTextArea").on("focusout", function () {
            $(this).css({ "height": "20px" });
        })
        //------------------------------------------------------------------

        //EXPANDE E RECOLHE O MENU DE OPÇÕES DO ITEM------------------------
        $(".buttonOptions").off().on("click", function () {
            console.log('clique')
            if ($(this).parent().find("#menuOptionsId").css('display') == 'none') {
                $(this).parent().find("#menuOptionsId").css({ "display": "flex" });
            } else {
                $(this).parent().find("#menuOptionsId").css({ "display": "none" });
            }
        })
        //------------------------------------------------------------------

        //RECOLHE O MENU CASO CLICK EM FECHAR-------------------------------
        $(".optionCloseOptions").off().on("click", function () {
            $(this).parent().css({ "display": "none" });
        })
        //------------------------------------------------------------------

        //ATUALIZA OS DADOS DO ITEM------------------------------------------
        $(".textAreaDesc, .selectUm").off().on('change', function () {
            helper.atualizaItemCompra(cmp, event, helper, this)
        })
        //------------------------------------------------------------------

        /* Armazena o valor original quando o input recebe foco
        $(".inputQtd").off('focus').on('focus', function () {
            $(this).data('valor-anterior', $(this).val());
        }); */

        // Trata a alteração
        $(".inputQtd").off('change').on('change', function () {

            //alert("Alteração de quantidade não permitida")


            var valorAnterior = $(this).data('valor-anterior');

            if (window.confirm('Alterar essa quantidade, alterará a quantidade de todas as pré-destinações, caso aplicável. Deseja continuar?')) {
                helper.atualizaItemCompra(cmp, event, helper, this);
            } else {
                // Restaura o valor anterior se o usuário cancelar
                $(this).val(valorAnterior);
            }
        });

        //REMOVE ITEM DA COTAÇÃO--------------------------------------------
        $(".optionClose").off().on("click", function () {
            helper.removeItemCotacaoCompra(cmp, event, helper, this)
        })
        //------------------------------------------------------------------
    },

    atualizaItemCompra: function (cmp, event, helper, elemento) {
        var idItemCotacao = $(elemento).parents('.containerCotacao').attr('data-iditemcotacao')
        var valorUM = $(elemento).parents('.containerCotacao').find('#selectUm option:selected').val()
        var quantidade = $(elemento).parents('.containerCotacao').find('#quantidade').val()
        var descricao = $(elemento).parents('.containerCotacao').find('#textAreaDesc').val()

        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.atualizaProdutos");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            itemCotacao: idItemCotacao,
            qtd: quantidade,
            unidade: valorUM,
            descricao: descricao
        });
        //----------------------------------------------------

        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#listaProdutos').click()
        helper.alertaErro(cmp, event, helper, "", "Carregando...", "info", "", "dismissable")

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                helper.consultaCotacaoCompra(cmp, event, helper);
                helper.alertaErro(cmp, event, helper, "ITEM ATUALIZADO", "TUDO OK!", "success", "", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.consultaCotacaoCompra(cmp, event, helper);
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ATUALIZAÇÃO DO ITEM", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.consultaCotacaoCompra(cmp, event, helper);
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO ATUALIZAR OS DADOS DO ITEM", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.consultaCotacaoCompra(cmp, event, helper);
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO AO ATUALIZAR OS DADOS DO ITEM", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },

    //FUNÇÃO QUE REMOVE UM ITEM DA COTAÇÃO----------------------
    removeItemCotacaoCompra: function (cmp, event, helper, item) {

        var textAlerta = "Deseja mesmo remover este item?"
        var textAlertaErro = "ITEM REMOVIDO"

        //EXIBE CAIXA DE DÍALOGO CONFIRMANDO A EXCLUSÃO DO ITEM
        if (confirm(textAlerta)) {
            helper.showSpinner(cmp); //EXIBE SPINNER DE CARREGAMENTO

            var idItemCotacao = $(item).closest(".containerCotacao").attr('data-idItemCotacao');	//VARIÁVEL QUE ARMAZENA O ID DO PRODUTO A SER ADICIONADO
            var action = cmp.get("c.removeProduto"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO

            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                itemCotacao: idItemCotacao,
            });
            //--------------------------------------------------

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#listaProdutos').click()
            helper.alertaErro(cmp, event, helper, "", "Carregando...", "info", "", "dismissable")

            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX

                //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                if (state === "SUCCESS") {
                    //helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    helper.consultaCotacaoCompra(cmp, event, helper); //CHAMA FUNÇÃO QUE IRÁ CONSULTAR A COTAÇÃO NOVAMENTE E EXIBIR OS ITENS ATUALIZADOS
                    helper.alertaErro(cmp, event, helper, textAlertaErro, "ÓTIMO!", "success", "", "dismissable") //EXIBE UM ALERTA DE SUCESSO AO USUÁRIO
                }
                //CASO O MÉTODO SEJA EXECUTADO DE FORMA INCOMPLETA
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky") //EXIBE UM ALERTA DE INSERÇÃO INCOMPLETA AO USUÁRIO
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO REMOVER PRODUTO", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });

            $A.enqueueAction(action);
        } else {
            console.log("else confirma")
        }



    },
    //----------------------------------------------------------

    //FUNCAO AUXILIAR CHAMADA ANTES DE PREENCHER A COLUNA DA ESQUERDA COM OS PEDIDOS DE VENDA E ITENS PARA COMPRA
    //A FUNCAO AUXILIAR FAZ A CONSULTA APLICANDO OS FILTROS NECESSÁRIOS
    auxiliarPreenchePedidos: function (cmp, event, helper) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var recordId = helper.retornaRecorId(cmp, event, helper)

        //CONSULTA PARA VERIFICAR O TIPO DO PEDIDO DE COMPRA
        this.soql(cmp, "SELECT Tipo__c FROM Pedido_de_compra__c WHERE Id = '" + recordId + "'")

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (detalhePedidoCompra) {


                detalhePedidoCompra.forEach(function (detalhe) {
                    var tipo = detalhe.Tipo__c
                    if (tipo == "Compra para consumo") {
                        helper.auxiliarPreenchePedidosConsumo(cmp, event, helper)
                    } else {
                        helper.auxiliarPreenchePedidosRevenda(cmp, event, helper)
                        helper.auxiliarPreencheOpps(cmp, event, helper)
                    }
                    //console.log("OPERACAO")
                    //helper.auxiliarPreenchePedidosRevenda(cmp, event, helper)
                });

            })
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    auxiliarPreenchePedidosRevenda: function (cmp, event, helper, operacao) {

        var itensPedidosPadronizados = [];
        var numeroDoPedido = [];
        var numeroDoPedidoJson = [];

        //REALIZA A CONSULTA PARA
        var query = "SELECT Id, OrderId, Quantity, OrderItemNumber, Descricao_da_linha__c,  PriceBookEntry.Product2.Tipo_do_Produto__c, Order.OrderNumber, Quantidade_a_requisitar_novo__c, Order.Account.Name, Order.Account.Raz_o_Social__c, Order.Faturamento_Feito__r.Name, Order.Faturamento_Feito__r.Raz_o_Social__c, PriceBookEntry.Product2Id, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.StockKeepingUnit, PriceBookEntry.Product2.ProductCode, PriceBookEntry.Product2.URL_da_Imagem__c, PriceBookEntry.Product2.Marca__c, PriceBookEntry.Product2.Modelo__c, (SELECT ID, Item_do_pedido_de_compra2__r.Fornecedor__r.Name FROM Requisicoes_de_Produtos__r) FROM OrderItem WHERE (Order.Status NOT IN ('Rascunho', 'Aguardando Aprovação Comercial', 'Aguardando Aprovação Financeira', 'Reprovado', 'Cancelado') AND Quantidade_falta_requisitar__c > 0 AND Status__c = 'OPR - ANALISE DE COMPRA') ";

        query += (helper.selectMarca != null && helper.selectMarca != 'NENHUM') ? " AND PriceBookEntry.Product2.Marca__c = '" + helper.selectMarca + "' " : '';
        query += (helper.selectTipo != null && helper.selectTipo != 'NENHUM') ? " AND PriceBookEntry.Product2.Tipo_do_Produto__c = '" + helper.selectTipo + "' " : '';
        query += (helper.selectNPedido != null && helper.selectNPedido != 'NENHUM') ? " AND Order.OrderNumber = '" + helper.selectNPedido + "' " : '';

        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#listaProdutos').click()
        helper.alertaErro(cmp, event, helper, "", "Carregando Produtos...", "info", "", "dismissable")

        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itensPedidos) {
                //console.log("ITENS PEDIDO CONSULTA", itensPedidos)

                //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                $('#listaProdutos').click()
                //-----------------------------------------

                itensPedidos.forEach(function (itemPedido) {
                    if (itemPedido.hasOwnProperty('Requisicoes_de_Produtos__r')) {
                        var itemPedidoPadronizado = { "Quantidade": itemPedido.Quantity, "RequisicaoProduto": itemPedido.Requisicoes_de_Produtos__r, "IdProduto": itemPedido.PricebookEntry.Product2.Id, "tipoProduto": itemPedido.PricebookEntry.Product2.Tipo_do_Produto__c, "codigoHospcom": itemPedido.PricebookEntry.Product2.StockKeepingUnit, "modelo": itemPedido.PricebookEntry.Product2.Modelo__c, "quantidadeFaltaRequisitar": itemPedido.Quantidade_a_requisitar_novo__c, "numeroPedido": itemPedido.Order.OrderNumber, "pedido": { "iDPedido": itemPedido.OrderId, "numeroPedido": itemPedido.Order.OrderNumber, "nomeDaConta": itemPedido.Order.Account.Name, "idDaConta": itemPedido.Order.Account.Id, "contaCompradora": itemPedido.Order.Faturamento_Feito__r.Raz_o_Social__c, "idContaCompradora": itemPedido.Order.Faturamento_Feito__r.Id }, "Id": itemPedido.Id, "OrderItemNumber": itemPedido.OrderItemNumber, "Descricao": itemPedido.Descricao_da_linha__c, "iDPedido": itemPedido.OrderId, "urlImagem": itemPedido.PricebookEntry.Product2.URL_da_Imagem__c, "nomeProduto": itemPedido.PricebookEntry.Product2.Name, "codigoFabricante": itemPedido.PricebookEntry.Product2.ProductCode, "marca": itemPedido.PricebookEntry.Product2.Marca__c };
                    } else {
                        var itemPedidoPadronizado = { "Quantidade": itemPedido.Quantity, "IdProduto": itemPedido.PricebookEntry.Product2.Id, "tipoProduto": itemPedido.PricebookEntry.Product2.Tipo_do_Produto__c, "codigoHospcom": itemPedido.PricebookEntry.Product2.StockKeepingUnit, "modelo": itemPedido.PricebookEntry.Product2.Modelo__c, "quantidadeFaltaRequisitar": itemPedido.Quantidade_a_requisitar_novo__c, "numeroPedido": itemPedido.Order.OrderNumber, "pedido": { "iDPedido": itemPedido.OrderId, "numeroPedido": itemPedido.Order.OrderNumber, "nomeDaConta": itemPedido.Order.Account.Name, "idDaConta": itemPedido.Order.Account.Id, "contaCompradora": itemPedido.Order.Faturamento_Feito__r.Raz_o_Social__c, "idContaCompradora": itemPedido.Order.Faturamento_Feito__r.Id }, "Id": itemPedido.Id, "OrderItemNumber": itemPedido.OrderItemNumber, "Descricao": itemPedido.Descricao_da_linha__c, "iDPedido": itemPedido.OrderId, "urlImagem": itemPedido.PricebookEntry.Product2.URL_da_Imagem__c, "nomeProduto": itemPedido.PricebookEntry.Product2.Name, "codigoFabricante": itemPedido.PricebookEntry.Product2.ProductCode, "marca": itemPedido.PricebookEntry.Product2.Marca__c };
                    }
                    itensPedidosPadronizados.push(itemPedidoPadronizado)
                });

                //console.log("itens pedidos padronizados", itensPedidosPadronizados)

                itensPedidosPadronizados = itensPedidosPadronizados.reduce(function (result, current) {
                    result[current.IdProduto] = result[current.IdProduto] || [];
                    result[current.IdProduto].push(current);
                    return result;
                }, {});


                helper.itensPedidosPadronizados = itensPedidosPadronizados
                helper.preenchePedidos(cmp, event, helper, 0);
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log('Erro detalhado:', error);

                // Mostrar mensagem específica baseada no tipo de erro
                var mensagem = 'Erro inesperado';

                if (error.message && error.message.includes('Invalid id')) {
                    mensagem = 'Erro: Nenhum fornecedor válido foi selecionado. Verifique se você selecionou pelo menos um fornecedor.';
                } else if (error.message) {
                    mensagem = error.message;
                }

            })

    },

    itensOppsPadronizados: [],

    auxiliarPreencheOpps: function (cmp, event, helper) {

        var itensOppsPadronizados = []

        //REALIZA A CONSULTA PARA OPPORTUNITYLINEITEM
        var query = "SELECT ID, name, Quantity, Opportunity.Numero_OP__c, Product2.StockKeepingUnit, Product2.ProductCode, PRODUCT2.NAME, PRODUCT2.MARCA__C, PRODUCT2.URL_DA_IMAGEM__C, PRODUCT2.MODELO__C, PRODUCT2.DESCRIPTION, PRODUCT2.TIPO_DO_PRODUTO__C, OPPORTUNITY.ACCOUNT.NAME, OPPORTUNITY.ACCOUNT.RAZ_O_SOCIAL__C, OPPORTUNITY.FATURAMENTO_FEITO2__C FROM OPPORTUNITYLINEITEM WHERE OPPORTUNITY.STAGENAME NOT IN ('WIN','LOSS') AND OPPORTUNITY.CLOSEDATE > TODAY";

        query += (helper.selectMarca != null && helper.selectMarca != 'NENHUM') ? " AND PRODUCT2.MARCA__C = '" + helper.selectMarca + "' " : '';
        query += (helper.selectModelo != null && helper.selectModelo != 'NENHUM') ? " AND PRODUCT2.MODELO__C = '" + helper.selectModelo + "' " : '';
        query += (helper.selectTipo != null && helper.selectTipo != 'NENHUM') ? " AND PRODUCT2.TIPO_DO_PRODUTO__C = '" + helper.selectTipo + "' " : '';

        // Adicionando o LIMIT
        query += " LIMIT 50";

        console.log("query preenche opps", query)

        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itensOpps) {
                //console.log("ITENS PEDIDO CONSULTA", itensPedidos)

                //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                $('#listaProdutos').click()
                //-----------------------------------------

                //console.log("ITENS OPPS", itensOpps)

                itensOpps.forEach(function (itemOpp) {
                    var itemOppPadronizado = {
                        "Id": itemOpp.Id,
                        "nomeProduto": itemOpp.Product2.Name,
                        "marca": itemOpp.Product2.Marca__c,
                        "modelo": itemOpp.Product2.Modelo__c,
                        "IdProduto": itemOpp.Product2.Id,
                        "codigoHospcom": itemOpp.Product2.StockKeepingUnit,
                        "nomeItem": itemOpp.Name,
                        "quantidade": itemOpp.Quantity,
                        "codigoFabricante": itemOpp.Product2.ProductCode,
                        "descricao": itemOpp.Product2.Description,
                        "tipoProduto": itemOpp.Product2.Tipo_do_Produto__c,
                        "urlImagem": itemOpp.Product2.URL_da_Imagem__c,
                        "pedido": {
                            "numeroOpp": itemOpp.Opportunity.Numero_OP__c,
                            "idOpp": itemOpp.Opportunity.Id,
                            "nomeDaConta": itemOpp.Opportunity.Account.Name,
                            "razaoSocialConta": itemOpp.Opportunity.Account.Raz_o_Social__c,
                            "faturamentoFeito": itemOpp.Opportunity.Faturamento_Feito2__c
                        }
                    };

                    itensOppsPadronizados.push(itemOppPadronizado);
                });

                //console.log("itens opps padronizados", itensOppsPadronizados)

                itensOppsPadronizados = itensOppsPadronizados.reduce(function (result, current) {
                    result[current.IdProduto] = result[current.IdProduto] || [];
                    result[current.IdProduto].push(current);
                    return result;
                }, {});

                //console.log("itens opps padronizados 2", itensOppsPadronizados)
                helper.itensOppsPadronizados = itensOppsPadronizados
                helper.preencheOpps(cmp, event, helper, 0);
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    //FUNCAO DE PADRONIZACAO DA CONSULTA E RESULTADO
    auxiliarPreenchePedidosConsumo: function (cmp, event, helper, operacao) {
        $("#buttonPlataformaMarketing").html("ITENS PARA CONSUMO");

        $("#buttonPesquiseProdutos").off();

        const idDaCotacaoDeCompra = cmp.get("v.recordId");

        var itensPedidosPadronizados = [];
        var query = `SELECT Produto__r.Name, ID, Name, Requisi_o_Interna_Relacionada__c, Requisi_o_Interna_Relacionada__r.Owner.Name, Requisi_o_Interna_Relacionada__r.Name, Quantidade__c, Status_do_Item__c, Descri_o_do_Item__c
                FROM Item_requerido__c
                WHERE Requisi_o_Interna_Relacionada__r.Status_da_Requisi_o__c IN ('Em cotação')
                    AND Requisi_o_Interna_Relacionada__c
                    IN (Select Requisicao_Interna__c from Pedido_de_compra__c where id = '${idDaCotacaoDeCompra}')`;

        //REALIZA A CONSULTA PARA
        //var query = "SELECT Produto__r.Name,  ID, Name, Requisi_o_Interna_Relacionada__r.Owner.name, Requisi_o_Interna_Relacionada__r.Name, Quantidade__c, Status_do_Item__c, Descri_o_do_Item__c FROM Item_requerido__c WHERE Requisi_o_Interna_Relacionada__r.Status_da_Requisi_o__c IN ('Em cotação')";



        //query += (helper.selectMarca != null && helper.selectMarca != 'NENHUM') ? " AND PriceBookEntry.Product2.Marca__c = '" + helper.selectMarca + "' " : '';
        //query += (helper.selectTipo != null && helper.selectTipo != 'NENHUM')? " AND PriceBookEntry.Product2.Tipo_do_Produto__c = '" + helper.selectTipo + "' " : '';
        //query += (helper.selectNPedido != null && helper.selectNPedido != 'NENHUM') ? " AND Order.OrderNumber = '" + helper.selectNPedido + "' " : '';

        this.soql(cmp, query)
            .then(function (itensPedidos) {
                console.log("itens pedido consumo", itensPedidos);

                $('#listaProdutos').click();

                itensPedidos.forEach(function (itemPedido) {
                    var nomeProduto = itemPedido.Produto__r && itemPedido.Produto__r.Name ? itemPedido.Produto__r.Name : '';
                    var nomeSolicitante = itemPedido.Requisi_o_Interna_Relacionada__r &&
                        itemPedido.Requisi_o_Interna_Relacionada__r.Owner &&
                        itemPedido.Requisi_o_Interna_Relacionada__r.Owner.Name
                        ? itemPedido.Requisi_o_Interna_Relacionada__r.Owner.Name : '';
                    var numeroRequisicao = itemPedido.Requisi_o_Interna_Relacionada__r &&
                        itemPedido.Requisi_o_Interna_Relacionada__r.Name
                        ? itemPedido.Requisi_o_Interna_Relacionada__r.Name : '';

                    var itemPedidoPadronizado = {
                        nomeProdutoVinculo: nomeProduto,
                        IdItem: itemPedido.Id,
                        NomeSolicitante: nomeSolicitante,
                        NomeItem: itemPedido.Name,
                        IdRequisicao: itemPedido.Requisi_o_Interna_Relacionada__c,
                        descricaoProduto: itemPedido.Descri_o_do_Item__c,
                        quantidade: itemPedido.Quantidade__c,
                        numeroRequisicao: numeroRequisicao
                    };

                    itensPedidosPadronizados.push(itemPedidoPadronizado);
                });

                //console.log("itens pedidos padronizados", itensPedidosPadronizados);

                helper.itensPedidosPadronizados = itensPedidosPadronizados;
                helper.preenchePedidos(cmp, event, helper, 1);
            })
            .catch(function (error) {
                console.error("Erro ao buscar itens para consumo:", error);
            });
    },

    //PREENCHE A COLUNA DA ESQUERDA COM OS PEDIDOS DE VENDA COM ITENS DISPONÍVEIS PARA COMPRA
    preencheOpps: function (cmp, event, helper, option) {

        var itensPedidosPadronizados = helper.itensOppsPadronizados

        $('#colunaDivOpps').empty()

        for (var key in itensPedidosPadronizados) {

            //console.log("KEY", key)
            //console.log("ITEM PADRONIZADO NA KEY", itensPedidosPadronizados[key])
            //console.log("ITEM PADRONIZADO NA KEY E 0", itensPedidosPadronizados[key][0])

            var quantidadeTotalAux = 0
            var nomeProduto = itensPedidosPadronizados[key][0].nomeProduto;
            var modeloProduto = itensPedidosPadronizados[key][0].modelo;
            var codigoFabricante = itensPedidosPadronizados[key][0].codigoFabricante;
            var codigoHospcom = itensPedidosPadronizados[key][0].codigoHospcom;
            var marca = itensPedidosPadronizados[key][0].marca;
            var urlImagem = itensPedidosPadronizados[key][0].urlImagem;
            var quantidadeFaltaRequisitar = itensPedidosPadronizados[key][0].quantidadeFaltaRequisitar;
            var idProduto = itensPedidosPadronizados[key][0].IdProduto;
            var urlProduto = 'https://hospcom.my.site.com/Sales/s/product2/' + idProduto + '';
            var tipoProduto = itensPedidosPadronizados[key][0].tipoProduto;
            var colorAuxItem = itensPedidosPadronizados[key][0].hasOwnProperty('RequisicaoProduto') ? "background-color:#C9C9C9!important" : ""
            var classAuxDisableDragable = itensPedidosPadronizados[key][0].hasOwnProperty('RequisicaoProduto') ? "disableDragable" : ""

            /*if ( $("#selectMarcaPv option[value='"+marca+"']").length == 0 ){
                $('#selectMarcaPv').append("<option value='"+marca+"'>"+marca+"</option>")
            }
            
            if ( $("#selectTipoPv option[value='"+tipoProduto+"']").length == 0 ){
                $('#selectTipoPv').append("<option value='"+tipoProduto+"'>"+tipoProduto+"</option>")
            } */

            //INSERE BLOCO DO PRODUTO
            var item = $('#colunaDivOpps').append("\
            <!-- APPEND DOS ITENS -->\
            <div class='containerMestreBlocos "+ classAuxDisableDragable + "' data-type='itemPedido' data-quantidade='" + quantidadeFaltaRequisitar + "' data-idProduto='" + idProduto + "' id='containerMestreBlocos' title='Clique para expandir'>\
            <div class='blocoItemPedidoVenda' style='z-index: 1; cursor: pointer; "+ colorAuxItem + "'>\
            <div class='row' style='height: 100%;'>\
            <!-- PRIMEIRA COLUNA COM IMAGEM E NOMES -->\
            <div class='col-md-6' style='display: flex; height: 100%;'>\
            <div class='containerImageItem'>\
            <a href='"+ urlProduto + "' title='Clique para abrir o produto' target='_blank' class='imageItemProd'>\
            <img class='imgItemPedido' style='height: 90%' src='"+ urlImagem + "'/>\
            </a>\
            </div>\
            <div class='containerDadosIniciaisItem'>\
            <div style='width: 100%; height: auto; font-size: 14px; color: #00345c; font-weight: bold;'>"+ nomeProduto + "</div>\
            <div style='width: 100%; height: auto; font-size: 12px; color: #A0BB31;'>"+ modeloProduto + "</div>\
            </div>\
            </div>\
            <!-- SEGUNDA COLUNA COM CODIGOS E CONTADOR -->\
            <div class='col-md-6' style='display: flex; height: 100%;'>\
            <div class='containerDetalhesItem'>\
            <div class='textoSecundario'>"+ marca + ": " + codigoFabricante + "</div>\
            <div class='textoSecundario'>HOSPCOM: "+ codigoHospcom + "</div>\
            </div>\
            <div class='containerQuantItens'>\
            <div class='contadorItens' id='contadorItem'>#</div>\
            </div>\
            </div>\
            </div>\
            </div>\
            <div class='blocoItemPedidoVenda blocoItemPedidoVendaExpand' style='background-color: #F5F6F8;' id='blocoItemPedidoVenda'>\
            </div>\
            </div>")

            var pedidosPadronizadosTemp = itensPedidosPadronizados[key];



            pedidosPadronizadosTemp.forEach(function (itemPedidoPadronizado) {

                //console.log("padronizado", itemPedidoPadronizado)

                quantidadeTotalAux = quantidadeTotalAux + parseInt(itemPedidoPadronizado.quantidade)

                var quantFaltaRequisitar = itemPedidoPadronizado.quantidade
                var linkPedido = "https://hospcom.my.site.com/Sales/s/order/" + itemPedidoPadronizado.pedido.idOpp + ""
                var numeroPedido = itemPedidoPadronizado.pedido.numeroOpp;
                var produtoDoPedido = itemPedidoPadronizado.Id;
                var numeroItem = itemPedidoPadronizado.nomeItem;
                var nomeDaConta = itemPedidoPadronizado.pedido.nomeDaConta.substring(0, 20);
                var descricaoProduto = itemPedidoPadronizado.Descricao == undefined ? "PRODUTO SEM DESCRIÇÃO" : String(itemPedidoPadronizado.Descricao).substring(0, 180);
                var empresa = itemPedidoPadronizado.pedido.contaCompradora;
                var urlLogoHospcom = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000BlZVy&oid=00Di0000000JVhH&lastMod=1666210877000'
                var urlLogoGDB = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbdf&oid=00Di0000000JVhH&lastMod=1666362135000'
                var urlLogoHealth = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbex&oid=00Di0000000JVhH&lastMod=1666363177000'
                var urlLogoABC = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbdu&oid=00Di0000000JVhH&lastMod=1666362299000'
                var imageEmpresa = empresa == 'HOSPCOM EQUIPAMENTOS HOSPITALARES EIRELI' ? urlLogoHospcom : (empresa == 'GDB COMERCIO E SERVICOS - EIRELI' ? urlLogoGDB : (empresa == 'HEALTH SOLUTIONS' ? urlLogoHealth : (empresa == 'ABC EQUIPAMENTOS HOSPITALARES LTDA' ? urlLogoABC : '')))
                var colorAuxItem = itemPedidoPadronizado.hasOwnProperty('RequisicaoProduto') ? "background-color: #C9C9C9!important" : ""
                var statusButtom = itemPedidoPadronizado.hasOwnProperty('RequisicaoProduto') ? "disabled" : ""
                var htmlPedidoDeCompraExistente = itemPedidoPadronizado.hasOwnProperty('RequisicaoProduto') ? "https://hospcom.my.site.com/Sales/s/fornecedor/" + itemPedidoPadronizado.RequisicaoProduto[0].Item_do_pedido_de_compra2__r.Fornecedor__r.Id : ""
                var aditionalHtml = itemPedidoPadronizado.hasOwnProperty('RequisicaoProduto') ? "<div class='textBlocoItens' style='width: 5%'><a href='" + htmlPedidoDeCompraExistente + "' target='_blank'><i class='fa fa-external-link' aria-hidden='true'></i></a></div>" : ""
                var quantidadeItemPV = itemPedidoPadronizado.quantidade;


                if ($("#selectNumeroPedidoPv option[value='" + numeroPedido + "']").length == 0) {
                    $('#selectNumeroPedidoPv').append("<option value='" + numeroPedido + "'>" + numeroPedido + "</option>")
                }

                //INSERE BLOCO DO PEDIDO DENTRO DO BLOCO DO PRODUTO
                $(".containerMestreBlocos:last").children("#blocoItemPedidoVenda").append("\
                <!-- BLOCO DO PEDIDO -->\
                <div class='blocoItemPedidoVenda blocoItemPedidoVendaFilho classeRastreio' data-quantidadePV='"+ quantidadeItemPV + "' data-falta-req='" + quantFaltaRequisitar + "' data-item-pv='" + numeroItem + "' data-type='pedidoItem' data-produtoDoPedido='" + produtoDoPedido + "' style='z-index: 1; margin-bottom: 10px; display: flex; padding: 10px; flex-direction: column; " + colorAuxItem + "''>\
                <div style='display: flex; width: 100%; height: 40%; gap: 10px'>"+ aditionalHtml + "\
                <div class='textBlocoItens'>Oportunidade: <a href='"+ linkPedido + "' target='_blank'><span style='font-weight: 400;'>" + numeroPedido + "</span></a></div>\
                <div class='textBlocoItens' style='width: 45%'>Nome da conta: <span style='font-weight: 400;'>"+ nomeDaConta + "</span></div>\
                </div>\
                <div style='display: flex; width: 100%; height: 30%' class='textoSecundario'>"+ descricaoProduto + "</div>\
                <button "+ statusButtom + " type='button' class='btn btn-success buttonInserirOpp'>Inserir no pedido de compra (" + quantFaltaRequisitar + " UNIDADES)</button>\
                </div>\
                <!-- FIM BLOCO DO PEDIDO -->");

            });


            //SETA A QUANTIDADE NA DIV CONTADORA------------------
            $(".contadorItens:last").html(quantidadeTotalAux)
            $(".containerMestreBlocos:last").attr("data-quantidade", quantidadeTotalAux)
            //data-quantidade='"+quantidadeFaltaRequisitar+"'
            //console.log(quantidadeTotalAux)
            //----------------------------------------------------

            //OCULTA SPINNER DE CARREGAMENTO---
            helper.hideSpinner(cmp);
            //---------------------------------

        };

        //FUNÇÕES ADICIONAIS APÓS CARREGAR OS ITENS DE PEDIDO DE VENDA
        //helper.exibeModalFornecedores(cmp, event, helper);
        helper.eventsAfterAddItemOpp(cmp, event, helper);
        helper.ativaDragAndDropItensOpp(cmp, event, helper);

    },

    //PREENCHE A COLUNA DA ESQUERDA COM OS PEDIDOS DE VENDA COM ITENS DISPONÍVEIS PARA COMPRA
    preenchePedidos: function (cmp, event, helper, option) {

        var itensPedidosPadronizados = helper.itensPedidosPadronizados
        $('#colunaPlataformaMkt').empty()

        for (var key in itensPedidosPadronizados) {

            //O OPTION CONTROLA A INSERSAO POR TIPO DE PRODUTO, 
            //SE TIPO 0 == COMPRA PRA REVENDA, 
            //SE TIPO 1 COMPRA PRA USO E CONSUMO
            if (option == 0) {
                var quantidadeTotalAux = 0
                var nomeProduto = itensPedidosPadronizados[key][0].nomeProduto;
                var modeloProduto = itensPedidosPadronizados[key][0].modelo;
                var codigoFabricante = itensPedidosPadronizados[key][0].codigoFabricante;
                var codigoHospcom = itensPedidosPadronizados[key][0].codigoHospcom;
                var marca = itensPedidosPadronizados[key][0].marca;
                var urlImagem = itensPedidosPadronizados[key][0].urlImagem;
                var quantidadeFaltaRequisitar = itensPedidosPadronizados[key][0].quantidadeFaltaRequisitar;
                var idProduto = itensPedidosPadronizados[key][0].IdProduto;
                var urlProduto = 'https://hospcom.my.site.com/Sales/s/product2/' + idProduto + '';
                var tipoProduto = itensPedidosPadronizados[key][0].tipoProduto;
                var colorAuxItem = itensPedidosPadronizados[key][0].hasOwnProperty('RequisicaoProduto') ? "background-color:#C9C9C9!important" : ""
                var classAuxDisableDragable = itensPedidosPadronizados[key][0].hasOwnProperty('RequisicaoProduto') ? "disableDragable" : ""

                if ($("#selectMarcaPv option[value='" + marca + "']").length == 0) {
                    $('#selectMarcaPv').append("<option value='" + marca + "'>" + marca + "</option>")
                }

                if ($("#selectTipoPv option[value='" + tipoProduto + "']").length == 0) {
                    $('#selectTipoPv').append("<option value='" + tipoProduto + "'>" + tipoProduto + "</option>")
                }

                //INSERE BLOCO DO PRODUTO
                $('#colunaPlataformaMkt').append("\
                <!-- APPEND DOS ITENS -->\
                <div class='containerMestreBlocos "+ classAuxDisableDragable + "' data-type='itemPedido' data-quantidade='" + quantidadeFaltaRequisitar + "' data-idProduto='" + idProduto + "' id='containerMestreBlocos' title='Clique para expandir'>\
                <div class='blocoItemPedidoVenda' style='z-index: 1; cursor: pointer; "+ colorAuxItem + "'>\
                <div class='row' style='height: 100%;'>\
                <!-- PRIMEIRA COLUNA COM IMAGEM E NOMES -->\
                <div class='col-md-6' style='display: flex; height: 100%;'>\
                <div class='containerImageItem'>\
                <a href='"+ urlProduto + "' title='Clique para abrir o produto' target='_blank' class='imageItemProd'>\
                <img class='imgItemPedido' style='height: 90%' src='"+ urlImagem + "'/>\
                </a>\
                </div>\
                <div class='containerDadosIniciaisItem'>\
                    <div style='width: 100%; height: auto; font-size: 14px; color: #00345c; font-weight: bold;'>"+ nomeProduto + "</div>\
                    <div style='width: 100%; height: auto; font-size: 12px; color: #A0BB31;'>"+ modeloProduto + "</div>\
                </div>\
                </div>\
                <!-- SEGUNDA COLUNA COM CODIGOS E CONTADOR -->\
                <div class='col-md-6' style='display: flex; height: 100%;'>\
                <div class='containerDetalhesItem'>\
                <div class='textoSecundario'>"+ marca + ": " + codigoFabricante + "</div>\
                <div class='textoSecundario'>HOSPCOM: "+ codigoHospcom + "</div>\
                </div>\
                <div class='containerQuantItens'>\
                <div class='contadorItens' id='contadorItem'>#</div>\
                </div>\
                </div>\
                </div>\
                </div>\
                <div class='blocoItemPedidoVenda blocoItemPedidoVendaExpand' style='background-color: #F5F6F8;' id='blocoItemPedidoVenda'>\
                </div>\
                </div>")
                var pedidosPadronizadosTemp = itensPedidosPadronizados[key];

                pedidosPadronizadosTemp.forEach(function (itemPedidoPadronizado) {
                    //console.log("padronizado", itemPedidoPadronizado);

                    quantidadeTotalAux = quantidadeTotalAux + parseInt(itemPedidoPadronizado.quantidadeFaltaRequisitar);

                    // Variáveis básicas
                    var quantFaltaRequisitar = itemPedidoPadronizado.quantidadeFaltaRequisitar;
                    var linkPedido = "https://hospcom.my.site.com/Sales/s/order/" + itemPedidoPadronizado.pedido.iDPedido;
                    var numeroPedido = itemPedidoPadronizado.numeroPedido;
                    var produtoDoPedido = itemPedidoPadronizado.Id;
                    var numeroItem = itemPedidoPadronizado.OrderItemNumber;
                    var nomeDaConta = itemPedidoPadronizado.pedido.nomeDaConta.substring(0, 15);
                    var descricaoProduto = itemPedidoPadronizado.Descricao == undefined ? "PRODUTO SEM DESCRIÇÃO" : String(itemPedidoPadronizado.Descricao).substring(0, 180);
                    var empresa = itemPedidoPadronizado.pedido.contaCompradora;

                    // URLs das logos
                    var urlLogoHospcom = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000BlZVy&oid=00Di0000000JVhH&lastMod=1666210877000';
                    var urlLogoGDB = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbdf&oid=00Di0000000JVhH&lastMod=1666362135000';
                    var urlLogoHealth = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbex&oid=00Di0000000JVhH&lastMod=1666363177000';
                    var urlLogoABC = 'https://hospcom--c.na170.content.force.com/servlet/servlet.ImageServer?id=0156e00000Blbdu&oid=00Di0000000JVhH&lastMod=1666362299000';

                    var imageEmpresa = empresa == 'HOSPCOM EQUIPAMENTOS HOSPITALARES EIRELI' ? urlLogoHospcom :
                        (empresa == 'GDB COMERCIO E SERVICOS - EIRELI' ? urlLogoGDB :
                            (empresa == 'HEALTH SOLUTIONS' ? urlLogoHealth :
                                (empresa == 'ABC EQUIPAMENTOS HOSPITALARES LTDA' ? urlLogoABC : '')));

                    // Verificações seguras para RequisicaoProduto
                    var hasRequisicao = itemPedidoPadronizado.hasOwnProperty('RequisicaoProduto') &&
                        Array.isArray(itemPedidoPadronizado.RequisicaoProduto) &&
                        itemPedidoPadronizado.RequisicaoProduto.length > 0;

                    var colorAuxItem = hasRequisicao ? "background-color: #C9C9C9!important" : "";
                    var statusButtom = hasRequisicao ? "disabled" : "";

                    // Verificação segura para o link do fornecedor
                    var htmlPedidoDeCompraExistente = "";
                    var aditionalHtml = "";

                    if (hasRequisicao) {
                        try {
                            var requisicao = itemPedidoPadronizado.RequisicaoProduto[0];
                            if (requisicao &&
                                requisicao.Item_do_pedido_de_compra2__r &&
                                requisicao.Item_do_pedido_de_compra2__r.Fornecedor__r &&
                                requisicao.Item_do_pedido_de_compra2__r.Fornecedor__r.Id) {

                                htmlPedidoDeCompraExistente = "https://hospcom.my.site.com/Sales/s/fornecedor/" +
                                    requisicao.Item_do_pedido_de_compra2__r.Fornecedor__r.Id;

                                aditionalHtml = "<div class='textBlocoItens' style='width: 5%'><a href='" +
                                    htmlPedidoDeCompraExistente + "' target='_blank'><i class='fa fa-external-link' aria-hidden='true'></i></a></div>";
                            }
                        } catch (error) {
                            console.log("Erro ao processar link do fornecedor:", error);
                            aditionalHtml = "";
                        }
                    }

                    var quantidadeItemPV = itemPedidoPadronizado.Quantidade;

                    if ($("#selectNumeroPedidoPv option[value='" + numeroPedido + "']").length == 0) {
                        $('#selectNumeroPedidoPv').append("<option value='" + numeroPedido + "'>" + numeroPedido + "</option>")
                    }

                    //INSERE BLOCO DO PEDIDO DENTRO DO BLOCO DO PRODUTO
                    $(".containerMestreBlocos:last").children("#blocoItemPedidoVenda").append("\
                    <!-- BLOCO DO PEDIDO -->\
                    <div class='blocoItemPedidoVenda blocoItemPedidoVendaFilho classeRastreio' data-quantidadePV='"+ quantidadeItemPV + "' data-falta-req='" + quantFaltaRequisitar + "' data-item-pv='" + numeroItem + "' data-type='pedidoItem' data-produtoDoPedido='" + produtoDoPedido + "' style='z-index: 1; margin-bottom: 10px; display: flex; padding: 10px; flex-direction: column; " + colorAuxItem + "''>\
                    <div style='display: flex; width: 100%; height: 40%'>"+ aditionalHtml + "\
                    <div class='textBlocoItens'>Pedido: <a href='"+ linkPedido + "' target='_blank'><span style='font-weight: 400;'>" + numeroPedido + "</span></a></div>\
                    <div class='textBlocoItens'>Item: <span style='font-weight: 400;'>"+ numeroItem + "</span></div>\
                    <div class='textBlocoItens' style='width: 45%'>Nome da conta: <span style='font-weight: 400;'>"+ nomeDaConta + "</span></div>\
                    <div class='textBlocoItens' style='width: 15%; display: flex; flex-direction: column'>\
                    <img class='imageEmpresa' src='"+ imageEmpresa + "'/>\
                    </div>\
                    </div>\
                    <div style='display: flex; width: 100%; height: 30%' class='textoSecundario'>"+ descricaoProduto + "</div>\
                    <button "+ statusButtom + " type='button' class='btn btn-success buttonInserirPv'>Inserir no pedido de compra (" + quantFaltaRequisitar + " UNIDADES)</button>\
                    </div>\
                    <!-- FIM BLOCO DO PEDIDO -->");

                });

            } else {
                var quantidadeTotalAux = itensPedidosPadronizados[key].quantidade
                var nomeProduto = itensPedidosPadronizados[key].nomeProdutoVinculo ? itensPedidosPadronizados[key].nomeProdutoVinculo : itensPedidosPadronizados[key].nomeProduto;
                var modeloProduto = '';
                var codigoFabricante = '';
                var nomeSolicitante = itensPedidosPadronizados[key].NomeSolicitante;
                var marca = '';
                var urlProduto = ''; //'https://hospcomhospitalar.force.com/Sales/s/product2/01t6e000009aJhr';
                var urlImagem = '';
                var quantidadeFaltaRequisitar = itensPedidosPadronizados[key].quantidade;
                var idProduto = itensPedidosPadronizados[key].IdItem;
                var tipoProduto = 'Item para consumo';
                var descricaoItem = itensPedidosPadronizados[key].descricaoProduto
                var descricaoLimpa = descricaoItem.replace(/<\/?[^>]+(>|$)/g, "");


                if ($("#selectMarcaPv option[value='" + marca + "']").length == 0) {
                    $('#selectMarcaPv').append("<option value='" + marca + "'>" + marca + "</option>")
                }

                if ($("#selectTipoPv option[value='" + tipoProduto + "']").length == 0) {
                    $('#selectTipoPv').append("<option value='" + tipoProduto + "'>" + tipoProduto + "</option>")
                }

                //INSERE BLOCO DO PRODUTO
                $('#colunaPlataformaMkt').append("\
                <!-- APPEND DOS ITENS -->\
                <div class='containerMestreBlocos' data-nomeItemRequerido='"+ nomeProduto + "' data-descricao='" + descricaoItem + "' data-type='itemPedidoConsumo' data-quantidade='" + quantidadeFaltaRequisitar + "' data-idProduto='" + idProduto + "' id='containerMestreBlocos' title='Clique para expandir'>\
                <div class='blocoItemPedidoVenda' style='z-index: 1; cursor: pointer'>\
                <div class='row' style='height: 100%;'>\
                <!-- PRIMEIRA COLUNA COM IMAGEM E NOMES -->\
                <div class='col-md-6' style='display: flex; height: 100%;'>\
                <div class='containerImageItem'>\
                <a href='"+ urlProduto + "' title='Clique para abrir o produto' target='_blank' class='imageItemProd'>\
                <img class='imgItemPedido' style='height: 90%' src='https://hospcom.file.force.com/servlet/servlet.ImageServer?id=0156e00000CIN6e&oid=00Di0000000JVhH&lastMod=1685122533000'/>\
                </a>\
                </div>\
                <div class='containerDadosIniciaisItem'>\
                <div style='width: 100%; height: auto; font-size: 14px; color: #00345c; font-weight: bold;'>"+ nomeProduto + "</div>\
                <div style='width: 100%; height: auto; font-size: 12px; color: #A0BB31;'>"+ modeloProduto + "</div>\
                </div>\
                </div>\
                <!-- SEGUNDA COLUNA COM CODIGOS E CONTADOR -->\
                <div class='col-md-6' style='display: flex; height: 100%;'>\
                <div class='containerDetalhesItem'>\
                <div class='textoSecundario'></div>\
                <div class='textoSecundario'>Solicitante: "+ nomeSolicitante + "</div>\
                </div>\
                <div class='containerQuantItens'>\
                <div class='contadorItens' id='contadorItem'>#</div>\
                </div>\
                </div>\
                </div>\
                </div>\
                <div class='blocoItemPedidoVenda blocoItemPedidoVendaExpand' style='background-color: #F5F6F8;' id='blocoItemPedidoVenda'>"+ descricaoLimpa + "\
                </div>\
                </div>")
                var pedidosPadronizadosTemp = itensPedidosPadronizados[key];
            }

            //SETA A QUANTIDADE NA DIV CONTADORA------------------
            $(".contadorItens:last").html(quantidadeTotalAux)
            $(".containerMestreBlocos:last").attr("data-quantidade", quantidadeTotalAux);

            //OCULTA SPINNER DE CARREGAMENTO---
            helper.hideSpinner(cmp);
            //---------------------------------

        };

        //FUNÇÕES ADICIONAIS APÓS CARREGAR OS ITENS DE PEDIDO DE VENDA
        helper.exibeModalFornecedores(cmp, event, helper);
        helper.eventsAfterAddItemPedidoVenda(cmp, event, helper);
        helper.ativaDragAndDropItensPV(cmp, event, helper);

    },

    //VERIFICA SE NÃO EXISTE NENHUM PEDIDO DE COMPRA JÁ CRIADO, ENTÃO EXIBE O MODAL DE FORNECEDORES
    exibeModalFornecedores: function (cmp, event, helper) {

        var recordId = helper.retornaRecorId(cmp, event, helper)
        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT ID, Comprador__c FROM Fornecedor__c WHERE Pedido_de_compra__c = '" + recordId + "'")

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (pedidos) {
                if (pedidos.length == 0) {
                    helper.preencheModalFornecedores(cmp, event, helper);
                    $('#containerFornecedores').css({ "display": "flex" });
                } else {
                    helper.empresaCompradora = pedidos[0].Comprador__c
                    helper.pedidoDeCompraClone = pedidos[0].Id
                    //console.log("EXISTE PEDIDOS DE COMPRA", pedidos)
                    helper.getPedidosDeCompra(cmp, event, helper); //POPULA O ARRAY COM OS IDS DO PEDIDO DE VENDA
                    $('#containerFornecedores').css({ "display": "none" });
                }
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    //VERIFICA SE NÃO EXISTE NENHUM PEDIDO DE COMPRA JÁ CRIADO, ENTÃO EXIBE O MODAL DE FORNECEDORES
    getPedidosDeCompra: function (cmp, event, helper) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var recordId = helper.retornaRecorId(cmp, event, helper)

        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT Id FROM Fornecedor__c WHERE Pedido_de_compra__c = '" + recordId + "'")

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (pedidos) {
                helper.iDsPedidoDeCompra = []

                pedidos.forEach(function (pedido) {
                    helper.iDsPedidoDeCompra.push(pedido.Id)
                });

                //OCULTA SPINNER DE CARREGAMENTO---
                helper.hideSpinner(cmp);
                //---------------------------------
            })

            //trata excessão de erro
            .catch(function (error) {
                return error
                console.log(error)
            })
    },

    buscaFornecedores: function (cmp, event, helper, termo, inputElement) {

        var queryFornecedor = "SELECT id, type, name, CNPJ__c from account WHERE (Name LIKE '%" + termo + "%' OR CNPJ__c LIKE '%" + termo + "%') AND type = 'fornecedor' ORDER BY Name LIMIT 10"

        //REALIZA A CONSULTA
        this.soql(cmp, queryFornecedor)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (fornecedores) {

                $(inputElement).parent().find('.resultados4239584')
                    .css("display", "flex")
                    .on('click', function (event) {
                        event.stopPropagation(); // impede fechar ao clicar nos resultados
                    });


                $(inputElement).parent().find('.resultados4239584').empty()

                fornecedores.forEach((element) => {

                    var nomeConta = element.Name.length > 20 ? element.Name.substring(0, 20) + "..." : element.Name;
                    var cnpj = element.CNPJ__c
                    var id = element.Id

                    var html = "<p class='item48359345' data-id='" + id + "' data-name='" + nomeConta + "'>\
                        <strong>Forn.:&nbsp;</strong>"+ nomeConta + "&nbsp;|&nbsp;\
                        <strong>CNPJ:&nbsp;</strong>"+ cnpj + "\
                    </p>"

                    $(inputElement).parent().find('.resultados4239584').append(html)
                });

                $(".item48359345").off().on("click", function () {
                    var id = $(this).attr("data-id")
                    var nomeConta = $(this).attr("data-name")
                    var recordId = cmp.get("v.recordId");

                    console.log("CLIQUE ADD", id, nomeConta)

                    $(this).parents('.box3724832942').find('.inputFornecedor492305').val(nomeConta)
                    $(this).parents('.resultados4239584').css("display", "none")

                    if (!helper.iDsContas.includes(id)) {
                        helper.iDsContas.push(id);
                    }

                    console.log(helper.iDsContas)
                });
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    //PREENCHE OS SELECT OPTIONS DO MODAL DE FORNECEDORES
    preencheModalFornecedores: function (cmp, event, helper) {

        let typingTimer;
        let doneTypingInterval = 500; // Tempo em milissegundos (0.5s)

        $(document).on("keyup", ".inputFornecedor492305", function () {
            clearTimeout(typingTimer);
            let inputElement = $(this);

            typingTimer = setTimeout(function () {
                //console.log("Usuário parou de digitar: " + inputElement.val());
                helper.alertaErro(cmp, event, helper, "Pesquisando Fornecedores", "Aguarde", "Info", "", "dismissible");
                helper.buscaFornecedores(cmp, event, helper, inputElement.val(), inputElement);
            }, doneTypingInterval);
        });

        // Esconde todos quando clicar em qualquer lugar da página
        document.addEventListener('click', function () {
            $('.resultados4239584').css('display', 'none');
        });

        //EVENTO DO BOTAO ADICIONAR FORNECEDOR-----------------
        $("#addFornecedor").off().on("click", function () {
            helper.showSpinner(cmp);
            helper.insereDivNewFornecedor(cmp, event, helper);
        });

        //EVENTO DO BOTAO CONTINUAR--------------------------
        $("#buttonContinuar").off().on("click", function () {
            helper.validaFornecedores(cmp, event, helper);
        });

    },

    insereDivNewFornecedor: function (cmp, event, helper) {

        var html = "<div class='div3232Fornecedor'>\
        <div class='containerImageItem'>\
        <a href='javascript:void(0)' target='_blank' class='imageItemProd'>\
        <img class='imgItemPedido' style='height: 90%' src='https://hospcom.my.site.com/servlet/servlet.ImageServer?id=0156e00000Blc34&amp;oid=00Di0000000JVhH&amp;lastMod=1666381080000'/>\
        </a>\
        </div>\
        <div class='box3724832942'>\
        <input class='inputFornecedor492305 custominput453453534' placeholder='Digite um nome ou cnpj de um fornecedor' type='text'>\
        <div class='resultados4239584'>\
        </div>\
        </div>\
        </div>";

        var itemAdicionado = $("#divSelectsFornecedores").append(html);
        helper.hideSpinner(cmp);
    },

    //VALIDA O PREENCHIMENTO DO MODAL DE FORNECEDORES
    validaFornecedores: function (cmp, event, helper) {
        var empresaCompradora = $('#empresaCompradora').val();
        var fornecedores = helper.iDsContas

        if (empresaCompradora == null) {
            helper.alertaErro(cmp, event, helper, "Você deve preencher a empresa compradora", "ERRO NAS INFORMAÇÕES PREENCHIDAS", "error", "Erro: ", "sticky");
        } else if (fornecedores.length == 0) {
            helper.alertaErro(cmp, event, helper, "Você deve preencher ao menos 1 fornecedor", "ERRO NAS INFORMAÇÕES PREENCHIDAS", "error", "Erro: ", "sticky");
        } else {
            helper.criaPedidos(cmp, event, helper, empresaCompradora, fornecedores.toString(), fornecedores.length);
        }
    },

    //CRIA OS PEDIDOS DE COMPRAS PARA OS FORNECEDORES PREENCHIDOS NO MODAL
    criaPedidos: function (cmp, event, helper, empresaCompradora, fornecedores, quantidadeFornecedores) {

        console.log("FORNECEDORES CRIA PEDIDOS", fornecedores)

        var recordId = helper.retornaRecorId(cmp, event, helper)
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        console.log(fornecedores)

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.inserirFornecedores");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idCotacao: recordId,
            idComprador: empresaCompradora,
            idsFornecedores: fornecedores,
        });
        //----------------------------------------------------

        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#listaProdutos').click()
        //-----------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                $('#containerFornecedores').css({ "display": "none" });
                helper.getPedidosDeCompra(cmp, event, helper); //POPULA O ARRAY COM OS IDS DO PEDIDO DE VENDA
                //OCULTA SPINNER DE CARREGAMENTO---
                helper.hideSpinner(cmp);
                //---------------------------------
                helper.alertaErro(cmp, event, helper, quantidadeFornecedores + " pedido(s) foram criados, 1 para cada fornecedor informado.", "TUDO OK!", "success", "", "dismissable")
                location.reload();
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ATUALIZAÇÃO DO ITEM", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CRIAR OS PEDIDOS DE COMPRAS", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A CRIAÇÃO DOS PEDIDOS DE COMPRA", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },

    //FUNÇÃO QUE ATIVA O DRAG AND DROP NA COLUNA DA ESQUERDA
    ativaDragAndDropItensPV: function (cmp, event, helper) {
        //CONFIGURAÇÕES DA COLUNA DROP "ESQUERDA"------------------------------------------
        var el = document.getElementById('colunaPlataformaMkt');
        //INSTANCIA O OBJETO SORTABLE, DO PLUGIN DE DRAG AND DROP
        Sortable.create(el, {
            sort: false,
            //DEFINIÇÕES DO GRUPO DE ARRASTA E SOLTA
            group: {
                name: 'shared', //DEFINE O NOME DO GRUPO DE COMPARTILHAMENTO ENTRE ITENS
            },
            onUpdate: function (evt) {
                //ATUALIZA O NUMBERITEM DE TODOS OS ITENS JÁ ADICIONADOS----------------------------------
                //helper.atualizaListaItens(cmp, evt.item, helper)
                //----------------------------------------------------------------------------------------
            },
            // A FUNÇÃO ABAIXO É EXECUTADA QUANDO UM ITEM É ADICIONADO A DIV DA COLUNA DEFINIDA EM "EL"
            onAdd: function (evt) {
                helper.adicionaItemPedidoVenda(cmp, event, helper, evt.item) //CHAMA FUNÇÃO QUE ADICIONA UM ITEM NA COTAÇÃO, PASSANDO O ITEM A SER ADICIONADO
            },
            animation: 150, //DEFINE O TEMPO DE ANIMAÇÃO AO ARRASTAR UM ITEM
            scroll: true, //HABILITA O PLUGIN DE SCROLL
            forceAutoscrollFallback: true, //FORÇA O PLUGIN DE SCROOL
            scrollSensitivity: 100, //DEFINE A SENSIBILIDADE DO SCROLL DA LISTA AO ARRASTAR UM ITEM
            forceFallback: true,	//FORÇA O USO DO PLUGIN, SOBRESCREVENDO O MÉTODO NATIVO DE DRAG AND DROP
            filter: '.disableDragable'
        });
        //------------------------------------------------------
    },
    //----------------------------------------------------------

    //FUNÇÃO QUE ATIVA O DRAG AND DROP NA COLUNA DA ESQUERDA
    ativaDragAndDropItensOpp: function (cmp, event, helper) {
        //CONFIGURAÇÕES DA COLUNA DROP "ESQUERDA"------------------------------------------
        var el = document.getElementById('colunaDivOpps');
        //INSTANCIA O OBJETO SORTABLE, DO PLUGIN DE DRAG AND DROP
        Sortable.create(el, {
            sort: false,
            //DEFINIÇÕES DO GRUPO DE ARRASTA E SOLTA
            group: {
                name: 'shared', //DEFINE O NOME DO GRUPO DE COMPARTILHAMENTO ENTRE ITENS
            },
            onUpdate: function (evt) {
                //ATUALIZA O NUMBERITEM DE TODOS OS ITENS JÁ ADICIONADOS----------------------------------
                //helper.atualizaListaItens(cmp, evt.item, helper)
                //----------------------------------------------------------------------------------------
            },
            // A FUNÇÃO ABAIXO É EXECUTADA QUANDO UM ITEM É ADICIONADO A DIV DA COLUNA DEFINIDA EM "EL"
            onAdd: function (evt) {
                //helper.adicionaItemPedidoVenda(cmp, event, helper, evt.item) //CHAMA FUNÇÃO QUE ADICIONA UM ITEM NA COTAÇÃO, PASSANDO O ITEM A SER ADICIONADO
            },
            animation: 150, //DEFINE O TEMPO DE ANIMAÇÃO AO ARRASTAR UM ITEM
            scroll: true, //HABILITA O PLUGIN DE SCROLL
            forceAutoscrollFallback: true, //FORÇA O PLUGIN DE SCROOL
            scrollSensitivity: 100, //DEFINE A SENSIBILIDADE DO SCROLL DA LISTA AO ARRASTAR UM ITEM
            forceFallback: true,	//FORÇA O USO DO PLUGIN, SOBRESCREVENDO O MÉTODO NATIVO DE DRAG AND DROP
            filter: '.disableDragable'
        });
        //------------------------------------------------------
    },
    //----------------------------------------------------------

    //EVENTOS EXECUTADOS APÓS A ADIÇÃO DOS ITENS EM PEDIDOS DE VENDAS---
    eventsAfterAddItemPedidoVenda: function (cmp, event, helper) {

        //helper.eventsAfterModalFornecedores(cmp, event, helper);

        //EVENTO PARA ABERTURA OU FECHAMENTO DO DROPDOWN COM PEDIDOS
        $('.containerMestreBlocos').on('click', function () {
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

        $('.buttonInserirPv').on('click', function () {
            var elemento = $(this).parents('#containerMestreBlocos')
            var iDProdutoPedido = $(this).parents('.blocoItemPedidoVendaFilho').attr('data-produtoDoPedido')

            $(elemento).attr('data-type', 'pedidoItem');
            $(elemento).attr('data-idPvClicado', iDProdutoPedido);

            helper.adicionaItemCotacao(cmp, event, helper, elemento, this)
            //helper.openClosePedidos(cmp, event, helper, elemento);
        });
    },

    clicadoOpp: false,

    eventsAfterAddItemOpp: function (cmp, event, helper) {

        //EVENTO PARA ABERTURA OU FECHAMENTO DO DROPDOWN COM PEDIDOS
        $('.containerMestreBlocos').off().on('click', function () {
            helper.openClosePedidos(cmp, event, helper, this);
        });

        $('.buttonInserirOpp').on('click', function () {
            var elemento = $(this).parents('#containerMestreBlocos')
            var iDProdutoPedido = $(this).parents('.blocoItemPedidoVendaFilho').attr('data-produtoDoPedido')

            $(elemento).attr('data-type', 'pedidoItem');
            $(elemento).attr('data-idPvClicado', iDProdutoPedido);

            helper.adicionaItemOppCotacao(cmp, event, helper, elemento, this)
            //helper.openClosePedidos(cmp, event, helper, elemento);
        });
    },

    //ABRE OU FECHA O DROPDOWN COM OS PEDIDOS RELACIONADOS A UM PRODUTO----
    openClosePedidos: function (cmp, event, helper, elemento) {
        var tamanhoAberto = '220px';
        var tamanhoFechado = '90px';
        var tamanhoMarginAberto = '150px';
        var tamanhoMarginFechado = '10px';
        var tamanhoAtual = $(elemento).children('#blocoItemPedidoVenda').css('height');
        var tamanhoSetado = tamanhoAtual == tamanhoAberto ? tamanhoFechado : tamanhoAberto;
        var tamanhoMargin = tamanhoAtual == tamanhoAberto ? tamanhoMarginFechado : tamanhoMarginAberto;
        $(elemento).children('#blocoItemPedidoVenda').css("height", tamanhoSetado);
        $(elemento).css("padding-bottom", tamanhoMargin);
    },
    //---------------------------------------------------------------------

    //FUNÇÃO QUE RETORNA O ULTIMO ITEM DO INDICE DE PRODUTOS NA COTAÇÃO-
    retornaIndiceUltimoItem: function (cmp, event, helper) {

        var indices = []

        if ($('#listaCotacao').children().length === 1) {
            console.log("vazio")
            indices.push(1)
        } else {
            //PERCORRE O DOM DE ITENS PAIS INSERIDOS---------------------------------------------
            $('#listaCotacao').children().each(function () {
                var aux = $(this).attr('data-item-c')
                if (aux != undefined) {
                    indices.push(parseInt(aux) + 1)
                }
            });
        }

        console.log(Object.values(indices))

        var ultimoIndice = Math.max.apply(null, indices)

        return ultimoIndice//$('#listaCotacao').children().length //ultimoIndice 
    },
    //------------------------------------------------------------------

    //CHAMA FUNÇÃO DO APEX QUE ADICIONA UM ITEM NA COTAÇÃO--
    adicionaItemOppCotacao: function (cmp, event, helper, item, itemclicado) {

        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var tipoDoItem = $(item).attr('data-type');
        var recordId = helper.retornaRecorId(cmp, event, helper)
        var iDsPedidosDeCompra = helper.iDsPedidoDeCompra.toString();
        var idProduto = $(item).attr('data-idproduto');

        console.log("ADICIONA ITEM OPP")

        if (tipoDoItem == 'itemPedido') {
            var quantidadeRequisitada = $(item).attr('data-quantidade');
            var tempIdsPedidosVenda = [];
            var iDsPedidosVenda = '';

            $(item).find(".blocoItemPedidoVendaFilho").each(function () {
                tempIdsPedidosVenda.push($(this).attr('data-produtoDoPedido') + "-" + $(this).attr('data-quantidadepv'))
            });
            iDsPedidosVenda = tempIdsPedidosVenda.toString()

        } else if (tipoDoItem == 'pedidoItem') {
            var iDsPedidosVenda = $(item).attr('data-idPvClicado');
            var quantidadeRequisitada = $(itemclicado).parents('.blocoItemPedidoVendaFilho').attr('data-falta-req');
            $(item).attr('data-type', 'itemPedido');
        } else {
            var quantidadeRequisitada = 1;
            var iDsPedidosVenda = '';
        }


        console.log("ITEM ADICIONADO OPP: ")
        console.log("recordId", recordId)
        console.log("idProduto", idProduto)
        console.log("iDsPedidosVenda", iDsPedidosVenda)
        console.log("iDsPedidosDeCompra", iDsPedidosDeCompra)
        console.log("quantidadeRequisitada", quantidadeRequisitada)
        console.log("=======================")

        //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.inserirProdutosOpp");

        //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
        action.setParams({
            idCotacao: recordId,
            produto: idProduto,
            itensOPP: iDsPedidosVenda,
            idsPedidos: iDsPedidosDeCompra,
            quantidade: quantidadeRequisitada,
        });
        //----------------------------------------------------

        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#listaProdutos').click()
        //-----------------------------------------

        //CALLBACK DA REQUISIÇÃO---------------------------
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                helper.consultaCotacaoCompra(cmp, event, helper);
                helper.alertaErro(cmp, event, helper, " pedido(s) foram criados, 1 para cada fornecedor informado.", "TUDO OK!", "success", "", "dismissable")
            }
            else if (state === "INCOMPLETE") {
                helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ATUALIZAÇÃO DO ITEM", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
            } else if (state === "ERROR") {
                console.log("ERROR")
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CRIAR OS PEDIDOS DE COMPRAS", "error", "Erro: ", "sticky")
                    reject(errors[0].message);
                } else {
                    helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A CRIAÇÃO DOS PEDIDOS DE COMPRA", "error", "Erro: ", "sticky")
                    reject("Erro desconhecido");
                }
            }
        });

        $A.enqueueAction(action);
    },
    //-----------------------------------------------------

    //CHAMA FUNÇÃO DO APEX QUE ADICIONA UM ITEM NA COTAÇÃO--
    adicionaItemCotacao: function (cmp, event, helper, item, itemclicado) {


        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var tipoDoItem = $(item).attr('data-type');
        var recordId = helper.retornaRecorId(cmp, event, helper)
        var iDsPedidosDeCompra = helper.iDsPedidoDeCompra.toString();
        var idProduto = $(item).attr('data-idproduto');


        if (tipoDoItem == 'itemPedidoConsumo') {
            console.log("ENTROU ITEM PEDIDO CONSUMO")


            var descricaoTemp = $(item).attr('data-descricao')


            var descricaoItemRequerido = $(item).attr('data-nomeitemrequerido') + " - " + $(descricaoTemp).text();

            if (descricaoItemRequerido.length > 255) {
                descricaoItemRequerido = descricaoItemRequerido.substring(0, 252) + "...";
            }


            var quantidadeRequisicao = $(item).attr('data-quantidade');

            var contentLog = "=====ITEM ADICIONADO NA COTAÇÃO DE CONSUMO =====\n" + "RECORD ID: " + recordId + "\nID DO PRODUTO: " + idProduto + "\n IDS PEDIDOS DE COMPRA: " + iDsPedidosDeCompra + "\n  QUANTIDADE REQUISITADA: " + quantidadeRequisicao
            var pastaLog = "COMPRAS - LOGS"
            var dataLog = new Date();
            var tituloLog = dataLog + "ADICIONADO ITEM COTACAO DE CONSUMO: " + recordId

            //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
            var action = cmp.get("c.inserirRequisicoes");



            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                idCotacao: recordId,
                req: idProduto,
                descricao: descricaoItemRequerido,
                idsPedidos: iDsPedidosDeCompra,
                quantidade: quantidadeRequisicao,
            });
            //----------------------------------------------------

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#listaProdutos').click()
            helper.alertaErro(cmp, event, helper, "", "Carregando...", "info", "", "dismissable")

            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    helper.consultaCotacaoCompra(cmp, event, helper);
                    helper.criaLogs(cmp, event, helper, contentLog, tituloLog, 'txt', 'text/plain', pastaLog)
                    helper.alertaErro(cmp, event, helper, " pedido(s) foram criados, 1 para cada fornecedor informado.", "TUDO OK!", "success", "", "dismissable")
                }
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ATUALIZAÇÃO DO ITEM", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
                } else if (state === "ERROR") {
                    console.log("ERROR")
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CRIAR OS PEDIDOS DE COMPRAS", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A CRIAÇÃO DOS PEDIDOS DE COMPRA", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });

            $A.enqueueAction(action);
        } else {

            console.log("ENTROU ITEM PEDIDO REVENDA 435")

            if (tipoDoItem == 'itemPedido') {
                var quantidadeRequisitada = $(item).attr('data-quantidade');
                var tempIdsPedidosVenda = [];
                var iDsPedidosVenda = '';

                $(item).find(".blocoItemPedidoVendaFilho").each(function () {
                    tempIdsPedidosVenda.push($(this).attr('data-produtoDoPedido') + "-" + $(this).attr('data-quantidadepv'))
                });

                iDsPedidosVenda = tempIdsPedidosVenda.toString()

            } else if (tipoDoItem == 'pedidoItem') {
                let idPv = $(item).attr('data-idPvClicado');
                let quantidadePv = $(itemclicado).parents('.blocoItemPedidoVendaFilho').attr('data-falta-req');

                iDsPedidosVenda = idPv + "-" + quantidadePv;
                quantidadeRequisitada = quantidadePv;
                $(item).attr('data-type', 'itemPedido');
            } else {
                console.log("entrou else")
                var quantidadeRequisitada = 1;
                var iDsPedidosVenda = '';
            }


            var contentLog = "=====ITEM ADICIONADO NA COTAÇÃO =====\n" + "RECORD ID: " + recordId + "\nID DO PRODUTO: " + idProduto + "\n IDS ITENS PEDIDOS DE VENDA: " + iDsPedidosVenda + "\n IDS PEDIDOS DE COMPRA: " + iDsPedidosDeCompra + "\n  QUANTIDADE REQUISITADA: " + quantidadeRequisitada
            var pastaLog = "COMPRAS - LOGS"
            var dataLog = new Date();
            var tituloLog = dataLog + "ADICIONADO ITEM COTACAO: " + recordId


            console.log("ITEM ADICIONADO: ", tipoDoItem)
            console.log(recordId)
            console.log(idProduto)
            console.log(iDsPedidosVenda)
            console.log(iDsPedidosDeCompra)
            console.log(quantidadeRequisitada)
            console.log("=======================")

            //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
            var action = cmp.get("c.inserirProdutos");

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#listaProdutos').click()
            //-----------------------------------------

            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                idCotacao: recordId,
                produto: idProduto,
                itensPV: iDsPedidosVenda,
                idsPedidos: iDsPedidosDeCompra,
                quantidade: quantidadeRequisitada,
            });
            //----------------------------------------------------

            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            $('#listaProdutos').click()
            helper.alertaErro(cmp, event, helper, "", "Carregando...", "info", "", "dismissable")

            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    helper.consultaCotacaoCompra(cmp, event, helper);
                    helper.criaLogs(cmp, event, helper, contentLog, tituloLog, 'txt', 'text/plain', pastaLog)
                    helper.alertaErro(cmp, event, helper, " pedido(s) foram criados, 1 para cada fornecedor informado.", "TUDO OK!", "success", "", "dismissable")
                }
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ATUALIZAÇÃO DO ITEM", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
                } else if (state === "ERROR") {
                    console.log("ERROR")
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO CRIAR OS PEDIDOS DE COMPRAS", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A CRIAÇÃO DOS PEDIDOS DE COMPRA", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });

            $A.enqueueAction(action);
        }



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

                if (helper.clicadoOpp) {
                    helper.adicionaItemOppCotacao(cmp, event, helper, evt.item) //CHAMA FUNÇÃO QUE ADICIONA UM ITEM NA COTAÇÃO, PASSANDO O ITEM A SER ADICIONADO
                } else {
                    helper.adicionaItemCotacao(cmp, event, helper, evt.item) //CHAMA FUNÇÃO QUE ADICIONA UM ITEM NA COTAÇÃO, PASSANDO O ITEM A SER ADICIONADO
                }
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