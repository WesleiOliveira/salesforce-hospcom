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
    //----------------------------------------------------------------------------------------------
    
    mainFunction : function(cmp, event, helper) {
        $('#buttonAnexar7893478').on('click', function() {
            const fileInput = $('#inputFileCsv43534')[0];
            const file = fileInput.files[0];
            
            if (file) {
                const reader = new FileReader();
                
                reader.onload = function(e) {
                    const text = e.target.result;
                    helper.processCSV(cmp, event, helper, text);
                };
                
                reader.readAsText(file);
            } else {
                alert('Por favor, selecione um arquivo CSV primeiro.');
            }
        });
    },
    
    criaRevenda : function(cmp, event, helper, data){
        // CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.inserirProdutos ");
        
        // DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX
        action.setParams({
            jsonString: JSON.stringify(data),
        });
        
        helper.alertaErro(cmp, event, helper, "", "Processando arquivo...", "info", "", "dismissable");
        
        // CALLBACK DA REQUISIÇÃO
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCESSO");
                helper.alertaErro(cmp, event, helper, "", "Produtos criados com sucesso", "success", "", "dismissable");
            } else if (state === "INCOMPLETE") {
                // Incomplete logic
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("erro", errors[0].message);
                    helper.alertaErro(cmp, event, helper, "", errors[0].message, "error", "", "dismissable");
                    reject(errors[0].message);
                } else {
                    console.log("erro desconhecido");
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    criaConsumo : function(cmp, event, helper, data){
        // CHAMA A FUNÇÃO DO APEX QUE ADICIONA O ITEM
        var action = cmp.get("c.inserirProdutosConsumo");
        
        // DEFINE OS PARÂMETROS PASSADOS PARA CLASSE APEX
        action.setParams({
            jsonString: JSON.stringify(data),
        });
        
        helper.alertaErro(cmp, event, helper, "", "Processando arquivo...", "info", "", "dismissable");
        
        // CALLBACK DA REQUISIÇÃO
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCESSO");
                helper.alertaErro(cmp, event, helper, "", "Produtos criados com sucesso", "success", "", "dismissable");
            } else if (state === "INCOMPLETE") {
                // Incomplete logic
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("erro", errors[0].message);
                    helper.alertaErro(cmp, event, helper, "", errors[0].message, "error", "", "dismissable");
                    reject(errors[0].message);
                } else {
                    console.log("erro desconhecido");
                    reject("Erro desconhecido");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    processCSV : function(cmp, event, helper, csvText){
        const lines = csvText.split('\n');
        const headers = lines[0].split(',');
        const jsonData = [];
        const fabricanteSet = new Set(); // Set para verificar duplicatas
        let hasEmptyField = false;
        let hasDuplicate = false;
        var tipoCriacao = $("#tipoCadastro").val()
    
        for (let i = 1; i < lines.length; i++) {
            const currentLine = lines[i].split(',');
            const obj = {};
    
            headers.forEach((header, index) => {
                const value = currentLine[index].trim();
                if (!value) {
                    alert(`Campo vazio encontrado na linha ${i + 1}, coluna "${header.trim()}".`);
                    hasEmptyField = true;
                    return; // Sai do forEach, mas não do for
                }
                obj[header.trim()] = value;
            });
    
            // Se um campo vazio foi detectado, interrompe a execução
            if (hasEmptyField) {
                return;
            }
 
            if(tipoCriacao == "Revenda"){
                const codigoFabricante = obj["Código do Fabricante"];
                if (fabricanteSet.has(codigoFabricante)) {
                    alert(`Código do Fabricante duplicado encontrado: ${codigoFabricante} na linha ${i + 1}.`);
                    hasDuplicate = true;
                    return; // Sai do forEach, mas não do for
                } else {
                    fabricanteSet.add(codigoFabricante);
                }
            }
    
            if (Object.keys(obj).length > 0 && currentLine[0]) {
                jsonData.push(obj);
            }
        }
    
        // Se um código duplicado foi detectado, interrompe a execução
        if (hasDuplicate) {
            return;
        }
    
        if(jsonData.length >= 49){
            alert("Quantidade máxima de produtos por lote excedida!");
            return;
        }
		
        if(!tipoCriacao){
            alert("Selecione um tipo de cadastro.");
            return;
        }

        console.log(jsonData);
                
        if(tipoCriacao == "Uso e Consumo"){
            helper.criaConsumo(cmp, event, helper, jsonData)
        }else{
            helper.criaRevenda(cmp, event, helper, jsonData)
        }
    }
})