({
    doInit: function(cmp, event, helper) {
        const currentUserId = $A.get("$SObjectType.CurrentUser.Id");
        const recordId = cmp.get("v.recordId");

        helper.queryUserAndOc(cmp, currentUserId, recordId)
            .then(result => {
                if (result) {
                    console.log("Usuário:", result.user.Name);
                    console.log("É gerente?", result.isGerente);
                    console.log("É bypass?", result.isBypass);
                    console.log("É gestor do responsável?", result.userIsGestor);
                    console.log("Oc ready?", result.ocReady);
                } else {
                    console.warn("Não foi possível carregar User ou Ocorrência");
                }
            });
},
    criarAc: function(cmp, event, helper){
        const oc = cmp.get("v.oc");
        
        helper.criarAc(cmp, oc, event);
    }
})