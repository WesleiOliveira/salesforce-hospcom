({
    mainFunction : function(cmp, event, helper) {
        console.log("mainFunc Helper")
        helper.consultaSolicitacoes(cmp, event, helper)
        //helper.alertaErro(cmp, event, helper, "", "Processando Leitura...", "info", "", "dismissable")
        
    },
    
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
    
    
    consultaSolicitacoes: function(cmp, event, helper){
        console.log("consulta solicita")
        
        var query = "select id, Prioridade__c, Name, solicitacao_transferencia_estoque__r.Name, solicitacao_transferencia_estoque__c, Pedido__c, Pedido__r.Natureza_de_Opera_o__c, Numero_do_pedido__c, Status__c, createdDate FROM Solicita_es_de_faturamento__c WHERE Status__c != '' ORDER BY Status__c, Prioridade__c DESC LIMIT 200";
		
        var resultadoHtmlAFaturar = ''
        var resultadoHtmlFaturado = ''
        
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (solicitacoes) {
            console.log("solicitacoes", solicitacoes)
            
            solicitacoes.forEach((solicitacao) => {
                
                var numSolicita = solicitacao.Name;
                var idSolicita = solicitacao.Id;
                var numeroPedido = solicitacao.Numero_do_pedido__c;
                var idPedido = solicitacao.Pedido__c;
                var naturezaPedido = solicitacao.Pedido__c ? solicitacao.Pedido__r.Natureza_de_Opera_o__c : ""
                var cor = solicitacao.Prioridade__c == 'URGENTE' && solicitacao.Status__c == 'Novo' ? "urgentClass423342" : ""
                var icon = solicitacao.Status__c == 'Novo' ? "" : "<i class='fa fa-check-square-o' style='color: green' aria-hidden='true'></i>"
                var tipo = solicitacao.solicitacao_transferencia_estoque__c ? "Transf." : "Pedido"
                var endpoint = 'order'
                
                if(tipo == "Transf."){
                    numeroPedido = solicitacao.solicitacao_transferencia_estoque__r.Name;
                	endpoint = 'solicitacao-transferencia-estoque';
                	idPedido = solicitacao.solicitacao_transferencia_estoque__c;
                	naturezaPedido = "TRANSF"
                }
                                 
                
                var html = "\
                <div class='itemBox382472390 "+cor+"'>\
				<div class='naturezaOp34234 "+cor+"' style='font-size: 10px'>"+naturezaPedido+"</div>\
                <a target='_blank' href='https://hospcom.my.site.com/Sales/s/detail/"+idSolicita+"'>"+numSolicita+"</a>\
				<a target='_blank' href='https://hospcom.my.site.com/Sales/s/"+endpoint+"/"+idPedido+"'>"+tipo+":&nbsp;"+numeroPedido+"</a>"+icon+"\
				</div>";
                
                if(solicitacao.Status__c == 'Novo'){
                	resultadoHtmlAFaturar = resultadoHtmlAFaturar + html;
            	}else{
                                 resultadoHtmlFaturado = resultadoHtmlFaturado + html
                                 } 
            });
            
            $("#bodyAfaturar").empty()
            $("#bodyFaturados").empty()
            $("#bodyAfaturar").append(resultadoHtmlAFaturar)
            $("#bodyFaturados").append(resultadoHtmlFaturado)

        })
        
        //trata excessão de erro
        .catch(function (error) {
            console.log(error)
        })
    }
    
    
})