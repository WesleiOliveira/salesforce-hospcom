({
    mainHelper : function(cmp, event, helper) {
        console.log("MAIN HELPER")
        helper.verificaProcessoAprovacao(cmp, event, helper)
        helper.verificaDesconto(cmp, event, helper)
    },
    
    workItemId: '',
    motivoReprova : '',
    idConta : '',
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    showSpinner: function (cmp) {
        $('#spinnerDivAprovacao').css("display", "flex");
        console.log("show spinner")
    },
    //-------------------------------------------
    
    //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
    hideSpinner: function (cmp) {
        $('#spinnerDivAprovacao').css("display", "none");
    },
    //-------------------------------------------
    
    verificaProcessoAprovacao: function(cmp, event, helper){
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var recordId = cmp.get('v.recordId');
        
        //var query = "SELECT Id, status, TargetObjectId, TargetObject.Type, ProcessDefinitionId, CreatedById, CreatedDate, (SELECT Id, ActorId, ProcessInstanceId FROM Workitems) FROM ProcessInstance WHERE Status = 'Pending' and ID IN (SELECT ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ActorId = '"+userId+"') AND TargetObjectId = '"+recordId+"'"
        var query = "SELECT Id, status, TargetObjectId, TargetObject.Type, ProcessDefinitionId, CreatedById, CreatedDate, (SELECT Id, ActorId, ProcessInstanceId FROM Workitems) FROM ProcessInstance WHERE Status = 'Pending' and ID IN (SELECT ProcessInstanceId FROM ProcessInstanceWorkItem) AND TargetObjectId = '"+recordId+"'"
        
        console.log("QUERY", query)
        
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (processosDeAprovacao) {
            
            console.log("PROCESSOS DE APROVACAO", processosDeAprovacao)
            console.log(processosDeAprovacao.length)
            
            if(processosDeAprovacao.length >= 1){
                $("#divMestre").css("display", "flex")
                var workItemId = processosDeAprovacao[0].Workitems[0].Id
                helper.workItemId = workItemId
            }else{
                $(".divMestre").css("display", "none")
                helper.alertaErro(cmp, event, helper, "Nenhum processo de aprovação disponível", "ERRO!", "Error", "dismissable")
            }
            
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
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
    
    consultaAnalises: function(cmp, event, helper){
        console.log("consultaAnalises")
        
        var query = "SELECT ID, NAME, createdDate, STATUS__C FROM ANALISE_DE_CREDITO__C WHERE CREATEDDATE = LAST_N_DAYS:180 AND (COTACAO__R.OPPORTUNITY.ACCOUNTID = '"+helper.idConta+"' OR OPORTUNIDADE__R.ACCOUNTID = '"+helper.idConta+"')"
        
        console.log("QUERY consultaAnalises", query)
        
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (analisesRelacionados) {
            
            console.log("analises relacionadas", analisesRelacionados)
            $("#innerListAnalisesRelac").empty()
            
            const hasAprovado = analisesRelacionados.some(item => item.Status__c === "Aprovado");
            
            analisesRelacionados.forEach(function(analiseAtual){
                var idAnalise = analiseAtual.Id;
                var link = 'https://hospcom.my.site.com/Sales/s/analise-de-credito/' + idAnalise;
                var name = analiseAtual.Name
                var status = analiseAtual.Status__c
                var dataCriacao = analiseAtual.CreatedDate
                const data = new Date(dataCriacao);
                
                const dia = String(data.getDate()).padStart(2, '0'); // Adiciona zero à esquerda
                const mes = String(data.getMonth() + 1).padStart(2, '0'); // getMonth() retorna 0-11, então soma 1
                const ano = data.getFullYear();
                
                // Formatar a data no padrão brasileiro
                const dataFormatada = `${dia}/${mes}/${ano}`;
                
                var html = "\
                <div class='lineInner'>\
                <div class='blockInListRel'>\
                <a target='_blank' href='https://hospcom.my.site.com/Sales/s/analise-de-credito/"+idAnalise+"'>"+name+"</a>\
                </div>\
                \
                <div class='blockInListRel'>\
                "+dataFormatada+"\
                </div>\
                \
                <div class='blockInListRel'>\
                "+status+"\
                </div>\
                </div>\
                "
                
                $("#innerListAnalisesRelac").append(html)
            })
            
            if(hasAprovado){
                alert("Existem análises de crédito aprovadas e vigentes para o cliente atual")
            }
            

        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    },
    
    verificaDesconto: function(cmp, event, helper){
        console.log("verificando desconto")
        var recordId = cmp.get('v.recordId');
        
        var query = "SELECT id, Order.AccountId, UnitPrice, Order.Motivo__c, Order.Desconto__c, Order.TotalAmount, Product2.Valor_de_Venda__c from OrderItem where orderid = '"+recordId+"'"
        var descontoTotalEmReais = 0;
        console.log("QUERY DESCONTO", query)
        
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (produtosPedido) {
            console.log(produtosPedido)
            var percentualTotalDesconto = produtosPedido[0].Order.Desconto__c
            helper.motivoReprova = produtosPedido[0].Order.Motivo__c
            helper.idConta = produtosPedido[0].Order.AccountId
            console.log("Percentual Total de Desconto:", percentualTotalDesconto);
            $(".percentualDesconto").html(percentualTotalDesconto + "%")
            helper.consultaAnalises(cmp, event, helper)
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    }
})