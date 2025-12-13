({
    handleSelect: function (component, event, helper) {
        console.log('1');
        component.set("v.modal", true);
        
        var selectedMenuItemValue = event.getParam("value");
        var recordId = component.get("v.recordId");
        
        if (selectedMenuItemValue == "ORDEM DE TRABALHO") {   
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/Imprimir_OTv3?Id=" + recordId;
            } else {
                component.set("v.Imprimir_OTv3", true);
            }       
        }
        
        if (selectedMenuItemValue == "REGISTRO DE ATENDIMENTO") {
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/Registro_de_Atendimento_v3?Id=" + recordId;
            } else {
                component.set("v.pdf_RA", true);
            }
        }
        
        if (selectedMenuItemValue == "REGISTRO DE BASE INSTALADA") {
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/APDFDEINSTALACAO_v2?Id=" + recordId;
            } else {    
                component.set("v.pdf_RBI", true);
            }
        }
        
        if (selectedMenuItemValue == "LISTA DE PRESENÇA") {
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/LISTADEPRESENCA2?Id=" + recordId;
            } else {
                component.set("v.pdf_LP", true);
            }
        }
        
        if (selectedMenuItemValue == "LISTA DE PRESENÇA(NOVO)") {
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/LISTADEPRESENCA2_NOVO?Id=" + recordId;
            } else {
                component.set("v.pdf_LP_NOVO", true);
            }
        }
        
        if (selectedMenuItemValue == "PROPOSTA") {
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/OrdemDeTrabalhoProposta?Id=" + recordId;
            } else {
                component.set("v.pdf_PROPOSTA", true);
            }
        }
        
        if (selectedMenuItemValue == "REGISTRO DE ENTREGA") {
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/Registro_de_Entrega_v2?Id=" + recordId;
            } else {
                component.set("v.pdf_RE", true);
            }
        }
        
        if (selectedMenuItemValue == "REGISTRO DE RETIRADA") {
            if (navigator.userAgent.match(/Android/i)) {
                window.location.href = "https://hospcom.my.site.com/Sales/apex/Registro_de_Retirada?Id=" + recordId;
            } else {
                component.set("v.pdf_RE2", true);
            }
        }
    },
    
    FecharPdf: function (component, event, helper) {
        component.set("v.modal", false);        
        component.set("v.Imprimir_OTv3", false);
        component.set("v.pdf_RA", false);
        component.set("v.pdf_RBI", false);
        component.set("v.pdf_LP", false);
        component.set("v.pdf_PROPOSTA", false);
        component.set("v.pdf_RE", false);
        component.set("v.pdf_RE2", false);
        component.set("v.pdf_LP_NOVO", false);
    },
});