({
    selectedInstrucoesIds: [],
    recordId: '',
    
    adicionarTag: function(cmp, event, helper) {
        helper.recordId = cmp.get("v.recordId");
        console.log("Id: ", helper.recordId);
        
        var selected = cmp.get("v.selectedInstrucoes");
        var itemId = event.currentTarget.getAttribute("data-id");
        var items = cmp.get("v.instrucoesDeServico");
        
        var selectedItem = items.find(function(item) {
            return item.Id === itemId;
        });
        
        if(!selected.some(item => item.Id === itemId)) {
            selected.push(selectedItem);
            cmp.set("v.selectedInstrucoes", selected);
            helper.selectedInstrucoesIds.push(itemId); // Armazena o ID
        }
        $("#resultados12212").css("display", "none");
        cmp.set("v.searchTerm", "");
    },
    
    removerTag: function(cmp, event, helper) {
        var tagId = event.currentTarget.getAttribute("data-tagid");
        var selected = cmp.get("v.selectedInstrucoes");
        
        var newSelected = selected.filter(function(item) {
            return item.Id !== tagId;
        });
        
        cmp.set("v.selectedInstrucoes", newSelected);
        helper.selectedInstrucoesIds = helper.selectedInstrucoesIds.filter(id => id !== tagId); // Remove o ID
    },
    // função para buscar instruções de serviço
    buscaIs : function(cmp, event, helper) {
        
        
        console.log("BUSCA IS")
        var termo = cmp.get("v.searchTerm")
        
        var query = "SELECT Id, Name, Departamento__c " +
            "FROM Instrucao_de_Servico__c " +
            "WHERE Name LIKE '%" + termo + "%' " +
            "LIMIT 5";
        
        console.log(query)
        
        //REALIZA A CONSULTA
        helper.soql(cmp, query)
        
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (menus) {
            
            var maxLength = 30;
            
            menus.forEach(function (is) {
                if (is.Name && is.Name.length > maxLength) {
                    console.log("Passou aqui");
                    is.Name = is.Name.substring(0, maxLength) + "...";
                }
                
            });
            
            $("#resultados12212").css("display", "flex")
            cmp.set("v.instrucoesDeServico", menus);
            
            $(".is12122").on( "click", function() {
                var id = $(this).attr("data-id")
                var recordId = cmp.get("v.recordId");
                
                console.log("CLIQUE ADD", id);
                
                
            });
        })
        
        //trata excessão de erro	
        .catch(function (error) {
            console.log(error)
        })
        
    },
    inicarFlow: function(cmp, event, helper) {
        var flow = cmp.find("flowData");
        
        // Ativa o Spinner
        cmp.set("v.isLoading", true);
        
        if (!helper.selectedInstrucoesIds || helper.selectedInstrucoesIds.length === 0) {
            cmp.set("v.isLoading", false);
            alert("Nenhuma instrução selecionada.");
            return;
        }
        
        var inputVariables = [
            {
                name: "idIs",
                type: "String",
                value: helper.selectedInstrucoesIds // Passando os IDs
            },
            {
                name: "IdPop",  // Adicionando o ID do POP como parâmetro
                type: "String",
                value: helper.recordId.trim() // Pegando o ID do POP da página atual
            }
        ];
        
        // Inicia o Flow
        flow.startFlow("POP_Relaciona_Instru_o_de_Servi_o", inputVariables);
        
    },
    
    statusFlow: function(cmp, event, helper) {
        
        var status = event.getParam("status");
        console.log("Arrays de Is: ", helper.selectedInstrucoesIds);
        console.log("Status do Flow:", status);
        
        if (status === "FINISHED_SCREEN") {
            cmp.set("v.isLoading", false);
            location.reload();
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "success",
                "title": "Sucesso!",
                "message": "Instrução relacionada com sucesso!"
            });
            toastEvent.fire();
            
            $A.get("e.force:refreshView").fire();
            
        } else if (status === "ERROR") {
            cmp.set("v.isLoading", false);
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Erro!",
                "message": "Erro: Instrução de Serviço já vinculada!"
            });
            toastEvent.fire();
        }
        
    }
})