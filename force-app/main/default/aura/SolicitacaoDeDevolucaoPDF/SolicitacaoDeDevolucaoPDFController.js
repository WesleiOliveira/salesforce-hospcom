({
    throwPdf : function(component, event, helper) {
        window.open('https://hospcom--c.vf.force.com/apex/PDF_Itens_da_solicitacao_de_devolucao?scontrolCaching=1&id=' + component.get('v.recordId'), '_blank');
    }
})