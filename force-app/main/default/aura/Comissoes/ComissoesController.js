({
    //FUNÇÃO EXECUTADA APÓS O TÉRMINO DA RENDERIZAÇAO DO COMPONENTE-----------------------------------------------------------
    onRender : function(cmp,event, helper){
        //helper.mainHelper(cmp, event, helper);
        
        //OBTEM O ID DO USUARIO
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        //CRIA A QUERY PARA OBTER O PERFIL DO USUARIO
        var query = "SELECT id, name, Profile.name, Contact.Admissao__c FROM user where id = '"+userId+"'"
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        .then(function (usuario) {
            //OBTEM O NOME DO PERFIL DO USUARIO E SETA NA VARIÁVEL GLOBAL
            helper.perfilUsuario = usuario[0].Profile.Name;
            helper.consultaVendedores(cmp, event, helper)
            
        }).catch(function (error) {
            console.log(error)
        })  

        
    },
    
})