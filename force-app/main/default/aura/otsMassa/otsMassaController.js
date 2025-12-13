({
	onRender : function(cmp, event, helper) {
		console.log("onRender")
        helper.helperMethod(cmp, event, helper)
	},
    
    handleKeyUp: function (cmp, evt, helper) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            console.log("enter")
            var queryTerm = cmp.find('enter-search').get('v.value');
            
            $("#divSearchResults").show()
            console.log('Pesquisando por: ', queryTerm);
            
            var query = "SELECT id, Name, CNPJ__c from account WHERE Name LIKE '%"+queryTerm+"%' ORDER BY Name"
            //var query = "SELECT id, IsActive, name, Title from User where IsActive = true and Name LIKE '%"+queryTerm+"%'";
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (contas) {
                console.log("CONTAS", contas)
                $("#divSearchResults").empty()
                
                contas.forEach(function(usuarioAtual){
                    var nomeUsuario = usuarioAtual.Name
                    var idUsuario = usuarioAtual.Id
                    var cnpjUsuario = usuarioAtual.CNPJ__c
                    
                    var html = "<div class='userResultSearchShare' data-id='"+idUsuario  +"'>"+nomeUsuario+ "<br/>"+cnpjUsuario+ "</div>"
                    $("#divSearchResults").append(html)
                })
                
                $(".userResultSearchShare").off().on("click", function() {
                    var idUsuarioClicado = $(this).attr('data-id')
                    console.log("clique", idUsuarioClicado)
                    //var stringClicada = $(this).html()
                    //cmp.set('v.valInputShare', stringClicada);
                    $("#divSearchResults").hide()
                    helper.contaSelecionada = idUsuarioClicado
                    helper.consultaContatos(cmp, evt, helper)
                });
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        }
    },
    
    handleKeyUp2: function (cmp, evt, helper) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            console.log("enter")
            var queryTerm = cmp.find('enter-search2').get('v.value');
            
            $("#divSearchResults2").show()
            console.log('Pesquisando por 2: ', queryTerm);
            
            var query = "SELECT id, Name from Contrato_de_Servi_o__c WHERE Name LIKE '%"+queryTerm+"%' ORDER BY Name"
            //var query = "SELECT id, IsActive, name, Title from User where IsActive = true and Name LIKE '%"+queryTerm+"%'";
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (contas) {
                console.log("CONTAS", contas)
                $("#divSearchResults2").empty()
                
                contas.forEach(function(usuarioAtual){
                    var nomeUsuario = usuarioAtual.Name
                    var idUsuario = usuarioAtual.Id
                    
                    var html = "<div class='userResultSearchShare2' data-id='"+idUsuario  +"'>"+nomeUsuario+"</div>"
                    $("#divSearchResults2").append(html)
                })
                
                $(".userResultSearchShare2").off().on("click", function() {
                    var idUsuarioClicado = $(this).attr('data-id')
                    var stringClicada = $(this).html()
                    cmp.set('v.valInputContratoRelacionado', stringClicada);
                    $("#divSearchResults2").hide()
                    helper.contratoSelecionado = idUsuarioClicado
                    
                    console.log(helper.contratoSelecionado)
                });
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        }
    },
    
    handleKeyUp3: function (cmp, evt, helper) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var queryTerm = cmp.find('enter-search3').get('v.value');
            
            $("#divSearchResults3").show()
            console.log('Pesquisando por 3: ', queryTerm);
            
            var query = "select id, Name from Contact where Account.Grupo_Hospcom__c = true and Name LIKE '%"+queryTerm+"%' ORDER BY Name"
            //var query = "SELECT id, IsActive, name, Title from User where IsActive = true and Name LIKE '%"+queryTerm+"%'";
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (contas) {
                console.log("CONTAS", contas)
                $("#divSearchResults3").empty()
                
                contas.forEach(function(usuarioAtual){
                    var nomeUsuario = usuarioAtual.Name
                    var idUsuario = usuarioAtual.Id
                    
                    var html = "<div class='userResultSearchShare3' data-id='"+idUsuario  +"'>"+nomeUsuario+"</div>"
                    $("#divSearchResults3").append(html)
                })
                
                $(".userResultSearchShare3").off().on("click", function() {
                    var idUsuarioClicado = $(this).attr('data-id')
                    var stringClicada = $(this).html()
                    cmp.set('v.valTecnicoResponsavel', stringClicada);
                    $("#divSearchResults3").hide()
                    helper.tecnicoResponsavel = idUsuarioClicado
                    
                    console.log(helper.tecnicoResponsavel)
                });
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        }
    }
})