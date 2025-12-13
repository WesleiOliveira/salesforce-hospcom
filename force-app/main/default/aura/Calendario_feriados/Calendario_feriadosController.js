({
    doInit: function(component, event, helper) {
        // Após carregar os scripts, buscar os feriados e renderizar o calendário
        helper.buscarFeriados(component);
    }
    ,
    criarFeriadoC: function(component, event, helper) {
        // Após carregar os scripts, buscar os feriados e renderizar o calendário
        helper.criarFeriado(component);
    }
    , 
    closeModal:function (component, event, helper){
    
    helper.closeModal(component);
	}
 
 })