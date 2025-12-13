({
    onRender: function(cmp, event, helper) {
        
        let modalEl = document.querySelector('.uiModal.open.active');
        if (modalEl) {
            modalEl.removeAttribute('aria-hidden');
        }
        
        
        document.querySelector('.faturas').addEventListener('wheel', function (e) {
            if (e.deltaY !== 0) {
                e.preventDefault();
                this.scrollLeft += e.deltaY;
            }
        });
        document.querySelector('.tabelaContainer').addEventListener('wheel', function (e) {
            if (e.deltaY !== 0) {
                e.preventDefault();
                this.scrollLeft += e.deltaY;
            }
        });
        
        console.log("Renderizando componente, chamando mainFunction");
        helper.mainFunction(cmp, event, helper);
    },
    
    handleClosePopup: function(cmp, event, helper){
        console.log("Fechando pop up")
        $('.overlayFaturar').css('display', 'none').attr('aria-hidden', 'true');
        $('.JanelaFaturar').css('display', 'none').attr('aria-hidden', 'true');
        
        helper.excluiDocumentosERegistro(cmp, event, helper);
        
    },
    
    HandleOpenPopUp: function(cmp, event, helper){
        $("#spinnerPopupDiv").show();
        
        const pedidosSelecionados = Array.from(document.querySelectorAll(".pedido-checkbox:checked")).map(cb => cb.value);
        console.log("Pedidos selecionados: ", pedidosSelecionados);
        
        if (pedidosSelecionados.length === 0) {
            helper.alertaErro(cmp, event, helper, 'Erro', 'Nenhum pedido selecionado.', 'error');
            return;
        }
        
        $('.overlayFaturar').css('display', 'block').attr('aria-hidden', 'false');
        $('.JanelaFaturar').css('display', 'block').attr('aria-hidden', 'false');
        $('.JanelaFaturar').focus();
        
        helper.renderPopUp(cmp, event, helper, pedidosSelecionados);
        
        
        helper.criaRegistroRelacionemnto(cmp, event, helper, pedidosSelecionados);
    },
    
    handleUploadFinished: function(cmp, event, helper){
        helper.handleUploadFinished(cmp, event, helper);
    },
    
    adicionarEmail : function(component, event, helper) {
        let email = component.get("v.emailDigitado").trim();
        if (email.length === 0) return;
        
        // Expressão regular para validar formato de e-mail
        let emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            helper.alertaErro(component, event, helper, 'Erro', 'E-mail inválido', 'error');
            return;
        }
        
        let lista = component.get("v.emailList");
        
        // Evita duplicados
        if (!lista.includes(email)) {
            lista.push(email);
            component.set("v.emailList", lista);
        }
        
        component.set("v.emailDigitado", ""); // limpa o campo
        console.log("lista de email: ", component.get("v.emailList"));
    },
    
    
    reenviarPedido: function (cmp, event, helper) {
    const pedidoInput = cmp.find("pedidoInput");
    const pedido = pedidoInput.getElement().value;

    fetch(`https://integracao.hospcom.net/reenviarEmail/${pedido}`)
        .then(response => {
            if (!response.ok) {
                throw new Error("Erro ao chamar o serviço externo");
            }
            return response.json();
        })
        .then(resultadoGet => {
            if (resultadoGet.status === "success") {

                let query = `
                    SELECT Id, Numero_pedido_sap__c, URLs__c, Emails_Clientes__c,
                           CreatedById, N_mero_nota_sap__c, Parcela__c,
                           data_vencimento__c, DocEntrySap__c
                    FROM DocumentoEPedido__c
                    WHERE Numero_pedido_sap__c = '${pedido}'
                `;

                return helper.soql(cmp, query)
                    .then(function (resultados) {

                        if (resultados && resultados.length > 0) {
                            let pedidoEncontrado = resultados[0];

                            let urlsArray = pedidoEncontrado.URLs__c
                                ? pedidoEncontrado.URLs__c.split(',').map(u => u.trim())
                                : [];

                            return fetch(
                                "https://workflowwebhook.hospcom.net/webhook/1f0d16c7-0d79-48f6-b7db-824d98643023",
                                {
                                    method: "POST",
                                    headers: { "Content-Type": "application/json" },
                                    body: JSON.stringify({
                                        Numero_pedido_sap__c: pedidoEncontrado.Numero_pedido_sap__c,
                                        N_mero_nota_sap__c: pedidoEncontrado.N_mero_nota_sap__c,
                                        Parcela__c: pedidoEncontrado.Parcela__c,
                                        data_vencimento__c: pedidoEncontrado.data_vencimento__c,
                                        DocEntrySap__c: pedidoEncontrado.DocEntrySap__c,
                                        Emails_Clientes__c: pedidoEncontrado.Emails_Clientes__c,
                                        URLs: resultados[0].URLs__c,
                                        UserId: pedidoEncontrado.CreatedById
                                    })
                                }
                            );
                        } else {
                            helper.alertaErro(cmp, event, helper, 'Erro', 'Nenhum pedido com esse número', 'error');
                            pedidoInput.getElement().value = "";
                            return null;
                        }
                    });
            } else {
                helper.alertaErro(cmp, event, helper, 'Erro', 'Retorno inválido do serviço externo', 'error');
                return null;
            }
        })
        .then(r => r ? r.text() : null)
        .then(r => {
            if (r) {
                helper.alertaErro(cmp, event, helper, 'Sucesso!', 'Documentos reenviados com sucesso', 'success');
                console.log("Webhook resposta:", r);

                pedidoInput.getElement().value = "";
                cmp.set("v.resultado", "");
            } else {
                helper.alertaErro(cmp, event, helper, 'Erro', 'Erro em alguma parte do fluxo', 'error');
                pedidoInput.getElement().value = "";
            }
        })
        .catch(function (err) {
            console.error("Erro:", err);
            cmp.set("v.resultado", "Erro ao processar o pedido!");
        });
},

/*
    reenviarPedido: function (cmp, event, helper) {
         const pedidoInput = cmp.find("pedidoInput");
    const pedido = pedidoInput.getElement().value;
        
         fetch(`https://integracao.hospcom.net/reenviarEmail/${pedido}`)
        .then(response => {
            if (!response.ok) {
                throw new Error("Erro ao chamar o serviço externo");
            }
            return response.json(); // caso o backend retorne JSON
        })
        .then(resultadoGet => {
            // 🔹 Verificação correta de retorno
            if (resultadoGet.status === "success") {
        let query = `
            SELECT Id, Numero_pedido_sap__c, URLs__c, Emails_Clientes__c,
                   CreatedById, N_mero_nota_sap__c, Parcela__c,
                   data_vencimento__c, DocEntrySap__c
            FROM DocumentoEPedido__c
            WHERE Numero_pedido_sap__c = '${pedido}'
        `;
        
        helper.soql(cmp, query)
            .then(function(resultados) {             
                if (resultados && resultados.length > 0) {                 
                    let pedidoEncontrado = resultados[0];
                  
                    let urlsArray = pedidoEncontrado.URLs__c.split(',').map(u => u.trim());
                 
                    // 🔴 Precisa estar liberado em CSP Trusted Sites
                    return fetch("https://workflowwebhook.hospcom.net/webhook/1f0d16c7-0d79-48f6-b7db-824d98643023", {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({
                            Numero_pedido_sap__c: pedidoEncontrado.Numero_pedido_sap__c,
                            N_mero_nota_sap__c: pedidoEncontrado.N_mero_nota_sap__c,
                            Parcela__c: pedidoEncontrado.Parcela__c,
                            data_vencimento__c: pedidoEncontrado.data_vencimento__c,
                            DocEntrySap__c: pedidoEncontrado.DocEntrySap__c,
                            Emails_Clientes__c: pedidoEncontrado.Emails_Clientes__c,
                            URLs: resultados[0].URLs__c,
                            UserId: pedidoEncontrado.CreatedById
                        })
                    });                    
                } else {
                   // pedidoInput.getElement().value = "";
                    helper.alertaErro(cmp, event, helper, 'Erro', 'Nenum pedido com esse número', 'error');
                     pedidoInput.getElement().value = ""; 
                    return;
                }
            })
            .then(r => r ? r.text() : null)
            .then(r => {
                console.log("Webhook resposta:", r);
                if (r) {
              //  alert("sucesso", r);
                helper.alertaErro(cmp, event, helper, 'Sucesso!', 'Documentos reenviados com sucesso', 'success');
                    console.log("Webhook resposta:", r);
                 pedidoInput.getElement().value = ""; 
                    cmp.set("v.resultado", "");
            }else{
                  helper.alertaErro(cmp, event, helper, 'Erro', 'Erro em alguma parte do fluxo', 'error');
         pedidoInput.getElement().value = ""; 
                    return;
                  }
            })
            .catch(function(err) {
               //  alert("sucesso", err);
                console.error("Erro:", err);
                cmp.set("v.resultado", "Erro ao processar o pedido!");
            });
            
    },
*/

    
    toggleDocs : function(cmp, event, helper) {
        console.log("chamando função")
    cmp.set("v.mostrarDocs", !cmp.get("v.mostrarDocs"));
},
                
                
    handleEnter: function(cmp, event, helper) {
    if (event.key === "Enter") {       
       const button = cmp.find("pesquisarButton");      
            if (button) {
                button.getElement().click(); 
            }
    }
},
    
    
    
    removerTag : function(component, event, helper) {
        let email = event.currentTarget.dataset.email;
        let listaAtual = component.get("v.emailList");
        let novaLista = listaAtual.filter(e => e !== email);
        component.set("v.emailList", novaLista);
        console.log("lista de email: ", component.set("v.emailList"));
    }
})