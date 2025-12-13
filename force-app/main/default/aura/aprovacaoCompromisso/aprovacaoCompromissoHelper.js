({
    mainHelper : function(cmp, event, helper) {
        console.log("MAIN HELPER")
        helper.verificaProcessoAprovacao(cmp, event, helper)
    },
    
    workItemId: '',
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    showSpinner: function (cmp) {
        $('#spinnerDivAprovacao').css("display", "flex");
        console.log("show spinner")
        
    },
    //-------------------------------------------
    
    //FUNÇÃO QUE EXIBE ERROS AO USUÁRIO-------------------------------------------------------------
    alertaErro: function (cmp, event, helper, error, title, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": error,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    //----------------------------------------------------------------------------------------------
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    hideSpinner: function (cmp) {
        $('#spinnerDivAprovacao').css("display", "none");
    },
    //-------------------------------------------
    
    verificaProcessoAprovacao: function(cmp, event, helper){
        
        helper.showSpinner(cmp);
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var recordId = cmp.get('v.recordId');
        
        //var query = "SELECT IdsCalendarios__c, id, Name, checkInRealizado__c, justificativa__c from User where id ='"+recordId+"' AND IsActive = true and lastLoginDate > 2023-01-01T10:10:59.000+0000 ORDER BY Name"
        var query = "SELECT OwnerId, checkInRealizado__c, justificativa__c, Owner.Name, id, Description, WhatId, What.Name, Subject, StartDateTime, EndDateTime from Event WHERE Id = '"+recordId+"'"
        
        console.log("QUERY", query)
        console.log(userId)
        
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (compromisso) {
            
            if(!compromisso[0].hasOwnProperty('justificativa__c') && compromisso[0].checkInRealizado__c == false){
                $(".divMestre").css("display", "none")
                helper.alertaErro(cmp, event, helper, "Nenhum processo de aprovação disponível", "ERRO!", "Error", "dismissable")
                return;
            }
            
            var OwnerId = compromisso[0].OwnerId
            var query = "select Id, Gestor__c from User where Id = '"+OwnerId+"'"
            
            console.log("QUERY", query)
            //console.log(userId)
            
            //REALIZA A CONSULTA
            helper.soql(cmp, query)
            
            //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
            .then(function (usuario) {
                
                var idGestor = usuario[0].Gestor__c
                console.log("ID GESTOR: ", idGestor)
                console.log("ID usuario: ", userId)

                if(idGestor != userId){
                    $(".divMestre").css("display", "none")
                    helper.alertaErro(cmp, event, helper, "Somente o gestor do usuário do compromisso pode aprovar este registro.", "ERRO!", "Error", "dismissable")
                    helper.hideSpinner(cmp)
                    return;
                }
                
                //console.log(usuario)
                console.log(compromisso)
                //helper.alertaErro(cmp, event, helper, "Carregando...", "Aguarde,", "Success", "dismissable")
                helper.hideSpinner(cmp)
            })
            
            //trata excessão de erro
            .catch(function (error) {
                console.log(error)
            })
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
})