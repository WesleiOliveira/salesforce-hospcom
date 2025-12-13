({
    openFileUploadModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    
    closeFileUploadModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    handleUploadFinished: function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentIds = [];

        uploadedFiles.forEach(file => {
            documentIds.push(file.documentId);
        });

        var action = component.get("c.processUploadedFiles");
        action.setParams({
            documentIds: documentIds,
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Files uploaded and processed successfully.');
            } else {
                console.error('Error in uploading files: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);

        component.set("v.isModalOpen", false);
    }
})