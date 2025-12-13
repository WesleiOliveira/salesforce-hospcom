({
    //FUNÇÃO EXECUTADA APÓS O TÉRMINO DA RENDERIZAÇAO DO COMPONENTE-----------------------------------------------------------
    onRender: function (cmp, event, helper) {
        helper.helperMain(cmp, event, helper, false);

    },

    handleToggle: function (cmp, event, helper) {
        var isChecked = cmp.find("btnApenasDestinados").get("v.checked");
        cmp.set("v.apenasDestinados", isChecked);
        helper.preencheTabela(cmp, event, helper, isChecked);
    },

    abrirModal: function (component, event, helper) {
        const produtosSelecionados = component.get("v.produtosSelecionados");
        console.log("Produtos Selecionados: ", produtosSelecionados);
        if (component.get("v.produtosSelecionados") == null || component.get("v.produtosSelecionados").length == 0) {
            // Mostrar mensagem de erro usando toast
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção!",
                "message": "Por favor, selecione um item.",
                "type": "warning"
            });
            toastEvent.fire();
            return
        }
        component.set("v.mostrarModal", true);
        component.set("v.statusSelecionado", "");
    },

    fecharModal: function (component, event, helper) {
        component.set("v.mostrarModal", false);
        component.set("v.statusSelecionado", "");
    },
    confirmarAlteracao: function (component, event, helper) {
        var statusSelecionado = component.get("v.statusSelecionado");
        console.log("Status selecionado", statusSelecionado);


        if (!statusSelecionado || statusSelecionado === "") {
            // Mostrar mensagem de erro usando toast
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção!",
                "message": "Por favor, selecione um status antes de confirmar.",
                "type": "warning"
            });
            toastEvent.fire();
            return;
        }
        console.log("chamando metodo do helper");
        // Chamar a função helper passando o status selecionado
        helper.mudaTodosStatus(component, event, helper, statusSelecionado);

        // Fechar o modal
        component.set("v.mostrarModal", false);
        component.set("v.statusSelecionado", "");
    },

    doInit: function (component, event, helper) {
        const empty = []
        component.set("v.produtosSelecionados", empty);
        console.log("carregando")
        // Adiciona listener global uma única vez
        window.addEventListener('change', $A.getCallback(function (e) {
            if (e.target && e.target.getAttribute('data-action') === 'updateSelection') {
                helper.atualizarProdutosSelecionados(component);
            }
        }));
    },

    marcarTodosOsItens: function (cmp, event, helper) {
        setTimeout(function () {
            var container = document.querySelector('#listaCotacao');

            if (!container) {
                console.error('Container não encontrado');
                return;
            }

            var checkboxes = container.querySelectorAll('.checkboxItem[data-action="updateSelection"]');

            console.log('Checkboxes encontrados:', checkboxes.length);

            if (checkboxes.length === 0) {
                console.warn('Nenhum checkbox encontrado');
                return;
            }

            var todosEstaoMarcados = Array.from(checkboxes).every(function (cb) {
                return cb.checked;
            });

            checkboxes.forEach(function (checkbox) {
                checkbox.checked = !todosEstaoMarcados;

                // IMPORTANTE: Disparar o evento change para atualizar v.produtosSelecionados
                var changeEvent = new Event('change', { bubbles: true });
                checkbox.dispatchEvent(changeEvent);
            });

            console.log('✅ Checkboxes atualizados e evento disparado');

        }, 200);
    }

})