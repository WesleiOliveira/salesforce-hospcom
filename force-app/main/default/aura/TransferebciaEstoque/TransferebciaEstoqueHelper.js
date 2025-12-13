({
    validAddress : [true, true],
    
	mainFunction : function(cmp, event, helper) {
        const intgButton = document.getElementById("integracaoSAP");
        //const testButton = document.getElementById("integracaoSAP2");
        const modal = document.getElementById("modal-overlayer");
        const modalClose = document.getElementById("close-modal-button");
        const modalContentCobranca = document.getElementById("modal-content-cobranca");
        const modalContentEntrega = document.getElementById("modal-content-entrega");
        const divSpin = document.getElementById("spinnerDivPedidoVenda");
        
        const recordId = cmp.get("v.recordId");
        const query = "SELECT Id FROM Solicitacao_transferencia_estoque__c WHERE Id = '"+recordId+"'";

        
        this.soql(cmp, query).then(value => {
            intgButton.addEventListener("click", function integFunction() {

	            divSpin.style.display = 'block';
                fetch('http://integracao.hospcom.net/requestInvetory/' + recordId).then((response) => {
                    if (response.ok) return response.json();
                    return response.json().then(err => {throw err});
                }).then((json) => {
            		divSpin.style.display = 'none';
            		helper.alertaErro(cmp, event, helper, 'Trasferência INTEGRADO AO SAP', 'Com sucesso!', 'success');                    
            		setTimeout(() => {
            			window.location.reload();
        			}, 1000);
            		//helper.ativarPedidoVenda(cmp, recordId).then(function () {
        			//}).catch(err => {
            		//	helper.alertaErro(cmp, event, helper, 'O PEDIDO FOI INTEGRADO AO SAP, MAS NÃO FOI ATIVADO', err, 'error');
        			//});
        		}).catch((err) => {
		            divSpin.style.display = 'none';
            		console.log(err.data)
                    if (err.data.dados && err.data.dados.length > 0) {
            			helper.alertaErro(cmp, event, helper, 'Error ao integrar', err.data.menssage, 'error');
                        const addCobranca = err.data.dados.filter(v => v.TipoEndereco == 'Cobranca');
                        const addEntrega = err.data.dados.filter(v => v.TipoEndereco == 'Entrega');
            
            			if (addCobranca.length !== 0) helper.validAddress[0] = false;
            			if (addEntrega.length !== 0) helper.validAddress[1] = false;
            
                        modal.style.display = "flex";
        
                        let innerHtmlCobranca = '';
            			let innerHtmlEntrega = '';
            
                        if(addCobranca.length != 0){
            				let currentAddress = '';
            				if(value[0].BillingStreet) currentAddress += value[0].BillingStreet;
            				if(value[0].BillingCity) currentAddress += currentAddress ? ', ' + value[0].BillingCity : value[0].BillingCity;
            				if(value[0].BillingState) currentAddress += currentAddress ? ', ' + helper.getSiglaEstado(value[0].BillingState) : helper.getSiglaEstado(value[0].BillingState);
            				if(value[0].BillingPostalCode) currentAddress += currentAddress ? ', ' + value[0].BillingPostalCode : value[0].BillingPostalCode;
            
                            innerHtmlCobranca += `
                                <div class="row-IntegracaoPedidoVenda">
                                    <div class="error-title-IntegracaoPedidoVenda">
                                        <span>
            								O <b> endereço de cobrança </b> não possui cadastro no SAP: ${currentAddress}
                                        </span>
                                    </div>
                                    <div>
                                        <span class="spacing-IntegracaoPedidoVenda green-text-IntegracaoPedidoVenda"><b>Outros endereços de cobrança já cadastrados no SAP:</b></span>
                                    </div>
                            `;
                            addCobranca.forEach(v => {
                                let address =  ''; 
            					let street = '';
                                if (v.Logradouro) address += v.Logradouro;
                                if (v.Numero) address += address ? ', ' + v.Numero : v.Numero;
                                if (v.Complemento) address += address ? ', ' + v.Complemento : v.Complemento;
                                if (v.Bairro) address += address ? ', ' + v.Bairro : v.Bairro;
            					street = address;
                                if (v.Cidade) address += address ? ', ' + v.Cidade : v.Cidade;
                                if (v.Uf) address += address ? ', ' + v.Uf : v.Uf;
                                if (v.Cep) address += address ? ', ' + v.Cep : v.Cep;            				
                                innerHtmlCobranca += helper.mountAddressRow('Cobranca', address, street, v.Cidade, helper.getEstadoName(v.Uf), v.Cep);
                            });
                            innerHtmlCobranca += `</div>`;
                        }
    
                        if(addEntrega.length != 0){
            				let currentAddress = '';
            				if(value[0].ShippingStreet) currentAddress += value[0].ShippingStreet;
            				if(value[0].ShippingCity) currentAddress += currentAddress ? ', ' + value[0].ShippingCity : value[0].ShippingCity;
            				if(value[0].ShippingState) currentAddress += currentAddress ? ', ' + helper.getSiglaEstado(value[0].ShippingState) : helper.getSiglaEstado(value[0].ShippingState);
            				if(value[0].ShippingPostalCode) currentAddress += currentAddress ? ', ' + value[0].ShippingPostalCode : value[0].ShippingPostalCode;
    
    						innerHtmlEntrega += `
                                <div>
                                    <div class="error-title-IntegracaoPedidoVenda">
                                        <span>
    										O <b> endereço de entrega </b> não possui entrega no SAP: ${currentAddress}
                                        </span>
                                    </div>
                                    <div>
                                        <span class="spacing-IntegracaoPedidoVenda green-text-IntegracaoPedidoVenda"><b>Outros endereços de entrega já cadastrados no SAP:</b></span>
                                    </div>
                            `;
                            addEntrega.forEach(v => {
                                let address =  ''; 
            					let street = '';
                                if (v.Logradouro) address += v.Logradouro;
                                if (v.Numero) address += address ? ', ' + v.Numero : v.Numero;
                                if (v.Complemento) address += address ? ', ' + v.Complemento : v.Complemento;
                                if (v.Bairro) address += address ? ', ' + v.Bairro : v.Bairro;
            					street = address;
                                if (v.Cidade) address += address ? ', ' + v.Cidade : v.Cidade;
                                if (v.Uf) address += address ? ', ' + v.Uf : v.Uf;
                                if (v.Cep) address += address ? ', ' + v.Cep : v.Cep;
                                innerHtmlEntrega += helper.mountAddressRow('Entrega', address, street, v.Cidade, helper.getEstadoName(v.Uf), v.Cep);
                            });
                            innerHtmlEntrega += `</div>`;
                        }

                        modalContentCobranca.innerHTML = innerHtmlCobranca;
                        modalContentEntrega.innerHTML = innerHtmlEntrega;
                        //modalContent.insertAdjacentHTML('beforeend',innerHtml);

						$(".botao-usar").on('click', function(event){
                            let data = $(this).data();
                            if (confirm('Deseja mesmo integrar esse pedido? Após isso alterações nao serão permitidas') == true) {
				            	divSpin.style.display = 'block';                                
	                            helper.updateAddressPedido(cmp, recordId, data.type, data.street, data.city, data.state, data.postalcode).then(function () {
    	                            helper.alertaErro(cmp, event, helper, `Endereço de ${data.type} atualizado`, 'Com sucesso!', 'success');
        	                        divSpin.style.display = 'none';
                                    if (data.type == 'Cobranca') {
                                        modalContentCobranca.innerHTML = '';
										helper.validAddress[0] = true;
                                    }
                                    if (data.type == 'Entrega') {
                                    	modalContentEntrega.innerHTML = '';
                                        helper.validAddress[1] = true;   
                                    }
		                            if (helper.validAddress[0] == true && helper.validAddress[1] == true) {
        	                            modal.style.display = "none";
    	    	                        integFunction();
        	    	                }
            	                }).catch(err => {
                	                divSpin.style.display = 'none';
                    	            helper.alertaErro(cmp, event, helper, 'Error ao atualizar endereço', err, 'error');
                        	    });
                            }
                        });
        
        			} else {
                        helper.alertaErro(cmp, event, helper, 'Error ao integrar', err.data.menssage, 'error');
                    }            
        		});
            });
            /*testButton.addEventListener("click", () => {
                helper.ativarPedidoVenda(cmp, recordId).then(function () {
            		helper.alertaErro(cmp, event, helper, 'O PEDIDO FOI INTEGRADO AO SAP', 'Com sucesso!', 'success');                    
                    setTimeout(() => {
                        window.location.reload();
        			}, 2000);
        		}).catch(err => {
            		helper.alertaErro(cmp, event, helper, 'O PEDIDO FOI INTEGRADO AO SAP, MAS NÃO FOI ATIVADO', err, 'error');
        		});
            });*/

                                    
        });
        
        modalClose.addEventListener("click", function() {
            modal.style.display = "none";
        });
                 
	},
                                
    alertaErro: function (cmp, event, helper, title, tipoMensagem, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": tipoMensagem,
            "type": type,
            "mode": 'sticky'
        });
        toastEvent.fire();
    },
        
    mountAddressRow : function (addressType, address, street, city, state, postalCode) {
		return `
        	<div>
            	<span class="address-IntegracaoPedidoVenda">
                    ${address}
                </span>
                <button type="button" class="btn btn-success botao-usar" data-type="${addressType}" data-street="${street}" data-city="${city}" data-state="${state}" data-postalCode="${postalCode}">
                    Usar esse
                </button>
            </div>
        `;            
    },

    getSiglaEstado : function (estado) {
        const states = {
            "Acre": "AC",
            "Alagoas": "AL",
            "Amapá": "AP",
            "Amazonas": "AM",
            "Bahia": "BA",
            "Ceará": "CE",
            "Distrito Federal": "DF",
            "Espírito Santo": "ES",
            "Goiás": "GO",
            "Maranhão": "MA",
            "Mato Grosso": "MT",
            "Mato Grosso do Sul": "MS",
            "Minas Gerais": "MG",
            "Pará": "PA",
            "Paraíba": "PB",
            "Paraná": "PR",
            "Pernambuco": "PE",
            "Piauí": "PI",
            "Rio de Janeiro": "RJ",
            "Rio Grande do Norte": "RN",
            "Rio Grande do Sul": "RS",
            "Rondônia": "RO",
            "Roraima": "RR",
            "Santa Catarina": "SC",
            "São Paulo": "SP",
            "Sergipe": "SE",
            "Tocantins": "TO"
        };
        
        return states[estado] || null;
    },
        
    getEstadoName : function (estado) {
        if(!estado) return null;
        
	    const states = {
          AC: 'Acre',
          AL: 'Alagoas',
          AM: 'Amazonas',
          AP: 'Amapá',
          BA: 'Bahia',
          CE: 'Ceará',
          DF: 'Distrito Federal',
          ES: 'Espírito Santo',
          GO: 'Goiás',
          MA: 'Maranhão',
          MG: 'Minas Gerais',
          MS: 'Mato Grosso do Sul',
          MT: 'Mato Grosso',
          PA: 'Pará',
          PB: 'Paraíba',
          PE: 'Pernambuco',
          PI: 'Piauí',
          PR: 'Paraná',
          RJ: 'Rio de Janeiro',
          RN: 'Rio Grande do Norte',
          RO: 'Rondônia',
          RR: 'Roraima',
          RS: 'Rio Grande do Sul',
          SC: 'Santa Catarina',
          SE: 'Sergipe',
          SP: 'São Paulo',
          TO: 'Tocantins'
        };
      
        return states[estado.toUpperCase()] || null;    
    }

})