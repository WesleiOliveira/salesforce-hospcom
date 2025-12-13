({
    processFilesHelper : function(component, uploadedFiles) {
        //let action = component.get("c.attachFilesToWorkOrder");
        let fileDetails = [];

        // Prepara a lista de arquivos para processar
        uploadedFiles.forEach(file => {
            let workOrderNumber = file.name.split(".")[0]; // Extrai o número da Ordem de Trabalho
            fileDetails.push({
                "fileId": file.documentId,  // O documentId refere-se ao arquivo já carregado
                "workOrderNumber": workOrderNumber
            });
        });
    
    	console.log("FILE DETAILS", fileDetails)
		
    	let action = component.get("c.attachFilesToWorkOrder");
        action.setParams({
            "fileDetails": fileDetails
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                alert("Arquivos processados e vinculados com sucesso!");
            } else {
                alert("Erro ao processar os arquivos.");
            }
        });

        $A.enqueueAction(action);
    }
})