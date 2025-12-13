({
	onRender : function(component, event, helper) {
		helper.mainMethod(component, event, helper)
	},
    
    handleKeyUp: function (cmp, evt, helper) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var queryTerm = cmp.find('enter-search').get('v.value');

            $("#divSearchResults").show()
            //console.log('Pesquisando por: ', queryTerm);
            var query = "SELECT id, IsActive, name, Title from User where IsActive = true and Name LIKE '%"+queryTerm+"%'";
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (usuarios) {
                //console.log("usuarios", usuarios)
                $("#divSearchResults").empty()
                
                usuarios.forEach(function(usuarioAtual){
                    var nomeUsuario = usuarioAtual.Name
                    var idUsuario = usuarioAtual.Id
                    var cargoUsuario = usuarioAtual.Title ? usuarioAtual.Title : "Cargo não cadastrado"
                    
                    var html = "<div class='userResultSearchShare' data-id='"+idUsuario  +"'>"+nomeUsuario+" - "+cargoUsuario+"</div>"
                    $("#divSearchResults").append(html)
                })
                
                $(".userResultSearchShare").off().on("click", function() {
                    var idUsuarioClicado = $(this).attr('data-id')
                    var stringClicada = $(this).html()
                    cmp.set('v.valInputShare', stringClicada);
                    $("#divSearchResults").hide()
                    
                    helper.newUsuarioCompartilhado = idUsuarioClicado
                    //helper.compartilhaQuadro(cmp, event, helper, idUsuarioClicado)
                });
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
            
            
        }
        
        
    }
})