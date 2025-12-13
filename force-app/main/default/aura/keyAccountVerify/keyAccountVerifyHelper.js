({
    //FUNÇÃO QUE OBTÉM E RETORNA O RECORDID DO REGISTRO--
    retornaRecorId: function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        return recordId
    },
    //---------------------------------------------------
    
    
	helperMethod : function(cmp, event, helper) {
        
        var recordId = helper.retornaRecorId(cmp, event, helper)        
        var tresPrimeirosCaracteres = recordId.substring(0, 3);
        var objeto = ""
        
        switch (tresPrimeirosCaracteres) {
            case '001':
                objeto = "Account"
                break;
            case '801':
                objeto = "Order"
                break;
            case '006':
                objeto = "Opportunity"
                break;
            case 'a2C':
                objeto = "Pendencia__c"
                break;    
            case '0WO':
                objeto = "WorkOrder"
                break;
            default:
                objeto = "null"
                break;
        }
		
        if(objeto != "null"){
            //CONSULTA AS VARIAÇÕES DO USUARIO
            var query = "SELECT Key_Account__c from "+objeto+" where id = '"+recordId+"'"
            
            //REALIZA A CONSULTA
            this.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (pedido) {
                
                //recupera todas as variacoes habilitadas do usuário
                var KeyAccount = pedido[0].Key_Account__c
                if(KeyAccount == true){
                    $("#keyAccountVerify").css("display", "flex")
                }
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        }
	}
})