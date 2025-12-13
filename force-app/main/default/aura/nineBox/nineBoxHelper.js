({
    fetchDataAndRenderChart: function(component) {
        var action = component.get("c.executeSoql");

        // Altere a consulta SOQL para o seu objeto e campos
        var soqlQuery = "SELECT Nome_do_colaborador__c, Nota_Metas__c, Nota_Competencia__c FROM SeuObjeto__c";

        action.setParams({ soql: soqlQuery });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                // Verifique se os dados foram retornados corretamente
                console.log(data);

                var labels = data.map(record => record.Nome_do_colaborador__c);
                var metas = data.map(record => record.Nota_Metas__c);
                var competencias = data.map(record => record.Nota_Competencia__c);

                this.renderChart(labels, metas, competencias); // Chama a função para renderizar
            } else {
                console.error("Erro ao buscar dados: ", response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },

    renderChart: function(labels, metas, competencias) {
        const ctx = document.getElementById("myChart").getContext("2d");

        // Criação do gráfico
        new Chart(ctx, {
            type: 'bar', // Tipo de gráfico
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Nota Metas',
                        data: metas,
                        backgroundColor: 'rgba(255, 99, 132, 0.2)',
                        borderColor: 'rgba(255, 99, 132, 1)',
                        borderWidth: 1
                    },
                    {
                        label: 'Nota Competência',
                        data: competencias,
                        backgroundColor: 'rgba(54, 162, 235, 0.2)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true // Inicia em zero
                    }
                }
            }
        });
    }
})