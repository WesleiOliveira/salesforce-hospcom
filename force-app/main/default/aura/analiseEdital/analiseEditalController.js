({
    doInit: function (component, event, helper) {
        var soqlQuery = "SELECT Id, Name, Analisado__c, Codigo_fabricante__c, Imagem__c, Produto__c, Nome_do_Fabricante__c, Modelo_do_Produto__c, Quantity, UnitPrice, Analise_Tecnica__c, Itens_que_justificam__c, Product2.Name FROM OpportunityLineItem WHERE Item__c != null AND OpportunityId = '" + component.get("v.recordId") + "' ORDER BY Product2.Name";
        var action = component.get("c.executeSoql");
        action.setParams({ soql: soqlQuery });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.opportunityLineItems", response.getReturnValue());
            } else {
                console.error("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    openRecordEditModal: function (component, event, helper) {
        var selectedRecordId = event.currentTarget.getAttribute("data-id");
        console.log("Selected Record Id: " + selectedRecordId); // Log for debugging
        component.set("v.selectedRecordId", selectedRecordId);
        component.set("v.showAnaliseModal", true);
    },
    
    closeRecordEditModal: function (component, event, helper) {
        component.set("v.selectedRecordId", null);
        component.set("v.showAnaliseModal", false);
    },
    
    handleSuccess: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : 'success',
            "title": '',
            "message": 'Análise realizada com sucesso.'
        });
        toastEvent.fire();
        component.set("v.selectedRecordId", null);
        // Recarregar os itens de linha da oportunidade para refletir as alterações
        component.set("v.showAnaliseModal", false);
        var soqlQuery = "SELECT Id, Name, Analisado__c, Codigo_fabricante__c, Imagem__c, Produto__c, Nome_do_Fabricante__c, Modelo_do_Produto__c, Quantity, UnitPrice, Analise_Tecnica__c, Itens_que_justificam__c, Product2.Name FROM OpportunityLineItem WHERE Item__c != null AND OpportunityId = '" + component.get("v.recordId") + "' ORDER BY Product2.Name";
        var action = component.get("c.executeSoql");
        action.setParams({ soql: soqlQuery });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.opportunityLineItems", response.getReturnValue());
            } else {
                console.error("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    openAnaliseEdital : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = 'https://hospcom.my.site.com/Sales/s/sfdcpage/%2Fapex%2FAnalise_Edital%3F%26id%3D' + recordId;
        window.open(url, '_blank');
    },
    openCotacao : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = 'https://hospcom.my.site.com/Sales/s/sfdcpage/%2Fapex%2FNovaPropostaGoverno%3F%26id%3D' + recordId;
        window.open(url, '_blank');
    },

    openConcorrenteModal: function(component, event, helper) {

        let initialList = [{
            nome: "",
            valorUnit: "",
            valorTotal: "",
            qtd: "",
            marca: "",
            modelo: "",
            obs: "",
            selectedMotivo: "",
            selectedSituacao: "",
            searchTerm: "",
            searchResults: [],
            selectedAccount: null
        }];
        
        component.set("v.concorrentes", initialList);


        const actionMotivo = component.get("c.listagem");
        actionMotivo.setParams({
                nomeObjeto: "Analise_de_Mercado__c",
                nomeCampo: "Motivo__c"
            });

            actionMotivo.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.motivos", response.getReturnValue());
                } else {
                    console.error("Erro ao buscar picklist: ", response.getError());
                }
            });

    $A.enqueueAction(actionMotivo);
        const actionSituacoes = component.get("c.listagem");

        actionSituacoes.setParams({
                nomeObjeto: "Analise_de_Mercado__c",
                nomeCampo: "Situacao__c"
            });

            actionSituacoes.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.situacoes", response.getReturnValue());
                } else {
                    console.error("Erro ao buscar picklist: ", response.getError());
                }
            });

    $A.enqueueAction(actionSituacoes);

    const actionMarcas = component.get("c.listagem");

    actionMarcas.setParams({
                nomeObjeto: "Analise_de_Mercado__c",
                nomeCampo: "Marca__c"
            });

            actionMarcas.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.marcas", response.getReturnValue());
                } else {
                    console.error("Erro ao buscar picklist: ", response.getError());
                }
            });

    $A.enqueueAction(actionMarcas);


    let actionExists = component.get("c.executeSoql");

    let selectedProductId = event.currentTarget.getAttribute("data-id");

    let query = `
        SELECT Id, Concorrente__c, Concorrente__r.Name, Motivo__c, Situacao__c, Preco_unitario__c, Valor_total__c, Marca__c
        FROM Analise_de_Mercado__c 
        WHERE Produto_da_Oportunidade__c = '${selectedProductId}'
    `;

    console.log(query);

    actionExists.setParams({ soql: query });

    actionExists.setCallback(this, function(response) {
        let state = response.getState();
        if (state === "SUCCESS") {
            let rawData = response.getReturnValue();
            console.log("Dados recebidos:", rawData);

            let mapped = rawData.map(function(a) {
                return {
                    Id: a.Id,
                    Concorrente: a.Concorrente__r ? a.Concorrente__r.Name : '',
                    Marca: a.Marca__c,
                    Motivo: a.Motivo__c,
                    Situacao: a.Situacao__c,
                    PrecoUnitario: a.Preco_unitario__c,
                    valorTotal: a.Valor_total__c
                };
            });

            component.set("v.analisesExistentes", mapped);
            component.set("v.analiseColumns", [
                { label: 'Concorrente', fieldName: 'Concorrente', type: 'text' },
                { label: 'Marca', fieldName: 'Marca', type: 'text' },
                { label: 'Situação', fieldName: 'Situacao', type: 'text' },
                { label: 'Motivo', fieldName: 'Motivo', type: 'text' },
                { label: 'Valor unitário', fieldName: 'PrecoUnitario', type: 'currency' },
                { label: 'Valor total', fieldName: 'valorTotal', type: 'currency' }
            ]);
            
        } else {
            console.error("Erro:", response.getError());
        }
    });

    $A.enqueueAction(actionExists);


        let id = event.currentTarget.getAttribute("data-id");
        component.set("v.selectedRecordId", id);
        component.set("v.concorrenteRecordId", id);
        //component.set("v.concorrentes", [{ nome: "", marca: "" }]);
        component.set("v.showConcorrenteModal", true);
    },
    
    closeConcorrenteModal: function(component, event, helper) {
        component.set("v.showConcorrenteModal", false);
        component.set("v.concorrenteRecordId", null);
        component.set("v.concorrentes", []);
    },
    
    addConcorrente: function(component, event, helper) {
        let list = component.get("v.concorrentes");
    
        // Crie uma nova cópia do array e adicione o novo concorrente
        let newConcorrente = {
            nome: "",
            valorUnit: "",
            valorTotal: "",
            qtd: "",
            marca: "",
            modelo: "",
            obs: "",
            selectedMotivo: "",
            selectedSituacao: "",
            searchTerm: "",
            searchResults: [],
            selectedAccount: null
        };
    
        let newList = list.slice();  // Cria uma cópia do array
        newList.push(newConcorrente);  // Adiciona o novo item
    
        // Define a nova lista no componente
        component.set("v.concorrentes", newList);
    },      
    
    handleConcorrenteChange: function(component, event, helper) {
        let index = event.getSource().get("v.data-index");
        let field = event.getSource().get("v.name");
        let list = component.get("v.concorrentes");
        list[index][field] = event.getSource().get("v.value");
        component.set("v.concorrentes", list);
    },

    handleKeyUp : function(component, event, helper) {
        const input = event.getSource();
        const index = parseInt(input.get("v.name")); // vem do name no input
        let concorrentes = component.get("v.concorrentes");

        console.log("Entrou key up");
    
        const term = concorrentes[index].searchTerm;
    
        if (!term || term.trim() === '') return;
    
        const query = "SELECT Id, Name FROM Account WHERE Name LIKE '%" + term + "%' LIMIT 10";
        const action = component.get("c.executeSoql");
    
        action.setParams({ soql: query });
    
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let results = response.getReturnValue();
                concorrentes[index].searchResults = results;
                component.set("v.concorrentes", concorrentes); // atualiza a lista inteira
            }
        });
    
        $A.enqueueAction(action);
        console.log(concorrentes);
    },    

    selectAccount: function(component, event, helper) {
        const index = event.currentTarget.getAttribute("data-index");
        const accountId = event.currentTarget.getAttribute("data-id");
    
        let concorrentes = component.get("v.concorrentes");
        let selectedAccount = concorrentes[index].searchResults.find(a => a.Id === accountId);
    
        if (selectedAccount) {
            concorrentes[index].selectedAccount = selectedAccount;
            concorrentes[index].searchTerm = selectedAccount.Name;
            concorrentes[index].searchResults = [];
            component.set("v.concorrentes", concorrentes);
        }
    },
    
    saveConcorrentes : function(component, event, helper) {
        console.log("Entrou");
        console.log("id do produto da opp: " + component.get("v.selectedRecordId"));
        let produtoId = component.get("v.selectedRecordId")
        let concorrentes = component.get("v.concorrentes");
    
        let concorrentesData = concorrentes.map(function(conc) {
            return {
                accountId: conc.selectedAccount.Id,
                marca: conc.marca,
                motivo: conc.selectedMotivo ,
                situacao: conc.selectedSituacao,
                modelo: conc.modelo,
                precoUnitario: conc.valorUnit,
                precoTotal: conc.valorTotal,
                obs: conc.obs
            };
        });
    
        let action = component.get("c.saveConcorrentesApex");
        action.setParams({
            concorrentes: JSON.stringify(concorrentesData),
            oportunidadeId: component.get("v.recordId"), // esse é o ID da Oportunidade
            produto: produtoId // esse é o ID do Produto da Oportunidade
        });
    
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                // Exibe um toast de sucesso
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Sucesso",
                    "message": "Concorrentes salvos com sucesso!",
                    "type": "success"
                });
                toastEvent.fire();
            
                // Fechar o modal
                component.set("v.showConcorrenteModal", false); 
                // Limpar os campos de concorrente
                component.set("v.concorrentes", []);  // Limpa a lista de concorrentes, se necessário
                component.set("v.selectedMotivo", null);  // Limpa o valor selecionado para "Motivo"
                component.set("v.selectedSituacao", null);  // Limpa o valor selecionado para "Situação"
                // Adicione outros campos que você precisar limpar aqui
            } else {
                console.error("Erro ao salvar concorrentes: ", response.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro",
                    "message": "Ocorreu um erro ao salvar os concorrentes.",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
    
        $A.enqueueAction(action);
    }     
});