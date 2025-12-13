({
    dataInicio : '',
    dataFinal : '',
    tarefas:[],
    
    helperMethod : function(cmp, event, helper) {
        console.log("HELPER METHOD")
        
        var dataAtual = new Date();
        var mesAtual = dataAtual.getFullYear() + '-' + ('0' + (dataAtual.getMonth() + 1)).slice(-2);
        $('#mes').val(mesAtual);
        
        // Extrair o ano, mês e dia da data atual
        var ano = dataAtual.getFullYear();
        var mes = ('0' + (dataAtual.getMonth() + 1)).slice(-2); // Adiciona um zero à esquerda se o mês tiver apenas um dígito
        var dia = '01'
        
        // Criar a string no formato desejado (YYYY-MM-DD)
        var dataFormatada = ano + '-' + mes + '-' + dia;
        helper.dataInicio = dataFormatada
        
        // Obtém o último dia do mês
        var ultimoDiaMes = new Date(dataAtual.getFullYear(), dataAtual.getMonth() + 1, 0);
        var dataFinalMes = ultimoDiaMes.toISOString().slice(0, 10);
        helper.dataFinal = dataFinalMes
        
        helper.consultaMetas(cmp, event, helper)
        
        $('#mes').on('change', function() {
            console.log("CHANGE")
            
            var dataSelecionada = $(this).val()
            var ultimoDiaMes = new Date(dataAtual.getFullYear(), dataAtual.getMonth() + 1, 0).getDate();
            var dataFinalMes = dataSelecionada + "-" + ultimoDiaMes
            console.log("Data final do mês: " + dataFinalMes);
            
            console.log("DATA FINAL", dataFinalMes)
            helper.dataFinal = dataFinalMes
            helper.dataInicio = $(this).val() + '-01'
            helper.consultaMetas(cmp, event, helper)
        });
    },
    
    consultaMetas : function(cmp, event, helper){
        console.log("consulta metas")
        //CONSULTA AS VARIAÇÕES DO USUARIO
        var query = "select id, Subject, Data_da_Conclusao__c, Status_do_gestor__c, ID_do_Gestor__c, OwnerId, Owner.Name from task where meta__c = true AND Data_da_Conclusao__c > "+helper.dataInicio+" AND Data_da_Conclusao__c < "+helper.dataFinal+""
        console.log("query", query)
        //REALIZA A CONSULTA
        this.soql(cmp, query)
        
        //QUANDO A SOLICITAÇÃO FOR CONCLUÍDA, FAÇA:
        .then(function (tarefas) {
            helper.tarefas = tarefas
            helper.preencheColaboradores(cmp, event, helper)
            console.log(tarefas)
        });
    },
    
    preencheColaboradores:function(cmp, event, helper){
        
        $("#inputColaboradoresMetaResumo").empty().append('<option value="default" selected="true" disabled="true">Escolha o colaborador</option>')
        
        helper.tarefas.forEach(function(tarefaAtual) {
            var optionExists = false;
            $("#inputColaboradoresMetaResumo option").each(function() {
                if ($(this).val() === tarefaAtual.OwnerId) {
                    optionExists = true;
                    return false; // Sai do loop assim que encontrar uma correspondência
                }
            });
            
            if (!optionExists) {
                var html = "<option value='" + tarefaAtual.OwnerId + "'>" + tarefaAtual.Owner.Name + "</option>";
                $("#inputColaboradoresMetaResumo").append(html);
            }
        });
        
        helper.eventsAfterPreencheColabs(cmp, event, helper)
    },
    
    eventsAfterPreencheColabs:function(cmp, event, helper){
        $('#inputColaboradoresMetaResumo').on('change', function() {
            console.log("CHANGE");
            
            // Obter o valor selecionado
            var valorSelecionado = $(this).val();
            
            // Filtrar o array pelo OwnerId
            var resultadoFiltrado = helper.tarefas.filter(function(item) {
                return item.OwnerId === valorSelecionado;
            });
            
            console.log("Valor selecionado:", valorSelecionado);
            console.log("Resultado filtrado:", resultadoFiltrado);
            
            
            
        });
    }
})