({
    helperMethod : function(component, event, helper) {
        var recordId = component.get("v.recordId");

        var query = "SELECT Id, Name FROM User WHERE Id = '" + recordId + "'";

        return helper.soql(component, query)
            .then(result => {
                if (result && result.length > 0) {
                    component.set("v.userName", result[0].Name);
                    console.log("Name encontrado: ", result[0].Name);
                } else {
                    console.log("Nenhum usuário encontrado.");
                }
            })
            .catch(error => {
                console.log("Erro ao buscar usuário:", error);
            });
    }
})