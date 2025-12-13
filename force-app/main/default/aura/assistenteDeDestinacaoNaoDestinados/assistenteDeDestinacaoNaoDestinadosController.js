({
    //FUNÇÃO EXECUTADA APÓS O TÉRMINO DA RENDERIZAÇAO DO COMPONENTE-----------------------------------------------------------
    onRender: function (cmp, event, helper) {

        helper.helperMain(cmp, event, helper);

    },

    abrirModal: function (component, event, helper) {
        component.set("v.mostrarModal", true);
        component.set("v.statusSelecionado", "");
    },

    fecharModal: function (component, event, helper) {
        component.set("v.mostrarModal", false);
        component.set("v.statusSelecionado", "");
    },
    confirmarAlteracao: function (component, event, helper) {
        var statusSelecionado = component.get("v.statusSelecionado");
        console.log("", statusSelecionado);

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
        
        // Chamar a função helper passando o status selecionado
        helper.mudaTodosStatus(component, event, helper, statusSelecionado);

        // Fechar o modal
        component.set("v.mostrarModal", false);
        component.set("v.statusSelecionado", "");
    },

    doInit: function (cmp, event, helper) {
        console.log("carregando")
    }


})