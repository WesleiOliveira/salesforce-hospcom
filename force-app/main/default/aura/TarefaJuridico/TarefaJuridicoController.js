({
  doInit: function(cmp, event, helper) {
    //console.log("===componente juridico===");

    helper
      .inicialize(cmp, event, helper)
      .then(function(taskValida) {
        if (taskValida) {
          //console.log("passou aqui");
          helper.setConfirmOnExit();
          helper.cleanFields(
            cmp,
            event,
            helper,
            cmp.get("v.assuntoSelecionado")
          );
          cmp.set("v.show", true);
          //console.log(cmp.get("v.taskRecord"));
        }
      })
      .catch(function(error) {
        console.error("Erro na inicialização:", error);
      });
  },

  // Trata mudança de valor no subject
  handleSubjectChange: function(cmp, event, helper) {
    let field = event.target.getAttribute("data-field");
    let value = event.target.value;
    let taskRecord = cmp.get("v.taskRecord");
    cmp.set("v.assuntoSelecionado", value);
    const dataMinima = helper.valiDate(cmp, event, helper);
    cmp.set("v.dataMinima", dataMinima);
    helper.cleanFields(cmp, event, helper, value);
  },
  irParaProximaEtapa: function(cmp, event, helper) {
    let isOk = helper.checkFields(cmp, event, helper);

    //console.log("is ok?: ", isOk);
    //console.log(cmp.get("v.assuntoSelecionado"));
    if (isOk) {
      cmp.set("v.etapaAtual", 2);
    } else {
      helper.alerta(
        cmp,
        event,
        helper,
        "",
        "Preencha todos os campos para continuar",
        "error",
        "",
        "error"
      );
    }
  },

  voltarEtapaAnterior: function(cmp, event, helper) {
    cmp.set("v.etapaAtual", 1);
  },

  // Trata mudança de valor nos campos
  handleChange: function(cmp, event, helper) {
    //console.log("handleChange() start");
    let field = event.target.getAttribute("data-field");

    let value = event.target.value;
    let taskRecord = cmp.get("v.taskRecord");
    taskRecord[field] = value;
    cmp.set("v.taskRecord", taskRecord);
    //console.log("novo valor: ", value, " para: ", field);
    //console.log("handleChange() end");

     // Oculta a mensagem de erro relacionada ao campo (se existir)
    let errorDiv = document.getElementById("error-" + field);
    if (errorDiv) {
      errorDiv.style.display = "none";
    }
  },

  handleFileUploaded: function(cmp, event, helper) {
    //console.log("arquivo enviado!");

    let sourceComponent = event.getSource();

    // Quem disparou o evento
    let fileName = sourceComponent.getLocalId();

    //console.log("1");
    let uploadedFiles = event.getParam("files");
    //console.log("2");
    uploadedFiles.forEach(file => {
      let documentId = file.documentId;

      //console.log("Arquivo enviado por:", fileName);
      //console.log("documentId:", documentId);

      // Chama o Apex passando os dois dados
      helper.renameFileByAuraId(cmp, fileName, documentId);
      // Oculta mensagem de erro caso exista
      let errorDiv = document.getElementById("error-" + fileName);
      if (errorDiv) {
        errorDiv.style.display = "none";
      }
    });
  },

  save: function(cmp, event, helper) {
    helper.save(cmp, event, helper);
  }
  /*
    deleteFile: function(cmp, event, helper) {
      var action = cmp.get("c.deleteFile");
      var recordId = cmp.get("v.recordId");
      var fileName = "ComprovanteDeRecebimento";
  
      action.setParams({
        recordId: '00TU400000PX74lMAD',
        fileName: 'ComprovanteDeRecebimento'
      });
  
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          $A.get("e.force:showToast")
            .setParams({
              title: "Sucesso",
              message: "Arquivo deletado com sucesso.",
              type: "success"
            })
            .fire();
        } else {
          let errors = response.getError();
          let message =
            errors && errors[0] && errors[0].message
              ? errors[0].message
              : "Erro desconhecido";
          $A.get("e.force:showToast")
            .setParams({
              title: "Erro",
              message: message,
              type: "error"
            })
            .fire();
          console.error("Erro ao deletar arquivo:", message);
        }
      });
  
      $A.enqueueAction(action);
    }
    */
});