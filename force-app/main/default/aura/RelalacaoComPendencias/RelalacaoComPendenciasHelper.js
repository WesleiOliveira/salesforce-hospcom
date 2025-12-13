({
  helperMethod: function(cmp, event, helper) {
    let recordId = cmp.get("v.recordId");
    console.log("recordId: ", recordId);

    let query = `SELECT Id, TaskId__c FROM Pendencia__c WHERE Id = '${recordId}'`;
    console.log("query: ", query);

    helper
      .soql(cmp, query)
      .then(function(result) {
        console.log("passou aqui");
        if (result && result.length > 0 && result[0].TaskId__c) {
          console.log("TaskId: ", result[0].TaskId__c);
          let taskId = result[0].TaskId__c;
          cmp.set("v.taskId", taskId)
          console.log("taskId salvo no helper:", taskId);
          helper.localizaTask(cmp, event, helper, taskId);
        } else {
          console.warn("Nenhum TaskId__c encontrado.");
        }
      })
      .catch(function(error) {
        console.error("Erro ao buscar TaskId:", error);
      });
  },

  localizaTask: function(cmp, event, helper, taskId) {
    let query = `SELECT Id, Subject, ActivityDate FROM Task WHERE Id = '${taskId}'`;
    console.log(query);
    helper
      .soql(cmp, query)
    .then(function(result) {
        if (result[0].Id) {
            console.log(result[0].Subject)
            console.log(result[0].ActivityDate)
            console.log(result[0].Id)

            cmp.set("v.show", true);
            $('#subjectDiv34').text(result[0].Subject);
            $('#activityDateDiv34').text(result[0].ActivityDate);
           
            
        }
    })
    .catch(function(error) {
        console.error("Erro ao buscar Task:", error);
    });
  }
});