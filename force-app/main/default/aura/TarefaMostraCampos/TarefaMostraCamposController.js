({
  doInit: function(cmp, event, helper) {
    //console.log("=========Mostrar==Campos=============");

    let recordId = cmp.get("v.recordId");
   // console.log("RecordId:", recordId);

    let query = `SELECT Id, Subject, AssuntoJuridco__c, JuridicoSalvo__c FROM Task WHERE Id = '${recordId}'`;

    helper
      .soql(cmp, query)
      .then(function(result) {
          
        if (result && result.length > 0) {
          let task = result[0];
          console.log("Task encontrada:", task);

          let subject = task.Subject;
          let juridicoSalvo = task.JuridicoSalvo__c;

          if (subject === "Departamento Juridico" && juridicoSalvo === true) {            
            
              helper.initialize(cmp, event, helper, subject);
              
              
            cmp.set("v.show", true);
              
          } else {
           console.log("Condição não atendida.");
          }
        } else {
          console.warn("Nenhuma task encontrada.");
        }
      })
      .catch(function(error) {
        console.error("Erro ao buscar Task:", error);
        return false;
      });
  },

    openEditModal: function(cmp, event, helper) {
        console.log("botao clicado")
        cmp.set("v.showEditModal", true);
        cmp.set("v.selectedAssunto", cmp.get("v.assunto"));
    },

    closeEditModal: function(cmp, event, helper) {
        cmp.set("v.showEditModal", false);
    },

    saveAssunto: function(cmp, event, helper) {
        var novoAssunto = cmp.get("v.selectedAssunto");
        var recordId = cmp.get("v.recordId");

        var action = cmp.get("c.atualizarAssunto");
        action.setParams({
            taskId: recordId,
            novoAssunto: novoAssunto
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.assunto", novoAssunto);
                cmp.set("v.showEditModal", false);
                helper.carregaCampos(cmp, event, helper, novoAssunto);
                console.log("Sucesso ao salvar o assunto: ", novoAssunto)
            } else {
                console.error("Erro ao atualizar assunto:", response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    
    handleChange: function(cmp, event, helper) {
        var selectedValue = event.target.value;
        cmp.set("v.selectedAssunto", selectedValue);
    }
});