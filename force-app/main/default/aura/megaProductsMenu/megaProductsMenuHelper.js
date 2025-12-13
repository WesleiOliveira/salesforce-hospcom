({  
    linhaSelecionada: "null",
    familiaSelecionada: "null",
    tipoSelecionado: "null",

    
    listeningButtons : function() {
        //DEFINE OUVINTES DE AÇÕES DOS CLIQUES PARA SCROLL----
        $('#right').click(function() {
            $('#boxItens').animate({
                scrollLeft: "+=500px"
            }, "100");
        });
        
        $('#left').click(function() {
            $('#boxItens').animate({
                scrollLeft: "-=500px"
            }, "100");
        });
        //-----------------------------------------------------
    },
    
    showSpinner : function(component) {
        $('#spinnerDiv').show();
    },
    
    hideSpinner : function(component) {
        $('#spinnerDiv').css("display", "none");
    },
    
})