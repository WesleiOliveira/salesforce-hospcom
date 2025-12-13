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
    //------------------------------------------

    inputPesquisa: "null",
	tipoOpp: "",
    ultimoTipoSelecionado : "",
    
    isEmpty: function (cmp, str) {
        return !str.trim().length;
    },

    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecorId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        //var recordId = '0Q06e000002r2vKCAQ'
        return recordId
    },
    //---------------------------------------------------

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

        console.log("events after append")	
        
        //EVENTO QUE FORMATA O TAMANHO DOS TEXTOS COM BASE NO TAMANHO DA DIV PAI
        //var divProdutosHeight = parseInt($(".divListaProdutosMaster").height()) + "px";
        //$("#listaProdutos").css('height', divProdutosHeight);
        //----------------------------------------------------------------------

        //EVENTO QUE FORMATA O TAMANHO DOS TEXTOS COM BASE NO TAMANHO DA DIV PAI
        var divCotacaoHeight = parseInt($(".divListaProdutosCotacao").height()) + "px";
        $("#listaCotacao").css('height', divCotacaoHeight);
        //----------------------------------------------------------------------

        //EVENTO QUE FORMATA O TAMANHO DOS TEXTOS COM BASE NO TAMANHO DA DIV PAI
        var divColunaScrollParent = parseInt($("#divColunaScrollParent").height() - 10) + "px";
        $("#colunaPlataformaMkt").css('height', divColunaScrollParent);
        //----------------------------------------------------------------------
        
        //EXPANDE DIV DESCRICAO
        $(document).off("click", ".textAreaDesc435453");
        $( ".textAreaDesc435453" ).on( "click", function() {
            $(this).css({ "height": "200px" });
            console.log("expande div")
        });
        
        //RECOLHE DIV DESCRICAO
        $(document).off("focusout", ".textAreaDesc435453");
        $( ".textAreaDesc435453" ).on( "focusout", function() {
            $(this).css({ "height": "20px" });
            console.log("recolhe div") 
        });
        
        //EXPANDE E RECOLHE A DIV COM OS PRODUTOS FILHOS--------------------
        $(document).off("click", ".exibirProdutosDiv32478237");
        $( ".exibirProdutosDiv32478237" ).on( "click", function() {
            console.log("exibirProdutosDiv32478237")	
            
            //Se o tamanho da div = 300, ou seja, já está expandida, então recolhe
            if ($(this).parents('#divProdutosFilhos').css('height') == '300px') {
                $(this).parents('#divProdutosFilhos').attr("style", $(this).parents('#divProdutosFilhos').attr("style") + 'height: 20px !important;');
                $(this).children('#exibirProdutosTextTag').text('Exibir produtos filhos'); //ok
                $(this).parents('#divProdutosFilhos').children('#produtosFilhosDrop').css({ "opacity": "0" })
            } else {
                //SE NÃO A DIV ESTÁ RECOLHIDA, LOGO EXPANDE
                $(this).parents('#divProdutosFilhos').attr("style", $(this).parents('#divProdutosFilhos').attr("style") + 'height: 300px !important;');
                $(this).children('#exibirProdutosTextTag').text('Ocultar produtos filhos');
                $(this).parents('#divProdutosFilhos').children('#produtosFilhosDrop').css({ "opacity": "1" })
            }
        })
        //------------------------------------------------------------------ 
        
        //EXPANDE E RECOLHE O MENU DE OPÇÕES DO ITEM------------------------
        $(document).off("click", ".dropItemOptions3243");
        $( ".dropItemOptions3243" ).on( "click", function() {
            console.log("clicado")
            if ($(this).parent().find("#menuOptionsId").css('display') == 'none') {
                $(this).parent().find("#menuOptionsId").css({ "display": "flex" });
            } else {
                $(this).parent().find("#menuOptionsId").css({ "display": "none" });
            }
        })
        //------------------------------------------------------------------
        
        //RECOLHE O MENU CASO CLICK EM FECHAR-------------------------------
        $(document).off("click", ".optionCloseOptions");
        $( ".optionCloseOptions" ).on( "click", function() {
            $(this).parent().css({ "display": "none" });
        })
        //------------------------------------------------------------------
        
        //REMOVE ITEM DA OPP
        $(document).off("click", ".optionRemoveOptions");
        $( ".optionRemoveOptions" ).on( "click", function() {
            helper.removeItemCotacao(cmp, event, helper, this, 0)
        })
        
        //ATUALIZA OS DADOS DO ITEM------------------------------------------
        $(document).off("change", ".inputDetalhes32432");
        $( ".inputDetalhes32432" ).on( "change", function() {
            helper.atualizaItem(cmp, event, helper, this)
        })
        //------------------------------------------------------------------
        
        //EXIBE DETALHES DO ITEM--------------------------------------------
        $(document).off("click", ".optionShowDetails");
        $( ".optionShowDetails" ).on( "click", function() {
            var inputHtml = $(this).parents(".containerCotacao")
            helper.exibeDetalhesItem(cmp, helper, inputHtml)
        })
        //-----------------------------------------------------------------
        
        //EVENTOS DOS INPUTS---------------------------------------
        $("input").filter("#valorUnitario, #subtotal").mask('000.000.000.000.000,00', { reverse: true }); //DEFINE AS MASCARAS NOS INPUTS DE VALORES
        $("input").filter("#desconto").mask('##0,0%', { reverse: true }); //DEFINE AS MASCARAS NOS INPUTS DE DESCONTO
        $("input").filter("#quantidade").mask("#0", { reverse: true });
        
        $("input, textarea").unbind('mouseenter mouseleave');
        $("input, textarea").off('hover');
        
        
        $("input, textarea").not("#default").hover(function () {
            $(this).not("#inputPesquisa").attr("title", "Clique aqui para editar");
            helper.oldColorInput = $(this).css("background-color")
            helper.oldColorTextInput = $(this).css("color")
            
            $(this).css("color", "#00345c");
            $(this).css("background-color", "rgb(251,255,177)");
        }, function () {
            $(this).css("background-color", helper.oldColorInput);
            $(this).css("color", helper.oldColorTextInput);
        });
        //-------------------------------------------------------------
        
        
        //ATIVA OU DESATIVA O AUTO UPDATE NOS FILHOS------------------------
        $( ".optionUpdate" ).on( "click", function() {
            
            //alert("FUNCIONALIDADE EM DESENVOLVIMENTO")
            
            //prop('checked', false); 
            var estadoUpdate = $(this).find("#autoUpdate").is(":checked")
            
            if(estadoUpdate == true){
                $(this).parents(".containerCotacao").attr('data-autoupdate', '0')
                
                $(this).empty()
                var sample = "\
                <div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '> Auto Update</div>\
                <div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; justify-content: center; text-align: center'>\
                <input type='checkbox' id='autoUpdate'>\
                </div>";
                
                $(this).append(sample)
                
                
            }else{
                $(this).parents(".containerCotacao").attr('data-autoupdate', '1')
                
                $(this).empty()
                var sample = "\
                <div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '> Auto Update</div>\
                <div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; justify-content: center; text-align: center'>\
                <input type='checkbox' id='autoUpdate' checked>\
                </div>";
                $(this).append(sample)
                
            }
        })
        //------------------------------------------------------------------
        
        console.log("fim events after append")
        
    },
    
    consultaTipo : function(cmp, event, helper){
        var recordId = helper.retornaRecorId(cmp, event, helper)
        
        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT SyncedQuoteId, RecordType.DeveloperName FROM Opportunity WHERE id = '" + recordId + "'")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (sincronismo) {
            sincronismo.forEach(function (itemAtual) {    
                var aux = itemAtual.RecordType.DeveloperName
                helper.tipoOpp = aux
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
	
    //FUNÇÃO QUE BUSCA E PREECHE OS PRODUTOS ENCONTRADOS---------------------
    buscaProdutos: function (cmp, event, helper, inputPesquisa, filtro) {
        var recordId = helper.retornaRecorId(cmp, event, helper)

        //EXIBE O SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA--------------------
        $('#listaProdutos').click()

        //RECUPERA O ID DO LIVRO DE PREÇOS DA COTAÇÃO ATUAL
        helper.soql(cmp, "SELECT Pricebook2Id FROM Opportunity WHERE id = '" + recordId + "'")
            .then(function (response) {
                response.forEach(function (resposta) {
                    //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                    $('#listaProdutos').click()

                    //VARIÁVEL QUE ARMAZENA O ID DO LIVRO DE PREÇOS
                    var pricebook2id = resposta.Pricebook2Id;

                    //VALIDA APLICAÇÃO DO FILTRO NA PESQUISA--------------------------------------
                    //SE O INPUT DE PESQUISA NÃO FOR VAZIO----------------------------------------
                    if (filtro === "null" && inputPesquisa != "all") {
                        var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c   FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY  LastModifiedDate  DESC LIMIT 100"
                    } else if (filtro === "familia" && inputPesquisa != "all") {
                        var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') AND  Linha__c = '" + helper.selectLinha + "' ORDER BY Name LIMIT 100"
                    } else if (filtro === "tipo" && inputPesquisa != "all") {
                        var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' ORDER BY Name LIMIT 100"
                    } else if (filtro === "marca" && inputPesquisa != "all") {
                        var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' ORDER BY Name LIMIT 100"
                    } else if (filtro === "end" && inputPesquisa != "all") {
                        var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' AND Marca__c = '" + helper.selectMarca + "' ORDER BY Name LIMIT 100"

                        //SE O INPUT DE PESQUISA FOR ALL, ISTO É, A CAIXA DE PESQUISA É VAZIA---
                    } else if (inputPesquisa === "all") {
                        if (filtro === 'null') {
                            var query = "SELECT Name, Tipo_do_Produto__c, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true ORDER BY LastModifiedDate  DESC LIMIT 100"
                        } else if (filtro === 'familia') {
                            var query = "SELECT Name, Tipo_do_Produto__c, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND Linha__c = '" + helper.selectLinha + "' ORDER BY LastModifiedDate  DESC LIMIT 100"
                        } else if (filtro === 'tipo') {
                            var query = "SELECT Name, Tipo_do_Produto__c, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' ORDER BY LastModifiedDate  DESC LIMIT 100"
                        } else if (filtro === 'marca') {
                            var query = "SELECT Name, Tipo_do_Produto__c, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' ORDER BY LastModifiedDate  DESC LIMIT 100"
                        } else if (filtro === 'end') {
                            var query = "SELECT Name, Tipo_do_Produto__c, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' AND Marca__c = '" + helper.selectMarca + "' ORDER BY LastModifiedDate  DESC LIMIT 100"
                        }
                    } else {
                        console.log("else geral")
                        //var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Quantidade_em_Estoque_Oficial__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '"+pricebook2id+"') AND IsActive = true AND (Name like '%"+inputPesquisa+"%' OR Modelo__c like '%"+inputPesquisa+"%' OR Marca__c like '%"+inputPesquisa+"%') ORDER BY Name LIMIT 200"
                    }
                    //---------------------------------------------------------------------------
                    
                    helper.alertaErro(cmp, event, helper, "", "Carregando Produtos...", "info", "", "dismissable")
                    
                    //REALIZA A CONSULTA AOS PRODUTOS FILTRANDO PELO LIVRO DE PREÇO ATUAL
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
                                if (String(produtoAtual.Description) === undefined || String(produtoAtual.Description) === "undefined") {
                                    var produtoDescricao = "PRODUTO SEM DESCRIÇÃO"
                                    var produtoDescricaoData = "PRODUTO SEM DESCRIÇÃO"
                                } else {
                                    var produtoDescricao = String(produtoAtual.Description).substring(0, 200).toUpperCase() + "..."
                                    var produtoDescricaoData = String(produtoAtual.Description)
                                }
                                //-----------------------------------------

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

                                    var quantEstoque = produtoAtual.Estoque_disponivel__c + " EM ESTOQUE"
                                    var quantidadeEstoque = produtoAtual.Estoque_disponivel__c + " UND"

                                    var aguardandoReceber = produtoAtual.Qtd_Aguardando_Recebimento__c
                                    if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                                        aguardandoReceber = "0 UND"
                                    }
                                }
                                //-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                var idProduto = produtoAtual.ID_do_Produto__c
                                var tipoProduto = produtoAtual.Tipo_do_Produto__c ? produtoAtual.Tipo_do_Produto__c : "N.C."
                                var modelo =  produtoAtual.Modelo__c ? String(produtoAtual.Modelo__c).substring(0, 30) : "N.C."

                                //ADICIONA O ITEM À DIV
                                $('#listaProdutos').append("<div id='" + contId + "' data-idProduto='" + idProduto + "' class='itemPesquisa' data-descricao='" + produtoDescricaoData + "' data-codigo='" + produtoAtual.ProductCode + "' data-marca='" + produtoAtual.Marca__c + "' data-modelo='" + produtoAtual.Modelo__c + "' data-image='" + produtoAtual.URL_da_Imagem__c + "' name='" + produtoAtual.Name + "'> <!-- IMAGEM DO ITEM --> <div style='width: 26%; display: flex; align-items:center; justify-content: center;'> <img src='" + produtoAtual.URL_da_Imagem__c + "' style=' height: 90%; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/> </div> <!-- DIVISOR --> <div style='display: flex; height: 100%; width: 4%; align-items: center;'> <hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/> </div> <!-- INFO DO ITEM --> <div style='background-color: ; width: 70%; display: flex; flex-direction: column'> <!-- NOME DO ITEM --> <div style=' width: 100%; height: 24%; font-size: 14px; color: #00345c; font-weight: bold;'>" + produtoAtual.Name.substring(0, 17) + "...</div> <!-- MODELO DO ITEM --> <div style='background-color: ; width: 100%; height: 24%; font-size: 12px; color: #00345c;'>" +modelo+ "</div> <!-- DIVISOR --> <div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div> <!-- MARCA E CÓDIGO ITEM --> <div style=' width: 100%; height: 24%; font-size: 12px; color: #A0BB31;'>" + produtoAtual.Marca__c + ": " + produtoAtual.ProductCode + "</div> <!-- STATUS STOQUE ITEM --> <div style='background-color: grown; width: 100%; height: 24%'> <div style='color: white; background-color: " + corEtiqueta + "; height: 100%; width: 70%; display: flex; justify-content: center; align-items: center; border-radius: 120px; font-size: 13px;'>" + quantEstoque + "</div> </div> </div> <!-- DESCRIÇÃO FLUTUANTE DO ITEM --> <div class='divDescricaoItem' style='display: none; flex-direction: column; padding: 10px; border: 0.01px solid " + corEstoque + ";'> <!-- NOME DO ITEM --> <div class='itemNameFlutuante'>" + produtoAtual.Name + " </div> <!-- DIVISOR --> <div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div> <!-- MODELO DO ITEM --> <div style='height: 15%; width: 100%; display: flex'> <!-- NOME DO MODELO --> <div style='width: 60%; height: 100%; font-size: 10px; color: #a0bb31'>" + produtoAtual.Marca__c + ": " + produtoAtual.ProductCode + "</div> <!-- MODELO DO ITEM --> <div style='width: 40%; height: 100%; font-size: 10px; color: #a0bb31; text-align: right;'> TIPO: " + tipoProduto + "</div> </div> <!-- DESCRIÇÃO DO ITEM --> <div class='descricaoFlutuanteItem'>" + produtoDescricao + " </div> <!-- RODAPÉ --> <div style='width: 100%; height: 26%; column-gap: 3px; display: flex'> <div class='containerRodape'> <div class='rodapeBlocos'> Preço de lista </div> <div class='rodapeBlocos' style=''>R$ " + new Intl.NumberFormat('id').format(produtoAtual.Valor_Total__c) + "</div> </div> <div class='containerRodape' style='background-color: #ffff00'> <div class='rodapeBlocos' style='color: #00345c'>Em recebimento</div> <div class='rodapeBlocos' style='color: #00345c;'>" + aguardandoReceber + "</div> </div> <div class='containerRodape' style='background-color: " + corEstoque + "'> <div class='rodapeBlocos'> Qnt. em estoque </div> <div class='rodapeBlocos' style='font-size: 11px!important;'>" + quantidadeEstoque + "</div> </div> </div>   </div>")
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
                            
                            // VERIFICA SE O SORTABLE JÁ EXISTE E REMOVE
                            if (el._sortable) {
                                el._sortable.destroy(); // DESTROI A INSTÂNCIA EXISTENTE
                            }
                            
                            var sortable = Sortable.create(el, {
                                group: {
                                    name: 'shared', //seta o nome do grupo de compartilhamento de itens
                                    pull: 'clone', // To clone: set pull to 'clone'
                                    put: false,
                                },
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
                        })
                })
            })
            .catch(function (error) {
                console.log(error)
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
	
    //FUNÇÃO QUE REMOVE UM ITEM DA COTAÇÃO----------------------
    removeItemCotacao: function (cmp, event, helper, item, option) {
        console.log("remove item opp")
        var recordId = helper.retornaRecorId(cmp, event, helper) //VARIÁVEL QUE ARMAZENA O RECORDID DO REGISTRO
        
        var aux = helper.tipoOpp
        const recordsBypass = ["OPME_2", "OPME", "Licitacao"];
        
        if (!recordsBypass.includes(aux)) {
            helper.alertaErro(cmp, event, helper, "Não é permitido a remoção de produtos pela oportunidade. Remova os produtos pela cotação.", "REMOVA ESTE ITEM PELA COTAÇÃO", "warning", "Alerta!", "")
            helper.consultaCotacao(cmp, event, helper, 0)
        } else {
            
            if (option === 0) {
                var textAlerta = "Deseja mesmo remover este item?";
                var textAlertaErro = "ITEM REMOVIDO";
            } else {
                var textAlerta = "Deseja mesmo transformar este item em acessório?";
                var textAlertaErro = "ITEM MOVIDO";
            }
            
            //EXIBE CAIXA DE DÍALOGO CONFIRMANDO A EXCLUSÃO DO ITEM
            if (confirm(textAlerta)) {
                helper.showSpinner(cmp); //EXIBE SPINNER DE CARREGAMENTO
                
                var recordId = helper.retornaRecorId(cmp, event, helper) //VARIÁVEL QUE ARMAZENA O RECORDID DO REGISTRO
                var idItemCotacao = $(item).closest(".containerCotacao").attr('data-iditemcotacao');	//VARIÁVEL QUE ARMAZENA O ID DO PRODUTO A SER ADICIONADO
                var action = cmp.get("c.deleta"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
                
                //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
                action.setParams({
                    idOpp: recordId,
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
            }
        }
    },
    //----------------------------------------------------------
	
    //FUNÇÃO QUE ATIVA O DRAG AND DROP NOS ITENS FILHOS---------
    ativaDragAndDropFilhos: function (cmp, event, helper) {
        // SELECIONA TODAS AS DIVS COM A CLASSE 'produtosFilhosDrop' NO DOCUMENTO
        var elementos = document.querySelectorAll('.produtosFilhosDrop');
        
        // VERIFICA SE O SORTABLE JÁ EXISTE E REMOVE
        if (elementos._sortable) {
            console.log("sortable ja existe")
            elementos._sortable.destroy(); // DESTROI A INSTÂNCIA EXISTENTE
        }
        
        // ITERA SOBRE TODOS OS ELEMENTOS ENCONTRADOS
        elementos.forEach(function (element) {
            // CRIA UMA INSTÂNCIA DO SORTABLE PARA CADA DIV
            var sortable = Sortable.create(element, {
                // DEFINE AS CONFIGURAÇÕES DO DRAG-AND-DROP
                group: {
                    name: 'shared', // SETA O NOME DO GRUPO DE COMPARTILHAMENTO DE ITENS
                },
                // EVENTO DISPARADO QUANDO HOUVER UMA ADIÇÃO
                onAdd: function (evt) {
                    helper.adicionaItemFilhoCotacao(cmp, helper, evt.item);
                },
                forceFallback: true,
            });
        });
    },
	
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
        //helper.eventsAfterAppend(cmp, event, helper)
        //---------------------------------------------------------------
    },
    //----------------------------------------------------------

    //EXIBE DIV DA PESQUISA DE PRODUTOS------------------------
    exibePesquisaProdutos: function (cmp, event, helper) {
        //ALTERA ESTILO DOS BOTÕES APÓS CLIQUE
        $("#buttonPlataformaMarketing").css("opacity", "40%")
        $("#buttonPesquiseProdutos").css("opacity", "100%")

        //OCULTA DIV DO PESQUISE
        $("#divPlataformaMkt").hide()

        //EXIBE DIV DO MKT
        $("#divPesquiseProdutos").show()

        //CHAMA FUNÇÃO GENÉRICA QUE ADICIONA EVENTOS APÓS A ATUALIZAÇÃO--
        //helper.eventsAfterAppend(cmp, event, helper)
        //---------------------------------------------------------------
    },
    //---------------------------------------------------------

    preenchePlataformaMkt: function (cmp, event, helper, categoriaPai) {
        
        if (categoriaPai === '') {
            var query = "SELECT Name, Id, Icone_url__c, Categoria_Pai__c FROM MktCategoria__c WHERE Ativo__c = true AND Categoria_Pai__c = '" + categoriaPai + "' ORDER BY Name"
            } else {
                var query = "SELECT Name, Id, Icone_url__c, Categoria_Pai__c FROM MktCategoria__c WHERE Ativo__c = true AND Categoria_Pai__c = '" + categoriaPai + "' ORDER BY Ordem__c"
                }
        
        helper.alertaErro(cmp, event, helper, "", "Carregando Categorias...", "info", "", "dismissable")
        
        //REALIZA A CONSULTA PASSANDO O ID DA CATEGORIA PAI
        this.soql(cmp, query)

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (response) {

                if (response.length != 0) {

                    $("#colunaPlataformaMkt").empty()

                    response.forEach(function (categoria) {

                        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA--------------------
                        $('#listaProdutos').click()

                        //DEFINE VARIÁVEIS DA CATEGORIA INSERIDAI----------------------
                        var nomeCategoria = String(categoria.Name) //.toUpperCase()
                        var categoriaPai = categoria.Categoria_Pai__C
                        var urlImagem = categoria.Icone_url__c
                        //-------------------------------------------------------------

                        //VARIÁVEL QUE RECUPERA O ID DA CATEGORIA--
                        var Id = categoria.Id
                        //-----------------------------------------

                        //ADICIONA A CATEGORIA À DIV
                        var item = $("<a class='customAUnderline center-catalogo' data-urlImagem='" + urlImagem + "' data-idItem='" + Id + "'> <div  class='itemNavegacao' style=''> <div style='height: auto; padding-bottom: 10px; '> <div style='display: flex; width: 100%; justify-content: center; align-items: center;'> <img src='" + urlImagem + "' style='width: 100%; height: 100%; border-radius: 15px 15px 0px 0px; object-fit: cover;'/> </div> <div style='width: 100% height: auto; display: flex; padding-top: 10px; flex-direction: column; align-items: center'> <!-- NOME DA CATEGORIA --> <div id='nomeCategoria' style='width: 100%; height: 100%; font-size: calc(100% - 6px); color: #00345c; font-weight: 500; display: flex; justify-content: center; text-align: center;'>" + nomeCategoria + "</div> <div style='width: 20%; height: 100%; font-size: 14px; color: #00345c; font-weight: 500; display: flex; margin-left: 10px;'> </div> </div> </div> </div> </a>")
                        $("#colunaPlataformaMkt").append(item)

                        //EVENTO DE CLICK NA CATEGORIA---------------------------------
                        $(item).click(function () {

                            //EXIBE O SPINNER DE CARREGAMENTO
                            helper.showSpinner(cmp);

                            var idCategoriaPai = $(this).attr('data-idItem');
                            var urlImagem = $(this).attr('data-urlImagem');
                            var nomeCategoria = $(this).find("#nomeCategoria").text()

                            helper.ultimaCategoriaInserida = nomeCategoria
                            helper.imagemUltimaCategoriaInserida = urlImagem

                            $(".breadcrumbs__item").css("background", "white")
                            $(".breadcrumbs__item").css("color", "#333")

                            var item = $("<a style='background: #00345c; color: white' data-idItem='" + idCategoriaPai + "' class='breadcrumbs__item'>" + nomeCategoria + "</a>")
                            $("#breadcrumbsNav").append(item)

                            $(item).click(function () {
                                var idCategoriaPai = $(this).attr('data-idItem');
                                helper.indiceRemocao = $(this).index();

                                //EXIBE O SPINNER DE CARREGAMENTO
                                helper.showSpinner(cmp);
                                //--------------------------------

                                $(this).css("background", "#00345c")
                                $(this).css("color", "#ffffff")

                                $('#breadcrumbsNav').children().each(function () {
                                    if ($(this).index() > helper.indiceRemocao) {
                                        $(this).remove()
                                    }
                                });

                                helper.preenchePlataformaMkt(cmp, event, helper, idCategoriaPai)
                            })

                            helper.preenchePlataformaMkt(cmp, event, helper, idCategoriaPai)
                        })

                        //OCULTA SPINNER DE CARREGAMENTO---
                        helper.hideSpinner(cmp);
                        //---------------------------------
                    })
                } else {
                    console.log("exibe produtos")
                    helper.preencheProdutosMkt(cmp, event, helper, categoriaPai, '')
                }
            })

            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
    },

    //FUNÇÃO QUE BUSCA E PREECHE OS PRODUTOS NA GUIA DO MARKETING-
    preencheProdutosMkt: function (cmp, event, helper, categoriaPai, tipo) {
        
        //console.log("TIPO", tipo)
        var recordId = helper.retornaRecorId(cmp, event, helper)

        //CRIA LISTA COM OS TIPOS DOS PRODUTOS
        var listaTipos = ["PEÇA", "EQUIPAMENTO", "MÓDULO", "CONSUMÍVEL", "ACESSÓRIO", "FERRAMENTA", "SET CIRURGICO", "INSTRUMENTAL", "IMPLANTE"]

        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#listaProdutos').click()
        helper.alertaErro(cmp, event, helper, "", "Carregando Produtos...", "info", "", "dismissable")
        //-----------------------------------------
                
        //RECUPERA O ID DO LIVRO DE PREÇOS DA COTAÇÃO ATUAL
        helper.soql(cmp, "SELECT Pricebook2Id FROM Opportunity WHERE id = '" + recordId + "'")
            .then(function (response) {
                response.forEach(function (resposta) {
                    
                    //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                    $('#colunaPlataformaMkt').click()

                    //VARIÁVEL QUE ARMAZENA O ID DO LIVRO DE PREÇOS
                    var pricebook2id = resposta.Pricebook2Id

                    //DEFINE A QUERY DE CONSULTA COM BASE NO TIPO RECEBIDO----
                    if (tipo == '') {
                        var query = "SELECT Name, Parte__r.Name, Tipo__c, Parte__r.ProductCode, Parte__r.Qtd_Aguardando_Recebimento__c, Parte__r.Estoque_disponivel__c, Parte__r.Marca__c,  Parte__r.ID_do_Produto__c, Parte__r.Modelo__c, Parte__r.URL_da_Imagem__c, Parte__r.Valor_Total__C, Parte__c FROM MktParte__c WHERE Parte__c in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND Categoria__c = '" + categoriaPai + "'"
                    } else {
                        var query = "SELECT Name, Parte__r.Name, Tipo__c, Parte__r.ProductCode, Parte__r.Qtd_Aguardando_Recebimento__c, Parte__r.Estoque_disponivel__c, Parte__r.Marca__c,  Parte__r.ID_do_Produto__c, Parte__r.Modelo__c, Parte__r.URL_da_Imagem__c, Parte__r.Valor_Total__C, Parte__c FROM MktParte__c WHERE Parte__c in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND Tipo__c = '" + tipo + "' AND  Categoria__c = '" + categoriaPai + "'"
                    }
                    //-------------------------------------------------------
                    
                    //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                    $('#colunaPlataformaMkt').click()
                    helper.alertaErro(cmp, event, helper, "", "Carregando Produtos...", "info", "", "dismissable")
                    

                    //REALIZA A CONSULTA AOS PRODUTOS FILTRANDO PELO LIVRO DE PREÇO ATUAL
                    helper.soql(cmp, query)

                        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
                        .then(function (produtos) {

                            //VARIÁVEL CONTADORA DAS DIVS INSERIDAS
                            var contId = 1;

                            //LIMPA A TELA DE EXIBIÇÃO DOS PRODUTOS
                            $('#colunaPlataformaMkt').empty();

                            //ADICIONA CABEÇALHO COM O TÍTULO DA CATEGORIA PAI E OS FILTROS DOS RESULTADOS
                            $('#colunaPlataformaMkt').append("<!-- APPEND DOS ITENS --> <a class='customAUnderline' style='width: 100%'> <div class='itemResultadoNavegacao' style='width: auto; margin-right: 0px!important'> <div style='height: auto; padding-top: 10px; padding-bottom: 10px; display: flex;'> <div style='display: flex; width: 25%; justify-content: center; align-items: center;'> <img src='" + helper.imagemUltimaCategoriaInserida + "' style='width: 110px; height: 100px; border-radius: 10px; object-fit: cover;'/> </div> <div style='width: 75%; height: fit-content; display: flex; flex-direction: column; align-items: center'> <!-- NOME DA CATEGORIA --> <div id='nomeCategoria' style='margin-right: 10px; border-bottom: 1px solid #f3e4e4; align-items: center; width: 100%; height: 30%; font-size: 14px; color: #00345c; font-weight: 500; display: flex; justify-content: center; text-align: center;'>" + helper.ultimaCategoriaInserida + "</div> <div id='listaFiltrosMkt' style='padding-top: 10px; width: 100%; height: 70%; font-size: 14px; color: #00345c; font-weight: 500; display: flex; justify-content: space-around; flex-wrap: wrap;'> <!-- APPEND DOS TIPOS --> </div> </div> </div> </div> </a>")

                            //LOOP QUE PERCORRE TODOS OS PRODUTOS ENCONTRADOS, ITERANDO SOBRE PRODUTOATUAL---------------------------------------
                            produtos.forEach(function (produtoAtual) {

                                //VERIFICA SE O PRODUTO POSSÚI DESCRIÇÃO---
                                if (String(produtoAtual.Parte__r.Description) === undefined || String(produtoAtual.Parte__r.Description) === "undefined") {
                                    var produtoDescricao = "PRODUTO SEM DESCRIÇÃO"
                                    var produtoDescricaoData = "PRODUTO SEM DESCRIÇÃO"
                                } else {
                                    var produtoDescricao = String(produtoAtual.Parte__r.Description).substring(0, 200).toUpperCase() + "..."
                                    var produtoDescricaoData = String(produtoAtual.Parte__r.Description)
                                }
                                //-----------------------------------------

                                //DEFINE VARIÁVEIS DE COR E QUANTIDADE DO ESTOQUE---------------------------------------------------------------------------------------------------------------------------------------------
                                //Verifica se há estoque do produto atual
                                if (produtoAtual.Parte__r.Estoque_disponivel__c === 0 || produtoAtual.Parte__r.Estoque_disponivel__c === undefined || produtoAtual.Parte__r.Estoque_disponivel__c === "undefined") {
                                    //Se não houver estoque, verifica se está aguardando recebimento
                                    if (produtoAtual.Qtd_Aguardando_Recebimento__c >= 1) {
                                        //Caso esteja aguardando recebimento, mostrará a quantidade que está aguardando recebimento

                                        //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO PRINCIPAL DO ITEM-------------------------------
                                        var quantEstoque = produtoAtual.Parte__r.Qtd_Aguardando_Recebimento__c + " EM RECEBIMENTO"
                                        var corEstoque = "#f40a29"; //define a cor vermelha
                                        var corEtiqueta = "#FCFB20"; //define a cor amarela
                                        //-------------------------------------------------------------------------------------
                                        //
                                        //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO EXPANDIDA DO ITEM "HOVER"------------------------
                                        var quantidadeEstoque = "0 UND"
                                        var aguardandoReceber = produtoAtual.Parte__r.Qtd_Aguardando_Recebimento__c
                                        if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                                            aguardandoReceber = "0 UND"
                                        }
                                        //-------------------------------------------------------------------------------------
                                        //
                                    } else {
                                        //Se não tiver aguardando recebimento, logo exibirá "Sem estoque e 0 UND"

                                        //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO PRINCIPAL DO ITEM-------------------------------
                                        var quantEstoque = "SEM ESTOQUE"
                                        var quantidadeEstoque = "0 UND"
                                        //------------------------------------------------------------------------------------
                                        //
                                        //EXIBIÇÃO DO ESTOQUE NA VISUALIZAÇÃO EXPANDIDA DO ITEM "HOVER"-----------------------
                                        var corEstoque = "#f40a29";
                                        var corEtiqueta = "#f40a29";
                                        var quantidadeEstoque = "0 UND"

                                        var aguardandoReceber = produtoAtual.Parte__r.Qtd_Aguardando_Recebimento__c
                                        if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                                            aguardandoReceber = "0 UND"
                                        }
                                        //------------------------------------------------------------------------------------ 
                                    }
                                } else {
                                    //Se houver estoque, exibirá a quantidade em estoque na visualização principal, e na expandida a quantidade aguardando recebimento
                                    var corEstoque = "#a0bb31";
                                    var corEtiqueta = "#a0bb31";


                                    var quantEstoque = produtoAtual.Parte__r.Estoque_disponivel__c + " EM ESTOQUE"
                                    var quantidadeEstoque = produtoAtual.Parte__r.Estoque_disponivel__c + " UND"

                                    var aguardandoReceber = produtoAtual.Parte__r.Qtd_Aguardando_Recebimento__c
                                    if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                                        aguardandoReceber = "0 UND"
                                    }
                                }
                                //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                var idProduto = produtoAtual.Parte__r.ID_do_Produto__c
                                var nomeProduto = produtoAtual.Parte__r.Name
                                var codigoProduto = produtoAtual.Parte__r.ProductCode
                                var marcaProduto = produtoAtual.Parte__r.Marca__c
                                var modeloProduto = produtoAtual.Parte__r.Modelo__c
                                var urlImagemProduto = produtoAtual.Parte__r.URL_da_Imagem__c
                                var valorTotalProduto = produtoAtual.Parte__r.Valor_Total__c
                                
                                var classeParOuImpar = (contId % 2 === 0) ? "even" : "";

                                //ADICIONA O ITEM À DIV
                                $('#colunaPlataformaMkt').append("<div id='" + contId + "' data-idProduto='" + idProduto + "' class='itemPesquisa "+classeParOuImpar+"' data-descricao='" + produtoDescricaoData + "' data-codigo='" + codigoProduto + "' data-marca='" + marcaProduto + "' data-modelo='" + modeloProduto + "' data-image='" + urlImagemProduto + "' name='" + nomeProduto + "'> <!-- IMAGEM DO ITEM --> <div style='width: 26%; display: flex; align-items:center; justify-content: center;'> <img src='" + urlImagemProduto + "' style='height: 90%; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/> </div> <!-- DIVISOR --> <div style='display: flex; height: 100%; width: 4%; align-items: center;'> <hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/> </div> <!-- INFO DO ITEM --> <div style='background-color: ; width: 70%; display: flex; flex-direction: column'> <!-- NOME DO ITEM --> <div style=' width: 100%; height: 24%; font-size: 14px; color: #00345c; font-weight: bold;'>" + nomeProduto.substring(0, 17) + "...</div> <!-- MODELO DO ITEM --> <div style='background-color: ; width: 100%; height: 24%; font-size: 12px; color: #00345c;'>" + String(modeloProduto).substring(0, 30) + "</div> <!-- DIVISOR --> <div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div> <!-- MARCA E CÓDIGO ITEM --> <div style=' width: 100%; height: 24%; font-size: 12px; color: #A0BB31;'>" + marcaProduto + ": " + codigoProduto + "</div> <!-- STATUS STOQUE ITEM --> <div style='background-color: grown; width: 100%; height: 24%'> <div style='color: white; background-color: " + corEtiqueta + "; height: 100%; width: 70%; display: flex; justify-content: center; align-items: center; border-radius: 120px;'>" + quantEstoque + "</div> </div> </div> <!-- DESCRIÇÃO FLUTUANTE DO ITEM --> <div class='divDescricaoItem' style='display: none; flex-direction: column; padding: 10px; border: 0.01px solid " + corEstoque + ";'> <!-- NOME DO ITEM --> <div class='itemNameFlutuante'>" + nomeProduto + " </div> <!-- DIVISOR --> <div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div> <!-- MODELO DO ITEM --> <div style='height: 15%; width: 100%; display: flex'> <!-- NOME DO MODELO --> <div style='width: 60%; height: 100%; font-size: 10px; color: #a0bb31'>" + marcaProduto + ": " + codigoProduto + "</div> <!-- MODELO DO ITEM --> <div style='width: 40%; height: 100%; font-size: 10px; color: #a0bb31; text-align: right;'> TIPO: ACESSORIO </div> </div> <!-- DESCRIÇÃO DO ITEM --> <div class='descricaoFlutuanteItem'>" + produtoDescricao + " </div> <!-- RODAPÉ --> <div style='width: 100%; height: 26%; column-gap: 3px; display: flex'> <div class='containerRodape'> <div class='rodapeBlocos'> Preço de lista </div> <div class='rodapeBlocos' style='font-size: 11px!important;'>R$ " + new Intl.NumberFormat('id').format(valorTotalProduto) + "</div> </div> <div class='containerRodape' style='background-color: #ffff00'> <div class='rodapeBlocos' style='color: #00345c'>Em recebimento</div> <div class='rodapeBlocos' style='color: #00345c; font-size: 11px!important;'>" + aguardandoReceber + "</div> </div> <div class='containerRodape' style='background-color: " + corEstoque + "'> <div class='rodapeBlocos'> Qnt. em estoque </div> <div class='rodapeBlocos' style='font-size: 11px!important;'>" + quantidadeEstoque + "</div> </div> </div>   </div>")
                                contId++;
                            })
                            //----------------------------------------------------------------------------------------------------------------

                            //PERCORRE A LISTA DE TIPOS IDENTIFICADA, E ADICIONA À DIV
                            listaTipos.forEach(function (tipoAtual) {
                                if (tipo == tipoAtual) {
                                    helper.ultimoTipoSelecionado = tipoAtual
                                    var item = $("<div class='form34234' data-tipo='" + tipoAtual + "' data-categoriaPai='" + categoriaPai + "' ><input class='form-check-input' type='checkbox' id='flexSwitchCheckDefault' checked='true' /> <label style='color: #00345c' class='form-check-label' for='flexSwitchCheckChecked'>" + tipoAtual + "</label> </div>")
                                } else {
                                    var item = $("<div class='form34234' data-tipo='" + tipoAtual + "' data-categoriaPai='" + categoriaPai + "' ><input class='form-check-input' type='checkbox' id='flexSwitchCheckDefault' /> <label style='color: #00345c' class='form-check-label' for='flexSwitchCheckChecked'>" + tipoAtual + "</label> </div>")
                                }

                                $("#listaFiltrosMkt").append(item)

                                $(item).click(function () {
                                    var categoriaPai = $(this).attr('data-categoriaPai')
                                    var tipo = $(this).attr('data-tipo')
                                    
                                    if(helper.ultimoTipoSelecionado == tipo){
                                        helper.preencheProdutosMkt(cmp, event, helper, categoriaPai, "")
                                    }else{
                                        helper.preencheProdutosMkt(cmp, event, helper, categoriaPai, tipo)
                                    }
                                })
                            })

                            //OUVINTE DE MOUSEOVER NOS ITENS INSERIDOS-----------------------------
                            $(".itemPesquisa").mouseover(function () {
                                var id = $(this).attr('id');
                                if ((id % 2) === 0) {
                                    $(".divDescricaoItem", this).css({ "margin-left": "-275px" });
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
                            var el = document.getElementById('colunaPlataformaMkt');
                            var sortable = Sortable.create(el, {
                                group: {
                                    name: 'shared', //seta o nome do grupo de compartilhamento de itens
                                    pull: 'clone', // To clone: set pull to 'clone'
                                    put: false,
                                },
                                filter: ".customAUnderline", //DESATIVA A ORDENÇÃO NA DIV QUE EXIBE OS FILTROS DE UMA CATEGORIA FINAL
                                animation: 150, //DEFINE O TEMPO DE ANIMAÇÃO AO ARRASTAR
                                forceFallback: true, //FORÇA O USO DO PLUGIN DE ARRASTA E SOLTA, SOBRESCREVENDO O MÉTODO NATIVO
                                sort: false //DESATIVA A REORDENAÇÃO
                            });
                            //-----------------------------------------------------------------------

                            //ATIVA DRAG AND DROP NA COLUNA DA DIREITA---------
                            //helper.ativaDragAndDrop(cmp, event, helper)
                            //-------------------------------------------------

                            //CHAMA FUNÇÃO QUE IRÁ PREENCHER OS FILTROS DE PESQUISA-
                            helper.preencheFiltros(cmp, event, helper, inputPesquisa)
                            //------------------------------------------------------

                            //CHAMA FUNÇÃO GENÉRICA QUE ADICIONA EVENTOS APÓS A ATUALIZAÇÃO--
                            //helper.eventsAfterAppend(cmp, event, helper)
                            //---------------------------------------------------------------

                            //OCULTA SPINNER DE CARREGAMENTO---
                            helper.hideSpinner(cmp);
                            //---------------------------------
                        })

                        //TRATA EXCESSÃO DE ERRO DA CONSULTA
                        .catch(function (error) {
                            helper.alertaErro(cmp, event, helper, error, "ERRO AO CONSULTAR PRODUTOS", "error")
                        })
                })
            })
            .catch(function (error) {
                console.log(error)
            })
    },
    //---------------------------------------------------

    //FUNÇÃO QUE RETORNA O ULTIMO ITEM DO INDICE DE PRODUTOS NA COTAÇÃO-
    retornaIndiceUltimoItem: function (cmp, event, helper) {
        
        // Pega os últimos 2 dígitos dos milissegundos atuais
        var milissegundos = Date.now().toString().slice(-2);
        // Gera um número aleatório entre 0 e 99
        var randomNumber = Math.floor(Math.random() * 100);
        // Soma e garante que o resultado seja no máximo 3 dígitos
        var numeroFinal = (parseInt(milissegundos) + randomNumber) % 1000;
        
        return numeroFinal;
    },
    //------------------------------------------------------------------
    
    //CHAMA FUNÇÃO DO APEX QUE ADICIONA UM ITEM NA COTAÇÃO--
    adicionaItemCotacao: function (cmp, event, helper, item) {
        //console.log("adiciona item opp")

        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var recordId = helper.retornaRecorId(cmp, event, helper)
        var idProduto = $(item).attr('data-idproduto');
        var descricao = $(item).attr('data-descricao');
        var item = helper.retornaIndiceUltimoItem(cmp, event, helper)
        
        //console.log("ITEMS", item)

        var aux = helper.tipoOpp
        const recordsBypass = ["OPME_2", "OPME", "Licitacao"];
        
        if (!recordsBypass.includes(aux)) {
            helper.alertaErro(cmp, event, helper, "Não é permitido a adição de produtos pela oportunidade. Edite os produtos pela cotação.", "ADICIONE ESTE ITEM PELA COTAÇÃO", "warning", "Alerta!", "")
            helper.consultaCotacao(cmp, event, helper, 0)
        }else {
            
            //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
            var action = cmp.get("c.inserirPai");
            //console.log(recordId + " , " + idProduto + " , " + descricao + " , " + item)
            
            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                opp: recordId,
                produto: idProduto,
                descricao: descricao,
                item: item
            });
            //----------------------------------------------------
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            //$('#listaProdutos').click()
            helper.alertaErro(cmp, event, helper, "", "Carregando Operação...", "info", "", "dismissable")
            //-----------------------------------------
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, $A.getCallback(function(response) {
                var state = response.getState();
                helper.hideSpinner(cmp);
                
                if (state === "SUCCESS") {
                    helper.alertaErro(cmp, event, helper, "O Produto foi inserido com sucesso a oportunidade!", "SUCESSO", "success", "Operação concluída!", "dismissable")
                    helper.consultaCotacao(cmp, event, helper, 1)
                }
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE A INSERÇÃO", "INSERÇÃO IMCOMPLETA", "error", "Erro: ", "sticky")
                    console.log("incompleto")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO INSERIR NA OPORTUNIDADE", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            }));
            
            $A.enqueueAction(action);
        }
        
    },
    //-----------------------------------------------------

    //CHAMA FUNÇÃO DO APEX QUE ADICIONA UM ITEM NA COTAÇÃO--
    adicionaItemFilhoCotacao: function (cmp, helper, item) {
        console.log("adiciona item filho oppp")

        helper.showSpinner(cmp); //EXIBE SPINNER DE CARREGAMENTO
        var recordId = helper.retornaRecorId(cmp, event, helper) //VARIÁVEL QUE ARMAZENA O RECORDID DO REGISTRO
        
        var aux = helper.tipoOpp
        const recordsBypass = ["OPME_2", "OPME", "Licitacao"];
        
        if (!recordsBypass.includes(aux)) {
            helper.alertaErro(cmp, event, helper, "Não é permitido a adição de acessórios pela oportunidade. Edite os acessórios pela cotação.", "INSIRA ESTE ACESSÓRIO PELA COTAÇÃO", "warning", "Alerta!", "")
            helper.consultaCotacao(cmp, event, helper, 0);
            
        } else {
            var idProduto = $(item).attr('data-idproduto');	//VARIÁVEL QUE ARMAZENA O ID DO PRODUTO A SER ADICIONADO
            var descricao = $(item).attr('data-descricao');	//VARIÁVEL QUE ARMAZENA A DESCRIÇÃO DO PRODUTO A SER ADICIONADO
            
            if ($(item).attr('data-item-c') === undefined) {
                var itemPai = $(item).closest(".containerCotacao").attr('data-item-c');	//VARIÁVEL QUE ARMAZENA O IDENTIFICADOR DO PRODUTO PAI O QUAL ESTE FILHO SERÁ ADICIONADO
                var option = 0;
            } else {
                var itemPai = $(item).parent().closest(".containerCotacao").attr('data-item-c');
                var option = 1;
            }
            
            var action = cmp.get("c.inserirFilho"); //DEFINE A CHAMADA DO MÉTODO APEX QUE IRÁ INSERIR O ITEM FILHO
            var recordId = helper.retornaRecorId(cmp, event, helper) //VARIÁVEL QUE ARMAZENA O RECORDID DO REGISTRO
                        
            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                opp: recordId,
                produto: idProduto,
                descricao: descricao,
                itemPai: itemPai
            });
            //--------------------------------------------------
            
            //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
            //$('#listaProdutos').click()
            helper.alertaErro(cmp, event, helper, "", "Carregando Operação...", "info", "", "dismissable")
            //-----------------------------------------
            
            //CALLBACK DA REQUISIÇÃO---------------------------
            action.setCallback(this, function (response) {
                var state = response.getState(); //VARIÁVEL QUE ARMAZENA O ESTADO DA REQUISIÇÃO AO MÉTODO APEX
                
                //CASO O MÉTODO SEJA EXECUTADO COM SUCESSO
                if (state === "SUCCESS") {
                    //helper.hideSpinner(cmp); //OCULTA SPINNER DE CARREGAMENTO
                    if (option == 0) {
                        helper.consultaCotacao(cmp, event, helper, 0) //CHAMA FUNÇÃO QUE IRÁ CONSULTAR A COTAÇÃO NOVAMENTE E EXIBIR OS ITENS ATUALIZADOS
                        helper.alertaErro(cmp, event, helper, "O Produto foi inserido com sucesso a cotação!", "SUCESSO", "success", "Operação concluída!", "dismissable") //EXIBE UM ALERTA DE SUCESSO AO USUÁRIO
                    } else {
                        helper.removeItemCotacao(cmp, event, helper, item, 1)
                    }
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
    },
    //-----------------------------------------------------

    //FUNÇÃO QUE ATIVA O DRAG AND DROP NOS ITENS----------------
    ativaDragAndDrop: function (cmp, event, helper) {
        //CONFIGURAÇÕES DA COLUNA DROP "DIREITA"------------------------------------------
        var el = document.getElementById('listaCotacao');
        //INSTANCIA O OBJETO SORTABLE, DO PLUGIN DE DRAG AND DROP
        
        // VERIFICA SE O SORTABLE JÁ EXISTE E REMOVE
        if (el._sortable) {
            el._sortable.destroy(); // DESTROI A INSTÂNCIA EXISTENTE
        }
        
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

                //helper.consultaCotacao(cmp, event, helper, 0)
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

    //FUNÇÃO QUE ATUALIZA OS DADOS DE UM ITEM, DESCRIÇÃO, VALORES ETC...
    atualizaItem: function (cmp, event, helper, item) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var recordId = helper.retornaRecorId(cmp, event, helper)
        var itemCotacao = $(item).closest(".containerCotacao").attr("data-iditemcotacao")
        var valorUnitario = parseFloat(String($(item).closest(".containerCotacao").find("#valorUnitario").val()).replace('BRL ', '').replaceAll(".", "").replace(",", "."));
        var quantidade = parseFloat($(item).closest(".containerCotacao").find("#quantidade").val().replace(".", "").replace(",", "."))
        var subtotal = parseFloat(String($(item).closest(".containerCotacao").find("#subtotal").val()).replace('BRL ', '').replaceAll(".", "").replace(",", "."))
        var desconto = parseFloat(String($(item).closest(".containerCotacao").find("#desconto").val()).replace('%', '').replace(",", "."))
        var descricao = String($(item).closest(".containerCotacao").find("#textAreaDesc").val())
        var autoUpdate = $(item).closest(".containerCotacao").attr("data-autoupdate")
        
        console.log("atualiza item", itemCotacao)
        
        var aux = helper.tipoOpp
        const recordsBypass = ["OPME_2", "OPME", "Licitacao"];
        
        if (!recordsBypass.includes(aux)) {
            helper.alertaErro(cmp, event, helper, "Não é permitido a edição de produtos pela oportunidade. Edite os produtos pela cotação.", "ATUALIZE ESTE ITEM PELA COTAÇÃO", "warning", "Alerta!", "")
            helper.consultaCotacao(cmp, event, helper, 0)
        } else {
            //CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
            var action = cmp.get("c.atualiza");
            
            //DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX----
            action.setParams({
                valor: valorUnitario,
                id: itemCotacao,
                qtd: quantidade,
                desconto: desconto,
                descricao: descricao,
                sinc: autoUpdate
                
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
                    helper.alertaErro(cmp, event, helper, "ITEM ATUALIZADO COM SUCESSO", "OK!", "success", "", "dismissable")
                }
                else if (state === "INCOMPLETE") {
                    helper.alertaErro(cmp, event, helper, "ERRO DURANTE A ATUALIZAÇÃO DO ITEM", "ATUALIZAÇÃO INCOMPLETA", "error", "Erro: ", "sticky")
                    console.log("incompleto")
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.alertaErro(cmp, event, helper, errors[0].message, "ERRO AO ATUALIZAR O ITEM", "error", "Erro: ", "sticky")
                        reject(errors[0].message);
                    } else {
                        console.log("Erro desconhecido");
                        helper.alertaErro(cmp, event, helper, "ERRO DESCONHECIDO", "OCORREU UM ERRO DESCONHECIDO DURANTE A ATUALIZAÇÃO DO ITEM", "error", "Erro: ", "sticky")
                        reject("Erro desconhecido");
                    }
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    //---------------------------------------------------------------------

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
                totalTemp = parseFloat(totalTemp.replaceAll('.', '').replaceAll(',', '.'));
                totalItensFilhos += totalTemp;
            })
            //--------------------------------------------------------------------------------

            var totalKit = String($(this).find("#totalItemPai").val()).replace('BRL ', '');
            totalKit = parseFloat(totalKit.replaceAll('.', '').replaceAll(',', '.'));
            totalKit = totalKit + totalItensFilhos

            totalCotacao = totalCotacao + totalKit
            $(this).find("#totalKit").text("TOTAL DO KIT: BRL " + new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(totalKit))
            totalItensFilhos = 0;
        });

        $(document).find("#totalCotacao").text("TOTAL DA OPORTUNIDADE BRL " + new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(totalCotacao))
    },
    //------------------------------------------------------------------

    //FUNÇÃO QUE BUSCA NA COTAÇÃO ATUAL OS ITENS PAIS E FILHOS,-
    //E INSERE NA VISUALIZAÇÃO DA COTAÇÃO-----------------------
    consultaCotacao: function (cmp, event, helper, option) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);

        var recordId = helper.retornaRecorId(cmp, event, helper)
        const itensPai = [] //CRIA UMA LISTA VAZIA DE ITENS PAI
        const itensFilho = [] //CRIA UMA LISTA VAZIA DE ITENS FILHO

        $("#listaCotacao").empty()

        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT Opportunity.Cliente_inadimplente__c, Opportunity.Tipo_de_Opera_o__c,  ordem__c, Id, UnitPrice, Quantity, Product2.StockKeepingUnit, Subtotal, Discount, TotalPrice, Codigo_fabricante__c, Item__c, Descricao_a_linha__c, Product2.ID_do_Produto__c, Nome_do_Fabricante__c, Modelo_do_Produto__c, Product2.Name, Product2.ProductCode, Product2.URL_da_Imagem__c, Item_Pai__c FROM OpportunityLineItem WHERE OpportunityId = '" + recordId + "' ORDER BY ordem__c")

            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (itens) {

                console.log("Inadiplente?", itens[0].Opportunity.Cliente_inadimplente__c)
                var clienteInadimplente = itens[0].Opportunity.Cliente_inadimplente__c
                if(clienteInadimplente){
                    helper.alertaErro(cmp, event, helper, "Cliente possuí débitos, verifique com o financeiro.", "Atenção!", "warning", "", "sticky")
                }

                //PERCORRE ENTRE OS ITENS E ADICIONA NAS LISTAS------------------------
                itens.forEach(function (itemAtual) {
					
                    console.log('itemAtual:' + itemAtual.Item_Pai__c );
                    if (itemAtual.Item_Pai__c === undefined || itemAtual.Item_Pai__c == '') {
                        //ADICIONA NA LISTA DE ITENS PAI
                        itensPai.push({
                            codigoHospcom: itemAtual.Product2.StockKeepingUnit,
                            id: itemAtual.Id,
                            ordem: itemAtual.ordem__c,
                            idProduto: itemAtual.Product2.ID_do_Produto__c,
                            Valor: itemAtual.UnitPrice,
                            Quantidade: itemAtual.Quantity,
                            SubTotal: itemAtual.Subtotal,
                            Desconto: itemAtual.Discount,
                            Total: itemAtual.TotalPrice,
                            Description: itemAtual.Descricao_a_linha__c,
                            CodigoFabricante: itemAtual.Product2.ProductCode,
                            Item__c: itemAtual.Item__c,
                            Item_Pai__c: itemAtual.Item_Pai__c,
                            Marca__c: itemAtual.Nome_do_Fabricante__c,
                            Modelo__c: itemAtual.Modelo_do_Produto__c,
                            Name: itemAtual.Product2.Name,
                            Image: itemAtual.Product2.URL_da_Imagem__c
                        })
                    } else {
                        //ADICIONA NA LISTA DE ITENS FILHO
                        itensFilho.push({
                            codigoHospcom: itemAtual.Product2.StockKeepingUnit,
                            id: itemAtual.Id,
                            ordem: itemAtual.ordem__c,
                            idProduto: itemAtual.Product2.ID_do_Produto__c,
                            Valor: itemAtual.UnitPrice,
                            Quantidade: itemAtual.Quantity,
                            SubTotal: itemAtual.Subtotal,
                            Desconto: itemAtual.Discount,
                            Total: itemAtual.TotalPrice,
                            Description: itemAtual.Descricao_a_linha__c,
                            CodigoFabricante: itemAtual.Product2.ProductCode,
                            Item__c: itemAtual.Item__c,
                            Item_Pai__c: itemAtual.Item_Pai__c,
                            Marca__c: itemAtual.Nome_do_Fabricante__c,
                            Modelo__c: itemAtual.Modelo_do_Produto__c,
                            Name: itemAtual.Product2.Name,
                            Image: itemAtual.Product2.URL_da_Imagem__c
                        })
                    }
                })
                //---------------------------------------------------------------------
                
                var htmlFinal = '';

                //ADICIONA ITENS PAIS NA COLUNA DA DIREITA-----------------------------
                itensPai.forEach(function (itemPai) {
                    
                    console.log("ITENS PAI", itensPai)
                    
                    //DEFINE A VISUALIZAÇÃO DO NOME DO PRODUTO-------------------------
                    var nomeItem = itemPai.Name.length >= 30 ? (itemPai.Name.substring(0, 30) + "...") : itemPai.Name;

                    //DEFINE A VARIAVEL DE DESCRIÇÃO (MODELO, MARCA E CODIGO)----------
                    var modelo = itemPai.Modelo__c ? itemPai.Modelo__c : "Modelo N. Cadastrado";
                    var codigo = itemPai.CodigoFabricante;
                    var marca = itemPai.Marca__c;
                    var modCodMarca = modelo + " - " + marca + ": " + codigo
                    //-----------------------------------------------------------------

                    //DEFINE DESCRIÇÃO DO PRODUTO, IMAGEM E NÚMERO DO ITEM, ID E ORDEM-
                    var descricao = itemPai.Description ? itemPai.Description : "PRODUTO SEM DESCRIÇÃO";
                    var imageUrl = itemPai.Image;
                    var numberItem = itemPai.Item__c;
                    var idProduto = itemPai.idProduto
                    var idItemCotacao = itemPai.id
                    var ordem = itemPai.ordem === undefined ? '0' : itemPai.ordem
                    //-----------------------------------------------------------------

                    //DEFINE VARIÁVEIS DE VALORES DOS PRODUTOS-------------------------
                    var valorUnitario = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(itemPai.Valor)
                    var quantidade = itemPai.Quantidade;
                    var subtotal = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(itemPai.SubTotal);
                    var desconto = itemPai.Desconto ? itemPai.Desconto.toFixed(1) + "%" : ""
                    var total = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(itemPai.Total);
                    //----------------------------------------------------------------
					
                    
                    //CRIA A VARIÁVEL COM O ITEM QUE SERÁ ADICIONADO-------------------
                    var inputHtml = "\
                    <div class='containerCotacao' data-autoupdate='0' data-marca='" + marca + "' data-codigoHospcom='" + itemPai.codigoHospcom + "' data-codigoFabricante='" + codigo + "' data-modelo='" + modelo + "' data-name='" + itemPai.Name + "' data-image='" + imageUrl + "' data-idProduto='" + idProduto + "' data-idItemCotacao='" + idItemCotacao + "' data-item-c='" + numberItem + "'>\
                       <div class='itemMainCotacao'>\
                          <!-- IMAGEM DO ITEM --> \
                          <div style='width: 20%'> <img src='" + imageUrl + "' style='height: auto; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/> </div>\
                          <!-- DIVISOR --> \
                          <div style='display: flex; height: 100%; width: 4%; align-items: center; justify-content: center;'>\
                             <hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
                          </div>\
                          <!-- INFO DO ITEM --> \
                          <div style='background-color: ; width: 76%; display: flex; flex-direction: column'>\
                             <!-- NOME DO ITEM E BOTÕES DE AÇÃO --> \
                             <div style='position: relative; display: flex; align-items: center; width: 100%; height: 24%'>\
                                <div style='display: flex; align-items: center; width: 80%; height: 100%; font-size: 20px; color: #00345c; font-weight: bold;'>" + nomeItem + "</div>\
                                <div style='justify-content:center; align-items: center; display: flex; align-items: center; width: 10%; height: 100%; font-size: 20px; color: #00345c; font-weight: bold;'>\
                                   <div class='buttonNumberItem' id='numberItem' style=''>#" + ordem + "</div>\
                                </div>\
                                <a class='dropItemOptions3243' id='buttonOptions'>\
                                   <div style='justify-content:center; align-items: center; display: flex; align-items: center; width: 100%; height: 100%; color: #00345c; font-weight: bold;'>\
                                      <div class='' aria-hidden='true'><i class='fa fa-arrow-down' aria-hidden='true'></i> </div>\
                                   </div>\
                                </a>\
                                <!-- MENU OPTIONS ITEM --> \
                                <div style='display: none; flex-direction: column' id='menuOptionsId'  class='menuOptions'>\
                                   <div class='option32423 optionRemoveOptions' id='optionClose' style='width: 100%; height:33.3%; display: flex; justify-content: right; align-items: center'>\
                                      <div style='width: 80%; height: 100%; color: red; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Remover</div>\
                                      <div style='width: 20%; height: 100%; color: red; display: flex; align-items: center; justify-content: center; text-align: center'> <i class='fa fa-times-circle' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i> </div>\
                                   </div>\
                                   <div class='option32423 optionShowDetails' id='optionShowDetails' style='width: 100%; height:33.3%; display: flex; justify-content: right; align-items: center'>\
                                      <div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Exibir Detalhes</div>\
                                      <div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; justify-content: center; text-align: center'> <i class='fa fa-th-large' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i> </div>\
                                   </div>\
                                    <div class='optionUpdate' id='optionUpdate' style='cursor: pointer; width: 100%; height:33.3%; display: flex; justify-content: right; align-items: center'>\
                                        <div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '> Auto Update</div>\
                                        	<div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; text-align: center; padding-left: 4px;'>\
                                            <input type='checkbox' id='autoUpdate'>\
                                        </div>\
                                    </div>\
                                   <div id='optionCloseOptions' class='optionCloseOptions option32423'>\
                                      <div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Fechar</div>\
                                      <div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; justify-content: center; text-align: center'> <i class='fa fa-minus-circle' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i> </div>\
                                   </div>\
                                </div>\
                             </div>\
                             <!-- MODELO DO ITEM --> \
                             <div style='width: 100%; height: auto; font-size: 12px; color: #00345c; display: flex; align-items: center'>" + modCodMarca + "</div>\
                             <!-- DIVISOR --> \
                             <div style='display: flex; height: 4%; height: 8%; align-items: center;'>\
                                <hr style='border-top: 1px solid #dcdcdc; margin-top: 2px; width: 95%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
                             </div>\
                             <!-- DESCRIÇÃO --> \
                             <div style='width: 100%; height: auto'>\
                                <div style='font-size: 11px; color: #00345e; height: auto; width: 100%; display: flex; justify-content: center; align-items: center; border-radius: 5px;'>\
                                      <textarea id='textAreaDesc' value='"+descricao+"' class='textAreaDesc435453' id='multiliner' name='multiliner'>"+descricao+"</textarea>\
								</div>\
                             </div>\
                             <!-- VALORES --> \
                             <div style='column-gap: 2px; padding-bottom: 1px; padding-top: 1px; width: 100%; height: 26%; font-size: 12px; color: #A0BB31; display: flex'>\
                                <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 25%; background-color: #a0bb31'>\
                                   <div style='height: 50%; font-weight: 700;    font-size: 10px; color: #00345c; display: flex; justify-content: center; align-items: center'>Valor Unitário (BRL)</div>\
                                   <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input class='inputDetalhes32432' type='text' id='valorUnitario' name='lname' value='"+valorUnitario+"'/> </div>\
                                </div>\
                                <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 12.5%; background-color: #a0bb31'>\
                                   <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>QNTD</div>\
                                   <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input class='inputDetalhes32432' type='text' id='quantidade' name='lname' value='"+quantidade+"'/> </div>\
                                </div>\
                                <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 25%; background-color: #a0bb31'>\
                                   <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>Subtotal (BRL)</div>\
                                   <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input class='inputDetalhes32432' type='text' id='subtotal' name='lname' value='"+subtotal+"'/> </div>\
                                </div>\
                                <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 12.5%; background-color: #a0bb31'>\
                                   <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>DESC.</div>\
                                   <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input class='inputDetalhes32432' type='text' id='desconto' name='lname' value='"+desconto+"'/> </div>\
                                </div>\
                                <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 25%; background-color: #a0bb31'>\
                                   <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>Total (BRL)</div>\
                                   <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input disabled='true' class='inputDetalhes32432' type='text' id='totalItemPai' name='lname' value='"+total+"'/> </div>\
                                </div>\
                             </div>\
                             <!-- TOTAL DA MAIN UNITY --> \
                             <div style='background-color: grown; width: 100%; height: 20%'>\
                                <div style='font-weight: 700; color: white; background-color: #00345c; height: 100%; width: 100%; display: flex; justify-content: center; align-items: center; border-radius: 7px;' id='totalKit'> TOTAL: BRL 303.000,00 </div>\
                             </div>\
                          </div>\
                       </div>\
                       <div id='divProdutosFilhos' class='itemMainCotacao divProdutosFilhos' style='flex-direction: column!important;'>\
                          <div id='produtosFilhosDrop' class='produtosFilhosDrop' style='padding-top: 5px; display: flex; width: 100%; height: 95%; overflow: auto; flex-direction: column; align-items: flex-end;'> </div>\
                          <div id='exibirProdutosText' class='exibirProdutosDiv32478237'> <a id='exibirProdutosTextTag'>Exibir produtos filhos</a> </div>\
                       </div>\
                    </div>";
                    
                    htmlFinal = htmlFinal + inputHtml
                })
                
                $("#listaCotacao").append(htmlFinal)
                helper.ativaDragAndDrop(cmp, event, helper)
                
				htmlFinal = ''
                //ADICIONA ITENS FILHOS AOS ITENS PAIS---------------------------------
                itensFilho.forEach(function (itemFilho) {
                    
                    //DEFINE A VISUALIZAÇÃO DO NOME DO PRODUTO-------------------------
                    var nomeItem = itemFilho.Name.length >= 19 ? (itemFilho.Name.substring(0, 19) + "...") : itemFilho.Name;
                    //-----------------------------------------------------------------

                    //DEFINE A VARIAVEL DE DESCRIÇÃO (MODELO, MARCA E CODIGO)----------
                    if (itemFilho.Modelo__c === undefined) { var modelo = "Model. Não Cadastrado" } else { var modelo = itemFilho.Modelo__c }

                    var codigo = itemFilho.CodigoFabricante;
                    var marca = itemFilho.Marca__c;
                    var modCodMarca = modelo + " | " + marca + ": " + codigo
                    //-----------------------------------------------------------------

                    //DEFINE DESCRIÇÃO DO PRODUTO, IMAGEM E NÚMERO DO ITEM-------------
                    var descricao = itemFilho.Description ? itemFilho.Description : "Sem Descrição";
                    var imageUrl = itemFilho.Image;
                    var numberItem = itemFilho.Item__c;
                    var idItemCotacao = itemFilho.id
                    //-------------------------------------------------------------------

                    //DEFINE VARIÁVEIS DE VALORES DOS PRODUTOS-------------------------
                    var valorUnitario = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(itemFilho.Valor);
                    var quantidade = itemFilho.Quantidade;
                    var subtotal = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(itemFilho.SubTotal);

                    if (itemFilho.Desconto === undefined) { var desconto = "0.0%" } else { var desconto = itemFilho.Desconto.toFixed(1) + "%"; }

                    var total = new Intl.NumberFormat('id', { minimumFractionDigits: 2 }).format(itemFilho.Total);
                    //----------------------------------------------------------------

                    //PERCORRE O DOM DE ITENS PAIS INSERIDOS----------------------------
                    $('#listaCotacao').children().each(function () {
                        //CHAMA FUNÇÃO QUE SETA A DIV DOS PRODUTOS FILHOS COMO ARRASTÁVEL---
                        //helper.ativaDragAndDropFilhos(cmp, this, helper)
                        //------------------------------------------------------------------

                        //CASO O ITEM PAI CORRESPONDA AO ITEM FILHO, INSERE O ITEM FILHO NO ITEM PAI
                        if ($(this).attr('data-item-c') === String(itemFilho.Item_Pai__c)) {

                            //CRIA A VARIÁVEL COM O ITEM QUE SERÁ ADICIONADO-------------------
							var inputHtml = $("\
                            <div class='containerCotacao' data-marca='" + marca + "' data-codigoHospcom='" + itemFilho.codigoHospcom + "' data-codigoFabricante='" + codigo + "' data-modelo='" + modelo + "' data-name='" + itemFilho.Name + "' data-image='" + imageUrl + "' data-idItemCotacao='" + idItemCotacao + "' style='width: 95%!important; margin-right: 5px;'>\
                               <div class='itemMainCotacao' style='padding: 5px; margin-bottom: 0px'>\
                                  <!-- IMAGEM DO ITEM --> \
                                  <div style='background-color: ; width: 20%'> <img src='" + imageUrl + "' style='height: auto; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/> </div>\
                                  <!-- DIVISOR --> \
                                  <div style='display: flex; height: 100%; width: 4%; align-items: center; justify-content: center;'>\
                                     <hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
                                  </div>\
                                  <!-- INFO DO ITEM --> \
                                  <div style='background-color: ; width: 76%; display: flex; flex-direction: column'>\
                                     <!-- NOME DO ITEM E BOTÕES DE AÇÃO --> \
                                     <div style='position: relative; display: flex; align-items: center; width: 100%; height: 29%'>\
                                        <div style='display: flex; align-items: center; width: 80%; height: 100%; font-size: 20px; color: #00345c; font-weight: bold;'>" + nomeItem + "</div>\
                                        <div style='justify-content:center; align-items: center; display: flex; align-items: center; width: 10%; height: 100%; font-size: 20px; color: #00345c; font-weight: bold; opacity: 0'>\
                                           <div class='' style=''>#1</div>\
                                        </div>\
                                        <div id='buttonOptions' class='dropItemOptions3243'>\
                                           <div class='buttonNumberItem' style='border: 0px'> <i class='fa fa-sort-desc' style='color: #00345c; font-size: 18px;' aria-hidden='true'></i> </div>\
                                        </div>\
                                        <!-- MENU OPTIONS ITEM --> \
                                        <div style='display: none; flex-direction: column' class='menuOptions' id='menuOptionsId'>\
                                           <div class='option32423 optionRemoveOptions' id='optionClose' style='width: 100%; height:33.3%; display: flex; justify-content: right; align-items: center'>\
                                              <div style='width: 80%; height: 100%; color: red; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Remover</div>\
                                              <div style='width: 20%; height: 100%; color: red; display: flex; align-items: center; justify-content: center; text-align: center'> <i class='fa fa-times-circle' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i> </div>\
                                           </div>\
                                           <div class='option32423 optionShowDetails' id='optionShowDetails' style='width: 100%; height:33.3%; display: flex; justify-content: right; align-items: center'>\
                                              <div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Exibir Detalhes</div>\
                                              <div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; justify-content: center; text-align: center'> <i class='fa fa-th-large' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i> </div>\
                                           </div>\
                                           <div class='option32423 optionCloseOptions' id='optionCloseOptions' style='width: 100%; height:33.3%; display: flex; justify-content: right; align-items: center'>\
                                              <div style='width: 80%; height: 100%; color: #a0bb31; display: flex; padding-right: 5px; justify-content: right; align-items: center; '>Fechar</div>\
                                              <div style='width: 20%; height: 100%; color: #a0bb31; display: flex; align-items: center; justify-content: center; text-align: center'> <i class='fa fa-minus-circle' style='width: 100%; height: 100%; display: flex; font-size: 20px; align-items:center; text-align:center' aria-hidden='true'></i> </div>\
                                           </div>\
                                        </div>\
                                     </div>\
                                     <!-- MODELO DO ITEM --> \
                                     <div style='width: 90%; height: 15%; font-size: 12px; color: #00345c; display: flex; align-items: center'>" + modCodMarca + "</div>\
                                     <!-- DIVISOR --> \
                                     <div style='display: flex; height: 4%; height: 13%; align-items: center;'>\
                                        <hr style='border-top: 1px solid #dcdcdc; margin-top: 2px; width: 95%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
                                     </div>\
                                     <!-- DESCRIÇÃO --> \
                                     <div style='width: 100%; height: auto'>\
                                        <div style='font-size: 11px; color: #00345e; height: auto; width: 100%; display: flex; justify-content: center; align-items: center; border-radius: 5px;'> <textarea class='textAreaDesc435453' value='"+descricao+"' style='border: 0.1px solid rgb(160, 187, 49); border-radius: 4px; height: 20px; min-height: 20px; width: 100%; overflow: hidden;' id='textAreaDesc' name='multiliner'>"+descricao+"</textarea> </div>\
                                     </div>\
                                     <!-- VALORES --> \
                                     <div style='column-gap: 2px; padding-bottom: 1px; padding-top: 1px; width: 100%; height: 31%; font-size: 12px; color: #A0BB31; display: flex'>\
                                        <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 25%; background-color: #a0bb31'>\
                                           <div style='height: 50%; font-weight: 700; color: #00345c;    font-size: 10px; display: flex; justify-content: center; align-items: center'>Valor Unitário (BRL)</div>\
                                           <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input class='inputDetalhes32432' style='text-align: center; background-color: rgb(0, 0, 0, 0); border: 0px solid;width: 100%;height: 100%;' type='text' id='valorUnitario' name='lname' value='"+valorUnitario+"'/> </div>\
                                        </div>\
                                        <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 12.5%; background-color: #a0bb31'>\
                                           <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>QNTD</div>\
                                           <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input class='inputDetalhes32432' style='text-align: center; background-color: rgb(0, 0, 0, 0); border: 0px solid;width: 100%;height: 100%;' type='text' id='quantidade' name='lname' value='"+quantidade+"'/> </div>\
                                        </div>\
                                        <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 25%; background-color: #a0bb31'>\
                                           <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>Subtotal (BRL)</div>\
                                           <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input class='inputDetalhes32432' style='text-align: center; background-color: rgb(0, 0, 0, 0); border: 0px solid;width: 100%;height: 100%;' type='text' id='subtotal' name='lname' value='"+subtotal+"'/> </div>\
                                        </div>\
                                        <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 12.5%; background-color: #a0bb31'>\
                                           <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>DESC.</div>\
                                           <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input class='inputDetalhes32432' style='text-align: center; background-color: rgb(0, 0, 0, 0); border: 0px solid;width: 100%;height: 100%;' type='text' id='desconto' name='lname' value='"+desconto+"'/> </div>\
                                        </div>\
                                        <div style='border-radius: 5px; display: flex; justify-content: center; flex-direction: column; height: 100%; width: 25%; background-color: #a0bb31'>\
                                           <div style='height: 50%; font-weight: 700; color: #00345c; display: flex; justify-content: center; align-items: center'>Total (BRL)</div>\
                                           <div style='height: 50%; font-weight: 600; color: white; display: flex; justify-content: center; align-items: center'> <input disabled='disabled' style='text-align: center; background-color: rgb(0, 0, 0, 0); border: 0px solid;width: 100%;height: 100%;' type='text' id='totalItem' name='lname' value='"+total+"'/> </div>\
                                        </div>\
                                     </div>\
                                  </div>\
                               </div>\
                            </div>");
                            
                            //ADICIONA O ITEM--------------------------------------------------
                            $(this).find("#produtosFilhosDrop").append(inputHtml)
                            //-----------------------------------------------------------------

                            //DEFINE O VALUE NA DESCRIÇÃO DO PRODUTO--------------------------------
                            //inputHtml.find("#textAreaDesc").val(descricao)
                            //----------------------------------------------------------------------

                            //DEFINE O VALOR, QNT, SUBTOTAL, DESCONTO  E TOTAL DO PRODUTO------
                            //inputHtml.find("#valorUnitario").val(valorUnitario)
                            //inputHtml.find("#quantidade").val(quantidade)
                            //inputHtml.find("#subtotal").val(subtotal)
                            //inputHtml.find("#desconto").val(desconto)
                            //inputHtml.find("#totalItem").val(total)
                            //inputHtml.find("#totalItem").prop('disabled', true);
                            //----------------------------------------------------------------

                            /*EXPANDE OU RECOLHE O TEXTAREA------------------------------------
                            inputHtml.find("#textAreaDescFilho").click(function () {
                                $(this).css({ "height": "200px" });
                            })
                            inputHtml.find("#textAreaDescFilho").focusout(function () {
                                $(this).css({ "height": "20px" });
                            })
                            //----------------------------------------------------------------- */

                            /*EXPANDE E RECOLHE O MENU DE OPÇÕES DO ITEM-----------------------
                            inputHtml.find("#buttonOptions").click(function () {
                                if ($(this).parent().find("#menuOptionsId").css('display') == 'none') {
                                    $(this).parent().find("#menuOptionsId").css({ "display": "flex" });
                                } else {
                                    $(this).parent().find("#menuOptionsId").css({ "display": "none" });
                                }
                            }) */

                            /*RECOLHE O MENU CASO CLICK EM FECHAR------------------------------
                            inputHtml.find("#optionCloseOptions").click(function () {
                                $(this).parent().css({ "display": "none" });
                            })
                            //------------------------------------------------------------------ */

                            /*ALTERA CORES COM HOVER NO MENU DE OPÇÕES DO ITEM------------------
                            inputHtml.find("#buttonOptions").hover(function () {
                                $(this).find(".buttonNumberItem").css({ "background-color": "#cfcfcf" })

                            }, function () {
                                $(this).find(".buttonNumberItem").css("background-color", "#f4f4f4");
                            });
                            //------------------------------------------------------------------ */

                            /*EXIBE DETALHES DO ITEM--------------------------------------------
                            inputHtml.find("#optionShowDetails").click(function () {
                                helper.exibeDetalhesItem(cmp, helper, inputHtml)
                            })
                            //------------------------------------------------------------------ */

                            /*REMOVE ITEM DA COTAÇÃO--------------------------------------------
                            inputHtml.find("#optionClose").click(function () {
                                helper.removeItemCotacao(cmp, event, helper, this, 0)
                            })
                            //------------------------------------------------------------------ */

                            /*ATUALIZA OS DADOS DO ITEM------------------------------------------
                            inputHtml.find("#valorUnitario, #quantidade, #subtotal, #desconto, #textAreaDesc").change(function () {
                                helper.atualizaItem(cmp, event, helper, this)
                            })
                            //------------------------------------------------------------------ */
                        }
                    });
                })
                
                helper.ativaDragAndDropFilhos(cmp, event, helper)
                
                if (option == 1) {
                    helper.atualizaListaItens(cmp, event, helper)
                    helper.calculaTotais(cmp, event, helper);
                    helper.eventsAfterAppend(cmp, event, helper);
                } else {
                    //CALCULA O VALOR TOTAL DO KIT-------------------
                    helper.calculaTotais(cmp, event, helper);
                    //-----------------------------------------------

                    helper.eventsAfterAppend(cmp, event, helper);

                    //OCULTA SPINNER DE CARREGAMENTO---
                    helper.hideSpinner(cmp);
                    //---------------------------------
                }
            })

            //TRATA EXCEÇÕES DE ERRO NA CONSULTA
            .catch(function (error) {
                console.log(error)
            })
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