({
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
    
    getCarteiras: function (component, event, helper) {
        
        const textoCarteira = $A.get("$Label.c.Carteira");
        
        var query = `
        SELECT Id, Name, Saldo__c, Colaborador__c, Nome_completo__c, Carteira_Ativa__c 
        FROM Carteira__c 
        WHERE Carteira_Ativa__c = true 
        ORDER BY Nome_completo__c`;
        
        helper.soql(component, query)
        .then(function (carteiras) {
            carteiras.forEach(function (carteira) {
                
                var saldo = carteira.Saldo__c || 0.00;
                let saldoFormatado = `H$ ${saldo.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
                
                $('#carteiras').append(`
                                       <div class='carteira'>
                                       <span class='foto'>TF</span>
                                       <span class='nome'>${carteira.Nome_completo__c}</span>
                                       <span class='saldo' id='${carteira.Id}'>${saldoFormatado}</span>
                                       <span>
                                       <button class='button-29 premiar-btn' role='button' 
                                       id='kk${carteira.Id}' 
                                       data-nome='${carteira.Nome_completo__c}' 
                                       data-id='${carteira.Id}'>`+textoCarteira+`</button>
                                       </span>
                                       </div>
                                       `);
                
                $('#kk' + carteira.Id).click(function () {
                    console.log("clique carteira")
                    helper.alertaErro(component, event, helper, "", "Carregando carteira...", "info", "", "dismissable")
                    
                    const nome = $(this).data('nome');
                    const id = $(this).data('id');
                    
                    helper.buscarHistorico(component, carteira.Id)
                    .then(function(historicoHTML) {
                        $('#container_main').append(`
                                                    <div class="premiacao-popup">
                                                    <div>
                                                    <div style="font-size: 1.25rem;">Premiação</div>
                                                    <div style="display: flex; flex-direction: column; gap: 10px;">
                                                    <div>${nome}</div>
                                                    <div style="display: flex; gap: 5px;">
                                                    <div style="width: 85px">Programa:</div>
                                                    <select class="programa-select">
                                                    <option disabled="disabled" selected="selected">-- Selecione --</option>
                                                    <option>Programa valeu</option>
                                                    <option>5S</option>
                                                    <option>Resgate</option>
                                                    <option>Outro</option>
                                                    </select>
                                                    <input class="programa-outro" style="display: none; margin-left: 10px;" placeholder="Digite o programa" />
                                                    </div>
                                                    <div style="display: flex; gap: 5px;">
                                                    <div style="width: 85px">Valor:</div>
                                                    <input class="valor-input" style="width: 50px;" />
                                                    </div>
                                                    <div style="display: flex; gap: 20px; margin: 20px auto 5px;">
                                                    <button class="button-6" id="btn_cancelar_premiacao" role="button">Cancelar</button>
                                                    <button class="button-6 premiar" id="btn_premiacao" data-id-premiacao='${id}' role="button">Salvar</button>
                                                    </div>
                                                    </div>
                                                    </div>
                                                    <hr />
                                                    <div>
                                                    <div class="titulo342534">Histórico</div>
                                                    <br />
                                                    <div>
                                                    <div style="display: flex; justify-content: space-around;">
                                                    <div class="titulosColunasHistorico">
                                                    Programa
                                                    </div>
                                                    <div class="titulosColunasHistorico">
                                                    Valor
                                                    </div>
                                                    </div>
                                                    <br />
                                                    <div class="historico" style="overflow: auto; max-height: 100px;">
                                                    ${historicoHTML}  <!-- Adicionando o histórico dinâmico -->
                                                    </div>
                                                    </div>
                                                    </div>
                                                    </div>
                                                    `);
                    })
                    
                    .catch(function(error) {
                        console.error("Erro ao buscar histórico:", error);
                    });               
                });
            });
            
            $(document).on('change', '.programa-select', function () {
                $(this).siblings('.programa-outro').toggle($(this).val() === 'Outro');
            });
            
            $(document).on('click', '#btn_premiacao', function () {
                
                let $botao = $(this); // guarda referência ao botão 
                $botao.prop('disabled', true);
                console.log($botao);
                var programa = $('.programa-select').val();
                const programaOutro = $('.programa-outro').val();
                var valor = $('.valor-input').val();
                const id = $(this).data('id-premiacao');
                
                
                
                console.log(programa, programaOutro, valor, id);
                if (!programa || (programa === 'Outro' && !programaOutro)) {
                    helper.exibirAlerta(component, event, helper, "warning", "Alerta", "Por favor, selecione ou insira um programa válido.");
                    $botao.prop('disabled', false);
                    console.log("Botao desativado");
                    return;
                }
                
                if (!valor || isNaN(valor) || parseFloat(valor) < 0) {
                    helper.exibirAlerta(component, event, helper, "warning", "Alerta", "Por favor, insira um valor válido diferente de 0.");
                    $botao.prop('disabled', false);
                    console.log("Botao desativado");
                    return;
                }
                
                if (programa === 'Outro') {
                    programa = programaOutro;
                }
                var valorP
                if(programa == 'Resgate'){
                    valorP =  parseFloat(valor) * (-1);
                }else{
                    valorP = parseFloat(valor)
                }
                helper.alertaErro(component, event, helper, "", "Processando operação...", "info", "", "dismissable")
                console.log(id, valorP ,programa);
                helper.insereSaldo(component, event, helper, id, valorP ,programa)
                .then(() => {
                    helper.alertaErro(component, event, helper, "", "Operação concluída", "success", "", "dismissable")
                    helper.verificaValorCarteira(component, event, helper, id);                      
                })
                    .catch((error) => {
                    helper.exibirAlerta(`component, event, helper, "error", "Erro", Falha ao atualizar saldo: ${error}`);
            })
            .finally(() => {
                $botao.prop('disabled', false); // sempre reativa o botão no final
                
            });
        });
        $(document).on('click', '#btn_cancelar_premiacao', function () {
            $('.premiacao-popup').last().remove();
        });
        
    })
    .catch(function (error) {
    console.error("Erro ao buscar carteiras:", error);
});

},
    
    buscarHistorico: function (component, idCarteira) {
        var query = `
        SELECT Programa__c, Quantidade_de_Hospcoins__c
        FROM Transfer_ncia_Hospcoin__c
        WHERE Carteira_Destinataria__c = '${idCarteira}'
        ORDER BY CreatedDate DESC`;
        
        return new Promise((resolve, reject) => {
            this.soql(component, query)
            .then(function (historico) {
            if (historico.length === 0) {
            resolve(`
            <div style="text-align: center; margin-top: 10px;">Nenhum histórico encontrado.</div>
            `);
            return;
        }
            
            let historicoHTML = historico.map(function (registro) {
            
            let valor = registro.Quantidade_de_Hospcoins__c;
            let valorFormatado = `H$ ${valor.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    let cor = valor > 0 ? "#21e500" : "#e50000"; // Verde para entrada, vermelho para saída
    
    return `
    <div class="itemHistorico38294" style="color: ${cor};">
    <div style="width: 120px; text-align: left;">
    ${registro.Programa__c}
         </div>
         <div style="width: 120px; text-align: right; padding: 0 10px;">
         ${valor > 0 ? "+" : ""} ${valorFormatado}
         </div>
         </div>`
         ;
         }).join("");
resolve(historicoHTML);
})
.catch(function (error) {
    console.error("Erro ao buscar histórico:", error);
    reject("<div style='color: red;'>Erro ao carregar histórico.</div>");
});
});
},
    
    insereSaldo: function (component, event, helper, idCarteira, saldoPremiacao, programa) {
        return new Promise((resolve, reject) => {
            try {
            var novoSaldo =  saldoPremiacao ; 
            var action = component.get("c.carteiraInsereSaldo");
            action.setParams({ idCarteira, newSaldo: novoSaldo });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
           console.log("State: ",state);
            if (state === "SUCCESS") {
                helper.criaHistorico(component, event, helper, idCarteira, saldoPremiacao, programa);
                resolve();
            } else {                    
                console.log("Erro ao tentar atualizar o saldo.")
                reject("Erro ao tentar atualizar o saldo.");
            }
        });
        
        $A.enqueueAction(action);
    } catch (ex) {
        
        console.log(ex)
        reject("Erro ao executar ação: " + ex.message);
    }
});
},
    
    verificaValorCarteira: function (component, event, helper, idCarteira) {
        var query = `SELECT Id, Saldo__c FROM Carteira__c WHERE Id = '${idCarteira}'`;
        helper.alertaErro(component, event, helper, "", "Carregando carteira...", "info", "", "dismissable")
        
        helper.soql(component, query)
        .then(function (carteira) {
            if (carteira && carteira.length > 0) {
                const carteiraData = carteira[0];
                const saldoFormatado = `H$ ${carteiraData.Saldo__c.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
                
                $('#' + carteiraData.Id).html(saldoFormatado);
                $('.premiacao-popup').last().remove();
            } else {
                console.error("Nenhuma carteira encontrada com o ID fornecido.");
            }
        })
        .catch(function (error) {
            helper.exibirAlerta(`component, event, helper, "error", "Erro", Erro ao buscar saldo atualizado: ${error}`);
        });
    },
        
        criaHistorico: function (component, event, helper, idCarteiraDestinataria, saldo, programa) {
            try {
                var action = component.get("c.transderenciaRH");
                action.setParams({ 
                    idCarteiraDestinataria: idCarteiraDestinataria,
                    idCarteiraRemetente: 'a3fU40000006JET', 
                    saldo: saldo, 
                    programa: programa
                });
                
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("Histórico criado");
                    } else {
                        
                        console.log("falha ao criar histórico");
                    }
                });
                
                $A.enqueueAction(action);
            } catch (ex) {
                console.error("Erro ao criar histórico:", ex.message);
            }
        },
            
            
            //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
            showSpinner: function (cmp) {
                var a = $('#spinnerDiv').css("display", "flex");
            },
                //-------------------------------------------
                
                hideSpinner: function (cmp) {
                    $('#spinnerDiv').css("display", "none");
                },
                    
                    //--------------------------------------------
                    
                    exibirAlerta: function (component, event, helper, type, title, message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": type,
                            "title": title,
                            "message": message
                        });
                        toastEvent.fire();
                    }
});