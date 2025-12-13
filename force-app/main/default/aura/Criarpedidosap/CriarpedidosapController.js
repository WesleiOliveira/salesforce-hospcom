({
    handleClick: function(cmp, event, helper) {
        helper.buscarPedidos(cmp);
    },

    // Quando o componente carregar, já checa se está 100% faturado
    doInit: function(cmp, event, helper) {
        helper.verificarFaturamento(cmp);
    }
})