({
  loadList: function(component, event, helper) {
    helper.loadList(component, helper);
  },

  openChecklist: function(component, event, helper) {
    console.log("baaba");
    let modeloId = event.target.getAttribute("data-id");
    console.log("aaabaaaa");
    helper.openChecklist(component, event, helper);
  },

  closePopup: function(component, event, helper) {
    component.set("v.isPopupOpen", false);
  },

  onScriptsLoaded: function(component, event, helper) {
    console.log("SortableJS carregado:", typeof Sortable !== "undefined");

    // Inicializa lista de seções
    component.set("v.secoes", []);

    // Lista de origem (tipos de campos)
    Sortable.create(document.getElementById("sourceList"), {
      group: {
        name: "formFields",
        pull: "clone",
        put: false
      },
      sort: false,
      animation: 150,
      ghostClass: "campo-sombra",
      onStart: function(evt) {
        evt.item.classList.add("campo-ativo");
      },
      onEnd: function(evt) {
        evt.item.classList.remove("campo-ativo");
      }
    });
  },

  atualizarTitulo: function(component, event, helper) {
    helper.setConfirmOnExit(component);
    component.set("v.tituloChecklist", event.target.value);
  },

  atualizarDescricao: function(component, event, helper) {
    helper.setConfirmOnExit(component);
    component.set("v.descricaoChecklist", event.target.value);
  },

  adicionarSecao: function(component, event, helper) {
    helper.setConfirmOnExit(component);
    let secoes = component.get("v.secoes");
    let index = secoes.length;

    // Cria nova seção
    let novaSecao = {
      titulo: "Nova Seção",
      campos: []
    };

    secoes.push(novaSecao);
    component.set("v.secoes", secoes);

    let container = document.getElementById("canvasSecoes");

    let secaoDiv = document.createElement("div");
    secaoDiv.className = "secao223";
    secaoDiv.id = `secaoDiv_${index}`;

    secaoDiv.innerHTML = `
     <div class="secao-cabecalho">
      <input type="text" class="secaoTituloInput" value="Nova Seção"
             data-index="${index}"
             style="font-size: 16px; font-weight: bold; width: 100%; border: none;" />
      <button class="removerSecaoBtn" data-index="${index}" title="Remover seção"><i class="fa fa-trash-o" aria-hidden="true"></i>️</button>
    </div>
    <ul id="targetList_secao_${index}" class="slds-p-around_small slds-border_top"></ul>
  `;

    container.appendChild(secaoDiv);

    // Atualiza título da seção ao digitar
    secaoDiv
      .querySelector(".secaoTituloInput")
      .addEventListener("input", function(e) {
        let secoes = component.get("v.secoes");
        secoes[index].titulo = e.target.value;
        component.set("v.secoes", secoes);
      });

    // Botão remover seção
    secaoDiv
      .querySelector(".removerSecaoBtn")
      .addEventListener("click", function(e) {
        let secoes = component.get("v.secoes");
        secoes.splice(index, 1);
        component.set("v.secoes", secoes);

        // Remove do DOM
        let elemento = document.getElementById(`secaoDiv_${index}`);
        if (elemento) elemento.remove();

        console.log(
          "Seções após remoção:",
          JSON.stringify(component.get("v.secoes"), null, 2)
        );
      });

    // Cria Sortable na nova seção
    Sortable.create(document.getElementById(`targetList_secao_${index}`), {
      group: "formFields",
      animation: 150,
      onAdd: function(evt) {
        // Remove o item "clone" que vem da lista origem
        evt.item.parentNode.removeChild(evt.item);

        let tipoCampo = evt.item.getAttribute("data-tipo");
        let icon = evt.item.getAttribute("data-icon");
        let secoes = component.get("v.secoes");
        let campos = secoes[index].campos;

        let campo = {
          id:
            Date.now() +
            Math.random()
              .toString(36)
              .slice(2), // id único
          tipo: tipoCampo.toLowerCase(),
          label: tipoCampo,
          nome: tipoCampo.toLowerCase().replace(/\s+/g, "_") + "_" + Date.now(),
          obrigatorio: false,
          ajuda: ""
        };

        if (campo.tipo === "select") {
          campo.opcoes = ["Opção 1", "Opção 2"];
        }

        campos.push(campo);
        component.set("v.secoes", secoes); // Atualiza

        let campoIndex = campos.length - 1;

        let novoItem = document.createElement("li");
        novoItem.className = "fieldBox";
        novoItem.setAttribute("data-id", campo.id);

        novoItem.innerHTML = `
  <div>
    <i class="${icon}" aria-hidden="true" style="margin-right: 5px;"></i>
    <input type="text" value="${campo.label}"
           class="campoLabelInput"
           data-index="${campoIndex}"
           style="font-weight: bold; border: none; outline: none; background: transparent; width: 70%;" />
    <label style="margin-left: 10px;">
      <input type="checkbox" class="campoObrigatorioCheckbox" data-index="${campoIndex}" />
      Obrigatório
    </label>
    <button class="removerCampoBtn" data-index="${campoIndex}" style="margin-left: 10px;">
      <i class="fa fa-trash-o" aria-hidden="true"></i>
    </button>
  </div>
`;

        // Listeners para inputs do campo
        novoItem
          .querySelector(".campoLabelInput")
          .addEventListener("input", function(evt) {
            let idx = parseInt(evt.target.getAttribute("data-index"));
            let secoes = component.get("v.secoes");
            secoes[index].campos[idx].label = evt.target.value;
            component.set("v.secoes", secoes);
          });

        novoItem
          .querySelector(".campoObrigatorioCheckbox")
          .addEventListener("change", function(evt) {
            let idx = parseInt(evt.target.getAttribute("data-index"));
            let secoes = component.get("v.secoes");
            secoes[index].campos[idx].obrigatorio = evt.target.checked;
            component.set("v.secoes", secoes);
          });

        novoItem
          .querySelector(".removerCampoBtn")
          .addEventListener("click", function(e) {
            let idx = parseInt(e.target.getAttribute("data-index"));
            novoItem.remove();

            let secoes = component.get("v.secoes");
            secoes[index].campos.splice(idx, 1);
            component.set("v.secoes", secoes);
          });

        // Se for select, adiciona UI para opções
        if (campo.tipo === "select") {
          const opcoesContainer = document.createElement("div");
          opcoesContainer.style.marginTop = "10px";

          const atualizarOpcoesUI = () => {
            opcoesContainer.innerHTML = "";

            campo.opcoes.forEach((opcao, idx) => {
              const div = document.createElement("div");
              div.style.marginBottom = "5px";

              div.innerHTML = `
              <input type="text" value="${opcao}" class="opcaoInput"
                     data-opcao-index="${idx}" style="width: 70%;" />
              <button class="removerOpcaoBtn" data-opcao-index="${idx}" style="margin-left: 5px;"><i class="fa fa-trash-o" aria-hidden="true"></i></button>
            `;

              div
                .querySelector(".opcaoInput")
                .addEventListener("input", function(e) {
                  const i = parseInt(e.target.getAttribute("data-opcao-index"));
                  campo.opcoes[i] = e.target.value;
                  component.set("v.secoes", component.get("v.secoes"));
                });

              div
                .querySelector(".removerOpcaoBtn")
                .addEventListener("click", function(e) {
                  const i = parseInt(e.target.getAttribute("data-opcao-index"));
                  campo.opcoes.splice(i, 1);
                  component.set("v.secoes", component.get("v.secoes"));
                  atualizarOpcoesUI();
                });

              opcoesContainer.appendChild(div);
            });
          };

          const botaoAddOpcao = document.createElement("button");
          botaoAddOpcao.textContent = "Adicionar opção";
          botaoAddOpcao.className =
            "slds-button slds-button_neutral slds-m-top_small";

          botaoAddOpcao.addEventListener("click", function() {
            campo.opcoes.push("Nova opção");
            component.set("v.secoes", component.get("v.secoes"));
            atualizarOpcoesUI();
          });

          atualizarOpcoesUI();
          novoItem.appendChild(opcoesContainer);
          novoItem.appendChild(botaoAddOpcao);
        }

        document
          .getElementById(`targetList_secao_${index}`)
          .appendChild(novoItem);
      },

      onUpdate: function(evt) {
        let secoes = component.get("v.secoes");
        let campos = secoes[index].campos;

        let novosCampos = [];
        const listaDOM = evt.to;
        const itensDOM = listaDOM.querySelectorAll("li");

        itensDOM.forEach(li => {
          const campoId = li.getAttribute("data-id");
          if (!campoId) return;

          const campoExistente = campos.find(c => c.id === campoId);
          if (campoExistente) novosCampos.push(campoExistente);
        });

        secoes[index].campos = novosCampos;
        component.set("v.secoes", secoes);
      }
    });
  },

  exportarJson: function(component, event, helper) {
    const checklist = {
      titulo: component.get("v.tituloChecklist"),
      descricao: component.get("v.descricaoChecklist"),
      secoes: component.get("v.secoes")
    };

    const jsonStr = JSON.stringify(checklist, null, 2);
    const blob = new Blob([jsonStr], { type: "application/json" });
    const url = URL.createObjectURL(blob);

    const link = document.createElement("a");
    link.href = url;
    link.download = "checklist.json";
    link.click();

    URL.revokeObjectURL(url);
  },

  criar: function(component, event, helper) {
    helper.irParaTela1(component, helper);
  },
  voltar: function(component, event, helper) {
    let changesUnsaved = component.get("v.changesUnsaved");

    if (!changesUnsaved) {
      helper.irParaTela0(component);
      return;
    }

    var confirmacao = confirm("Voltar agora excluirá alterações não salvas.");
    if (confirmacao) {
      helper.irParaTela0(component);
    }
  },

  saveChecklist: function(component, event, helper) {
      console.log("Save clicks")
    helper.criaModelo(component, event, helper);
  }
});