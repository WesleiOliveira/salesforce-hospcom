({

onRender: function (component, event, helper) {
            const USER_ALBERTH = '0055A000008lqdWQAQ'
    const USER_DEV = '00531000006UzZsAAK'
    const currentUser = $A.get("$SObjectType.CurrentUser.Id");
    if (currentUser != USER_DEV && currentUser != USER_ALBERTH) { return }

    helper.mainMethod(component, event, helper)

},
fecharPopup: function (cmp, event, helper) {
            const USER_ALBERTH = '0055A000008lqdWQAQ'
    const USER_DEV = '00531000006UzZsAAK'
    const currentUser = $A.get("$SObjectType.CurrentUser.Id");
    if (currentUser != USER_DEV && currentUser != USER_ALBERTH) { return }

    $("#xyz").css("display", "none")
    $("#overlay4567").css("display", "none")
},
revisarContratoPopup: function (cmp, event, helper) {
            const USER_ALBERTH = '0055A000008lqdWQAQ'
    const USER_DEV = '00531000006UzZsAAK'
    const currentUser = $A.get("$SObjectType.CurrentUser.Id");
    if (currentUser != USER_DEV && currentUser != USER_ALBERTH) { return }

    $("#xyz").css("display", "flex")
    $("#overlay4567").css("display", "flex")

},
criarTarefa: function (component, event, helper) {
    const USER_ALBERTH = '0055A000008lqdWQAQ'
    const USER_DEV = '00531000006UzZsAAK'
    const currentUser = $A.get("$SObjectType.CurrentUser.Id");
    if (currentUser != USER_DEV && currentUser != USER_ALBERTH) { return }
    
    const JULIANA_GUIMARAES = '005U40000065ShmIAE'

    const dataDeVencimento = helper.getDataMaisDoisDiasUteis();

    var recordId = component.get("v.recordId");

    var createRecordEvent = $A.get("e.force:createRecord");

    createRecordEvent.setParams({
        entityApiName: "Task",
        defaultFieldValues: {
            Subject: 'Departamento Juridico',
            WhatId: recordId,
            Priority: 'Alto',
            Subtitulo__c: 'Revisão de contrato',
            OwnerId: JULIANA_GUIMARAES,
            Assunto_da_Visita__c: 'Favor revisar contrato de cotação enviado pelo cliente',
            AssuntoJuridco__c: 'Revisão de contrato',
            JuridicoSalvo__c: true,
            ActivityDate: dataDeVencimento


        }
    });
    createRecordEvent.fire();
}
})