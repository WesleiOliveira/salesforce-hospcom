({
    
    preencheResultados : function(cmp, event, helper){
        var inputPesquisa = helper.inputPesquisa;
        
        //realiza a consulta
        helper.soql(cmp, "SELECT Name FROM Product2 WHERE IsActive = true AND Name like '%"+inputPesquisa+"%'")
        
        //quando a solicitação for concluída, faça:
        .then(function (produtos) {
            console.log(produtos)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    
    //FUNÇÃO EXECUTADA APÓS O TÉRMINO DA RENDERIZAÇAO DO COMPONENTE-----------------------------------------------------------
    onRender : function(cmp,event, helper){
        //helper.alertaErro(cmp, event, helper, "Ferramenta em manutenção, aguarde.", "Atençao!", "Warning", "", "sticky")
        //FAZ A BUSCA E PREENCHIMENTO INICIAL USANDO ANESTESIA COMO TERMO--
        //helper.buscaProdutos(cmp, event, helper, "all", "null")
        helper.inputPesquisa = "all"
        //----------------------------------------------------------------
        
        //CHAMA A FUNÇÃO HELPER QUE BUSCA NA COTAÇÃO ATUAL OS ITENS PAIS E FILHOS, E INSERE NA VISUALIZAÇÃO--
        //helper.consultaCotacao(cmp, event, helper, 0)
        //---------------------------------------------------------------------------------------------------
        helper.ativaDragAndDrop(cmp, event, helper) //ATIVA O ARRASTA E SOLTA NA COLUNA DA DIREITA
        
        helper.consultaCotacaoCompra(cmp, event, helper);
        
        helper.modalFornecedores(cmp, event, helper);
        
        //CHAMA A FUNÇÃO QUE PREENCHE A COLUNA DA ESQUERDA COM OS PEDIDOS DE VENDA E ITENS DISPONÍVEIS PARA COMPRA
        helper.auxiliarPreenchePedidos(cmp, event, helper)
        //-------------------------------------------------------------------------
        
        helper.exibePlataformaMkt(cmp, event, helper)
        
        //EVENTO DISPARADO AO DIGITAR UM PRODUTO NA PESQUISA DE PRODUTOS-
        var x_timer;    
        $("#inputPesquisa").keyup(function (e){
            clearTimeout(x_timer);
            var inputPesquisa = $(this).val();
            helper.inputPesquisa = inputPesquisa
            x_timer = setTimeout(function(){
                
                //VERIFICA SE A PESQUISA NÃO FOI VAZIA
                if(inputPesquisa.trim().length){
                    //CLICK NECESSÁRIO PARA DESBUGAR A CONSULTA
                    $('#listaProdutos').click()
                    helper.buscaProdutos(cmp, event, helper, inputPesquisa, "null")
                }else{
                    //PESQUISA VAZIA, NÃO FAZ NADA
                    //$('#listaProdutos').empty();
                    helper.inputPesquisa = "all"
                    helper.buscaProdutos(cmp, event, helper, "all", "null")
                    helper.alertaErro(cmp, event, helper, "Exibindo todos os produtos", "PESQUISA VAZIA", "warning", "Alerta!", "")
                }
            }, 1000);
        });
        //---------------------------------------------------------------
        
        //EVENTO DISPARADO AO CLICAR NO BOTÃO DA PLATAFORMA DE MARKETING-
        $("#buttonPlataformaMarketing").click(function(){
            helper.exibePlataformaMkt(cmp, event, helper)
        })
        //---------------------------------------------------------------
        
        //EVENTO DISPARADO AO CLICAR NO BOTÃO PARA EXIBIR ITENS DE OPPS
        $("#buttonItensOPP").click(function(){
            helper.exibeItensOpp(cmp, event, helper)
        })
        //---------------------------------------------------------------
        
        //EVENTO DISPARADO AO CLICAR NO BOTÃO PESQUISE PRODUTOS---------
        $("#buttonPesquiseProdutos").click(function(){
            helper.exibePesquisaProdutos(cmp, event, helper)
        })  
        //--------------------------------------------------------------

    
},
})