({
doInit: function(cmp) {
    // Set the attribute value. 
    // You could also fire an event here instead.
    cmp.set("v.setMeOnInit", "controller init magic!");
},

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
onRender : function(cmp, event, helper){
    
    //EXIBE UM ALERTA DE SUCESSO AO USUÁRIO
    //helper.alertaErro(cmp, event, helper, textAlertaErro, "ÓTIMO!", "success", "", "dismissable")
    //helper.alertaErro(cmp, event, helper, error, "ERRO AO CONSULTAR PRODUTOS", "error")
    
    //FAZ A BUSCA E PREENCHIMENTO INICIAL USANDO ANESTESIA COMO TERMO-
    //helper.buscaProdutos(cmp, event, helper, "all", "null")
    //helper.inputPesquisa = "all"
    //----------------------------------------------------------------
    
    //CHAMA A FUNÇÃO QUE PREENCHE A DIV COM AS INFORMAÇÕES DA PLATAFORMA DE MKT
    helper.preenchePlataformaMkt(cmp, event, helper, "")
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
    
    //EVENTO DISPARADO AO CLICAR NO BOTÃO PESQUISE PRODUTOS---------
    $("#buttonPesquiseProdutos").click(function(){
        helper.exibePesquisaProdutos(cmp, event, helper)
    })  
    //--------------------------------------------------------------
    
    //EVENTO DISPARADO AO CLICAR NO BREADCRUMB DE INÍCIO NO MARKETING----
    $(".breadcrumbs__item").click(function(){
        var idCategoriaPai = $(this).attr('data-idItem');
        helper.indiceRemocao = $(this).index();
        
        $('#breadcrumbsNav').children().each(function () {
            if($(this).index() > helper.indiceRemocao){
                $(this).remove()
            }
        });
        
        helper.preenchePlataformaMkt(cmp, event, helper, idCategoriaPai)
    })
    //-------------------------------------------------------------------
    
    
        
	//Array.from(document.getElementsByClassName("midiaButton")).forEach(e => e.addEventListener('click',function(){
        //console.log('aaaa')
    //}))
    
},
    
    handleClick : function (cmp, event, helper) {
        alert("You clicked: " + event.getSource().get("v.label"));
    }
    
})