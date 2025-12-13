({
  checklists: [],
  /*
  adicionarCampoNaSecao: function(component, evt, secaoIndex) {
    const tipoCampo = evt.item.innerText.trim();
    evt.item.parentNode.removeChild(evt.item); // remove o item original adicionado automaticamente

    // Cria o objeto do novo campo
    let campo = {
      tipo: tipoCampo.toLowerCase(),
      label: tipoCampo,
      nome: tipoCampo.toLowerCase().replace(/\s+/g, "_") + "_" + Date.now(),
      obrigatorio: false,
      ajuda: ""
    };

    // Adiciona o campo na variável de seções
    let secoes = component.get("v.secoes");
    secoes[secaoIndex].campos.push(campo);
    component.set("v.secoes", secoes);

    const indexCampo = secoes[secaoIndex].campos.length - 1;

    // Cria visual do campo
    const novoItem = document.createElement("li");
    novoItem.className =
      "slds-box slds-m-around_xx-small slds-theme_alert-texture";
    novoItem.innerHTML = `
      <div class="slds-grid slds-grid_align-spread">
        <input type="text" value="${campo.label}" 
               class="campoLabelInput"
               data-secao="${secaoIndex}" data-index="${indexCampo}"
               style="font-weight: bold; border: none; outline: none; background: transparent; width: 70%;" />
        <div class="slds-form-element">
          <label class="slds-checkbox slds-m-left_small">
            <input type="checkbox" class="campoObrigatorioCheckbox" data-secao="${secaoIndex}" data-index="${indexCampo}" />
            <span class="slds-checkbox_faux"></span>
            <span class="slds-form-element__label">Obrigatório</span>
          </label>
        </div>
        <button class="slds-button slds-button_icon slds-button_icon-border removerCampoBtn"
                title="Remover campo" data-secao="${secaoIndex}" data-index="${indexCampo}">
          ✖
        </button>
      </div>
    `;

    // Eventos: editar label
    novoItem
      .querySelector(".campoLabelInput")
      .addEventListener("input", function(e) {
        const sIdx = e.target.getAttribute("data-secao");
        const cIdx = e.target.getAttribute("data-index");
        let secoes = component.get("v.secoes");
        secoes[sIdx].campos[cIdx].label = e.target.value;
        component.set("v.secoes", secoes);
      });

    // Eventos: checkbox obrigatório
    novoItem
      .querySelector(".campoObrigatorioCheckbox")
      .addEventListener("change", function(e) {
        const sIdx = e.target.getAttribute("data-secao");
        const cIdx = e.target.getAttribute("data-index");
        let secoes = component.get("v.secoes");
        secoes[sIdx].campos[cIdx].obrigatorio = e.target.checked;
        component.set("v.secoes", secoes);
      });

    // Evento: remover campo
    novoItem
      .querySelector(".removerCampoBtn")
      .addEventListener("click", function(e) {
        const sIdx = e.target.getAttribute("data-secao");
        const cIdx = e.target.getAttribute("data-index");

        // Remove visualmente
        novoItem.remove();

        // Remove da variável
        let secoes = component.get("v.secoes");
        secoes[sIdx].campos.splice(cIdx, 1);
        component.set("v.secoes", secoes);
      });

    // Adiciona no DOM da seção
    document.getElementById(`secao-${secaoIndex}`).appendChild(novoItem);
  },   
    */

  irParaTela0: function(component) {
    component.set("v.fase", 0);
    $("#btn-salvar").css("display", "none");
    $("#voltar-btn542").css("display", "none");
    $("#voltarToppo5432").css("display", "none");
    $("#criar-btn342").css("display", "flex");
  },

  irParaTela1: function(component, helper) {
    window.onbeforeunload = null;
    component.set("v.fase", 1);
    $("#voltar-btn542").css("display", "flex");
    $("#voltarToppo5432").css("display", "flex");
    $("#criar-btn342").css("display", "none");
  },

  //ATIVA TRAVA
  setConfirmOnExit: function(cmp) {
    $("#btn-salvar").css("display", "flex");
    cmp.set("v.changesUnsaved", true);
    console.log("setConfirmOnExit");
    window.onbeforeunload = function(event) {
      event.returnValue = "Sair agora descartará alterações não salvas";
      return "Sair agora descartará alterações não salvas";
    };
  },
  //DESATIVA TRAVA
  removeConfirmOnExit: function(cmp, helper) {
    $("#btn-salvar").css("display", "none");
    cmp.set("v.changesUnsaved", false);
    window.onbeforeunload = null;
             cmp.set("v.isLoading", false);
            helper.loadList(cmp, helper);
         

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

  //CARREGA LISTA DE MODELOS DE CHECKLISTS CRIADOS-----------------
  loadList: function(cmp, helper) {
    cmp.set("v.isLoading", false);

    console.log("===loadList() Iniciado===");
    var query =
      "SELECT id, name, JSON_do_checklist__c from Checklist_Modelo__c";
    console.log("query: ", query);

    helper
      .soql(cmp, query)
      .then(function(checklists) {
        console.log("Modelos: ", checklists);
        cmp.set("v.checklists", checklists);
        helper.checklists = checklists;
      })
      .catch(function(error) {
        console.error(error);
      })
      .finally(() => {
           helper.irParaTela0(cmp);
        cmp.set("v.isLoading", false);
        $("#criar-btn342").css("display", "flex");
      });
  },

openChecklist: function(cmp, event, helper) {
    console.log("===openChecklist() Iniciado===");

    const checklistId = event.currentTarget.getAttribute("data-id");
    console.log("checklistId: ", checklistId);

    const checklists = cmp.get("v.checklists");
    const selected = checklists.find(c => c.Id === checklistId);

    if (selected) {
        try {
            const jsonChecklist = selected.JSON_do_checklist__c;
            const parsed = JSON.parse(jsonChecklist);

            cmp.set("v.checklist", parsed);
            cmp.set("v.selectedChecklist", selected);
            cmp.set("v.isPopupOpen", true);

            console.log("Checklist carregado e popup aberto:", parsed);

        } catch (e) {
            console.error("Erro ao fazer parse do JSON: ", e);
            alert("Erro ao abrir o checklist. Verifique se o JSON está bem formatado.");
        }
    } else {
        console.error("Checklist não encontrado.");
    }
},

  criaModelo: function(component, event, helper) {
      component.set("v.isLoading", true);
    const checklist = {
      titulo: component.get("v.tituloChecklist"),
      descricao: component.get("v.descricaoChecklist"),
      secoes: component.get("v.secoes")
    };

    const jsonStr = JSON.stringify(checklist, null, 2);
    const titulo = checklist.titulo || "Checklist sem título";

    helper.salvarChecklistModelo(component, helper, titulo, jsonStr);
  },
  salvarChecklistModelo: function(component, helper, titulo, jsonStr) {
       
    const action = component.get("c.salvarChecklistModelo");
    action.setParams({
      nome: titulo,
      jsonStr: jsonStr
    });

    action.setCallback(this, function(response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        $A.get("e.force:showToast")
          .setParams({
            title: "Sucesso",
            message: "Checklist modelo salvo com sucesso!",
            type: "success"
          })
          .fire();
        helper.removeConfirmOnExit(component, helper);
      } else {
        console.error("Erro ao salvar:", response.getError());
        $A.get("e.force:showToast")
          .setParams({
            title: "Erro",
            message: "Erro ao salvar o checklist.",
            type: "error"
          })
          .fire();
      }
    });

    $A.enqueueAction(action);
  }
});