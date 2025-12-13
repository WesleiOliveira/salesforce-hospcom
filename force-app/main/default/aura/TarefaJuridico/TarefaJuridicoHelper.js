({
  recordId: "",

  inicialize: function(cmp, event, helper) {
    //console.log("Iniciando helper");

    let recordId = cmp.get("v.recordId");
    helper.recordId = recordId;
    //console.log("RecordId: ", recordId);

    let query = `SELECT Id, Subject, Status, JuridicoSalvo__c FROM Task WHERE Id = '${recordId}'`;

    // Retornar a promise para que o controller possa usar `.then(...)`
    return helper
      .soql(cmp, query)
      .then(function(result) {
        let taskFound = result && result.length > 0;
        //console.log("Resultado da query: ", result);

        if (taskFound) {
          let task = result[0];
          let isValid =
            task.Status === "Não iniciado" &&	
            task.Subject === "Departamento Juridico" &&
            task.JuridicoSalvo__c === false;

          //console.log("Task é válida? ", isValid);

          return isValid;
        }

        return false;
      })
      .catch(function(error) {
        console.error("Erro ao buscar Task:", error);
        return false;
      });
  },

  //ATIVA TRAVA
  setConfirmOnExit: function() {
    //console.log("setConfirmOnExit");
    window.onbeforeunload = function(event) {
      event.returnValue = "Se sair agora sua tarefa será cancelada"; // Chrome
      return "Se sair agora sua tarefa será cancelada"; // Outros navegadores
    };
  },

  //DESATIVA TRAVA
  removeConfirmOnExit: function() {
    window.onbeforeunload = null;
  },
  //FUNÇÃO QUE EXIBE ALERTAS AO USUÁRIO-------------------------------------------------------------
  alerta: function(cmp, event, helper, error, title, type, tipoMensagem, mode) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: tipoMensagem + " " + error,
      type: type,
      mode: mode
    });
    toastEvent.fire();
  },

  //FUNÇÃO QUE EXIBE O SPINNER DE CARREGAMENTO-
  showSpinner: function(cmp) {
    cmp.set("v.isLoading", true);
  },
  //-------------------------------------------

  //FUNÇÃO QUE OCULTA O SPINNER DE CARREGAMENTO-
  hideSpinner: function(cmp, event, helper) {
    cmp.set("v.isLoading", false);
  },
  //--------------------------------------------

  //SALVA VALORES NA TAREFA
  save: function(cmp, event, helper) {
    cmp.set("v.isLoading", true);
    cmp.set("v.taskRecord.JuridicoSalvo__c", true);

    //console.log("save Function started");
    let taskRecord = cmp.get("v.taskRecord");
    //console.log(
    //"Objeto com campos: ",
    // taskRecord + "\ntaskId: ",
    //helper.recordId);


    let rawDate = taskRecord.Qual_a_data_de_recebimento_do_primei__c;
  if (rawDate && typeof rawDate === "string") {
    const dateParts = rawDate.split("-");
    if (dateParts.length === 3) {
      const year = parseInt(dateParts[0], 10);
      const month = parseInt(dateParts[1], 10) - 1;
      const day = parseInt(dateParts[2], 10);

      const validDate = new Date(year, month, day);
      if (!isNaN(validDate.getTime()) && validDate.getFullYear() < 2100) {
        taskRecord.Qual_a_data_de_recebimento_do_primei__c = validDate
          .toISOString()
          .substring(0, 10);
      } else {
        console.error("Data inválida detectada:", rawDate);
        helper.alerta(
          cmp,
          event,
          helper,
          "Data inválida no campo de recebimento.",
          "Erro",
          "error",
          "Erro:",
          "sticky"
        );
        cmp.set("v.isLoading", false);
        return; // Para evitar envio com erro
      }
    }
  }


    let action = cmp.get("c.updateTask");
    action.setParams({
      recordId: helper.recordId,
      fieldsValue: taskRecord
    });

    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        helper.alerta(
          cmp,
          event,
          helper,
          "Registro Salvo",
          "Sucesso",
          "success",
          "success",
          "success"
        );
        //console.log("Task atualizada com sucesso.");
        cmp.set("v.show", false);
        helper.removeConfirmOnExit();
        window.location.reload();
      } else {
        console.error("Erro ao atualizar:", response.getError());
        helper.alerta(
          cmp,
          event,
          helper,
          "Escolha um dia util",
          "Erro",
          "error",
          "Erro:",
          "error"
        );
        cmp.set("v.taskRecord.JuridicoSalvo__c", false);
      }
    });

    $A.enqueueAction(action);

    //console.log("save Function worked yeeei");
  },

  //Conjunto de funções para retornar a data minima de vencimento para cada assunto se o assunto tiver uma.
  //validate + Date = valiDate Bhaaaaaaaa Hilario
  valiDate: function(cmp, event, helper) {
    //console.log("valiDate() start");

    const hoje = new Date();
    const subject = cmp.get("v.assuntoSelecionado");
    let diasUteisMinimos = 1;

    // Define a quantidade mínima de dias úteis com base no assunto
    if (
      subject === "Análise de aditivo" ||
      subject === "Confecção de contrato" ||
      subject === "Enviar carta" ||
      subject === "Esclarecimento" ||
      subject === "Impugnação" ||
      subject === "Revisão de contrato" ||
      subject === "Termo de acordo" ||
      subject === "NDA" ||
      subject === "Admissão PJ" ||
      subject === "Desligamento PJ" ||
      subject === "Alteração Contratual PJ" ||
      subject === "Alteração de CNPJ"
    ) {
      diasUteisMinimos = 2;
    }

    if (
      subject === "Contrarrazões" ||
      subject === "Notificação extrajudicial" ||
      subject === "Prorrogação de entrega" ||
      subject === "Reconsideração" ||
      subject === "Recurso" ||
      subject === "Resposta a notificação"
    ) {
      diasUteisMinimos = 3;
    }

    if (
      subject === "Defesa de processo administrativo" ||
      subject === "Denúncia" ||
      subject === "Documentação estratégica"
    ) {
      diasUteisMinimos = 5;
    }

    if (
      subject === "Processo judicial" ||
        subject === "Defesa processo judicial"
    ) {
        diasUteisMinimos = 7;
    }
      
      
      //Há uma regra sobre a contagem de dias uteis
      // O calculo do prazo de vencimento nao pode ser feito contando com o dia de abertura, 
      // Então fiz essa fiz um acressimo na contegem como forma de compensar o dia de abertura.
      // Porem, essa regra nao se aplica para os assuntos abaixo.
      if (subject != 'Recurso' && subject != 'Contrarrazões' && subject != 'Impugnação' && subject != 'Esclarecimento' ){
          //acressimo         
         diasUteisMinimos = diasUteisMinimos + 1;
         }
         // Calcula a data mínima
         const dataMinima = helper.somarDiasUteis(hoje, diasUteisMinimos);
      
      // Converte para o formato YYYY-MM-DD (necessário para input[type="date"])
      const yyyy = dataMinima.getFullYear();
      const mm = String(dataMinima.getMonth() + 1).padStart(2, "0");
    const dd = String(dataMinima.getDate()).padStart(2, "0");
    const dataFormatada = `${yyyy}-${mm}-${dd}`;

    return dataFormatada;
  },

  // Função auxiliar para somar dias úteis
  somarDiasUteis: function(dataInicial, diasUteis) {
    const resultado = new Date(dataInicial);
    let adicionados = 0;

    while (adicionados < diasUteis) {
      resultado.setDate(resultado.getDate() + 1);
      const diaSemana = resultado.getDay();
      if (diaSemana !== 0 && diaSemana !== 6) {
        adicionados++;
      }
    }
    //console.log("dataMinima: ", resultado);
    return resultado;
  },

checkFields: function (cmp, event, helper) {
  let isValid = true;
  let subject = cmp.get("v.assuntoSelecionado");
  let taskRecord = cmp.get("v.taskRecord");
  let files = cmp.get("v.files") || [];

  // Função auxiliar para mostrar ou ocultar erro
  function toggleError(fieldName, show) {
    let errorEl = document.getElementById("error-" + fieldName);
    if (errorEl) {
      errorEl.style.display = show ? "block" : "none";
    }
  }

  // Limpa todos os erros antes de checar
  const fieldNames = [
    "Qual_a_data_de_recebimento_do_primei__c",
    "Qual_a_data_prevista_para_a_resol__c",
    "Qual_o_motivo_do_envio_da_ocorr_nc__c",
    "Inclua_as_demais_informa_es_necess__c",
    "Acontecer_alguma_troca_de_modelo_ou__c"
  ];

  fieldNames.forEach(f => toggleError(f, false));

  if (
    subject === "Defesa de processo administrativo" ||
    subject === "Prorrogação de entrega" ||
    subject === "Defesa processo judicial" ||
    subject === "Resposta a notificação"
  ) {
    fieldNames.forEach(field => {
      if ($A.util.isEmpty(taskRecord[field])) {
        toggleError(field, true);
        isValid = false;
      }
    });

    if (!files.includes("ComprovanteDeRecebimento")) {
      // Mensagem de erro do comprovante
      let errorFileEl = document.getElementById("error-ComprovanteDeRecebimento");
      if (errorFileEl) {
        errorFileEl.style.display = "block";
      }
      isValid = false;
    } else {
      let errorFileEl = document.getElementById("error-ComprovanteDeRecebimento");
      if (errorFileEl) {
        errorFileEl.style.display = "none";
      }
    }
  }

  return isValid;
},

  //limpa campos - usado quando o assunto muda de valor
  cleanFields: function(cmp, event, helper, subjectValue) {
    cmp.set("v.taskRecord", {
      JuridicoSalvo__c: "",
      ActivityDate: "",
      AssuntoJuridco__c: subjectValue
    });

    if (
      subjectValue === "Defesa de processo administrativo" ||
      subjectValue === "Prorrogação de entrega" ||
      subjectValue === "Defesa processo judicial" ||
      subjectValue === "Resposta a notificação"
    ) {
      cmp.set("v.taskRecord", {
        Qual_a_data_de_recebimento_do_primei__c: "",
        Qual_a_data_prevista_para_a_resol__c: "",
        Qual_o_motivo_do_envio_da_ocorr_nc__c: "",
        Inclua_as_demais_informa_es_necess__c: "",
        Acontecer_alguma_troca_de_modelo_ou__c: "",
        ActivityDate: "",
        AssuntoJuridco__c: subjectValue
      });
    }
    //console.log("Assunto: ", subjectValue);
  },

  renameFileByAuraId: function(cmp, fileName, documentId) {
    //console.log("3");
    let action = cmp.get("c.renameFile");

    action.setParams({
      auraId: fileName,
      contentDocumentId: documentId
    });

    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        //console.log("Arquivo renomeado com sucesso.");
        cmp.set("v.comprovanteRecebimentoUploaded", true);
        let files = cmp.get("v.files") || [];
        files.push(fileName);
        cmp.set("v.files", files);
      } else {
        console.error("Erro ao renomear arquivo:", response.getError());
      }
    });

    $A.enqueueAction(action);
  }
});