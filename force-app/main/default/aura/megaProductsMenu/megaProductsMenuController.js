({
    doInit: function(cmp) {
        
        // Set the attribute value. 
        // You could also fire an event here instead.
        cmp.set("v.setMeOnInit", "controller init magic!");
        
    },
    
    onRender : function(cmp){
        console.log("scripts carregados!")
        
    },
        
    //FUNÇÃO É CHAMADA SEMPRE QUE UMA MARCA É SELECIONADA
    selectMarca : function (cmp, event, helper){
        //EXIBE A COLUNA COM AS LINHAS RELACIONADAS À ESSA MARCA
        $("#colunaLinha").css('display', 'flex');
        //LIMPA O SELECT COM A LISTA DE LINHAS
        $("#selectLinha").empty();
        //CHAMA FUNÇÃO QUE IRÁ PREENCHER AS LINHAS COM BASE NA MARCA SELECIONADA
        var a = cmp.get('c.preencheLinhas');
        //DISPARA O EVENTO DE CHAMADA DA FUNÇÃO
        $A.enqueueAction(a);
    },
    
	/*    
    //FUNÇÃO É CHAMADA SEMPRE QUE UMA LINHA É SELECIONADA
    selectLinha : function (cmp, event, helper){
        //RECUPERA A LINHA SELECIONADA NO SELECT
        const linhaSelected = $("#selectLinha" ).find(":selected").text();
        //RECUPERA A MARCA SELECIONADA NO SELECT
        const marcaSelected = $("#selectMarca" ).find(":selected").text();
        //ENVIA A CONSULTA SQL PASSANDO A MARCA E LINHA
        helper.soql(cmp, "SELECT Id, Name, Family, URL_da_Imagem__c, Marca__c, Tipo_do_Produto__c, Modelo__c FROM Product2 WHERE Tipo_do_Produto__c = 'EQUIPAMENTO' AND IsActive = true AND Marca__c = '"+marcaSelected+"' AND Family ='"+linhaSelected+"'")
        //RECEBE A RESPOSTA DA SOLICITAÇÃO NO OBJETO PRODUTOS
        .then(function (produtos) {
            //EXIBE A COLUNA COM OS MODELOS RELACIONADOS
            $("#colunaModelo").css('display', 'flex');
            //LIMPA O SELECT COM OS MODELOS RELACIONADOS
            $("#selectModelo").empty();
            //EXIBE A LINHA COM O SCROLL DE ITENS RELACIONADOS
            $("#bigBoxItens").show();
            //console.log(produtos)
            //LIMPA A LINHA COM OS ITENS RELACIONADOS
            $("#boxItens").empty()
            //VERIFICA SE NÃO FORAM ENCONTRADOS PRODUTOS
            if(Object.keys(produtos).length === 0){
                //console.log("produtos nao encontrados")
                //CASO NÃO FOR ENCONTRADO NENHUM, EXIBE MENSAGEM AO USUÁRIO
                $("#boxItens").append("<div style='display: flex; align-items:center; justify-content: center; width: 100%; height: 100%; color: #00345c;'>Nenhum produto encontrado</div>")
            }
            //PERCORRE LISTA DE PRODUTOS ENCONTRADOS
            produtos.forEach(function(atualEquipamento){
                //ADICIONA PRODUTO NO SELECT DE MODELOS
                $("#selectModelo").append("<option style='text-transform: capitalize' class='optionValue' value='1'>"+atualEquipamento.Modelo__c+"</option>");
                //ADICIONA PRODUTO NA LINHA COM SCROOL DE PRODUTOS
                $("#boxItens").append("<div  class='items'><div class='imageItem'><img class='image' src='"+atualEquipamento.URL_da_Imagem__c+"'/></div><div class='textoItem'><div value='"+atualEquipamento.Modelo__c+"' class='productTitle'>"+atualEquipamento.Modelo__c.substring(0, 12)+"...</div></div></div>");
                //$("#boxItens").append("<div  class='items' id='item'><div class='imageItem'><img class='image' src='"+atualEquipamento.URL_da_Imagem__c+"'/></div><div class='textoItem'><div class='marquee'><p><a title='' href='' target='_blank' class='productTitle'>"+atualEquipamento.Name+"</a></p></div></div></div>");
            })
            //O TRECHO ABAIXO FORÇA O SCROOL A SEMPRE INICIAR A LISTA NO INÍCIO
            $('#boxItens').animate({
                scrollLeft: "-=9000px"
            }, "100");
            //-----------------------------------------------------------------
            //$("#item").mouseenter(function(){
            //console.log("passou em cima")
            //$(".items").css("background-color", "yellow");
        //}//)//;
            
        })
        //CASO TENHA ERRO NA SOLICITAÇÃO
        .catch(function (error) {
            //EXIBE ERRO NO CONSOLE
            console.log(error)
        })
    },
    
    selectModelo : function (cmp, event, helper){
        console.log("entrou select modelo")
        const linhaSelected = $("#selectLinha" ).find(":selected").text();
        const modeloSelected = $("#selectModelo" ).find(":selected").text();
        console.log(modeloSelected);
        helper.soql(cmp, "SELECT Name, Modelo__c FROM Product2 WHERE Modelo__c = '"+modeloSelected+"' AND Tipo_do_Produto__c = 'EQUIPAMENTO' AND IsActive = true AND Marca__c = 'MINDRAY' AND Family = '"+linhaSelected+"'")
        .then(function (produtos) {
            console.log(produtos)
        })
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //ESSA FUNÇÃO PREENCHE O SELECT COM AS LINHAS DISPONÍVEIS
    ApreencheLinhas : function (cmp, event, helper){
        //recupera a marca selecionada no select da marca
        const marcaSelected = $("#selectMarca" ).find(":selected").text();
        //cria um array vazio de linhas
        const linhas = [];
        //insere o item inicial no select
        $("#selectLinha").append("<option style='text-transform: capitalize' class='optionValue' value='1' disabled='true' selected='true'>Clique aqui...</option>")
        //consulta as linhas de todos os produtos da marca selecionada
        helper.soql(cmp, "SELECT Family FROM Product2 WHERE IsActive = true AND Marca__c = '"+marcaSelected+"'")
        //quando a solicitação for concluída, faça:
        .then(function (produtos) {
            //percorre o json de produtos adicionando as linhas no array de linhas
            produtos.forEach(function(atual){
                //só adiciona a linha no array se ela não já tiver sido adicionada
                if (linhas.indexOf(atual.Family) == -1) {
                    linhas.push(atual.Family);
                }
            })
            //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
            linhas.forEach(function(atualLinhas){
                $( "#selectLinha" ).append("<option style='text-transform: capitalize' class='optionValue' value='1'>"+atualLinhas+"</option>");
            })
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    */
    //----------------------------------------------------------------------
    
    //ESSA FUNÇÃO PREENCHE O SELECT COM AS LINHAS DISPONÍVEIS
    preencheLinhas : function (cmp, event, helper){    
        console.log("preenchendo linhas...");
        //cria um array vazio de linhas
        const linhas = [];
        
        //realiza a consulta 
        helper.soql(cmp, "SELECT Linha__c FROM Product2")       
        //quando a solicitação for concluída, faça:
        .then(function (produtos) {
            //percorre o json de produtos adicionando as linhas no array de linhas
            produtos.forEach(function(atual){
                //só adiciona a linha no array se ela não já tiver sido adicionada
                if (linhas.indexOf(atual.Linha__c) == -1) {
                    linhas.push(atual.Linha__c);
                }
            })
            
            //limpa todos as opções do select
            $("#listaItens1").empty();
            $("#listaItens2").empty();
            
            //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
            $("#listaItens1").append("<input type='radio' name='item1' id='default' title='Selecione uma linha' checked='true'/>")
            
            linhas.forEach(function(atualLinha){
                if(atualLinha !== undefined){
                    $("#listaItens1").append("<input type='radio' name='item1' id='"+atualLinha+"' title='"+atualLinha+"'/>")
                    $("#listaItens2").append("<li id='"+atualLinha+"' class='itemLinha' onclick='{!c.onRead2}'><label for='"+atualLinha+"'>"+atualLinha+"</label></li>")
                }

            })
            
            $('.itemLinha').click(function () {
                var linhaSelecionada = $(this).text();
                helper.linhaSelecionada = linhaSelecionada;
                $('#selectLinhas').removeAttr("open");
                cmp.preencheFamiliaMethod();
            });
            
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
    },
    
    //ESSA FUNÇÃO PREENCHE O SELECT COM AS FAMÍLIAS DISPONÍVEIS
    preencheFamilia : function (cmp, event, helper){
        console.log("preenchendo Familias...");
        
        //Exibe Spinner de carregamento
        helper.showSpinner(cmp); 
        
        //cria um array vazio de linhas
        const familias = [];
        
        //recupera linha selecionada
        const linhaSelecionada = helper.linhaSelecionada;
        
        //realiza a consulta 
        helper.soql(cmp, "SELECT Family FROM Product2 WHERE Linha__c ='"+linhaSelecionada+"'") 
        
        //quando a solicitação for concluída, faça:
        .then(function (produtos) {
            //percorre o json de produtos adicionando as linhas no array de linhas
            produtos.forEach(function(atual){
                //só adiciona a linha no array se ela não já tiver sido adicionada
                if (familias.indexOf(atual.Family) == -1) {
                    familias.push(atual.Family);
                }
            })
            //limpa todos as opções do select
            $("#listaFamilia1").empty();
            $("#listaFamilia2").empty();
            
            //habilita visibilidade da div com select
            $("#colunaFamilia").css('display', 'flex');
            
            //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
            $("#listaFamilia1").append("<input type='radio' name='item2' id='default' title='Selecione uma Familia' checked='true'/>")
            
            familias.forEach(function(atualFamilia){
                if(true){
                    $("#listaFamilia1").append("<input type='radio' name='item2' id='"+atualFamilia+"' title='"+atualFamilia+"'/>")
                    $("#listaFamilia2").append("<li id='"+atualFamilia+"' class='itemFamilia'><label for='"+atualFamilia+"'>"+atualFamilia+"</label></li>")
                
                } 
            })
            
            //Ouvinte de clique em um item do select
            $('.itemFamilia').click(function () {
                var familiaSelecionada = $(this).text();
                helper.familiaSelecionada = familiaSelecionada;
                $('#selectFamilias').removeAttr("open");
                cmp.preencheTipoMethod();
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
    preencheTipo : function (cmp, event, helper){
        console.log("preenchendo Tipos...");
        
        //Exibe spinner de carregamento
        helper.showSpinner(cmp); 
        
        //cria um array vazio de linhas
        const tipos = [];
        
        //recupera familia selecionada
        const familiaSelecionada = helper.familiaSelecionada;
        
        //recupera linha selecionado
        const linhaSelecionada = helper.linhaSelecionada;
        
        //realiza a consulta 
        helper.soql(cmp, "SELECT Tipo_do_Produto__c FROM Product2 WHERE Linha__c = '"+linhaSelecionada+"' AND Family = '"+familiaSelecionada+"'")       
        //quando a solicitação for concluída, faça:
        .then(function (produtos) {
            //percorre o json de produtos adicionando as linhas no array de linhas
            produtos.forEach(function(atual){
                //só adiciona a linha no array se ela não já tiver sido adicionada
                if (tipos.indexOf(atual.Tipo_do_Produto__c) == -1) {
                    tipos.push(atual.Tipo_do_Produto__c);
                }
            })
            
            //limpa todos as opções do select
            $("#listaTipo1").empty();
            $("#listaTipo2").empty();
            
            //habilita visibilidade da div com select
            $("#colunaTipo").css('display', 'flex');
            
            //após preencher o array de linhas, percorre o mesmo adicionando as linhas no respectivo select.
            $("#listaTipo1").append("<input type='radio' name='item3' id='default' title='Selecione um Tipo' checked='true'/>")
            
            tipos.forEach(function(atualTipo){
                if(atualTipo !== undefined){
                    $("#listaTipo1").append("<input type='radio' name='item3' id='"+atualTipo+"' title='"+atualTipo+"'/>")
                    $("#listaTipo2").append("<li id='"+atualTipo+"' class='itemTipo'><label for='"+atualTipo+"'>"+atualTipo+"</label></li>")
                }
                
            })
            $('.itemTipo').click(function () {
                var tipoSelecionado = $(this).text();
                helper.tipoSelecionado = tipoSelecionado;
                $('#selectTipos').removeAttr("open");
                cmp.preencheScroolMethod();
            });
            
            //Oculta Spinner de carregamento
            helper.hideSpinner(cmp);
        })
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        }) 
    },
    
    //ESSA FUNÇÃO PREENCHE O SCROOL COM OS ITENS RESULTANTES
    preencheScrool : function (cmp, event, helper){
        helper.showSpinner(cmp); 
        console.log("preenchendo Scroll...");
        
        //recupera familia selecionado
        const tipoSelecionado = helper.tipoSelecionado;
        
        //recupera familia selecionado
        const familiaSelecionada = helper.familiaSelecionada;
        
        //recupera linha selecionado
        const linhaSelecionada = helper.linhaSelecionada;
        
        const todosProdutos = []
        
        //realiza a consulta 
        helper.soql(cmp, "SELECT id, ID_do_Produto__c, name, Modelo__c, URL_da_Imagem__c  FROM Product2 WHERE Linha__c = '"+linhaSelecionada+"' AND Family = '"+familiaSelecionada+"' AND Tipo_do_Produto__c = '"+tipoSelecionado+"' AND id IN (SELECT Parte__c FROM MktParte__c WHERE Ativo_site__c = true)")       
        
        //quando a solicitação for concluída, faça:
        .then(function (produtos) {
            //console.log(produtos)
            //LIMPA O SELECT COM OS MODELOS RELACIONADOS
            $("#selectModelo").empty();
            
            //EXIBE A LINHA COM O SCROLL DE ITENS RELACIONADOS
            $("#bigBoxItens").show();
            
            //LIMPA A LINHA COM OS ITENS RELACIONADOS
            $("#boxItens").empty()
            
            //DEFINE OUVINTES DE AÇÕES DOS CLIQUES PARA SCROLL----
            $('#right').unbind("click");
            $('#right').click(function() {
                $('#boxItens').animate({
                    scrollLeft: "+=500px"
                }, "100");
            });
            
            $('#left').unbind("click");
            $('#left').click(function() {
                $('#boxItens').animate({
                    scrollLeft: "-=500px"
                }, "100");
            });
            //-----------------------------------------------------
            
            //VERIFICA SE NÃO FORAM ENCONTRADOS PRODUTOS
            if(Object.keys(produtos).length === 0){
                //CASO NÃO FOR ENCONTRADO NENHUM, EXIBE MENSAGEM AO USUÁRIO
                $("#boxItens").append("<div style='display: flex; align-items:center; justify-content: center; width: 100%; height: 100%; color: #00345c;'>Nenhum produto encontrado</div>")
                helper.hideSpinner(cmp);
            }else{
                //PERCORRE LISTA DE PRODUTOS ENCONTRADOS
                produtos.forEach(function(atualEquipamento){
                    //console.log(atualEquipamento)
                    //ADICIONA PRODUTO NA LINHA COM SCROOL DE PRODUTOS
                    $("#boxItens").append("<div  class='items' id='item'><div class='imageItem'><img class='image' src='"+atualEquipamento.URL_da_Imagem__c+"'/></div><div class='textoItem'><div class='marquee' id='marqueeDiv'><p><a title='' href='' target='_blank' class='productTitle'>"+atualEquipamento.Modelo__c+"</a></p></div></div></div>");
                    //$("#boxItens").append("<div class='items'><div class='imageItem'><img class='image' src='"+atualEquipamento.URL_da_Imagem__c+"'/></div><div class='textoItem'><div value='"+atualEquipamento.Modelo__c+"' class='productTitle'>"+atualEquipamento.Modelo__c.substring(0, 12)+"...</div></div></div>");
                })
                
                //O TRECHO ABAIXO FORÇA O SCROOL A SEMPRE INICIAR A LISTA NO INÍCIO------------------------------------------
                $('#boxItens').animate({
                    scrollLeft: "-=9000px"
                }, "100");
                //-----------------------------------------------------------------------------------------------------------
                //
                //PERCORRE TODOS OS ITENS ADICIONADOS AO SCROOL, ALINHANDO A ESQUERDA OS TEXTOS QUE ULTRAPASSAM 12 CARACTERES
                $('#marqueeDiv p').each(function(){
                    if($(this).text().length >= 20){
                        $(this).css({"display": "flex", "justify-content": "left"});
                        //console.log("aplica estilo")
                    }
                    
                })
                //-----------------------------------------------------------------------------------------------------------
                helper.hideSpinner(cmp);
            }
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        

    },
    
    //FUNÇÃO É CHAMADA TODA VEZ QUE O COMPONENTE TERMINA DE RENDERIZAR
    onRead : function (cmp, event, helper){
        console.log("rederizado!")
        

        //CHAMA FUNÇÃO PARA PREENCHER O SELECT COM AS LINHAS
        var actionLinhas = cmp.get('c.preencheLinhas');
        $A.enqueueAction(actionLinhas);
        
        
    },
    
    onRead2: function (cmp, event, helper){
        console.log("rederizado!2")
        
    },
    
    funcTeste : function (cmp, event, helper){
        console.log("executando func teste: ")
        var params = event.getParam('arguments')
        if(params){
            var linhaSelecionada = params.param1;
            console.log(linhaSelecionada);   
        }
    }
    
})