({
    helperMethod: function(component, event, helper) {
      //console.log("Início");
  
      var recordId = component.get("v.recordId");
      //console.log("Record ID:", recordId);
  
      var query =
        "SELECT Id, Name, Assunto__c, TaskId__c, Status__c " +
        "FROM Pendencia__c " +
        "WHERE TaskId__c = '" +
        recordId +
        "' AND Status__c != 'Fechado'";
      //console.log("SOQL Query:", query);
  
      helper
        .soql(component, query)
        .then(function(pen) {
          if (pen && pen.length > 0) {
            var pendenciasArray = []; // Criando um array para armazenar os registros
  
            pen.forEach(function(item) {
              // Percorrendo cada item retornado
              pendenciasArray.push({
                Id: item.Id, // Inclui o Id para identificar o item
                pName: item.Name,
                pAssunto: item.Assunto__c
              });
  
              //console.log("Nome da Pendência:", item.Name);
              //console.log("Assunto da Pendência:", item.Assunto__c);
            });
  
            // ✅ **Define corretamente o array no componente**
            component.set("v.pendencias", pendenciasArray);
            //console.log(
              //"Lista de Pendências Salva:",
             // component.get("v.pendencias"));
          } else {
            console.warn("Nenhuma pendência encontrada para esse TaskId__c.");
          }
        })
        .catch(function(error) {
          console.error("Erro na consulta SOQL:", error);
        });
    },
  
    handlePendenciaClick: function(component, event, helper) {
      var pendenciaId = event.currentTarget.dataset.id;
      //console.log("Pendência clicada:", pendenciaId);
      var url = "https://hospcom.my.site.com/Sales/s/pendencia/" + pendenciaId;
      window.open(url, "_blank");
    },
    handleNewClick: function(component, event, helper) {
      //console.log("new click");
  
      var recordId = component.get("v.recordId");
  
      var createRecordEvent = $A.get("e.force:createRecord");
  
      createRecordEvent.setParams({
        entityApiName: "Pendencia__c",
        defaultFieldValues: {
          TaskId__c: recordId
        }
      });
      createRecordEvent.fire();
    }
  });