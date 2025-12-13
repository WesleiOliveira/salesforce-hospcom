({
    handleUploadFinished : function(component, event) {
        // Captura a lista de arquivos carregados
        let uploadedFiles = event.getParam("files");

        // Exibe cada fileId no console
        uploadedFiles.forEach(file => {
            console.log('DocumentId: ' + file.documentId + ', Nome do Arquivo: ' + file.name);
        });

        // Armazena a lista de arquivos no componente
        component.set("v.uploadedFiles", uploadedFiles);
        alert(uploadedFiles.length + " arquivos carregados.");
    },

    processFiles : function(component, event, helper) {
        let uploadedFiles = component.get("v.uploadedFiles");
        if (uploadedFiles && uploadedFiles.length > 0) {
            // Chama a função helper para processar os arquivos
            helper.processFilesHelper(component, uploadedFiles);
        } else {
            alert("Nenhum arquivo carregado.");
        }
    }
})