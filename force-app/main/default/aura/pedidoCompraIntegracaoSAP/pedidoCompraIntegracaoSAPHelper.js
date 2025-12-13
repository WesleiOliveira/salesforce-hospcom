({
    mainFunction: function(cmp, event, helper){
        
        var recordId = cmp.get("v.recordId");
        var query = "select Status_do_PC__c, Pedido_de_compra__r.Status__c from fornecedor__c where id = '"+recordId+"'"
        
        this.soql(cmp, query)
        .then(function (pc) {  
            pc.forEach(function(pcAtual){
                var statusPc = pcAtual.Pedido_de_compra__r.Status__c;
                
                if (statusPc == "5 - Concluído"){
                    
                    $("#integracaoSAP").prop("disabled", false);
                    $('#integracaoSAP').attr('title', 'Integrar pedido ao SAP');
                    
                    $("#integracaoSAP").click(function(){
                        $("#spinnerDiv").show()
                        $('#integracaoSAP').prop('disabled', true);
                        fetch('https://integracao.hospcom.net/purchase-order/' + cmp.get("v.recordId")).then((response) => {
                            if (response.ok) return response.json();
                            return response.json().then(err => {throw err});
                        }).then((json) => {
                            helper.alertaErro(cmp, event, helper, 'TUDO OK!', 'Pedido integrado com sucesso.', 'success');
                            //helper.alertaErro(component, event, helper, 'Pedido de Compra integrado ao SAP', 'Com sucesso!', 'success');
                            $('#integracaoSAP').prop('disabled', false);
                            $("#spinnerDiv").hide()
                            setTimeout(() => {
                                helper.ativarPedidoCompra(cmp, cmp.get("v.recordId")).then(function () {
                                    window.location.reload();
                                }).catch(err => {
                                    console.log(err)
                                })
                            }, 2000);
                        }).catch((err) => {
                            helper.alertaErro(cmp, event, helper, 'Error ao integrar', err.data, 'error');
                            $('#integracaoSAP').prop('disabled', false);
                            $("#spinnerDiv").hide()
                        });
                    });
                    
                }else{
                    $("#integracaoSAP").prop("disabled", true);
                    $('#integracaoSAP').attr('title', 'Permitido apenas para pedidos cuja cotação está concluída');

                }
            })
            
            
        }).catch(function (error) {
            console.log(error)
        })

    },
    
    
    alertaErro: function (cmp, event, helper, title, tipoMensagem, type) {
        console.log("exibindo erro")
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": tipoMensagem,
            "type": type,
            "mode": 'sticky'
        });
        toastEvent.fire();
    },
    
})