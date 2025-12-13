({
    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecordId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        //var recordId = '8016e000007c8mfAAA'
        
        return recordId
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
    
    
    consultaObsGerais:function(cmp, event, helper){
        var idObjeto = helper.retornaRecordId(cmp, event, helper);
        var query = "select id, Observacoes_Gerais__c from order WHERE id = '"+idObjeto+"'";
        
        console.log("consultaObsGerais")
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (resposta) {
            console.log("RESPOSTA", resposta)
            
            if(!resposta[0].Observacoes_Gerais__c ){
                helper.alertaErro(cmp, event, helper, "O campo observações gerais do pedido está vazio.", "Atençao!", "Warning", "", "sticky")
            }
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    //helper.alertaErro(cmp, event, helper, "Ferramenta em manutenção, aguarde.", "Atençao!", "Warning", "", "sticky")
	
    //---------------------------------------------------
    mainFunction : function(cmp, event, helper) {
        
        var idObjeto = helper.retornaRecordId(cmp, event, helper);
        
        var Object;
        switch(idObjeto.substring(0,3)){
            case '801':
                Object = 'Pedido__c';
                helper.consultaObsGerais(cmp, event, helper)
                break;
            case '006':
                Object = 'Oportunidade__c';
                break;
            case 'a1Y':
                Object = 'Contrato_de_Servico__c';
                break;
            case '0WO':
                Object = 'Ordem_de_trabalho__c';
                break;
            case 'a0K':
                Object = 'Demonstracao__c';
                break;
        }
        
        var query = "SELECT Id, Name, status__c FROM pendencia__c WHERE " + Object + " = '"+idObjeto+"' AND Status__c != 'Fechado'";
        
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