({
    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecordId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        //cmp.set("v.userId", userId);
        //var recordId = '8016e000007c8mfAAA'
        
        return recordId
    },
    
    //---------------------------------------------------
    mainFunction : function(cmp, event, helper) {
        
        var idObjeto = helper.retornaRecordId(cmp, event, helper);
        
        
        var query = "SELECT Id, Name, status__c FROM pendencia__c WHERE Responsavel__c = '"  + userId +  "' AND Situacao__c like = ' %Atrasado%'";
        
        console.log("aqui")
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (resposta) {
            var quantRetorno = resposta.length;
            if(quantRetorno > 0){
                $('#iconeSucesso').hide();
                $('#iconeAtencao').show();
                $('#countItens').html(quantRetorno)
                
                // play sound
                var getSound = $A.get('$Resource.soundNotify');
                var playSound = new Audio(getSound);
                playSound.play();
            }else{
                //$('.iconClass').hide();
                $('#divPrincipalWidget').hide();
                $('#iconeSucesso').show();
                $('#iconeAtencao').hide();
                $('.boxItem').css("-webkit-animation", "none");
                $('.boxItem').css("-moz-animation", "none");
                $('.boxItem').css("-ms-animation", "none");
                $('.boxItem').css("animation", "none");
                
                $('#iconeSucesso').css("-webkit-animation", "none");
                $('#iconeSucesso').css("-moz-animation", "none");
                $('#iconeSucesso').css("-ms-animation", "none");
                $('#iconeSucesso').css("animation", "none");
            }
            
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
    }
})