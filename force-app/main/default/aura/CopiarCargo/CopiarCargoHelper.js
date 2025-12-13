({
    helperMethod : function(cmp, event, helper) {
        console.log("helperMethod iniciado")
        var recordId = cmp.get("v.recordId");
        console.log("RecordId: ", recordId)
        var query = `
        SELECT Name,
            Cargo_Superior__c,           
            Data_de_Aprovaco__c,
            Departamento__c,
            Formacao_Necessaria__c,
            Objetivos__c,
            Requisitos_comportamentais__c,
            Requisitos_tecnicos__c,
            responsabilidade1__c,
            responsabilidade2__c,
            responsabilidade3__c,
            responsabilidade4__c,
            responsabilidade5__c,
            responsabilidade6__c,
            responsabilidade7__c,
            responsabilidade8__c,
            Status__c,
            Tipo_Formacao__c
        FROM Cargo__c
        WHERE Id = '${recordId}'
        `;
        
        console.log("query: ", query)
        
        helper.soql(cmp, query)
        .then(function (result) {
            console.log("Resultado da SOQL:", result);
            if (result.length > 0) {
                var original = result[0];
                
                var fields = {
                   "Name": original.Name + " (Cópia)",              
                "Cargo_Superior__c": original.Cargo_Superior__c,              
                "Data_de_Aprovaco__c": original.Data_de_Aprovaco__c,
                "Departamento__c": original.Departamento__c,
                "Formacao_Necessaria__c": original.Formacao_Necessaria__c,
                "Objetivos__c": original.Objetivos__c,
                "Requisitos_comportamentais__c": original.Requisitos_comportamentais__c,
                "Requisitos_tecnicos__c": original.Requisitos_tecnicos__c,
                "Status__c": original.Status__c,
                "Tipo_Formacao__c": original.Tipo_Formacao__c,
                "responsabilidade1__c": original.responsabilidade1__c,
                "responsabilidade2__c": original.responsabilidade2__c,
                "responsabilidade3__c": original.responsabilidade3__c,
                "responsabilidade4__c": original.responsabilidade4__c,
                "responsabilidade5__c": original.responsabilidade5__c,
                "responsabilidade6__c": original.responsabilidade6__c,
                "responsabilidade7__c": original.responsabilidade7__c,
                "responsabilidade8__c": original.responsabilidade8__c
                };                              
                console.log("passou aqui")
                var createEvent = $A.get("e.force:createRecord");
                createEvent.setParams({
                    "entityApiName": "Cargo__c",
                    "defaultFieldValues": fields
                });
                createEvent.fire();
            } else {
                console.error("Nenhum registro encontrado.");
            }
        })
        .catch(function (error) {
            console.error("Erro ao executar SOQL: " + error);
        });
    }
})