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
    posicaoDivCotacao: 0,
    posicaoDivProdutoFilho: 0,
    numeroDivEmEdicao: 0,
    idsItensCotacao: [],
    filtroOpcao: '',
    filtroChecked: false,
    filtroModelo: '',
    perfisHabilitadosPCs: ['Administrador do sistema', 'Comunidade Logística', 'Analista de Compras', 'Assistente de Compras'],
    //-------------------------------------------
    
    inputPesquisa: "null",
    
    customEstoques: [
       // {"Name":"ESTOQUE DISPONÍVEL","Id":"00000XXX1","Codigos":"'40', '302', '303', '305', '153'"},
        {"Name":"ESTOQUE DISPONÍVEL","Id":"00000XXX1","Codigos":"'153', '305', '31', '37', '10', '401', '42', '32', '77', '38', '155', '89', 'ORT-01', '406', '11', '154', '90', '289', '156', '20', '402', '33', '30', '36'"},
        {"Name":"ESTOQUE DE CONSULTA","Id":"00000XXX2","Codigos":"'389', '77', '40', '20', '15', '109', '35', '11', '60', '33', '30', '36', '22', '289', '21', '70', '34', '38', '10', '31', '02', '1', '50', '32', '37'"}
    ],
    
    addListeners: function (cmp) {
        
    },
    
    isEmpty: function (cmp, str) {
        return !str.trim().length;
    },
    
    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecorId: function (cmp, event, helper) {
        //var recordId = cmp.get("v.recordId");
        var recordId = '0Q05A000002JcSCSA0'
        
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
        
        //EXIBE O SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);
        
        helper.soql(cmp, "SELECT Pricebook2Id FROM quote WHERE id = '" + recordId + "'")
        .then(function (response) {
            response.forEach(function (resposta) {
                //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                $('#listaProdutos').click()
                //VARIÁVEL QUE ARMAZENA O ID DO LIVRO DE PREÇOS
                var pricebook2id = resposta.Pricebook2Id;
                
                //VALIDA APLICAÇÃO DO FILTRO NA PESQUISA--------------------------------------
                //SE O INPUT DE PESQUISA NÃO FOR VAZIO----------------------------------------
                if (filtro === "null" && inputPesquisa != "all") {
                    var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND (Name like '%" + inputPesquisa + "%' OR Modelo__c like '%" + inputPesquisa + "%' OR Marca__c like '%" + inputPesquisa + "%' OR ProductCode like '%" + inputPesquisa + "%') ORDER BY  LastModifiedDate  DESC LIMIT 100"
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
                                            var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true ORDER BY LastModifiedDate  DESC LIMIT 100"
                                            } else if (filtro === 'familia') {
                                                var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND Linha__c = '" + helper.selectLinha + "' ORDER BY LastModifiedDate  DESC LIMIT 100"
                                                } else if (filtro === 'tipo') {
                                                    var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' ORDER BY LastModifiedDate  DESC LIMIT 100"
                                                    } else if (filtro === 'marca') {
                                                        var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' ORDER BY LastModifiedDate  DESC LIMIT 100"
                                                        } else if (filtro === 'end') {
                                                            var query = "SELECT Name, Tipo_do_Produto__c, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Estoque_disponivel__c  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '" + pricebook2id + "') AND IsActive = true AND Linha__c = '" + helper.selectLinha + "' AND Family = '" + helper.selectFamilia + "' AND  Tipo_do_Produto__c = '" + helper.selectTipo + "' AND Marca__c = '" + helper.selectMarca + "' ORDER BY LastModifiedDate  DESC LIMIT 100"
                                                            }
                                    } else {
                                        console.log("else geral")
                                        //var query = "SELECT Name, ID_do_Produto__c, URL_da_Imagem__c, Modelo__c, Qtd_Aguardando_Recebimento__c, Valor_Total__c, Description, ProductCode, Marca__c, Quantidade_em_Estoque_Oficial__c, Type  FROM Product2 WHERE id in (SELECT product2id FROM priceBookEntry WHERE pricebook2id = '"+pricebook2id+"') AND IsActive = true AND (Name like '%"+inputPesquisa+"%' OR Modelo__c like '%"+inputPesquisa+"%' OR Marca__c like '%"+inputPesquisa+"%') ORDER BY Name LIMIT 200"
                                    }
                //---------------------------------------------------------------------------
                
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
                        var tipoProduto = produtoAtual.Tipo_do_Produto__c
                        
                        //ADICIONA O ITEM À DIV
                        $('#listaProdutos').append("<div id='" + contId + "' data-idProduto='" + idProduto + "' class='itemPesquisa' data-descricao='" + produtoDescricaoData + "' data-codigo='" + produtoAtual.ProductCode + "' data-marca='" + produtoAtual.Marca__c + "' data-modelo='" + produtoAtual.Modelo__c + "' data-image='" + produtoAtual.URL_da_Imagem__c + "' name='" + produtoAtual.Name + "'> <!-- IMAGEM DO ITEM --> <div style='width: 26%; display: flex; align-items:center; justify-content: center;'> <img src='" + produtoAtual.URL_da_Imagem__c + "' style=' height: 90%; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/> </div> <!-- DIVISOR --> <div style='display: flex; height: 100%; width: 4%; align-items: center;'> <hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/> </div> <!-- INFO DO ITEM --> <div style='background-color: ; width: 70%; display: flex; flex-direction: column'> <!-- NOME DO ITEM --> <div style=' width: 100%; height: 24%; font-size: 14px; color: #00345c; font-weight: bold;'>" + produtoAtual.Name.substring(0, 17) + "...</div> <!-- MODELO DO ITEM --> <div style='background-color: ; width: 100%; height: 24%; font-size: 12px; color: #00345c;'>" + String(produtoAtual.Modelo__c).substring(0, 30) + "</div> <!-- DIVISOR --> <div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div> <!-- MARCA E CÓDIGO ITEM --> <div style=' width: 100%; height: 24%; font-size: 12px; color: #A0BB31;'>" + produtoAtual.Marca__c + ": " + produtoAtual.ProductCode + "</div> <!-- STATUS STOQUE ITEM --> <div style='background-color: grown; width: 100%; height: 24%'> <div style='color: white; background-color: " + corEtiqueta + "; height: 100%; width: 70%; display: flex; justify-content: center; align-items: center; border-radius: 120px; font-size: 13px;'>" + quantEstoque + "</div> </div> </div> <!-- DESCRIÇÃO FLUTUANTE DO ITEM --> <div class='divDescricaoItem' style='display: none; flex-direction: column; padding: 10px; border: 0.01px solid " + corEstoque + ";'> <!-- NOME DO ITEM --> <div class='itemNameFlutuante'>" + produtoAtual.Name + " </div> <!-- DIVISOR --> <div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div> <!-- MODELO DO ITEM --> <div style='height: 15%; width: 100%; display: flex'> <!-- NOME DO MODELO --> <div style='width: 60%; height: 100%; font-size: 10px; color: #a0bb31'>" + produtoAtual.Marca__c + ": " + produtoAtual.ProductCode + "</div> <!-- MODELO DO ITEM --> <div style='width: 40%; height: 100%; font-size: 10px; color: #a0bb31; text-align: right;'> TIPO: " + tipoProduto + "</div> </div> <!-- DESCRIÇÃO DO ITEM --> <div class='descricaoFlutuanteItem'>" + produtoDescricao + " </div> <!-- RODAPÉ --> <div style='width: 100%; height: 26%; column-gap: 3px; display: flex'> <div class='containerRodape'> <div class='rodapeBlocos'> Preço de lista </div> <div class='rodapeBlocos' style=''>R$ " + new Intl.NumberFormat('id').format(produtoAtual.Valor_Total__c) + "</div> </div> <div class='containerRodape' style='background-color: #ffff00'> <div class='rodapeBlocos' style='color: #00345c'>Em recebimento</div> <div class='rodapeBlocos' style='color: #00345c;'>" + aguardandoReceber + "</div> </div> <div class='containerRodape' style='background-color: " + corEstoque + "'> <div class='rodapeBlocos'> Qnt. em estoque </div> <div class='rodapeBlocos' style='font-size: 11px!important;'>" + quantidadeEstoque + "</div> </div> </div>   </div>")
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
                    
                    /*
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
                    */
                    //ATIVA DRAG AND DROP NA COLUNA DA DIREITA---------
                    //helper.ativaDragAndDrop(cmp, event, helper)
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
                    helper.alertaErro(cmp, event, helper, error, "ERRO AO CONSULTAR PRODUTOS 003X", "error")
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
    
    ultimaMoeda : "",
    idioma : "",
    estoque : "",
    catalogoPreco : "",
    
    preenchePlataformaMkt: function (cmp, event, helper, categoriaPai) {
        
        if (categoriaPai === '') {
            var query = "SELECT idiomas_de_exibicao__c, Estoque__c, catalogo_de_precos_exibicao__c, Name, Id, Icone_url__c, Categoria_Pai__c, CurrencyIsoCode FROM MktCategoria__c WHERE Ativo__c = true AND Categoria_Pai__c = '" + categoriaPai + "' ORDER BY Name"
            } else {
                var query = "SELECT idiomas_de_exibicao__c, Estoque__c, catalogo_de_precos_exibicao__c, Name, Id, Icone_url__c, Categoria_Pai__c, CurrencyIsoCode FROM MktCategoria__c WHERE Ativo__c = true AND Categoria_Pai__c = '" + categoriaPai + "' ORDER BY Ordem__c"
                }
        
        console.log("query plataforma mkt", query)
        
        //REALIZA A CONSULTA PASSANDO O ID DA CATEGORIA PAI
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (response) {
            
            console.log("resposta", response)
                        
            //RESETA O FILTRO DE MODELO
            helper.filtroModelo = ""
            
            if (response.length != 0) {
                
                $("#colunaPlataformaMkt").empty()
                
                response.forEach(function (categoria) {
                    
                    //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA--------------------
                    $('#listaProdutos').click()
                    
                    //DEFINE VARIÁVEIS DA CATEGORIA INSERIDAI----------------------
                    var nomeCategoria = String(categoria.Name) //.toUpperCase()
                    var categoriaPai = categoria.Categoria_Pai__C
                    var urlImagem = categoria.Icone_url__c
                    var moeda = categoria.CurrencyIsoCode
                    var idioma = categoria.idiomas_de_exibicao__c
                    var estoque = categoria.Estoque__c
                    var catalogoPreco = categoria.catalogo_de_precos_exibicao__c
                    //-------------------------------------------------------------
                    
                    //VARIÁVEL QUE RECUPERA O ID DA CATEGORIA--
                    var Id = categoria.Id
                    //-----------------------------------------
                    
                    //ADICIONA A CATEGORIA À DIV
                    var item = $("<a class='customAUnderline' data-catalogoPreco='"+catalogoPreco+"' data-estoque='"+estoque+"' data-idioma='"+idioma+"' data-moeda='"+moeda+"' data-urlImagem='" + urlImagem + "' data-idItem='" + Id + "'> <div  class='itemNavegacao' style=''> <div style='height: auto; padding-bottom: 10px; '> <div style='display: flex; width: 100%; justify-content: center; align-items: center;'> <img src='" + urlImagem + "' style='width: 100%; height: 100%; border-radius: 15px 15px 0px 0px; object-fit: cover;'/> </div> <div style='width: 100% height: auto; display: flex; padding-top: 10px; flex-direction: column; align-items: center'> <!-- NOME DA CATEGORIA --> <div id='nomeCategoria' style='width: 100%; height: 100%; font-size: calc(100% - 6px); color: #00345c; font-weight: 500; display: flex; justify-content: center; text-align: center;'>" + nomeCategoria + "</div> <div style='width: 20%; height: 100%; font-size: 14px; color: #00345c; font-weight: 500; display: flex; margin-left: 10px;'> </div> </div> </div> </div> </a>")
                    $("#colunaPlataformaMkt").append(item)
                    
                    //EVENTO DE CLICK NA CATEGORIA---------------------------------
                    $(item).click(function () {
                        
                        //EXIBE O SPINNER DE CARREGAMENTO
                        helper.showSpinner(cmp);
                        
                        helper.filtroOpcao = ''
                        helper.filtroChecked = false
                        
                        var idCategoriaPai = $(this).attr('data-idItem');
                        var urlImagem = $(this).attr('data-urlImagem');
                        var nomeCategoria = $(this).find("#nomeCategoria").text()
                        helper.ultimaMoeda = $(this).attr('data-moeda');
                        helper.idioma = $(this).attr('data-idioma');
                        helper.estoque = $(this).attr('data-estoque');
                        helper.catalogoPreco = $(this).attr('data-catalogoPreco');
                        
                        helper.ultimaCategoriaInserida = nomeCategoria
                        helper.imagemUltimaCategoriaInserida = urlImagem
                        
                        $(".breadcrumbs__item").css("background", "white")
                        $(".breadcrumbs__item").css("color", "#333")
                        
                        var item = $("<a style='background: #00345c; color: white' data-idItem='" + idCategoriaPai + "' class='breadcrumbs__item'>" + nomeCategoria + "</a>")
                        $("#breadcrumbsNav").append(item)
                        
                        var linkEdicao = "\
							<div class='linkEdicao' title='Clique para abrir a edição em uma nova guia'>\
								<a target='_blank' style='color: white' href='https://hospcom.my.site.com/Sales/s/mktcategoria/" + categoria.Id + "'>\
									<i class='fa fa-link' aria-hidden='true'></i>\
								</a>\
							</div>"
						$(".linkEdicao").remove()
                        $("#breadcrumbsNav").append(linkEdicao)

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
                                    $(".linkEdicao").remove()
                                    $("#breadcrumbsNav").append(linkEdicao)
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
                helper.preencheProdutosMkt(cmp, event, helper, categoriaPai, '', helper.filtroModelo)
            }
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //FUNÇÃO QUE BUSCA E PREECHE OS PRODUTOS NA GUIA DO MARKETING-
    preencheProdutosMkt: function (cmp, event, helper, categoriaPai, tipo, modelo) {
        //console.log(tipo)
        //
        var moeda = helper.ultimaMoeda
        
        //CRIA LISTA COM OS TIPOS DOS PRODUTOS
        var listaTipos = ["PEÇA", "EQUIPAMENTO", "MÓDULO", "CONSUMÍVEL", "ACESSÓRIO", "INSTRUMENTAL", "IMPLANTE", "FERRAMENTA", "SET CIRURGICO"]
        var listaModelos = []
        
        //EXIBE O SPINNER DE CARREGAMENTO
        helper.showSpinner(cmp);
        
        //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
        $('#colunaPlataformaMkt').click()
        
        //DEFINE A QUERY DE CONSULTA COM BASE NO TIPO RECEBIDO----
        var query = "SELECT Name, Parte__r.valor_de_venda_usd__c, Parte__r.Total_aguardando_entrega_transicional__c, Parte__r.StockKeepingUnit, Parte__r.Name, Parte__r.Description, Tipo__c, Parte__r.ProductCode, Parte__r.Qtd_Aguardando_Recebimento__c, Parte__r.Estoque_disponivel__c, Parte__r.Marca__c,  Parte__r.ID_do_Produto__c, Parte__r.Modelo__c, Parte__r.URL_da_Imagem__c, Parte__r.Valor_Total__C, Parte__c FROM MktParte__c WHERE Ativo__c = true AND " + "Categoria__c = '" + categoriaPai + "'"
        query += (modelo === '') ? "" : " AND  Parte__r.Modelo__c = '" + modelo + "'"
        query += (tipo === '') ? "" : " AND  Tipo__c = '" + tipo + "'"
        query += 'ORDER BY Ordem__c'
        //-------------------------------------------------------
        
        console.log(query)
        
        //REALIZA A CONSULTA AOS PRODUTOS FILTRANDO PELO LIVRO DE PREÇO ATUAL
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (produtos) {
            
            //VARIÁVEL CONTADORA DAS DIVS INSERIDAS
            var contId = 1;
            
            //LIMPA A TELA DE EXIBIÇÃO DOS PRODUTOS
            $('#colunaPlataformaMkt').empty();
            
            //ADICIONA CABEÇALHO COM O TÍTULO DA CATEGORIA PAI E OS FILTROS DOS RESULTADOS
            $('#colunaPlataformaMkt').append("\
<!-- APPEND DOS ITENS -->\
<a class='containerHeaderResult' data-idItem='' style='width: 100%;'>\
    <div class='itemResultadoNavegacao' style='width: auto; margin-right: 0px!important'>\
        <div style='height: auto; padding: 10px; display: flex;'>\
            <div style='display: flex; width: 15%; justify-content: center; align-items: center;'>\
            	<img src='" + helper.imagemUltimaCategoriaInserida + "' style='width: 150px; height: 140px; border-radius: 10px; object-fit: contain;'/>\
            </div>\
\
			<div style='width: 85%; height: auto; display: flex; flex-direction: column; align-items: center'>\
                <!-- NOME DA CATEGORIA -->\
                <div id='nomeCategoria' style='margin-right: 10px; border-bottom: 1px solid #f3e4e4; align-items: center; width: 100%; height: 30%; font-size: 14px; color: #00345c; font-weight: 500; display: flex; justify-content: center; text-align: center;'>" + helper.ultimaCategoriaInserida + "</div>\
                <div id='listaFiltrosMkt'>\
                <!-- APPEND DOS TIPOS -->\
                </div>\
				<!--SELECT COM OS MODELOS-->\
				<div style='width: 100%; display: flex'>\
                    <select name='select' class='selectpicker show-tick' id='selectModelo'>\
                      	<option selected disabled value='default'>Selecione um modelo</option>\
						<option value='nenhum'>Todos os modelos</option>\
                    </select>\
				</div>\
            </div>\
        </div>\
    </div>\
</a>\
\
<!--ARQUIVOS DE MIDIA -->\
<div style='flex-direction: column !important; height:20px !important;' class='itemMainCotacao divProdutosFilhos' id='divProdutosFilhos'>\
<div style='padding-top: 5px; display: flex; width: 100%; height: 95%; overflow: auto; flex-direction: column; opacity: 1;' class='produtosFilhosDrop' id='produtosFilhosDrop'>\
</div>\
<div style='display: flex; width: 100%; height: 5%; justify-content: center; align-items: center' id='exibirProdutosText'>\
<a id='exibirProdutosTextTag'>Exibir arquivos de mídia</a>\
</div>\
</div>")

            
            //EXPANDE E RECOLHE A DIV COM OS PRODUTOS FILHOS--------------------
            $('#colunaPlataformaMkt').find("#exibirProdutosText").click(function () {
                //Se o tamanho da div = 300, ou seja, já está expandida, então recolhe
                if ($(this).closest('#divProdutosFilhos').css('height') == '300px') {
                    helper.numeroDivEmEdicao = 0
                    $(this).closest('#divProdutosFilhos').attr("style", $(this).closest('#divProdutosFilhos').attr("style") + 'height: 20px !important;');
                    $(this).children('#exibirProdutosTextTag').text('Exibir arquivos de mídia'); //ok
                    $(this).closest('#divProdutosFilhos').children('#produtosFilhosDrop').css({ "opacity": "0" })
                } else {
                    //SE NÃO A DIV ESTÁ RECOLHIDA, LOGO EXPANDE
                    helper.numeroDivEmEdicao = $(this).closest('.containerCotacao').attr('data-item-c')
                    $(this).closest('#divProdutosFilhos').attr("style", $(this).closest('#divProdutosFilhos').attr("style") + 'height: 300px !important;');
                    $(this).children('#exibirProdutosTextTag').text('Ocultar arquivos de mídia');
                    $(this).closest('#divProdutosFilhos').children('#produtosFilhosDrop').css({ "opacity": "1" })
                }
            })
            //------------------------------------------------------------------
            
            //LOOP QUE PERCORRE TODOS OS PRODUTOS ENCONTRADOS, ITERANDO SOBRE PRODUTOATUAL---------------------------------------
            produtos.forEach(function (produtoAtual) {
                
                //VERIFICA SE O PRODUTO POSSÚI DESCRIÇÃO---
                if (String(produtoAtual.Parte__r.Description) == undefined || String(produtoAtual.Parte__r.Description) == "undefined") {
                    var produtoDescricao = "PRODUTO SEM DESCRIÇÃO"
                    var produtoDescricaoData = "PRODUTO SEM DESCRIÇÃO"
                    } else {
                        var produtoDescricao = String(produtoAtual.Parte__r.Description).substring(0, 900).toUpperCase()
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
                        var aguardandoReceber = produtoAtual.Parte__r.Total_aguardando_entrega_transicional__c
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
                        
                        var aguardandoReceber = produtoAtual.Parte__r.Total_aguardando_entrega_transicional__c
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
                    
                    var aguardandoReceber = produtoAtual.Parte__r.Total_aguardando_entrega_transicional__c
                    if (aguardandoReceber === undefined || aguardandoReceber === "undefined") {
                        aguardandoReceber = "0 UND"
                    }
                }
                //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                
                console.log("Moeda interno", moeda)
                
                var idProduto = produtoAtual.Parte__r.ID_do_Produto__c
                var nomeProduto = produtoAtual.Parte__r.Name
                var codigoProduto = produtoAtual.Parte__r.ProductCode
                var marcaProduto = produtoAtual.Parte__r.Marca__c
                var modeloProduto = produtoAtual.Parte__r.Modelo__c
                var urlImagemProduto = produtoAtual.Parte__r.URL_da_Imagem__c
                var valorTotalProduto = moeda == 'BRL' ? produtoAtual.Parte__r.Valor_Total__c : produtoAtual.Parte__r.Valor_de_Venda_USD__c
                //var valorTotalProduto = produtoAtual.Parte__r.Valor_Total__c
                var tipoProduto = produtoAtual.Tipo__c
                var codigoHospcom = produtoAtual.Parte__r.StockKeepingUnit
                
                //INSERE O MODELO NO ARRAY DE MODELOS
                listaModelos.push(modeloProduto)
                //-----------------------------------

                //CONFIGURA A COR DA LABEL DO RECEBIMENTO----------
                if (aguardandoReceber == 0){
                    var corRecebimento = "#f40a29"
                    }else{
                        var corRecebimento = "rgb(254, 208, 50)"
                        }
                //--------------------------------------------------
                
                var item = $("\
<div data-codigoHospcom='"+codigoHospcom+"' data-valorTotal='"+valorTotalProduto+"' data-codigoFabricante='"+codigoProduto+"' data-modelo='"+modeloProduto+"' id='" + contId + "' data-idProduto='" + idProduto + "' class='itemPesquisa' data-descricao='" + produtoDescricaoData + "' data-codigo='" + codigoProduto + "' data-marca='" + marcaProduto + "' data-modelo='" + modeloProduto + "' data-image='" + urlImagemProduto + "' name='" + nomeProduto + "'>\
<!-- IMAGEM DO ITEM -->\
<div style='width: 26%; display: flex; align-items:center; justify-content: center;'>\
<a class='imageItemProd' target='_blank' title='Clique para abrir o produto' href='https://hospcom.my.site.com/Sales/s/product2/"+idProduto+"' ><img src='" + urlImagemProduto + "' style='height: 90%; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/>\
</div></a>\
<!-- DIVISOR -->\
<div style='display: flex; height: 100%; width: 4%; align-items: center;'>\
<hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
</div>\
<!-- INFO DO ITEM -->\
<div style='background-color: ; width: 70%; display: flex; flex-direction: column'>\
        <!-- NOME DO ITEM -->\
        <div class='colunaItemNome' style=''>\
            <div style='height: 100%; width: 70%;'>\
                <div class='nomeProduto' style=''>\
                    " + nomeProduto.substring(0, 20) + ( nomeProduto.length > 20 ? '...' : '') + "\
                </div>\
                <!-- MODELO DO ITEM -->\
                <div style='width: 100%; height: 50%; font-size: 10px; color: #00345c;'>\
                    " + ( modeloProduto != undefined ? String(modeloProduto) : 'Modelo não cadastrado' ) + "\
                </div>\
            </div>\
				<div class='divPrecoListaPrincipal' style=''>\
				<div class='containerRodape' style='border-radius: 100px!important; width: 80%!important; height: 70%'>\
                    <div class='rodapeBlocos'> Preço de lista </div>\
                    <div class='rodapeBlocos' style='font-size: 11px!important;'>"+moeda+" " + new Intl.NumberFormat('id').format(valorTotalProduto) + "</div>\
                </div>\
            </div>\
        </div>\
<!-- DIVISOR -->\
<div style='display: flex; height: 4%'> <hr class='divisorHorizontal'/> </div>\
<!-- MARCA E CÓDIGO ITEM -->\
<div style=' width: 100%; height: 24%; font-size: 12px; color: #A0BB31;'>" + marcaProduto + ": " + codigoProduto + "</div>\
<!-- STATUS STOQUE ITEM -->\
<div style='display: flex; flex-direction: row; column-gap: 10px; background-color: grown; width: 100%; height: 24%'>\
<a class='tagButtonItem'><div class='divEstoque' id='divEstoque' style='background-color: " + corEtiqueta + "'>\
" + quantEstoque + "\
</div></a>\
<a class='tagButtonItem'><div class='divAguardandoReceber' id='divAguardandoReceber' style='background-color: " + corRecebimento + "'>\
" + aguardandoReceber + " EM RECEBIMENTO\
</div></a>\
</div>\
</div>\
<!-- DESCRIÇÃO FLUTUANTE DO ITEM -->\
<div class='divDescricaoItem' style='display: none; flex-direction: column; padding: 10px; border: 0.01px solid " + corEstoque + ";'>\
<!-- NOME DO ITEM -->\
<div class='itemNameFlutuante'>\
" + nomeProduto + "\
</div><!-- DIVISOR -->\
<div style='display: flex; height: 4%'>\
<hr class='divisorHorizontal'/>\
</div><!-- MODELO DO ITEM -->\
<div style='height: 15%; width: 100%; display: flex'>\
<!-- NOME DO MODELO -->\
<div style='width: 60%; height: 100%; font-size: 10px; color: #a0bb31'>\
" + marcaProduto + ": " + codigoProduto + "\
</div><!-- MODELO DO ITEM -->\
<div style='width: 40%; height: 100%; font-size: 10px; color: #a0bb31; text-align: right;'> TIPO: "+tipoProduto+" </div>\
</div> <!-- DESCRIÇÃO DO ITEM -->\
<div class='descricaoFlutuanteItem'>" + produtoDescricao + "</div> <!-- RODAPÉ -->\
<div style='width: 100%; height: 26%; column-gap: 3px; display: flex'>\
<div class='containerRodape'>\
<div class='rodapeBlocos'> Preço de lista </div>\
<div class='rodapeBlocos' style='font-size: 11px!important;'>R$ " + new Intl.NumberFormat('id').format(valorTotalProduto) + "</div>\
</div>\
<div class='containerRodape' style='background-color: #ffff00'>\
<div class='rodapeBlocos' style='color: #00345c'>Em recebimento</div>\
<div class='rodapeBlocos' style='color: #00345c; font-size: 11px!important;'>" + aguardandoReceber + "</div>\
</div>\
<div class='containerRodape' style='background-color: " + corEstoque + "'>\
<div class='rodapeBlocos'> Qnt. em estoque </div>\
<div class='rodapeBlocos' style='font-size: 11px!important;'>" + quantidadeEstoque + "</div>\
</div>\
</div>\
</div>");        
                      
                
              
                 
                 //ADICIONA O ITEM À DIV
                $('#colunaPlataformaMkt').append(item)                
                
                ////DANILO UPDATE CODIGO
                
               /* const codigo = item.attr('data-codigoFabricante');
                console.log("Código do produto:", codigo);
                
                 fetch('https://integracao.hospcom.net/stoky/salesforce', {
                 method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ codigoproduto: codigo })
                })
               .then(res => res.json())
               .then(data => {
               console.log('Atualização feita com sucesso:', codigo, data);
                })
               .catch(err => {
               console.error('Erro ao atualizar produto:', codigo, err);
               });*/
                
                
                ////DANILO UPDATE CODIGO
                 
                 
                 
                 
                //EVENTO DE CLIQUE NO BOTÃO PARA EXIBIR DETALHES DO ESTOQUE
                item.find("#divEstoque").click(function () {
                    console.log("clique")
                    helper.exibeDetalhesEstoque(cmp, helper, item)
                })
                //----------------------------------------------------------
                
                //EVENTO DE CLIQUE NO BOTÃO PARA EXIBIR DETALHES DO PRODUTO
                item.find("#divAguardandoReceber").click(function () {
                    helper.exibeDetalhesItem(cmp, helper, item)
                })
                //---------------------------------------------------------
                
                contId++;
            })
            //----------------------------------------------------------------------------------------------------------------
            
            
            listaModelos.sort()
            listaModelos.forEach(function (modeloAtual){
                //PREENCHE O SELECT COM OS MODELOS DO RESULTADO ATUAL
                if(modeloAtual != undefined){
                    if ( $("#selectModelo option[value='"+modeloAtual+"']").length == 0 ){
                        if(helper.filtroModelo == modeloAtual){
                            $('#selectModelo').append("<option selected value='"+modeloAtual+"'>"+modeloAtual+"</option>")
                        }else{
                            $('#selectModelo').append("<option value='"+modeloAtual+"'>"+modeloAtual+"</option>")
                        }
                        
                    }
                }
                //====================================================
            })
            
            //APLICA ESTILO EM TODAS OS SELECTS
            $('.selectpicker').selectpicker({
                dropupAuto: false            
            });
            
            //SELECT DE MODELO NOS RESULTADOS DA CONSULTA
            $('#selectModelo').on('changed.bs.select', function (e) {
                var modelo = $('#selectModelo').val();
                
                if(modelo == 'nenhum'){
                    helper.filtroModelo = ''
                }else{
                    helper.filtroModelo = modelo
                }
                
                helper.preencheProdutosMkt(cmp, event, helper, categoriaPai, helper.filtroOpcao, helper.filtroModelo)
            });
            //==================================
            
            //PERCORRE A LISTA DE TIPOS IDENTIFICADA, E ADICIONA À DIV
            listaTipos.forEach(function (tipoAtual) {
                if (tipo === tipoAtual) {
                    var item = $("<div class='form-check form-switch' data-tipo='" + tipoAtual + "' data-categoriaPai='" + categoriaPai + "' ><input class='form-check-input' type='checkbox' id='flexSwitchCheckDefault' checked='true' /> <label style='color: #00345c' class='form-check-label' for='flexSwitchCheckChecked'>" + tipoAtual + "</label> </div>")
                    } else {
                        var item = $("<div class='form-check form-switch' data-tipo='" + tipoAtual + "' data-categoriaPai='" + categoriaPai + "' ><input class='form-check-input' type='checkbox' id='flexSwitchCheckDefault' /> <label style='color: #00345c' class='form-check-label' for='flexSwitchCheckChecked'>" + tipoAtual + "</label> </div>")
                        }
                
                $("#listaFiltrosMkt").append(item)
                
                $(item).click(function () {
                    var categoriaPai = $(this).attr('data-categoriaPai')
                    var tipo = $(this).attr('data-tipo')
                    console.log(helper.filtroChecked, helper.filtroOpcao == tipo)
                    
                    if(helper.filtroChecked){
                        helper.filtroOpcao = tipo
                        helper.filtroChecked = !helper.filtroChecked
                    } else {
                        if(helper.filtroOpcao == tipo){
                            helper.filtroOpcao = ''
                            helper.filtroChecked = !helper.filtroChecked
                        } else {
                            helper.filtroOpcao = tipo                        
                        }
                    }
                    helper.preencheProdutosMkt(cmp, event, helper, categoriaPai, helper.filtroOpcao, helper.filtroModelo)
                })
            })
             
            //OUVINTE DE MOUSEOVER NOS ITENS INSERIDOS-----------------------------
            $(".itemPesquisa").mouseover(function () {
                var id = $(this).attr('id');
                if ((id % 2) === 0) {
                    $(".divDescricaoItem", this).css({ "margin-left": "-360px" });
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
            /*var el = document.getElementById('colunaPlataformaMkt');
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
                            })*/
            //-----------------------------------------------------------------------
            
            //ATIVA DRAG AND DROP NA COLUNA DA DIREITA---------
            //helper.ativaDragAndDrop(cmp, event, helper)
            //-------------------------------------------------
            
            //CHAMA FUNÇÃO QUE IRÁ PREENCHER OS FILTROS DE PESQUISA-
            helper.preencheFiltros(cmp, event, helper, inputPesquisa)
            //------------------------------------------------------
            
            //CHAMA FUNÇÃO GENÉRICA QUE ADICIONA EVENTOS APÓS A ATUALIZAÇÃO--
            helper.eventsAfterAppend(cmp, event, helper)
            //---------------------------------------------------------------
            
            //OCULTA SPINNER DE CARREGAMENTO---
            helper.hideSpinner(cmp);
            //---------------------------------
        })
        
        //TRATA EXCESSÃO DE ERRO DA CONSULTA
        .catch(function (error) {
            helper.alertaErro(cmp, event, helper, error, "ERRO AO CONSULTAR PRODUTOS 00X", "error")
        })
        
        
        var query = "SELECT Ativo__c, Name, DownloadId__c, URL_do_Arquivo__c, Extensao__c, Formato__c, Icone_url__c, Icone_mini__c, Interno__c, Player_externo__c, OwnerId, Quantidade_de_anexos__c, Tamanho__c, Tipo__c FROM MktMidia__c WHERE Ativo__c = true AND Categoria__c = '" + categoriaPai + "'"
        
        helper.soql(cmp, query).then(function (midias) {
            midias.forEach(function (midia) {
                
                //$('#colunaPlataformaMkt').append("\
                $('#produtosFilhosDrop').append("\
<div class='itemPesquisa' style='width: 97%!important; height: 120px!important;'>\
<div style='width: 16%; display: flex; align-items:center; justify-content: center;'>\
<img src='" + midia.Icone_url__c + "' style='height: 90%; border-bottom-left-radius: 10px; border-top-left-radius: 10px;'/>\
</div>\
<div style='display: flex; height: 100%; width: 4%; align-items: center;'>\
<hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
</div>\
<div style='background-color: ; width: 80%; display: flex; flex-direction: column'>\
<div style=' width: 100%; height: 24%; font-size: 14px; color: #00345c; font-weight: bold; padding-bottom: 20px;'>\
" + midia.Name + "\
</div>\
<div style='background-color: ; width: 100%; height: 20%; font-size: 12px; color: #00345c;'>\
Tipo: " + midia.Tipo__c + "\
</div>\
<div style='background-color: ; width: 100%; height: 20%; font-size: 12px; color: #00345c;'>\
Formato: " + midia.Formato__c + "\
</div>\
<div style='background-color: ; width: 100%; height: 20%; font-size: 12px; color: #00345c;'>\
Tamanho: " + midia.Tamanho__c + "\
</div>\
</div>\
<div class='containerMidiaButton'>\
" + (midia.DownloadId__c != undefined ? ("<button class='midiaButton midiaButtonDownload' id='midiaButtonDownload " + midia.DownloadId__c + "' '>Baixar</button>") : '') + "\
" + (midia.URL_do_Arquivo__c != undefined ? ("<button class='midiaButton midiaButtonShow' id='midiaButtonShow " + midia.URL_do_Arquivo__c + "'>Abrir</button>") : '') + "\
</div>\
</div>\
")
            })
            
            Array.from(document.getElementsByClassName("midiaButton")).forEach(e => e.addEventListener('click',function(){
                var id = e.id.split(' ')
                var url = (id[0] == 'midiaButtonDownload' ? 'https://hospcom.my.site.com/Sales/sfc/servlet.shepherd/version/download/' + id[1] : (id[0] == 'midiaButtonShow' ? id[1] : ''))
                window.open(url, '_blank').focus();                                
            }))
            
            //                        helper.preencheFiltros(cmp, event, helper, inputPesquisa)
            //                        helper.eventsAfterAppend(cmp, event, helper)
            //                        helper.hideSpinner(cmp);
            
        }).catch(function (error) {
            helper.alertaErro(cmp, event, helper, error, "ERRO AO CONSULTAR PRODUTOS 002X", "error")
        })
    },
    //---------------------------------------------------
    
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
        
        console.log(ultimoIndice)
        
        //var indices = []
        
        //$('#listaCotacao').children().each(function(){
        //indices.push(this.attr('data-item-c'))
        //console.log("preso loop")
        //})
        
        //var ultimoIndice = Math.max(indices)
        //console.log(ultimoIndice)
        
        //  if($('#listaCotacao').children().length === 0){
        // var ultimoIndice = 1
        // }else{
        //   $('#listaCotacao').children().each(function(){
        //     if(this.attr('data-item-c') >= ultimoIndice){
        //        var ultimoIndice = this.attr('data-item-c') + 1
        //   }else{
        //       var ultimoIndice = ultimoIndice + 1
        //  }
        // })
        //}
        //var ultimoIndice = 0
        
        return ultimoIndice//$('#listaCotacao').children().length //ultimoIndice 
    },
    //------------------------------------------------------------------
    
    //EXIBE DETALHES DO ITEM (NOME, MODELO, PEDIDO DE COMPRA, VALORES ETC...)
    exibeDetalhesItem: function (cmp, helper, item) {
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp);
        
        //DEFINE A VISUALIZAÇÃO DO NOME DO PRODUTO-------------------------
        var nomeItem = item.attr("name")//.length >= 20 ? (item.attr("data-name").substring(0,20) + "...") : item.attr("data-name");
        var urlImage = item.attr("data-image")
        var marca = item.attr("data-marca")
        var modelo = item.attr("data-modelo")
        var codigoFabricante = marca + ": " + item.attr("data-codigoFabricante")
        var codigoHospcom = "HOSPCOM: " + item.attr("data-codigoHospcom")
        var valorTotal = new Intl.NumberFormat('id', {minimumFractionDigits: 2 }).format(item.attr("data-valorTotal"));
        var idProduto = item.attr("data-idproduto")
        
        var inputHtml = $("<div class='containerDetalhes' id='containerDetalhes' style='display: flex'>\
<div class='containerDetalhesInterno'>\
<div style='width: 48%; height: 100%; display: flex;'>\
<div style='width: 100%; display: flex; justify-content: center; align-items: center;'>\
<img style='height: auto; border-bottom-left-radius: 10px; border-top-left-radius: 10px;' src='" + urlImage + "'/>\
</div>\
</div>\
<div style='display: flex; height: 100%; width: 4%; align-items: center; justify-content: center;'>\
<hr style='border-left: 1px solid #dcdcdc; margin-top: 0px; height: 90%; margin-bottom: 0; opacity: 1; background-color: #ffffff'/>\
</div>\
<div style='width: 48%; height: auto;'>\
<div style='width: 100%; height: auto; display: flex'>\
<div class='nomeProdutoDetails' style='width: 90%!important;'>\
" + nomeItem + "\
</div>\
<div id='closeButtonProdutoDetails' style='color: red; font-size: 25px; display: flex; justify-content: center; align-items: center; width: 10%; height: 100%;'>\
<a class='closeButtonProdutoDetails'>\
<i class='fa fa-times-circle' aria-hidden='true'></i>\
</a>\
</div>\
</div>\
<div class='modeloProdutoDetails'>\
" + modelo + "\
</div>\
<div class='codigosProdutosDetails'>\
" + codigoFabricante + "\
</div>\
<div class='codigosProdutosDetails'>\
" + codigoHospcom + "\
</div>\
<div class='codigosProdutosDetails'>\
PREÇO DE LISTA: " + valorTotal + "\
</div>\
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
<tbody id='corpoTabelaPedidosCompra'>\
</tbody>\
</table>\
</div>\
</div>\
</div>\
</div>")
        $("#containerPrincipal").append(inputHtml)
        
        var query = "SELECT Quantidade_destinada_Exibir__c, QuantidadeExibir__c, Quantidade_destinada__c, Quantidade_disponivel__c, Item_de_pedido_de_compra__r.Quantidade_disponivel_a_receber__c, Item_de_pedido_de_compra__r.Quantidade_Destinada__c, Item_de_pedido_de_compra__r.Quantidade_requisitada__c, Name, id, Fornecedor__c, Fornecedor__r.Name, Fornecedor__r.Nova_Data_de_Entrega__c, Fornecedor__r.Prazo_de_recebimento__c, Quantidade__c, Produto__c FROM Item_de_fornecedor__c WHERE  (Fornecedor__r.Status_do_PC__c != 'Cancelado') AND (status__c NOT IN ('Novo', 'Cancelado', 'Recebido Total') OR status__c = 'CMP - AG. ENTREGA FORNECEDOR') AND Quantidade_disponivel__c > 0 AND  status__c != '' AND Item_de_pedido_de_compra__r.Produto__c = '"+idProduto+"'"
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
                var urlPC = usuarioHabilitado ? 'https://hospcom.my.site.com/Sales/s/fornecedor/'+idPedidoDeCompra : "javascript:void(0)"
                    
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
        
        var idProduto = item.attr("data-idproduto");
        var todosEstoques = helper.customEstoques[0].Codigos + "," + helper.customEstoques[1].Codigos;
        
        var inputHtml = $("<div class='containerDetalhes' id='containerDetalhes' style='display: flex'> <div class='containerDetalhesInterno' style='height: auto!important'> <div style='width: 100%; height: auto;'> <div style='width: 100%; height: auto; display: flex'> <div class='nomeProdutoDetails'>Detalhe dos estoques</div><div id='closeButtonProdutoDetails' style='color: red; font-size: 25px; display: flex; justify-content: flex-end; align-items: center; width: 10%; height: 100%;'> <a class='closeButtonProdutoDetails'><i class='fa fa-times-circle' aria-hidden='true'></i></a> </div></div><div class='descricaoProdutosDetails'> <table class='table table-striped'> <thead> <tr> <th scope='col'>Cod. Estoque</th><th scope='col'>Nome do Estoque</th> <th scope='col'>Quantidade Disponível</th> </tr></thead> <tbody id='corpoTabelaPedidosCompra'> </tbody> </table> </div></div></div></div>")
        $("#containerPrincipal").append(inputHtml)
        
        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT Em_estoque__c, Estoque__r.Codigo__c, Estoque__r.Name FROM Entrada_de_Estoque__c WHERE produto__c = '"+idProduto+"' AND Estoque__r.Codigo__c IN ("+todosEstoques+")")
        
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
                
                inputHtml.find("#corpoTabelaPedidosCompra").append("<tr><th scope='row'><a href='https://hospcom.my.site.com/Sales/s/estoque/"+idEstoque+"' target='_blank'>"+codigoEstoque+"</a></th><td>"+nomeEstoque+"</td> <td>"+quantidadeDisponivelEstoque+"</td></tr>")
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
    
    //OBTEM IDS DOS ITENS DE COTAÇÃO APOS UMA INSERÇÃO---------
    obtemIds: function (cmp, event, helper) {
        var recordId = helper.retornaRecorId(cmp, event, helper)
        
        //REALIZA A CONSULTA
        this.soql(cmp, "SELECT Id, Product2Id FROM QuoteLineItem WHERE QuoteId = '" + recordId + "'")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (idsItensCotacao) {
            idsItensCotacao.forEach(function (itemAtual) {
                helper.idsItensCotacao.push({ Id: itemAtual.Id, Product2Id: itemAtual.Product2Id.slice(0, 15) })
            })
            helper.atualizaListaItens(cmp, event, helper, 1)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    //---------------------------------------------------------	
    
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