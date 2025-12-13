({
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        cmp.set("v.setMeOnInit", "controller init magic!");
    },
    
    //FUNÇÃO EXECUTADA APÓS O TÉRMINO DA RENDERIZAÇAO DO COMPONENTE-----------------------------------------------------------
    onRender : function(cmp,event, helper){
        
        $(function() {
            $( "#calendario, #calendario2" ).datepicker({
                showButtonPanel:true,
                changeMonth: true,
                changeYear: true,
                dateFormat: 'dd/mm/yy',
                dayNames: ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'],
                dayNamesMin: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
                dayNamesShort: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
                monthNames: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'],
                monthNamesShort: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
                nextText: 'Proximo',
                prevText: 'Anterior'
            });
        });
        
        
        
        helper.mainHelper(cmp, event, helper);
        
    },
    
})