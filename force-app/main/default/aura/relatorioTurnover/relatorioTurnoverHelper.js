({
    helperMethod : function(cmp, event, helper) {
        
        //REALIZA A CONSULTA
        this.soql(cmp, "select Turnover__c from account where id = '001i00000085QYbAAM'")
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (contas) {
            console.log(contas)
            var turnover = contas[0].Turnover__c 
            $("#Turnover").html(turnover + '%')
        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
        
        
    }
})