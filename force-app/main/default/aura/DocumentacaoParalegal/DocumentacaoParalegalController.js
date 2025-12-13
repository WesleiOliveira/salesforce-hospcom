({
    doInit : function(component, event, helper) {
        helper.helperMethod(component, event, helper);
        
    },
    handleUploadFinished : function(component, event, helper){
        helper.handleUploadFinished(component, event, helper);
    },
    handleDeleteFile: function(component, event, helper) {
        const auraId = event.getSource().get("v.value"); 
        helper.deleteDocument(component, auraId);
    },
    openPdfModal: function(component, event, helper) {
        var pdfUrl = event.currentTarget.dataset.url;
        component.set("v.selectedPdfUrl", pdfUrl);
        component.set("v.isModalOpen", true);
    },
    
    closePdfModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.selectedPdfUrl", "");  
    },
    
    handleSubmit: function(component, event, helper){
        event.preventDefault();
        helper.handleSubmit(component, event);
    },
    
    handleSuccess: function(component, event, helper){
        helper.handleSuccess(component, event);
    },
    
    handleError: function(component, event, helper){
        helper.handleError(component, event, helper);
    },
    handleDateChange: function(component, event) {
        var changedField = event.getSource().getLocalId(); // Obtém o aura:id do campo alterado
        var value = event.getSource().get("v.value");       // Obtém o novo valor do campo
        
        console.log("Campo alterado:", changedField, "Novo valor:", value);
        
        // Mapeamento dos campos para variáveis de controle
        if (changedField === "venc_CREA") {
            component.set("v.creaOnChanging", true);
            if (value === null || value === "") {
                component.set("v.isVencCREAFieldEmpty", true);
                console.log("venc crea esta vazio")
            } else {
                component.set("v.isVencCREAFieldEmpty", false);
            }
            
        } else if (changedField === "venc_C_Bombeiros") {
            component.set("v.bombeirosOnChanging", true);
            if (value === null || value === "") {
                component.set("v.isVencCorpoFieldEmpty", true);
                console.log("venc corpo esta vazio")
            } else {
                component.set("v.isVencCorpoFieldEmpty", false);
            }
            
            
        } else if (changedField === "venc_Alv_Sanitario") {
            component.set("v.sanitarioOnChanging", true);
            if (value === null || value === "") {
                component.set("v.isSanitarioFieldEmpty", true);
                console.log("venc crea esta vazio")
            } else {
                component.set("v.isSanitarioFieldEmpty", false);
            }
            
        } else if (changedField === "venc_Alv_Localizacao") {
            component.set("v.localizacaoOnChanging", true);
            if (value === null || value === "") {
                component.set("v.isLocalizacaoFieldEmpty", true);
                console.log("venc loc esta vazio")
            } else {
                component.set("v.isLocalizacaoFieldEmpty", false);
            }
            
        } else if (changedField === "venc_Licenca_Ambiental") {
            component.set("v.licencaChanging", true);
            if (value === null || value === "") {
                component.set("v.isLicencaFieldEmpty", true);
                console.log("venc licenca ambiental esta vazio")
            } else {
                component.set("v.isLicencaFieldEmpty", false);
            }
        }
    },
    setClickedButton: function(component, event, helper) {
        var buttonAuraId = event.getSource().getLocalId();
        component.set("v.clickedButton", buttonAuraId);
    }
    
})